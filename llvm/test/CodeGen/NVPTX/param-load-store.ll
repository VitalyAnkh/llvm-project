; Verifies correctness of load/store of parameters and return values.
; RUN: llc < %s -mtriple=nvptx64 -mcpu=sm_35 -O0 -verify-machineinstrs | FileCheck -allow-deprecated-dag-overlap %s
; RUN: %if ptxas %{ llc < %s -mtriple=nvptx64 -mcpu=sm_35 -O0 -verify-machineinstrs | %ptxas-verify %}

%s_i1 = type { i1 }
%s_i8 = type { i8 }
%s_i16 = type { i16 }
%s_f16 = type { half }
%s_i32 = type { i32 }
%s_f32 = type { float }
%s_i64 = type { i64 }
%s_f64 = type { double }

; More complicated types. i64 is used to increase natural alignment
; requirement for the type.
%s_i32x4 = type { i32, i32, i32, i32, i64}
%s_i32f32 = type { i32, float, i32, float, i64}
%s_i8i32x4 = type { i32, i32, i8, i32, i32, i64}
%s_i8i32x4p = type <{ i32, i32, i8, i32, i32, i64}>
%s_crossfield = type { i32, [2 x i32], <4 x i32>, [3 x {i32, i32, i32}]}
; All scalar parameters must be at least 32 bits in size.
; i1 is loaded/stored as i8.

