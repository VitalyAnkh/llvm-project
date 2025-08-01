import os, json, struct, signal

from typing import Any, Dict

import lldb
from lldb.plugins.scripted_process import ScriptedProcess
from lldb.plugins.scripted_process import ScriptedThread


class StackCoreScriptedProcess(ScriptedProcess):
    def get_module_with_name(self, target, name):
        for module in target.modules:
            if name in module.GetFileSpec().GetFilename():
                return module
        return None

    def __init__(self, exe_ctx: lldb.SBExecutionContext, args: lldb.SBStructuredData):
        super().__init__(exe_ctx, args)

        self.corefile_target = None
        self.corefile_process = None

        self.backing_target_idx = args.GetValueForKey("backing_target_idx")
        if self.backing_target_idx and self.backing_target_idx.IsValid():
            if self.backing_target_idx.GetType() == lldb.eStructuredDataTypeInteger:
                idx = self.backing_target_idx.GetIntegerValue(42)
            if self.backing_target_idx.GetType() == lldb.eStructuredDataTypeString:
                idx = int(self.backing_target_idx.GetStringValue(100))
            self.corefile_target = self.target.GetDebugger().GetTargetAtIndex(idx)
            self.corefile_process = self.corefile_target.GetProcess()
            for corefile_thread in self.corefile_process:
                structured_data = lldb.SBStructuredData()
                structured_data.SetFromJSON(
                    json.dumps(
                        {
                            "backing_target_idx": idx,
                            "thread_idx": corefile_thread.GetIndexID(),
                        }
                    )
                )

                self.threads[corefile_thread.GetThreadID()] = StackCoreScriptedThread(
                    self, structured_data
                )

        if len(self.threads) == 2:
            self.threads[len(self.threads) - 1].is_stopped = True

        custom_modules = args.GetValueForKey("custom_modules")
        if custom_modules.GetType() == lldb.eStructuredDataTypeArray:
            for id in range(custom_modules.GetSize()):

                custom_module = custom_modules.GetItemAtIndex(id)
                if (
                    not custom_module
                    or not custom_module.IsValid()
                    or not custom_module.GetType() == lldb.eStructuredDataTypeDictionary
                ):
                    continue

                # Get custom module path from args
                module_path_arg = custom_module.GetValueForKey("path")
                module_path = None
                if (
                    not module_path_arg
                    or not module_path_arg.IsValid()
                    or not module_path_arg.GetType() == lldb.eStructuredDataTypeString
                ):
                    continue

                module_path = module_path_arg.GetStringValue(100)

                # Get custom module load address from args
                module_load_addr = None
                module_load_addr_arg = custom_module.GetValueForKey("load_addr")
                if (
                    module_load_addr_arg
                    and module_load_addr_arg.IsValid()
                    and module_load_addr_arg.GetType()
                    == lldb.eStructuredDataTypeInteger
                ):
                    module_load_addr = module_load_addr_arg.GetIntegerValue()

                # If module load address is not specified/valid, try to find it from corefile module
                if module_load_addr is None:
                    module_name = os.path.basename(module_path)
                    corefile_module = self.get_module_with_name(
                        self.corefile_target, module_name
                    )

                    if not corefile_module or not corefile_module.IsValid():
                        continue

                    module_load_addr = (
                        corefile_module.GetObjectFileHeaderAddress().GetLoadAddress(
                            self.corefile_target
                        )
                    )

                self.loaded_images.append(
                    {
                        "path": module_path,
                        "load_addr": module_load_addr,
                    }
                )

    def get_memory_region_containing_address(
        self, addr: int
    ) -> lldb.SBMemoryRegionInfo:
        mem_region = lldb.SBMemoryRegionInfo()
        error = self.corefile_process.GetMemoryRegionInfo(addr, mem_region)
        if error.Fail():
            return None
        return mem_region

    def read_memory_at_address(
        self, addr: int, size: int, error: lldb.SBError
    ) -> lldb.SBData:
        data = lldb.SBData()
        bytes_read = self.corefile_process.ReadMemory(addr, size, error)

        if error.Fail():
            return data

        data.SetDataWithOwnership(
            error,
            bytes_read,
            self.corefile_target.GetByteOrder(),
            self.corefile_target.GetAddressByteSize(),
        )

        return data

    def get_loaded_images(self):
        return self.loaded_images

    def get_process_id(self) -> int:
        return 42

    def should_stop(self) -> bool:
        return True

    def is_alive(self) -> bool:
        return True

    def get_scripted_thread_plugin(self):
        return (
            StackCoreScriptedThread.__module__ + "." + StackCoreScriptedThread.__name__
        )