; CHECK: .func  (.param .b32 func_retval0)
; CHECK-LABEL: test_i1(
; CHECK-NEXT: .param .b32 test_i1_param_0
; CHECK:      ld.param.b8 [[A8:%rs[0-9]+]], [test_i1_param_0];
; CHECK:      and.b16 [[A:%rs[0-9]+]], [[A8]], 1;
; CHECK:      setp.ne.b16 %p1, [[A]], 0
; CHECK-DAG:  .param .b32 param0;
; CHECK-DAG:  .param .b32 retval0;
; CHECK:      cvt.u32.u16 [[B:%r[0-9]+]], [[A8]]
; CHECK-DAG:  st.param.b32    [param0], [[B]]
; CHECK:      call.uni (retval0), test_i1,
; CHECK:      ld.param.b32    [[R8:%r[0-9]+]], [retval0];
; CHECK:      st.param.b32    [func_retval0], [[R8]];
; CHECK:      ret;
define i1 @test_i1(i1 %a) {
  %r = tail call i1 @test_i1(i1 %a);
  ret i1 %r;
}

; Signed i1 is a somewhat special case. We only care about one bit and
; then us neg.s32 to convert it to 32-bit -1 if it's set.
; CHECK: .func  (.param .b32 func_retval0)
; CHECK-LABEL: test_i1s(
; CHECK-NEXT: .param .b32 test_i1s_param_0
; CHECK:      ld.param.b8 [[A8:%rs[0-9]+]], [test_i1s_param_0];
; CHECK:      cvt.u32.u16     [[A32:%r[0-9]+]], [[A8]];
; CHECK:      .param .b32 param0;
; CHECK:      .param .b32 retval0;
; CHECK:      and.b32         [[A1:%r[0-9]+]], [[A32]], 1;
; CHECK:      neg.s32         [[A:%r[0-9]+]], [[A1]];
; CHECK:      st.param.b32    [param0], [[A]];
; CHECK:      call.uni
; CHECK:      ld.param.b32    [[R8:%r[0-9]+]], [retval0];
; CHECK:      and.b32         [[R1:%r[0-9]+]], [[R8]], 1;
; CHECK:      neg.s32         [[R:%r[0-9]+]], [[R1]];
; CHECK:      st.param.b32    [func_retval0], [[R]];
; CHECK-NEXT: ret;
define signext i1 @test_i1s(i1 signext %a) {
       %r = tail call signext i1 @test_i1s(i1 signext %a);
       ret i1 %r;
}

; Make sure that i1 loads are vectorized as i8 loads, respecting each element alignment.
; CHECK: .func  (.param .align 1 .b8 func_retval0[1])
; CHECK-LABEL: test_v3i1(
; CHECK-NEXT: .param .align 1 .b8 test_v3i1_param_0[1]
; CHECK-DAG:  ld.param.b8     [[E2:%rs[0-9]+]], [test_v3i1_param_0+2];
; CHECK-DAG:  ld.param.b8     [[E0:%rs[0-9]+]], [test_v3i1_param_0]
; CHECK:      .param .align 1 .b8 param0[1];
; CHECK:      .param .align 1 .b8 retval0[1];
; CHECK-DAG:  st.param.b8     [param0], [[E0]];
; CHECK-DAG:  st.param.b8     [param0+2], [[E2]];
; CHECK:      call.uni (retval0), test_v3i1,
; CHECK-DAG:  ld.param.b8     [[RE0:%rs[0-9]+]], [retval0];
; CHECK-DAG:  ld.param.b8     [[RE2:%rs[0-9]+]], [retval0+2];
; CHECK-DAG:  st.param.b8     [func_retval0], [[RE0]]
; CHECK-DAG:  st.param.b8     [func_retval0+2], [[RE2]];
; CHECK-NEXT: ret;
define <3 x i1> @test_v3i1(<3 x i1> %a) {
       %r = tail call <3 x i1> @test_v3i1(<3 x i1> %a);
       ret <3 x i1> %r;
}

; CHECK: .func  (.param .align 1 .b8 func_retval0[1])
; CHECK-LABEL: test_v4i1(
; CHECK-NEXT: .param .align 1 .b8 test_v4i1_param_0[1]
; CHECK:      ld.param.b8 [[E0:%rs[0-9]+]], [test_v4i1_param_0]
; CHECK:      .param .align 1 .b8 param0[1];
; CHECK:      .param .align 1 .b8 retval0[1];
; CHECK:      st.param.b8  [param0], [[E0]];
; CHECK:      call.uni (retval0), test_v4i1,
; CHECK:      ld.param.b8  [[RE0:%rs[0-9]+]], [retval0];
; CHECK:      ld.param.b8  [[RE1:%rs[0-9]+]], [retval0+1];
; CHECK:      ld.param.b8  [[RE2:%rs[0-9]+]], [retval0+2];
; CHECK:      ld.param.b8  [[RE3:%rs[0-9]+]], [retval0+3];
; CHECK:      st.param.b8  [func_retval0], [[RE0]];
; CHECK:      st.param.b8  [func_retval0+1], [[RE1]];
; CHECK:      st.param.b8  [func_retval0+2], [[RE2]];
; CHECK:      st.param.b8  [func_retval0+3], [[RE3]];
; CHECK-NEXT: ret;
define <4 x i1> @test_v4i1(<4 x i1> %a) {
       %r = tail call <4 x i1> @test_v4i1(<4 x i1> %a);
       ret <4 x i1> %r;
}

; CHECK: .func  (.param .align 1 .b8 func_retval0[1])
; CHECK-LABEL: test_v5i1(
; CHECK-NEXT: .param .align 1 .b8 test_v5i1_param_0[1]
; CHECK-DAG:  ld.param.b8     [[E4:%rs[0-9]+]], [test_v5i1_param_0+4];
; CHECK-DAG:  ld.param.b8     [[E0:%rs[0-9]+]], [test_v5i1_param_0]
; CHECK:      .param .align 1 .b8 param0[1];
; CHECK:      .param .align 1 .b8 retval0[1];
; CHECK-DAG:  st.param.b8     [param0], [[E0]];
; CHECK-DAG:  st.param.b8     [param0+4], [[E4]];
; CHECK:      call.uni (retval0), test_v5i1,
; CHECK-DAG:  ld.param.b8  [[RE0:%rs[0-9]+]], [retval0];
; CHECK-DAG:  ld.param.b8     [[RE4:%rs[0-9]+]], [retval0+4];
; CHECK-DAG:  st.param.b8  [func_retval0], [[RE0]]
; CHECK-DAG:  st.param.b8     [func_retval0+4], [[RE4]];
; CHECK-NEXT: ret;
define <5 x i1> @test_v5i1(<5 x i1> %a) {
       %r = tail call <5 x i1> @test_v5i1(<5 x i1> %a);
       ret <5 x i1> %r;
}

; CHECK: .func  (.param .b32 func_retval0)
; CHECK-LABEL: test_i2(
; CHECK-NEXT: .param .b32 test_i2_param_0
; CHECK:      ld.param.b8 {{%rs[0-9]+}}, [test_i2_param_0];
; CHECK:      .param .b32 param0;
; CHECK:      .param .b32 retval0;
; CHECK:      st.param.b32    [param0], {{%r[0-9]+}};
; CHECK:      call.uni (retval0), test_i2,
; CHECK:      ld.param.b32    {{%r[0-9]+}}, [retval0];
; CHECK:      st.param.b32    [func_retval0], {{%r[0-9]+}};
; CHECK-NEXT: ret;
define i2 @test_i2(i2 %a) {
       %r = tail call i2 @test_i2(i2 %a);
       ret i2 %r;
}

; CHECK: .func  (.param .b32 func_retval0)
; CHECK-LABEL: test_i3(
; CHECK-NEXT: .param .b32 test_i3_param_0
; CHECK:      ld.param.b8 {{%rs[0-9]+}}, [test_i3_param_0];
; CHECK:      .param .b32 param0;
; CHECK:      .param .b32 retval0;
; CHECK:      st.param.b32    [param0], {{%r[0-9]+}};
; CHECK:      call.uni (retval0), test_i3,
; CHECK:      ld.param.b32    {{%r[0-9]+}}, [retval0];
; CHECK:      st.param.b32    [func_retval0], {{%r[0-9]+}};
; CHECK-NEXT: ret;
define i3 @test_i3(i3 %a) {
       %r = tail call i3 @test_i3(i3 %a);
       ret i3 %r;
}

; Unsigned i8 is loaded directly into 32-bit register.
; CHECK: .func  (.param .b32 func_retval0)
; CHECK-LABEL: test_i8(
; CHECK-NEXT: .param .b32 test_i8_param_0
; CHECK:      ld.param.b8 [[A8:%rs[0-9]+]], [test_i8_param_0];
; CHECK:      .param .b32 param0;
; CHECK:      .param .b32 retval0;
; CHECK:      cvt.u32.u16     [[A32:%r[0-9]+]], [[A8]];
; CHECK:      st.param.b32    [param0], [[A32]];
; CHECK:      call.uni (retval0), test_i8,
; CHECK:      ld.param.b32    [[R32:%r[0-9]+]], [retval0];
; CHECK:      st.param.b32    [func_retval0], [[R32]];
; CHECK-NEXT: ret;
define i8 @test_i8(i8 %a) {
       %r = tail call i8 @test_i8(i8 %a);
       ret i8 %r;
}

; signed i8 is loaded into 16-bit register which is then sign-extended to i32.
; CHECK: .func  (.param .b32 func_retval0)
; CHECK-LABEL: test_i8s(
; CHECK-NEXT: .param .b32 test_i8s_param_0
; CHECK:      ld.param.s8 [[A8:%rs[0-9]+]], [test_i8s_param_0];
; CHECK:      .param .b32 param0;
; CHECK:      .param .b32 retval0;
; CHECK:      cvt.s32.s16     [[A:%r[0-9]+]], [[A8]];
; CHECK:      st.param.b32    [param0], [[A]];
; CHECK:      call.uni (retval0), test_i8s,
; CHECK:      ld.param.b32    [[R32:%r[0-9]+]], [retval0];
; -- This is suspicious (though correct) -- why not cvt.u8.u32, cvt.s8.s32 ?
; CHECK:      cvt.u16.u32     [[R16:%rs[0-9]+]], [[R32]];
; CHECK:      cvt.s32.s16     [[R:%r[0-9]+]], [[R16]];
; CHECK:      st.param.b32    [func_retval0], [[R]];
; CHECK-NEXT: ret;
define signext i8 @test_i8s(i8 signext %a) {
       %r = tail call signext i8 @test_i8s(i8 signext %a);
       ret i8 %r;
}

; CHECK: .func  (.param .align 4 .b8 func_retval0[4])
; CHECK-LABEL: test_v3i8(
; CHECK-NEXT: .param .align 4 .b8 test_v3i8_param_0[4]
; CHECK:      ld.param.b32     [[R:%r[0-9]+]], [test_v3i8_param_0];
; CHECK:      .param .align 4 .b8 param0[4];
; CHECK:      .param .align 4 .b8 retval0[4];
; CHECK:      st.param.b32  [param0], [[R]]
; CHECK:      call.uni (retval0), test_v3i8,
; CHECK:      ld.param.b32  [[RE:%r[0-9]+]], [retval0];
; v4i8/i32->{v3i8 elements}->v4i8/i32 conversion is messy and not very
; interesting here, so it's skipped.
; CHECK:      st.param.b32  [func_retval0],
; CHECK-NEXT: ret;
define <3 x i8> @test_v3i8(<3 x i8> %a) {
       %r = tail call <3 x i8> @test_v3i8(<3 x i8> %a);
       ret <3 x i8> %r;
}

; CHECK: .func  (.param .align 4 .b8 func_retval0[4])
; CHECK-LABEL: test_v4i8(
; CHECK-NEXT: .param .align 4 .b8 test_v4i8_param_0[4]
; CHECK:      ld.param.b32 [[R:%r[0-9]+]], [test_v4i8_param_0]
; CHECK:      .param .align 4 .b8 param0[4];
; CHECK:      .param .align 4 .b8 retval0[4];
; CHECK:      st.param.b32  [param0], [[R]];
; CHECK:      call.uni (retval0), test_v4i8,
; CHECK:      ld.param.b32  [[RET:%r[0-9]+]], [retval0];
; CHECK:      st.param.b32  [func_retval0], [[RET]];
; CHECK-NEXT: ret;
define <4 x i8> @test_v4i8(<4 x i8> %a) {
       %r = tail call <4 x i8> @test_v4i8(<4 x i8> %a);
       ret <4 x i8> %r;
}

; CHECK: .func  (.param .align 8 .b8 func_retval0[8])
; CHECK-LABEL: test_v5i8(
; CHECK-NEXT: .param .align 8 .b8 test_v5i8_param_0[8]
; CHECK-DAG:  ld.param.b32    [[E0:%r[0-9]+]], [test_v5i8_param_0]
; CHECK-DAG:  ld.param.b8     [[E4:%rs[0-9]+]], [test_v5i8_param_0+4];
; CHECK:      .param .align 8 .b8 param0[8];
; CHECK:      .param .align 8 .b8 retval0[8];
; CHECK-DAG:  st.param.b32  [param0], [[E0]];
; CHECK-DAG:  st.param.b8     [param0+4], [[E4]];
; CHECK:      call.uni (retval0), test_v5i8,
; CHECK-DAG:  ld.param.b32    [[RE0:%r[0-9]+]], [retval0];
; CHECK-DAG:  ld.param.b8     [[RE4:%rs[0-9]+]], [retval0+4];
; CHECK-DAG:  st.param.b32  [func_retval0], [[RE0]];
; CHECK-DAG:  st.param.b8     [func_retval0+4], [[RE4]];
; CHECK-NEXT: ret;
define <5 x i8> @test_v5i8(<5 x i8> %a) {
       %r = tail call <5 x i8> @test_v5i8(<5 x i8> %a);
       ret <5 x i8> %r;
}

; CHECK: .func  (.param .b32 func_retval0)
; CHECK-LABEL: test_i11(
; CHECK-NEXT: .param .b32 test_i11_param_0
; CHECK:      ld.param.b16    {{%rs[0-9]+}}, [test_i11_param_0];
; CHECK:      .param .b32 retval0;
; CHECK:      st.param.b32    [param0], {{%r[0-9]+}};
; CHECK:      call.uni (retval0), test_i11,
; CHECK:      ld.param.b32    {{%r[0-9]+}}, [retval0];
; CHECK:      st.param.b32    [func_retval0], {{%r[0-9]+}};
; CHECK-NEXT: ret;
define i11 @test_i11(i11 %a) {
       %r = tail call i11 @test_i11(i11 %a);
       ret i11 %r;
}

; CHECK: .func  (.param .b32 func_retval0)
; CHECK-LABEL: test_i16(
; CHECK-NEXT: .param .b32 test_i16_param_0
; CHECK:      ld.param.b16    [[E16:%rs[0-9]+]], [test_i16_param_0];
; CHECK:      .param .b32 param0;
; CHECK:      .param .b32 retval0;
; CHECK:      cvt.u32.u16     [[E32:%r[0-9]+]], [[E16]];
; CHECK:      st.param.b32    [param0], [[E32]];
; CHECK:      call.uni (retval0), test_i16,
; CHECK:      ld.param.b32    [[RE32:%r[0-9]+]], [retval0];
; CHECK:      st.param.b32    [func_retval0], [[RE32]];
; CHECK-NEXT: ret;
define i16 @test_i16(i16 %a) {
       %r = tail call i16 @test_i16(i16 %a);
       ret i16 %r;
}

; CHECK: .func  (.param .b32 func_retval0)
; CHECK-LABEL: test_i16s(
; CHECK-NEXT: .param .b32 test_i16s_param_0
; CHECK:      ld.param.b16    [[E16:%rs[0-9]+]], [test_i16s_param_0];
; CHECK:      .param .b32 param0;
; CHECK:      .param .b32 retval0;
; CHECK:      cvt.s32.s16     [[E32:%r[0-9]+]], [[E16]];
; CHECK:      st.param.b32    [param0], [[E32]];
; CHECK:      call.uni (retval0), test_i16s,
; CHECK:      ld.param.b32    [[RE32:%r[0-9]+]], [retval0];
; CHECK:      cvt.s32.s16     [[R:%r[0-9]+]], [[RE32]];
; CHECK:      st.param.b32    [func_retval0], [[R]];
; CHECK-NEXT: ret;
define signext i16 @test_i16s(i16 signext %a) {
       %r = tail call signext i16 @test_i16s(i16 signext %a);
       ret i16 %r;
}

; CHECK: .func  (.param .align 8 .b8 func_retval0[8])
; CHECK-LABEL: test_v3i16(
; CHECK-NEXT: .param .align 8 .b8 test_v3i16_param_0[8]
; CHECK-DAG:  ld.param.b16      [[E2:%rs[0-9]+]], [test_v3i16_param_0+4];
; CHECK-DAG:  ld.param.b32      [[E0:%r[0-9]+]], [test_v3i16_param_0];
; CHECK:      .param .align 8 .b8 param0[8];
; CHECK:      .param .align 8 .b8 retval0[8];
; CHECK-DAG:  st.param.b32    [param0], [[E0]];
; CHECK-DAG:  st.param.b16    [param0+4], [[E2]];
; CHECK:      call.uni (retval0), test_v3i16,
; CHECK:      ld.param.b32 [[RE:%r[0-9]+]], [retval0];
; CHECK:      ld.param.b16    [[RE2:%rs[0-9]+]], [retval0+4];
; CHECK-DAG:  mov.b32       {[[RE0:%rs[0-9]+]], [[RE1:%rs[0-9]+]]}, [[RE]];
; CHECK-DAG:  st.param.v2.b16 [func_retval0], {[[RE0]], [[RE1]]};
; CHECK-DAG:  st.param.b16    [func_retval0+4], [[RE2]];
; CHECK-NEXT: ret;
define <3 x i16> @test_v3i16(<3 x i16> %a) {
       %r = tail call <3 x i16> @test_v3i16(<3 x i16> %a);
       ret <3 x i16> %r;
}

; CHECK: .func  (.param .align 8 .b8 func_retval0[8])
; CHECK-LABEL: test_v4i16(
; CHECK-NEXT: .param .align 8 .b8 test_v4i16_param_0[8]
; CHECK:      ld.param.v2.b32 {[[E0:%r[0-9]+]], [[E1:%r[0-9]+]]}, [test_v4i16_param_0]
; CHECK:      .param .align 8 .b8 param0[8];
; CHECK:      .param .align 8 .b8 retval0[8];
; CHECK:      st.param.v2.b32 [param0], {[[E0]], [[E1]]};
; CHECK:      call.uni (retval0), test_v4i16,
; CHECK:      ld.param.v2.b32 {[[RE0:%r[0-9]+]], [[RE1:%r[0-9]+]]}, [retval0];
; CHECK:      st.param.v2.b32 [func_retval0], {[[RE0]], [[RE1]]}
; CHECK-NEXT: ret;
define <4 x i16> @test_v4i16(<4 x i16> %a) {
       %r = tail call <4 x i16> @test_v4i16(<4 x i16> %a);
       ret <4 x i16> %r;
}

; CHECK: .func  (.param .align 16 .b8 func_retval0[16])
; CHECK-LABEL: test_v5i16(
; CHECK-NEXT: .param .align 16 .b8 test_v5i16_param_0[16]
; CHECK-DAG:  ld.param.b16    [[E4:%rs[0-9]+]], [test_v5i16_param_0+8];
; CHECK-DAG:  ld.param.v2.b32 {[[E0:%r[0-9]+]], [[E1:%r[0-9]+]]}, [test_v5i16_param_0]
; CHECK:      .param .align 16 .b8 param0[16];
; CHECK:      .param .align 16 .b8 retval0[16];
; CHECK-DAG:  st.param.v2.b32 [param0], {[[E0]], [[E1]]};
; CHECK-DAG:  st.param.b16    [param0+8], [[E4]];
; CHECK:      call.uni (retval0), test_v5i16,
; CHECK-DAG:  ld.param.v2.b32 {[[RE0:%r[0-9]+]], [[RE1:%r[0-9]+]]}, [retval0];
; CHECK-DAG:  ld.param.b16    [[RE4:%rs[0-9]+]], [retval0+8];
; CHECK-DAG:  st.param.v2.b32 [func_retval0], {[[RE0]], [[RE1]]}
; CHECK-DAG:  st.param.b16    [func_retval0+8], [[RE4]];
; CHECK-NEXT: ret;
define <5 x i16> @test_v5i16(<5 x i16> %a) {
       %r = tail call <5 x i16> @test_v5i16(<5 x i16> %a);
       ret <5 x i16> %r;
}

; CHECK: .func  (.param .align 2 .b8 func_retval0[2])
; CHECK-LABEL: test_f16(
; CHECK-NEXT: .param .align 2 .b8 test_f16_param_0[2]
; CHECK:      ld.param.b16    [[E:%rs[0-9]+]], [test_f16_param_0];
; CHECK:      .param .align 2 .b8 param0[2];
; CHECK:      .param .align 2 .b8 retval0[2];
; CHECK:      st.param.b16    [param0], [[E]];
; CHECK:      call.uni (retval0), test_f16,
; CHECK:      ld.param.b16    [[R:%rs[0-9]+]], [retval0];
; CHECK:      st.param.b16    [func_retval0], [[R]]
; CHECK-NEXT: ret;
define half @test_f16(half %a) {
       %r = tail call half @test_f16(half %a);
       ret half %r;
}

; CHECK: .func  (.param .align 4 .b8 func_retval0[4])
; CHECK-LABEL: test_v2f16(
; CHECK-NEXT: .param .align 4 .b8 test_v2f16_param_0[4]
; CHECK:      ld.param.b32    [[E:%r[0-9]+]], [test_v2f16_param_0];
; CHECK:      .param .align 4 .b8 param0[4];
; CHECK:      .param .align 4 .b8 retval0[4];
; CHECK:      st.param.b32    [param0], [[E]];
; CHECK:      call.uni (retval0), test_v2f16,
; CHECK:      ld.param.b32    [[R:%r[0-9]+]], [retval0];
; CHECK:      st.param.b32    [func_retval0], [[R]]
; CHECK-NEXT: ret;
define <2 x half> @test_v2f16(<2 x half> %a) {
       %r = tail call <2 x half> @test_v2f16(<2 x half> %a);
       ret <2 x half> %r;
}

; CHECK: .func  (.param .align 2 .b8 func_retval0[2])
; CHECK-LABEL: test_bf16(
; CHECK-NEXT: .param .align 2 .b8 test_bf16_param_0[2]
; CHECK:      ld.param.b16    [[E:%rs[0-9]+]], [test_bf16_param_0];
; CHECK:      .param .align 2 .b8 param0[2];
; CHECK:      .param .align 2 .b8 retval0[2];
; CHECK:      st.param.b16    [param0], [[E]];
; CHECK:      call.uni (retval0), test_bf16,
; CHECK:      ld.param.b16    [[R:%rs[0-9]+]], [retval0];
; CHECK:      st.param.b16    [func_retval0], [[R]]
; CHECK-NEXT: ret;
define bfloat @test_bf16(bfloat %a) {
       %r = tail call bfloat @test_bf16(bfloat %a);
       ret bfloat %r;
}

; CHECK: .func  (.param .align 4 .b8 func_retval0[4])
; CHECK-LABEL: test_v2bf16(
; CHECK-NEXT: .param .align 4 .b8 test_v2bf16_param_0[4]
; CHECK:      ld.param.b32    [[E:%r[0-9]+]], [test_v2bf16_param_0];
; CHECK:      .param .align 4 .b8 param0[4];
; CHECK:      .param .align 4 .b8 retval0[4];
; CHECK:      st.param.b32    [param0], [[E]];
; CHECK:      call.uni (retval0), test_v2bf16,
; CHECK:      ld.param.b32    [[R:%r[0-9]+]], [retval0];
; CHECK:      st.param.b32    [func_retval0], [[R]]
; CHECK-NEXT: ret;
define <2 x bfloat> @test_v2bf16(<2 x bfloat> %a) {
       %r = tail call <2 x bfloat> @test_v2bf16(<2 x bfloat> %a);
       ret <2 x bfloat> %r;
}


; CHECK:.func  (.param .align 8 .b8 func_retval0[8])
; CHECK-LABEL: test_v3f16(
; CHECK:      .param .align 8 .b8 test_v3f16_param_0[8]
; CHECK-DAG:  ld.param.b32    [[E0:%r[0-9]+]], [test_v3f16_param_0];
; CHECK-DAG:  ld.param.b16    [[E2:%rs[0-9]+]], [test_v3f16_param_0+4];
; CHECK:      .param .align 8 .b8 param0[8];
; CHECK:      .param .align 8 .b8 retval0[8];
; CHECK-DAG:  st.param.b32    [param0], [[E0]];
; CHECK-DAG:  st.param.b16    [param0+4], [[E2]];
; CHECK:      call.uni (retval0),      test_v3f16,
; CHECK-DAG:  ld.param.b32 [[R:%r[0-9]+]], [retval0];
; CHECK-DAG:  ld.param.b16    [[R2:%rs[0-9]+]], [retval0+4];
; CHECK-DAG:  mov.b32       {[[R0:%rs[0-9]+]], [[R1:%rs[0-9]+]]}, [[R]];
; CHECK-DAG:  st.param.v2.b16 [func_retval0], {[[R0]], [[R1]]};
; CHECK-DAG:  st.param.b16    [func_retval0+4], [[R2]];
; CHECK:      ret;
define <3 x half> @test_v3f16(<3 x half> %a) {
       %r = tail call <3 x half> @test_v3f16(<3 x half> %a);
       ret <3 x half> %r;
}

; CHECK:.func  (.param .align 8 .b8 func_retval0[8])
; CHECK-LABEL: test_v4f16(
; CHECK:      .param .align 8 .b8 test_v4f16_param_0[8]
; CHECK:      ld.param.v2.b32 {[[R01:%r[0-9]+]], [[R23:%r[0-9]+]]}, [test_v4f16_param_0];
; CHECK:      .param .align 8 .b8 param0[8];
; CHECK:      .param .align 8 .b8 retval0[8];
; CHECK:      st.param.v2.b32 [param0], {[[R01]], [[R23]]};
; CHECK:      call.uni (retval0),      test_v4f16,
; CHECK:      ld.param.v2.b32 {[[RH01:%r[0-9]+]], [[RH23:%r[0-9]+]]}, [retval0];
; CHECK:      st.param.v2.b32 [func_retval0], {[[RH01]], [[RH23]]};
; CHECK:      ret;
define <4 x half> @test_v4f16(<4 x half> %a) {
       %r = tail call <4 x half> @test_v4f16(<4 x half> %a);
       ret <4 x half> %r;
}

; CHECK:.func  (.param .align 16 .b8 func_retval0[16])
; CHECK-LABEL: test_v5f16(
; CHECK:      .param .align 16 .b8 test_v5f16_param_0[16]
; CHECK-DAG:  ld.param.v2.b32 {[[E0:%r[0-9]+]], [[E1:%r[0-9]+]]}, [test_v5f16_param_0];
; CHECK-DAG:  ld.param.b16    [[E4:%rs[0-9]+]], [test_v5f16_param_0+8];
; CHECK:      .param .align 16 .b8 param0[16];
; CHECK:      .param .align 16 .b8 retval0[16];
; CHECK-DAG:  st.param.v2.b32 [param0], {[[E0]], [[E1]]};
; CHECK-DAG:  st.param.b16    [param0+8], [[E4]];
; CHECK:      call.uni (retval0),      test_v5f16,
; CHECK-DAG:  ld.param.v2.b32 {[[R0:%r[0-9]+]], [[R1:%r[0-9]+]]}, [retval0];
; CHECK-DAG:  ld.param.b16    [[R4:%rs[0-9]+]], [retval0+8];
; CHECK-DAG:  st.param.v2.b32 [func_retval0], {[[R0]], [[R1]]};
; CHECK-DAG:  st.param.b16    [func_retval0+8], [[R4]];
; CHECK:      ret;
define <5 x half> @test_v5f16(<5 x half> %a) {
       %r = tail call <5 x half> @test_v5f16(<5 x half> %a);
       ret <5 x half> %r;
}

; CHECK:.func  (.param .align 16 .b8 func_retval0[16])
; CHECK-LABEL: test_v8f16(
; CHECK:      .param .align 16 .b8 test_v8f16_param_0[16]
; CHECK:      ld.param.v4.b32 {[[R01:%r[0-9]+]], [[R23:%r[0-9]+]], [[R45:%r[0-9]+]], [[R67:%r[0-9]+]]}, [test_v8f16_param_0];
; CHECK:      .param .align 16 .b8 param0[16];
; CHECK:      .param .align 16 .b8 retval0[16];
; CHECK:      st.param.v4.b32 [param0], {[[R01]], [[R23]], [[R45]], [[R67]]};
; CHECK:      call.uni (retval0), test_v8f16,
; CHECK:      ld.param.v4.b32 {[[RH01:%r[0-9]+]], [[RH23:%r[0-9]+]], [[RH45:%r[0-9]+]], [[RH67:%r[0-9]+]]}, [retval0];
; CHECK:      st.param.v4.b32 [func_retval0], {[[RH01]], [[RH23]], [[RH45]], [[RH67]]};
; CHECK:      ret;
define <8 x half> @test_v8f16(<8 x half> %a) {
       %r = tail call <8 x half> @test_v8f16(<8 x half> %a);
       ret <8 x half> %r;
}

; CHECK:.func  (.param .align 32 .b8 func_retval0[32])
; CHECK-LABEL: test_v9f16(
; CHECK:      .param .align 32 .b8 test_v9f16_param_0[32]
; CHECK-DAG:  ld.param.v2.b32 {[[E0:%r[0-9]+]], [[E1:%r[0-9]+]]}, [test_v9f16_param_0];
; CHECK-DAG:  ld.param.v2.b32 {[[E2:%r[0-9]+]], [[E3:%r[0-9]+]]}, [test_v9f16_param_0+8];
; CHECK-DAG:  ld.param.b16     [[E8:%rs[0-9]+]], [test_v9f16_param_0+16];
; CHECK:      .param .align 32 .b8 param0[32];
; CHECK:      .param .align 32 .b8 retval0[32];
; CHECK-DAG:  st.param.v2.b32 [param0], {[[E0]], [[E1]]};
; CHECK-DAG:  st.param.v2.b32 [param0+8], {[[E2]], [[E3]]};
; CHECK-DAG:  st.param.b16    [param0+16], [[E8]];
; CHECK:      call.uni (retval0), test_v9f16,
; CHECK-DAG:  ld.param.v2.b32 {[[R0:%r[0-9]+]], [[R1:%r[0-9]+]]}, [retval0];
; CHECK-DAG:  ld.param.v2.b32 {[[R2:%r[0-9]+]], [[R3:%r[0-9]+]]}, [retval0+8];
; CHECK-DAG:  ld.param.b16    [[R8:%rs[0-9]+]], [retval0+16];
; CHECK-DAG:  st.param.v2.b32 [func_retval0], {[[R0]], [[R1]]};
; CHECK-DAG:  st.param.v2.b32 [func_retval0+8], {[[R2]], [[R3]]};
; CHECK-DAG:  st.param.b16    [func_retval0+16], [[R8]];
; CHECK:      ret;
define <9 x half> @test_v9f16(<9 x half> %a) {
       %r = tail call <9 x half> @test_v9f16(<9 x half> %a);
       ret <9 x half> %r;
}

; CHECK: .func  (.param .b32 func_retval0)
; CHECK-LABEL: test_i19(
; CHECK-NEXT: .param .b32 test_i19_param_0
; CHECK-DAG:  ld.param.b16    {{%r[0-9]+}}, [test_i19_param_0];
; CHECK-DAG:  ld.param.b8     {{%r[0-9]+}}, [test_i19_param_0+2];
; CHECK:      .param .b32 param0;
; CHECK:      .param .b32 retval0;
; CHECK:      st.param.b32    [param0], {{%r[0-9]+}};
; CHECK:      call.uni (retval0), test_i19,
; CHECK:      ld.param.b32    {{%r[0-9]+}}, [retval0];
; CHECK:      st.param.b32    [func_retval0], {{%r[0-9]+}};
; CHECK-NEXT: ret;
define i19 @test_i19(i19 %a) {
       %r = tail call i19 @test_i19(i19 %a);
       ret i19 %r;
}

; CHECK: .func  (.param .b32 func_retval0)
; CHECK-LABEL: test_i23(
; CHECK-NEXT: .param .b32 test_i23_param_0
; CHECK-DAG:  ld.param.b16    {{%r[0-9]+}}, [test_i23_param_0];
; CHECK-DAG:  ld.param.b8     {{%r[0-9]+}}, [test_i23_param_0+2];
; CHECK:      .param .b32 param0;
; CHECK:      .param .b32 retval0;
; CHECK:      st.param.b32    [param0], {{%r[0-9]+}};
; CHECK:      call.uni (retval0), test_i23,
; CHECK:      ld.param.b32    {{%r[0-9]+}}, [retval0];
; CHECK:      st.param.b32    [func_retval0], {{%r[0-9]+}};
; CHECK-NEXT: ret;
define i23 @test_i23(i23 %a) {
       %r = tail call i23 @test_i23(i23 %a);
       ret i23 %r;
}

; CHECK: .func  (.param .b32 func_retval0)
; CHECK-LABEL: test_i24(
; CHECK-NEXT: .param .b32 test_i24_param_0
; CHECK-DAG:  ld.param.b8     {{%r[0-9]+}}, [test_i24_param_0+2];
; CHECK-DAG:  ld.param.b16    {{%r[0-9]+}}, [test_i24_param_0];
; CHECK:      .param .b32 param0;
; CHECK:      .param .b32 retval0;
; CHECK:      st.param.b32    [param0], {{%r[0-9]+}};
; CHECK:      call.uni (retval0), test_i24,
; CHECK:      ld.param.b32    {{%r[0-9]+}}, [retval0];
; CHECK:      st.param.b32    [func_retval0], {{%r[0-9]+}};
; CHECK-NEXT: ret;
define i24 @test_i24(i24 %a) {
       %r = tail call i24 @test_i24(i24 %a);
       ret i24 %r;
}

; CHECK: .func  (.param .b32 func_retval0)
; CHECK-LABEL: test_i29(
; CHECK-NEXT: .param .b32 test_i29_param_0
; CHECK:      ld.param.b32    {{%r[0-9]+}}, [test_i29_param_0];
; CHECK:      .param .b32 param0;
; CHECK:      .param .b32 retval0;
; CHECK:      st.param.b32    [param0], {{%r[0-9]+}};
; CHECK:      call.uni (retval0), test_i29,
; CHECK:      ld.param.b32    {{%r[0-9]+}}, [retval0];
; CHECK:      st.param.b32    [func_retval0], {{%r[0-9]+}};
; CHECK-NEXT: ret;
define i29 @test_i29(i29 %a) {
       %r = tail call i29 @test_i29(i29 %a);
       ret i29 %r;
}

; CHECK: .func  (.param .b32 func_retval0)
; CHECK-LABEL: test_i32(
; CHECK-NEXT: .param .b32 test_i32_param_0
; CHECK:      ld.param.b32    [[E:%r[0-9]+]], [test_i32_param_0];
; CHECK:      .param .b32 param0;
; CHECK:      .param .b32 retval0;
; CHECK:      st.param.b32    [param0], [[E]];
; CHECK:      call.uni (retval0), test_i32,
; CHECK:      ld.param.b32    [[R:%r[0-9]+]], [retval0];
; CHECK:      st.param.b32    [func_retval0], [[R]];
; CHECK-NEXT: ret;
define i32 @test_i32(i32 %a) {
       %r = tail call i32 @test_i32(i32 %a);
       ret i32 %r;
}

; CHECK: .func  (.param .align 16 .b8 func_retval0[16])
; CHECK-LABEL: test_v3i32(
; CHECK-NEXT: .param .align 16 .b8 test_v3i32_param_0[16]
; CHECK-DAG:  ld.param.b32     [[E2:%r[0-9]+]], [test_v3i32_param_0+8];
; CHECK-DAG:  ld.param.v2.b32  {[[E0:%r[0-9]+]], [[E1:%r[0-9]+]]}, [test_v3i32_param_0];
; CHECK-DAG:  .param .align 16 .b8 param0[16];
; CHECK-DAG:  .param .align 16 .b8 retval0[16];
; CHECK-DAG:  st.param.v2.b32  [param0], {[[E0]], [[E1]]};
; CHECK-DAG:  st.param.b32     [param0+8], [[E2]];
; CHECK:      call.uni (retval0), test_v3i32,
; CHECK:      ld.param.v2.b32  {[[RE0:%r[0-9]+]], [[RE1:%r[0-9]+]]}, [retval0];
; CHECK:      ld.param.b32     [[RE2:%r[0-9]+]], [retval0+8];
; CHECK-DAG:  st.param.v2.b32  [func_retval0], {[[RE0]], [[RE1]]};
; CHECK-DAG:  st.param.b32     [func_retval0+8], [[RE2]];
; CHECK-NEXT: ret;
define <3 x i32> @test_v3i32(<3 x i32> %a) {
       %r = tail call <3 x i32> @test_v3i32(<3 x i32> %a);
       ret <3 x i32> %r;
}

; CHECK: .func  (.param .align 16 .b8 func_retval0[16])
; CHECK-LABEL: test_v4i32(
; CHECK-NEXT: .param .align 16 .b8 test_v4i32_param_0[16]
; CHECK:      ld.param.v4.b32  {[[E0:%r[0-9]+]], [[E1:%r[0-9]+]], [[E2:%r[0-9]+]], [[E3:%r[0-9]+]]}, [test_v4i32_param_0]
; CHECK-DAG:  .param .align 16 .b8 param0[16];
; CHECK-DAG:  .param .align 16 .b8 retval0[16];
; CHECK-DAG:  st.param.v4.b32  [param0], {[[E0]], [[E1]], [[E2]], [[E3]]};
; CHECK:      call.uni (retval0), test_v4i32,
; CHECK:      ld.param.v4.b32  {[[RE0:%r[0-9]+]], [[RE1:%r[0-9]+]], [[RE2:%r[0-9]+]], [[RE3:%r[0-9]+]]}, [retval0];
; CHECK:      st.param.v4.b32  [func_retval0], {[[RE0]], [[RE1]], [[RE2]], [[RE3]]}
; CHECK-NEXT: ret;
define <4 x i32> @test_v4i32(<4 x i32> %a) {
       %r = tail call <4 x i32> @test_v4i32(<4 x i32> %a);
       ret <4 x i32> %r;
}

; CHECK: .func  (.param .align 32 .b8 func_retval0[32])
; CHECK-LABEL: test_v5i32(
; CHECK-NEXT: .param .align 32 .b8 test_v5i32_param_0[32]
; CHECK-DAG:  ld.param.b32     [[E4:%r[0-9]+]], [test_v5i32_param_0+16];
; CHECK-DAG:  ld.param.v4.b32  {[[E0:%r[0-9]+]], [[E1:%r[0-9]+]], [[E2:%r[0-9]+]], [[E3:%r[0-9]+]]}, [test_v5i32_param_0]
; CHECK:      .param .align 32 .b8 param0[32];
; CHECK:      .param .align 32 .b8 retval0[32];
; CHECK-DAG:  st.param.v4.b32  [param0], {[[E0]], [[E1]], [[E2]], [[E3]]};
; CHECK-DAG:  st.param.b32     [param0+16], [[E4]];
; CHECK:      call.uni (retval0), test_v5i32,
; CHECK-DAG:  ld.param.v4.b32  {[[RE0:%r[0-9]+]], [[RE1:%r[0-9]+]], [[RE2:%r[0-9]+]], [[RE3:%r[0-9]+]]}, [retval0];
; CHECK-DAG:  ld.param.b32     [[RE4:%r[0-9]+]], [retval0+16];
; CHECK-DAG:  st.param.v4.b32  [func_retval0], {[[RE0]], [[RE1]], [[RE2]], [[RE3]]}
; CHECK-DAG:  st.param.b32     [func_retval0+16], [[RE4]];
; CHECK-NEXT: ret;
define <5 x i32> @test_v5i32(<5 x i32> %a) {
       %r = tail call <5 x i32> @test_v5i32(<5 x i32> %a);
       ret <5 x i32> %r;
}

; CHECK: .func  (.param .b32 func_retval0)
; CHECK-LABEL: test_f32(
; CHECK-NEXT: .param .b32 test_f32_param_0
; CHECK:      ld.param.b32    [[E:%r[0-9]+]], [test_f32_param_0];
; CHECK:      .param .b32 param0;
; CHECK:      .param .b32 retval0;
; CHECK:      st.param.b32    [param0], [[E]];
; CHECK:      call.uni (retval0), test_f32,
; CHECK:      ld.param.b32    [[R:%r[0-9]+]], [retval0];
; CHECK:      st.param.b32    [func_retval0], [[R]];
; CHECK-NEXT: ret;
define float @test_f32(float %a) {
       %r = tail call float @test_f32(float %a);
       ret float %r;
}

; CHECK: .func  (.param .b64 func_retval0)
; CHECK-LABEL: test_i40(
; CHECK-NEXT: .param .b64 test_i40_param_0
; CHECK-DAG:  ld.param.b8    {{%rd[0-9]+}}, [test_i40_param_0+4];
; CHECK-DAG:  ld.param.b32   {{%rd[0-9]+}}, [test_i40_param_0];
; CHECK:      .param .b64 param0;
; CHECK:      .param .b64 retval0;
; CHECK:      st.param.b64    [param0], {{%rd[0-9]+}};
; CHECK:      call.uni (retval0), test_i40,
; CHECK:      ld.param.b64    {{%rd[0-9]+}}, [retval0];
; CHECK:      st.param.b64    [func_retval0], {{%rd[0-9]+}};
; CHECK-NEXT: ret;
define i40 @test_i40(i40 %a) {
       %r = tail call i40 @test_i40(i40 %a);
       ret i40 %r;
}

; CHECK: .func  (.param .b64 func_retval0)
; CHECK-LABEL: test_i47(
; CHECK-NEXT: .param .b64 test_i47_param_0
; CHECK-DAG:  ld.param.b16   {{%rd[0-9]+}}, [test_i47_param_0+4];
; CHECK-DAG:  ld.param.b32   {{%rd[0-9]+}}, [test_i47_param_0];
; CHECK:      .param .b64 param0;
; CHECK:      .param .b64 retval0;
; CHECK:      st.param.b64    [param0], {{%rd[0-9]+}};
; CHECK:      call.uni (retval0), test_i47,
; CHECK:      ld.param.b64    {{%rd[0-9]+}}, [retval0];
; CHECK:      st.param.b64    [func_retval0], {{%rd[0-9]+}};
; CHECK-NEXT: ret;
define i47 @test_i47(i47 %a) {
       %r = tail call i47 @test_i47(i47 %a);
       ret i47 %r;
}

; CHECK: .func  (.param .b64 func_retval0)
; CHECK-LABEL: test_i48(
; CHECK-NEXT: .param .b64 test_i48_param_0
; CHECK-DAG:  ld.param.b16   {{%rd[0-9]+}}, [test_i48_param_0+4];
; CHECK-DAG:  ld.param.b32   {{%rd[0-9]+}}, [test_i48_param_0];
; CHECK:      .param .b64 param0;
; CHECK:      .param .b64 retval0;
; CHECK:      st.param.b64    [param0], {{%rd[0-9]+}};
; CHECK:      call.uni (retval0), test_i48,
; CHECK:      ld.param.b64    {{%rd[0-9]+}}, [retval0];
; CHECK:      st.param.b64    [func_retval0], {{%rd[0-9]+}};
; CHECK-NEXT: ret;
define i48 @test_i48(i48 %a) {
       %r = tail call i48 @test_i48(i48 %a);
       ret i48 %r;
}

; CHECK: .func  (.param .b64 func_retval0)
; CHECK-LABEL: test_i51(
; CHECK-NEXT: .param .b64 test_i51_param_0
; CHECK-DAG:  ld.param.b8    {{%rd[0-9]+}}, [test_i51_param_0+6];
; CHECK-DAG:  ld.param.b16   {{%rd[0-9]+}}, [test_i51_param_0+4];
; CHECK-DAG:  ld.param.b32   {{%rd[0-9]+}}, [test_i51_param_0];
; CHECK:      .param .b64 param0;
; CHECK:      .param .b64 retval0;
; CHECK:      st.param.b64    [param0], {{%rd[0-9]+}};
; CHECK:      call.uni (retval0), test_i51,
; CHECK:      ld.param.b64    {{%rd[0-9]+}}, [retval0];
; CHECK:      st.param.b64    [func_retval0], {{%rd[0-9]+}};
; CHECK-NEXT: ret;
define i51 @test_i51(i51 %a) {
       %r = tail call i51 @test_i51(i51 %a);
       ret i51 %r;
}

; CHECK: .func  (.param .b64 func_retval0)
; CHECK-LABEL: test_i56(
; CHECK-NEXT: .param .b64 test_i56_param_0
; CHECK-DAG:  ld.param.b8    {{%rd[0-9]+}}, [test_i56_param_0+6];
; CHECK-DAG:  ld.param.b16   {{%rd[0-9]+}}, [test_i56_param_0+4];
; CHECK-DAG:  ld.param.b32   {{%rd[0-9]+}}, [test_i56_param_0];
; CHECK:      .param .b64 param0;
; CHECK:      .param .b64 retval0;
; CHECK:      st.param.b64    [param0], {{%rd[0-9]+}};
; CHECK:      call.uni (retval0), test_i56,
; CHECK:      ld.param.b64    {{%rd[0-9]+}}, [retval0];
; CHECK:      st.param.b64    [func_retval0], {{%rd[0-9]+}};
; CHECK-NEXT: ret;
define i56 @test_i56(i56 %a) {
       %r = tail call i56 @test_i56(i56 %a);
       ret i56 %r;
}

; CHECK: .func  (.param .b64 func_retval0)
; CHECK-LABEL: test_i57(
; CHECK-NEXT: .param .b64 test_i57_param_0
; CHECK:      ld.param.b64    {{%rd[0-9]+}}, [test_i57_param_0];
; CHECK:      .param .b64 param0;
; CHECK:      .param .b64 retval0;
; CHECK:      st.param.b64    [param0], {{%rd[0-9]+}};
; CHECK:      call.uni (retval0), test_i57,
; CHECK:      ld.param.b64    {{%rd[0-9]+}}, [retval0];
; CHECK:      st.param.b64    [func_retval0], {{%rd[0-9]+}};
; CHECK-NEXT: ret;
define i57 @test_i57(i57 %a) {
       %r = tail call i57 @test_i57(i57 %a);
       ret i57 %r;
}

; CHECK: .func  (.param .b64 func_retval0)
; CHECK-LABEL: test_i64(
; CHECK-NEXT: .param .b64 test_i64_param_0
; CHECK:      ld.param.b64    [[E:%rd[0-9]+]], [test_i64_param_0];
; CHECK:      .param .b64 param0;
; CHECK:      .param .b64 retval0;
; CHECK:      st.param.b64    [param0], [[E]];
; CHECK:      call.uni (retval0), test_i64,
; CHECK:      ld.param.b64    [[R:%rd[0-9]+]], [retval0];
; CHECK:      st.param.b64    [func_retval0], [[R]];
; CHECK-NEXT: ret;
define i64 @test_i64(i64 %a) {
       %r = tail call i64 @test_i64(i64 %a);
       ret i64 %r;
}

; CHECK: .func  (.param .align 32 .b8 func_retval0[32])
; CHECK-LABEL: test_v3i64(
; CHECK-NEXT: .param .align 32 .b8 test_v3i64_param_0[32]
; CHECK-DAG:  ld.param.b64     [[E2:%rd[0-9]+]], [test_v3i64_param_0+16];
; CHECK-DAG:  ld.param.v2.b64  {[[E0:%rd[0-9]+]], [[E1:%rd[0-9]+]]}, [test_v3i64_param_0];
; CHECK:      .param .align 32 .b8 param0[32];
; CHECK:      .param .align 32 .b8 retval0[32];
; CHECK-DAG:  st.param.v2.b64  [param0], {[[E0]], [[E1]]};
; CHECK-DAG:  st.param.b64     [param0+16], [[E2]];
; CHECK:      call.uni (retval0), test_v3i64,
; CHECK:      ld.param.v2.b64  {[[RE0:%rd[0-9]+]], [[RE1:%rd[0-9]+]]}, [retval0];
; CHECK:      ld.param.b64     [[RE2:%rd[0-9]+]], [retval0+16];
; CHECK-DAG:  st.param.v2.b64  [func_retval0], {[[RE0]], [[RE1]]};
; CHECK-DAG:  st.param.b64     [func_retval0+16], [[RE2]];
; CHECK-DAG:  st.param.v2.b64  [func_retval0], {[[RE0]], [[RE1]]};
; CHECK-DAG:  st.param.b64     [func_retval0+16], [[RE2]];
; CHECK-NEXT: ret;
define <3 x i64> @test_v3i64(<3 x i64> %a) {
       %r = tail call <3 x i64> @test_v3i64(<3 x i64> %a);
       ret <3 x i64> %r;
}

; For i64 vector loads are limited by PTX to 2 elements.
; CHECK: .func  (.param .align 32 .b8 func_retval0[32])
; CHECK-LABEL: test_v4i64(
; CHECK-NEXT: .param .align 32 .b8 test_v4i64_param_0[32]
; CHECK-DAG:  ld.param.v2.b64  {[[E2:%rd[0-9]+]], [[E3:%rd[0-9]+]]}, [test_v4i64_param_0+16];
; CHECK-DAG:  ld.param.v2.b64  {[[E0:%rd[0-9]+]], [[E1:%rd[0-9]+]]}, [test_v4i64_param_0];
; CHECK:      .param .align 32 .b8 param0[32];
; CHECK:      .param .align 32 .b8 retval0[32];
; CHECK-DAG:  st.param.v2.b64  [param0], {[[E0]], [[E1]]};
; CHECK-DAG:  st.param.v2.b64  [param0+16], {[[E2]], [[E3]]};
; CHECK:      call.uni (retval0), test_v4i64,
; CHECK:      ld.param.v2.b64  {[[RE0:%rd[0-9]+]], [[RE1:%rd[0-9]+]]}, [retval0];
; CHECK:      ld.param.v2.b64  {[[RE2:%rd[0-9]+]], [[RE3:%rd[0-9]+]]}, [retval0+16];
; CHECK-DAG:  st.param.v2.b64  [func_retval0+16], {[[RE2]], [[RE3]]};
; CHECK-DAG:  st.param.v2.b64  [func_retval0], {[[RE0]], [[RE1]]};
; CHECK-NEXT: ret;
define <4 x i64> @test_v4i64(<4 x i64> %a) {
       %r = tail call <4 x i64> @test_v4i64(<4 x i64> %a);
       ret <4 x i64> %r;
}

; Aggregates, on the other hand, do not get extended.

; CHECK: .func  (.param .align 1 .b8 func_retval0[1])
; CHECK-LABEL: test_s_i1(
; CHECK-NEXT: .align 1 .b8 test_s_i1_param_0[1]
; CHECK:      ld.param.b8 [[A:%rs[0-9]+]], [test_s_i1_param_0];
; CHECK:      .param .align 1 .b8 param0[1];
; CHECK:      .param .align 1 .b8 retval0[1];
; CHECK:      st.param.b8    [param0], [[A]]
; CHECK:      call.uni (retval0), test_s_i1,
; CHECK:      ld.param.b8    [[R:%rs[0-9]+]], [retval0];
; CHECK:      st.param.b8    [func_retval0], [[R]];
; CHECK-NEXT: ret;
define %s_i1 @test_s_i1(%s_i1 %a) {
       %r = tail call %s_i1 @test_s_i1(%s_i1 %a);
       ret %s_i1 %r;
}

; CHECK: .func  (.param .align 1 .b8 func_retval0[1])
; CHECK-LABEL: test_s_i8(
; CHECK-NEXT: .param .align 1 .b8 test_s_i8_param_0[1]
; CHECK:      ld.param.b8 [[A:%rs[0-9]+]], [test_s_i8_param_0];
; CHECK:      .param .align 1 .b8 param0[1];
; CHECK:      .param .align 1 .b8 retval0[1];
; CHECK:      st.param.b8    [param0], [[A]]
; CHECK:      call.uni (retval0), test_s_i8,
; CHECK:      ld.param.b8    [[R:%rs[0-9]+]], [retval0];
; CHECK:      st.param.b8    [func_retval0], [[R]];
; CHECK-NEXT: ret;
define %s_i8 @test_s_i8(%s_i8 %a) {
       %r = tail call %s_i8 @test_s_i8(%s_i8 %a);
       ret %s_i8 %r;
}

; CHECK: .func  (.param .align 2 .b8 func_retval0[2])
; CHECK-LABEL: test_s_i16(
; CHECK-NEXT: .param .align 2 .b8 test_s_i16_param_0[2]
; CHECK:      ld.param.b16 [[A:%rs[0-9]+]], [test_s_i16_param_0];
; CHECK:      .param .align 2 .b8 param0[2];
; CHECK:      .param .align 2 .b8 retval0[2];
; CHECK:      st.param.b16    [param0], [[A]]
; CHECK:      call.uni (retval0), test_s_i16,
; CHECK:      ld.param.b16    [[R:%rs[0-9]+]], [retval0];
; CHECK:      st.param.b16    [func_retval0], [[R]];
; CHECK-NEXT: ret;
define %s_i16 @test_s_i16(%s_i16 %a) {
       %r = tail call %s_i16 @test_s_i16(%s_i16 %a);
       ret %s_i16 %r;
}

; CHECK: .func  (.param .align 2 .b8 func_retval0[2])
; CHECK-LABEL: test_s_f16(
; CHECK-NEXT: .param .align 2 .b8 test_s_f16_param_0[2]
; CHECK:      ld.param.b16 [[A:%rs[0-9]+]], [test_s_f16_param_0];
; CHECK:      .param .align 2 .b8 param0[2];
; CHECK:      .param .align 2 .b8 retval0[2];
; CHECK:      st.param.b16    [param0], [[A]]
; CHECK:      call.uni (retval0), test_s_f16,
; CHECK:      ld.param.b16    [[R:%rs[0-9]+]], [retval0];
; CHECK:      st.param.b16    [func_retval0], [[R]];
; CHECK-NEXT: ret;
define %s_f16 @test_s_f16(%s_f16 %a) {
       %r = tail call %s_f16 @test_s_f16(%s_f16 %a);
       ret %s_f16 %r;
}

; CHECK: .func  (.param .align 4 .b8 func_retval0[4])
; CHECK-LABEL: test_s_i32(
; CHECK-NEXT: .param .align 4 .b8 test_s_i32_param_0[4]
; CHECK:      ld.param.b32    [[E:%r[0-9]+]], [test_s_i32_param_0];
; CHECK:      .param .align 4 .b8 param0[4]
; CHECK:      .param .align 4 .b8 retval0[4];
; CHECK:      st.param.b32    [param0], [[E]];
; CHECK:      call.uni (retval0), test_s_i32,
; CHECK:      ld.param.b32    [[R:%r[0-9]+]], [retval0];
; CHECK:      st.param.b32    [func_retval0], [[R]];
; CHECK-NEXT: ret;
define %s_i32 @test_s_i32(%s_i32 %a) {
       %r = tail call %s_i32 @test_s_i32(%s_i32 %a);
       ret %s_i32 %r;
}

; CHECK: .func  (.param .align 4 .b8 func_retval0[4])
; CHECK-LABEL: test_s_f32(
; CHECK-NEXT: .param .align 4 .b8 test_s_f32_param_0[4]
; CHECK:      ld.param.b32    [[E:%r[0-9]+]], [test_s_f32_param_0];
; CHECK:      .param .align 4 .b8 param0[4]
; CHECK:      .param .align 4 .b8 retval0[4];
; CHECK:      st.param.b32    [param0], [[E]];
; CHECK:      call.uni (retval0), test_s_f32,
; CHECK:      ld.param.b32    [[R:%r[0-9]+]], [retval0];
; CHECK:      st.param.b32    [func_retval0], [[R]];
; CHECK-NEXT: ret;
define %s_f32 @test_s_f32(%s_f32 %a) {
       %r = tail call %s_f32 @test_s_f32(%s_f32 %a);
       ret %s_f32 %r;
}

; CHECK: .func  (.param .align 8 .b8 func_retval0[8])
; CHECK-LABEL: test_s_i64(
; CHECK-NEXT: .param .align 8 .b8 test_s_i64_param_0[8]
; CHECK:      ld.param.b64    [[E:%rd[0-9]+]], [test_s_i64_param_0];
; CHECK:      .param .align 8 .b8 param0[8];
; CHECK:      .param .align 8 .b8 retval0[8];
; CHECK:      st.param.b64    [param0], [[E]];
; CHECK:      call.uni (retval0), test_s_i64,
; CHECK:      ld.param.b64    [[R:%rd[0-9]+]], [retval0];
; CHECK:      st.param.b64    [func_retval0], [[R]];
; CHECK-NEXT: ret;
define %s_i64 @test_s_i64(%s_i64 %a) {
       %r = tail call %s_i64 @test_s_i64(%s_i64 %a);
       ret %s_i64 %r;
}

; Fields that have different types, but identical sizes are not vectorized.
; CHECK: .func  (.param .align 8 .b8 func_retval0[24])
; CHECK-LABEL: test_s_i32f32(
; CHECK:        .param .align 8 .b8 test_s_i32f32_param_0[24]
; CHECK-DAG:    ld.param.b64    [[E4:%rd[0-9]+]], [test_s_i32f32_param_0+16];
; CHECK-DAG:    ld.param.b32    [[E3:%r[0-9]+]], [test_s_i32f32_param_0+12];
; CHECK-DAG:    ld.param.b32    [[E2:%r[0-9]+]], [test_s_i32f32_param_0+8];
; CHECK-DAG:    ld.param.b32    [[E1:%r[0-9]+]], [test_s_i32f32_param_0+4];
; CHECK-DAG:    ld.param.b32    [[E0:%r[0-9]+]], [test_s_i32f32_param_0];
; CHECK:        .param .align 8 .b8 param0[24];
; CHECK:        .param .align 8 .b8 retval0[24];
; CHECK-DAG:    st.param.b32    [param0], [[E0]];
; CHECK-DAG:    st.param.b32    [param0+4], [[E1]];
; CHECK-DAG:    st.param.b32    [param0+8], [[E2]];
; CHECK-DAG:    st.param.b32    [param0+12], [[E3]];
; CHECK-DAG:    st.param.b64    [param0+16], [[E4]];
; CHECK:        call.uni (retval0), test_s_i32f32,
; CHECK-DAG:    ld.param.b32    [[RE0:%r[0-9]+]], [retval0];
; CHECK-DAG:    ld.param.b32    [[RE1:%r[0-9]+]], [retval0+4];
; CHECK-DAG:    ld.param.b32    [[RE2:%r[0-9]+]], [retval0+8];
; CHECK-DAG:    ld.param.b32    [[RE3:%r[0-9]+]], [retval0+12];
; CHECK-DAG:    ld.param.b64    [[RE4:%rd[0-9]+]], [retval0+16];
; CHECK-DAG:    st.param.b32    [func_retval0], [[RE0]];
; CHECK-DAG:    st.param.b32    [func_retval0+4], [[RE1]];
; CHECK-DAG:    st.param.b32    [func_retval0+8], [[RE2]];
; CHECK-DAG:    st.param.b32    [func_retval0+12], [[RE3]];
; CHECK-DAG:    st.param.b64    [func_retval0+16], [[RE4]];
; CHECK:        ret;
define %s_i32f32 @test_s_i32f32(%s_i32f32 %a) {
       %r = tail call %s_i32f32 @test_s_i32f32(%s_i32f32 %a);
       ret %s_i32f32 %r;
}

; We do vectorize consecutive fields with matching types.
; CHECK:.visible .func  (.param .align 8 .b8 func_retval0[24])
; CHECK-LABEL: test_s_i32x4(
; CHECK:        .param .align 8 .b8 test_s_i32x4_param_0[24]
; CHECK-DAG:    ld.param.b64    [[RD1:%rd[0-9]+]], [test_s_i32x4_param_0+16];
; CHECK-DAG:    ld.param.v2.b32 {[[E2:%r[0-9]+]], [[E3:%r[0-9]+]]}, [test_s_i32x4_param_0+8];
; CHECK-DAG:    ld.param.v2.b32 {[[E0:%r[0-9]+]], [[E1:%r[0-9]+]]}, [test_s_i32x4_param_0];
; CHECK:        .param .align 8 .b8 param0[24];
; CHECK:        .param .align 8 .b8 retval0[24];
; CHECK-DAG:    st.param.v2.b32 [param0], {[[E0]], [[E1]]};
; CHECK-DAG:    st.param.v2.b32 [param0+8], {[[E2]], [[E3]]};
; CHECK-DAG:    st.param.b64    [param0+16], [[E4]];
; CHECK:        call.uni (retval0), test_s_i32x4,
; CHECK:        ld.param.v2.b32 {[[RE0:%r[0-9]+]], [[RE1:%r[0-9]+]]}, [retval0];
; CHECK:        ld.param.v2.b32 {[[RE2:%r[0-9]+]], [[RE3:%r[0-9]+]]}, [retval0+8];
; CHECK:        ld.param.b64    [[RE4:%rd[0-9]+]], [retval0+16];
; CHECK-DAG:    st.param.v2.b32 [func_retval0], {[[RE0]], [[RE1]]};
; CHECK-DAG:    st.param.v2.b32 [func_retval0+8], {[[RE2]], [[RE3]]};
; CHECK-DAG:    st.param.b64    [func_retval0+16], [[RE4]];
; CHECK:        ret;

define %s_i32x4 @test_s_i32x4(%s_i32x4 %a) {
       %r = tail call %s_i32x4 @test_s_i32x4(%s_i32x4 %a);
       ret %s_i32x4 %r;
}

; CHECK:.visible .func  (.param .align 8 .b8 func_retval0[32])
; CHECK-LABEL: test_s_i1i32x4(
; CHECK:        .param .align 8 .b8 test_s_i1i32x4_param_0[32]
; CHECK:        ld.param.b64    [[E5:%rd[0-9]+]], [test_s_i1i32x4_param_0+24];
; CHECK:        ld.param.b32    [[E4:%r[0-9]+]], [test_s_i1i32x4_param_0+16];
; CHECK:        ld.param.b32    [[E3:%r[0-9]+]], [test_s_i1i32x4_param_0+12];
; CHECK:        ld.param.b8     [[E2:%rs[0-9]+]], [test_s_i1i32x4_param_0+8];
; CHECK:        ld.param.v2.b32         {[[E0:%r[0-9]+]], [[E1:%r[0-9]+]]}, [test_s_i1i32x4_param_0];
; CHECK:        .param .align 8 .b8 param0[32];
; CHECK:        .param .align 8 .b8 retval0[32];
; CHECK-DAG:  st.param.v2.b32 [param0], {[[E0]], [[E1]]};
; CHECK-DAG:  st.param.b8     [param0+8], [[E2]];
; CHECK-DAG:  st.param.b32    [param0+12], [[E3]];
; CHECK-DAG:  st.param.b32    [param0+16], [[E4]];
; CHECK-DAG:  st.param.b64    [param0+24], [[E5]];
; CHECK:        call.uni (retval0), test_s_i1i32x4, (param0);
; CHECK:        ld.param.v2.b32 {[[RE0:%r[0-9]+]], [[RE1:%r[0-9]+]]}, [retval0];
; CHECK:        ld.param.b8     [[RE2:%rs[0-9]+]], [retval0+8];
; CHECK:        ld.param.b32    [[RE3:%r[0-9]+]], [retval0+12];
; CHECK:        ld.param.b32    [[RE4:%r[0-9]+]], [retval0+16];
; CHECK:        ld.param.b64    [[RE5:%rd[0-9]+]], [retval0+24];
; CHECK:        st.param.v2.b32 [func_retval0], {[[RE0]], [[RE1]]};
; CHECK:        st.param.b8     [func_retval0+8], [[RE2]];
; CHECK:        st.param.b32    [func_retval0+12], [[RE3]];
; CHECK:        st.param.b32    [func_retval0+16], [[RE4]];
; CHECK:        st.param.b64    [func_retval0+24], [[RE5]];
; CHECK:        ret;

define %s_i8i32x4 @test_s_i1i32x4(%s_i8i32x4 %a) {
       %r = tail call %s_i8i32x4 @test_s_i1i32x4(%s_i8i32x4 %a);
       ret %s_i8i32x4 %r;
}

; -- All loads/stores from parameters aligned by one must be done one
; -- byte at a time.
; CHECK:.visible .func  (.param .align 1 .b8 func_retval0[25])
; CHECK-LABEL: test_s_i1i32x4p(
; CHECK-DAG:        .param .align 1 .b8 test_s_i1i32x4p_param_0[25]
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+24];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+23];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+22];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+21];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+20];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+19];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+18];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+17];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+16];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+15];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+14];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+13];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+12];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+11];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+10];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+9];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+8];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+7];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+6];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+5];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+4];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+3];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+2];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0+1];
; CHECK-DAG:        ld.param.b8     %r{{.*}}, [test_s_i1i32x4p_param_0];
; CHECK:        .param .align 1 .b8 param0[25];
; CHECK:        .param .align 1 .b8 retval0[25];
; CHECK-DAG:        st.param.b8     [param0],
; CHECK-DAG:        st.param.b8     [param0+1],
; CHECK-DAG:        st.param.b8     [param0+2],
; CHECK-DAG:        st.param.b8     [param0+3],
; CHECK-DAG:        st.param.b8     [param0+4],
; CHECK-DAG:        st.param.b8     [param0+5],
; CHECK-DAG:        st.param.b8     [param0+6],
; CHECK-DAG:        st.param.b8     [param0+7],
; CHECK-DAG:        st.param.b8     [param0+8],
; CHECK-DAG:        st.param.b8     [param0+9],
; CHECK-DAG:        st.param.b8     [param0+10],
; CHECK-DAG:        st.param.b8     [param0+11],
; CHECK-DAG:        st.param.b8     [param0+12],
; CHECK-DAG:        st.param.b8     [param0+13],
; CHECK-DAG:        st.param.b8     [param0+14],
; CHECK-DAG:        st.param.b8     [param0+15],
; CHECK-DAG:        st.param.b8     [param0+16],
; CHECK-DAG:        st.param.b8     [param0+17],
; CHECK-DAG:        st.param.b8     [param0+18],
; CHECK-DAG:        st.param.b8     [param0+19],
; CHECK-DAG:        st.param.b8     [param0+20],
; CHECK-DAG:        st.param.b8     [param0+21],
; CHECK-DAG:        st.param.b8     [param0+22],
; CHECK-DAG:        st.param.b8     [param0+23],
; CHECK-DAG:        st.param.b8     [param0+24],
; CHECK:            call.uni (retval0), test_s_i1i32x4p, (param0);
; CHECK-DAG:        ld.param.b8     %rs{{[0-9]+}}, [retval0+8];
; CHECK-DAG:        ld.param.b8     %r{{[0-9]+}}, [retval0+3];
; CHECK-DAG:        ld.param.b8     %r{{[0-9]+}}, [retval0+2];
; CHECK-DAG:        ld.param.b8     %r{{[0-9]+}}, [retval0+1];
; CHECK-DAG:        ld.param.b8     %r{{[0-9]+}}, [retval0];
; CHECK-DAG:        ld.param.b8     %r{{[0-9]+}}, [retval0+7];
; CHECK-DAG:        ld.param.b8     %r{{[0-9]+}}, [retval0+6];
; CHECK-DAG:        ld.param.b8     %r{{[0-9]+}}, [retval0+5];
; CHECK-DAG:        ld.param.b8     %r{{[0-9]+}}, [retval0+4];
; CHECK-DAG:        ld.param.b8     %r{{[0-9]+}}, [retval0+12];
; CHECK-DAG:        ld.param.b8     %r{{[0-9]+}}, [retval0+11];
; CHECK-DAG:        ld.param.b8     %r{{[0-9]+}}, [retval0+10];
; CHECK-DAG:        ld.param.b8     %r{{[0-9]+}}, [retval0+9];
; CHECK-DAG:        ld.param.b8     %r{{[0-9]+}}, [retval0+16];
; CHECK-DAG:        ld.param.b8     %r{{[0-9]+}}, [retval0+15];
; CHECK-DAG:        ld.param.b8     %r{{[0-9]+}}, [retval0+14];
; CHECK-DAG:        ld.param.b8     %r{{[0-9]+}}, [retval0+13];
; CHECK-DAG:        ld.param.b8     %rd{{[0-9]+}}, [retval0+24];
; CHECK-DAG:        ld.param.b8     %rd{{[0-9]+}}, [retval0+23];
; CHECK-DAG:        ld.param.b8     %rd{{[0-9]+}}, [retval0+22];
; CHECK-DAG:        ld.param.b8     %rd{{[0-9]+}}, [retval0+21];
; CHECK-DAG:        ld.param.b8     %rd{{[0-9]+}}, [retval0+20];
; CHECK-DAG:        ld.param.b8     %rd{{[0-9]+}}, [retval0+19];
; CHECK-DAG:        ld.param.b8     %rd{{[0-9]+}}, [retval0+18];
; CHECK-DAG:        ld.param.b8     %rd{{[0-9]+}}, [retval0+17];
; CHECK:            } // callseq
; CHECK-DAG:        st.param.b8     [func_retval0],
; CHECK-DAG:        st.param.b8     [func_retval0+1],
; CHECK-DAG:        st.param.b8     [func_retval0+2],
; CHECK-DAG:        st.param.b8     [func_retval0+3],
; CHECK-DAG:        st.param.b8     [func_retval0+4],
; CHECK-DAG:        st.param.b8     [func_retval0+5],
; CHECK-DAG:        st.param.b8     [func_retval0+6],
; CHECK-DAG:        st.param.b8     [func_retval0+7],
; CHECK-DAG:        st.param.b8     [func_retval0+8],
; CHECK-DAG:        st.param.b8     [func_retval0+9],
; CHECK-DAG:        st.param.b8     [func_retval0+10],
; CHECK-DAG:        st.param.b8     [func_retval0+11],
; CHECK-DAG:        st.param.b8     [func_retval0+12],
; CHECK-DAG:        st.param.b8     [func_retval0+13],
; CHECK-DAG:        st.param.b8     [func_retval0+14],
; CHECK-DAG:        st.param.b8     [func_retval0+15],
; CHECK-DAG:        st.param.b8     [func_retval0+16],
; CHECK-DAG:        st.param.b8     [func_retval0+17],
; CHECK-DAG:        st.param.b8     [func_retval0+18],
; CHECK-DAG:        st.param.b8     [func_retval0+19],
; CHECK-DAG:        st.param.b8     [func_retval0+20],
; CHECK-DAG:        st.param.b8     [func_retval0+21],
; CHECK-DAG:        st.param.b8     [func_retval0+22],
; CHECK-DAG:        st.param.b8     [func_retval0+23],
; CHECK-DAG:        st.param.b8     [func_retval0+24],

define %s_i8i32x4p @test_s_i1i32x4p(%s_i8i32x4p %a) {
       %r = tail call %s_i8i32x4p @test_s_i1i32x4p(%s_i8i32x4p %a);
       ret %s_i8i32x4p %r;
}

; Check that we can vectorize loads that span multiple aggregate fields.
; CHECK:.visible .func  (.param .align 16 .b8 func_retval0[80])
; CHECK-LABEL: test_s_crossfield(
; CHECK:        .param .align 16 .b8 test_s_crossfield_param_0[80]
; CHECK:        ld.param.b32    [[E15:%r[0-9]+]], [test_s_crossfield_param_0+64];
; CHECK:        ld.param.v4.b32 {[[E11:%r[0-9]+]], [[E12:%r[0-9]+]], [[E13:%r[0-9]+]], [[E14:%r[0-9]+]]}, [test_s_crossfield_param_0+48];
; CHECK:        ld.param.v4.b32 {[[E7:%r[0-9]+]], [[E8:%r[0-9]+]], [[E9:%r[0-9]+]], [[E10:%r[0-9]+]]}, [test_s_crossfield_param_0+32];
; CHECK:        ld.param.v4.b32 {[[E3:%r[0-9]+]], [[E4:%r[0-9]+]], [[E5:%r[0-9]+]], [[E6:%r[0-9]+]]}, [test_s_crossfield_param_0+16];
; CHECK:        ld.param.b32    [[E2:%r[0-9]+]], [test_s_crossfield_param_0+8];
; CHECK:        ld.param.v2.b32 {[[E0:%r[0-9]+]], [[E1:%r[0-9]+]]}, [test_s_crossfield_param_0];
; CHECK:        .param .align 16 .b8 param0[80];
; CHECK:        .param .align 16 .b8 retval0[80];
; CHECK-DAG:    st.param.v2.b32 [param0], {[[E0]], [[E1]]};
; CHECK-DAG:    st.param.b32    [param0+8], [[E2]];
; CHECK-DAG:    st.param.v4.b32 [param0+16], {[[E3]], [[E4]], [[E5]], [[E6]]};
; CHECK-DAG:    st.param.v4.b32 [param0+32], {[[E7]], [[E8]], [[E9]], [[E10]]};
; CHECK-DAG:    st.param.v4.b32 [param0+48], {[[E11]], [[E12]], [[E13]], [[E14]]};
; CHECK-DAG:    st.param.b32    [param0+64], [[E15]];
; CHECK:        call.uni (retval0), test_s_crossfield,
; CHECK:        ld.param.v2.b32 {[[RE0:%r[0-9]+]], [[RE1:%r[0-9]+]]}, [retval0];
; CHECK:        ld.param.b32    [[RE2:%r[0-9]+]], [retval0+8];
; CHECK:        ld.param.v4.b32 {[[RE3:%r[0-9]+]], [[RE4:%r[0-9]+]], [[RE5:%r[0-9]+]], [[RE6:%r[0-9]+]]}, [retval0+16];
; CHECK:        ld.param.v4.b32 {[[RE7:%r[0-9]+]], [[RE8:%r[0-9]+]], [[RE9:%r[0-9]+]], [[RE10:%r[0-9]+]]}, [retval0+32];
; CHECK:        ld.param.v4.b32 {[[RE11:%r[0-9]+]], [[RE12:%r[0-9]+]], [[RE13:%r[0-9]+]], [[RE14:%r[0-9]+]]}, [retval0+48];
; CHECK:        ld.param.b32    [[RE15:%r[0-9]+]], [retval0+64];
; CHECK:        st.param.v2.b32 [func_retval0], {[[RE0]], [[RE1]]};
; CHECK:        st.param.b32    [func_retval0+8], [[RE2]];
; CHECK:        st.param.v4.b32 [func_retval0+16], {[[RE3]], [[RE4]], [[RE5]], [[RE6]]};
; CHECK:        st.param.v4.b32 [func_retval0+32], {[[RE7]], [[RE8]], [[RE9]], [[RE10]]};
; CHECK:        st.param.v4.b32 [func_retval0+48], {[[RE11]], [[RE12]], [[RE13]], [[RE14]]};
; CHECK:        st.param.b32    [func_retval0+64], [[RE15]];
; CHECK:        ret;

define %s_crossfield @test_s_crossfield(%s_crossfield %a) {
       %r = tail call %s_crossfield @test_s_crossfield(%s_crossfield %a);
       ret %s_crossfield %r;
}