class StackCoreScriptedThread(ScriptedThread):
    def __init__(self, process, args):
        super().__init__(process, args)
        backing_target_idx = args.GetValueForKey("backing_target_idx")
        thread_idx = args.GetValueForKey("thread_idx")
        self.is_stopped = False

        def extract_value_from_structured_data(data, default_val):
            if data and data.IsValid():
                if data.GetType() == lldb.eStructuredDataTypeInteger:
                    return data.GetIntegerValue(default_val)
                if data.GetType() == lldb.eStructuredDataTypeString:
                    return int(data.GetStringValue(100))
            return None

        # TODO: Change to Walrus operator (:=) with oneline if assignment
        # Requires python 3.8
        val = extract_value_from_structured_data(thread_idx, 0)
        if val is not None:
            self.idx = val

        self.corefile_target = None
        self.corefile_process = None
        self.corefile_thread = None

        # TODO: Change to Walrus operator (:=) with oneline if assignment
        # Requires python 3.8
        val = extract_value_from_structured_data(backing_target_idx, 42)
        if val is not None:
            self.corefile_target = self.target.GetDebugger().GetTargetAtIndex(val)
            self.corefile_process = self.corefile_target.GetProcess()
            self.corefile_thread = self.corefile_process.GetThreadByIndexID(self.idx)

        if self.corefile_thread:
            self.id = self.corefile_thread.GetThreadID()

    def get_thread_id(self) -> int:
        return self.id

    def get_name(self) -> str:
        return StackCoreScriptedThread.__name__ + ".thread-" + str(self.id)

    def get_stop_reason(self) -> Dict[str, Any]:
        stop_reason = {"type": lldb.eStopReasonInvalid, "data": {}}

        if (
            self.corefile_thread
            and self.corefile_thread.IsValid()
            and self.get_thread_id() == self.corefile_thread.GetThreadID()
        ):
            stop_reason["type"] = lldb.eStopReasonNone

            if self.is_stopped:
                if "arm64" in self.scripted_process.arch:
                    stop_reason["type"] = lldb.eStopReasonException
                    stop_reason["data"]["desc"] = self.corefile_thread.stop_description
                elif self.scripted_process.arch == "x86_64":
                    stop_reason["type"] = lldb.eStopReasonSignal
                    stop_reason["data"]["signal"] = signal.SIGTRAP
                else:
                    stop_reason["type"] = self.corefile_thread.GetStopReason()

        return stop_reason

    def get_register_context(self) -> str:
        if not self.corefile_thread or self.corefile_thread.GetNumFrames() == 0:
            return None
        frame = self.corefile_thread.GetFrameAtIndex(0)

        GPRs = None
        registerSet = frame.registers  # Returns an SBValueList.
        for regs in registerSet:
            if "general purpose" in regs.name.lower():
                GPRs = regs
                break

        if not GPRs:
            return None

        for reg in GPRs:
            self.register_ctx[reg.name] = int(reg.value, base=16)

        return struct.pack(
            "{}Q".format(len(self.register_ctx)), *self.register_ctx.values()
        )


def __lldb_init_module(debugger, dict):
    if not "SKIP_SCRIPTED_PROCESS_LAUNCH" in os.environ:
        debugger.HandleCommand(
            "process launch -C %s.%s" % (__name__, StackCoreScriptedProcess.__name__)
        )
    else:
        print(
            "Name of the class that will manage the scripted process: '%s.%s'"
            % (__name__, StackCoreScriptedProcess.__name__)
        )
