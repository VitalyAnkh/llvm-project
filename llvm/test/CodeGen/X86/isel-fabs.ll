; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc < %s -mtriple=x86_64-- -mattr=-x87,+sse,+sse2 | FileCheck %s --check-prefixes=X64
; RUN: llc < %s -mtriple=x86_64-- -mattr=-x87,+sse,+sse2 -fast-isel -fast-isel-abort=1 | FileCheck %s --check-prefixes=X64
; RUN: llc < %s -mtriple=x86_64-- -mattr=-x87,+sse,+sse2 -global-isel -global-isel-abort=1 | FileCheck %s --check-prefixes=GISEL-X64
; RUN: llc < %s -mtriple=i686-- -mattr=-x87,+sse,+sse2 | FileCheck %s --check-prefixes=X86
; RUN: llc < %s -mtriple=i686-- -mattr=-x87,+sse,+sse2 -fast-isel -fast-isel-abort=1 | FileCheck %s --check-prefixes=FASTISEL-X86
; RUN: llc < %s -mtriple=i686-- -mattr=-x87,+sse,+sse2 -global-isel -global-isel-abort=1 | FileCheck %s --check-prefixes=GISEL-X86

define float @test_float_abs(float %arg) nounwind {
; X64-LABEL: test_float_abs:
; X64:       # %bb.0:
; X64-NEXT:    andps {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0
; X64-NEXT:    retq
;
; GISEL-X64-LABEL: test_float_abs:
; GISEL-X64:       # %bb.0:
; GISEL-X64-NEXT:    movd %xmm0, %eax
; GISEL-X64-NEXT:    andl $2147483647, %eax # imm = 0x7FFFFFFF
; GISEL-X64-NEXT:    movd %eax, %xmm0
; GISEL-X64-NEXT:    retq
;
; X86-LABEL: test_float_abs:
; X86:       # %bb.0:
; X86-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X86-NEXT:    pand {{\.?LCPI[0-9]+_[0-9]+}}, %xmm0
; X86-NEXT:    movd %xmm0, %eax
; X86-NEXT:    retl
;
; FASTISEL-X86-LABEL: test_float_abs:
; FASTISEL-X86:       # %bb.0:
; FASTISEL-X86-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; FASTISEL-X86-NEXT:    pand {{\.?LCPI[0-9]+_[0-9]+}}, %xmm0
; FASTISEL-X86-NEXT:    movd %xmm0, %eax
; FASTISEL-X86-NEXT:    retl
;
; GISEL-X86-LABEL: test_float_abs:
; GISEL-X86:       # %bb.0:
; GISEL-X86-NEXT:    movl $2147483647, %eax # imm = 0x7FFFFFFF
; GISEL-X86-NEXT:    andl {{[0-9]+}}(%esp), %eax
; GISEL-X86-NEXT:    retl
    %abs = tail call float @llvm.fabs.f32(float %arg)
    ret float %abs
}

define double @test_double_abs(double %arg) nounwind {
; X64-LABEL: test_double_abs:
; X64:       # %bb.0:
; X64-NEXT:    andps {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0
; X64-NEXT:    retq
;
; GISEL-X64-LABEL: test_double_abs:
; GISEL-X64:       # %bb.0:
; GISEL-X64-NEXT:    movabsq $9223372036854775807, %rax # imm = 0x7FFFFFFFFFFFFFFF
; GISEL-X64-NEXT:    movq %xmm0, %rcx
; GISEL-X64-NEXT:    andq %rax, %rcx
; GISEL-X64-NEXT:    movq %rcx, %xmm0
; GISEL-X64-NEXT:    retq
;
; X86-LABEL: test_double_abs:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl $2147483647, %edx # imm = 0x7FFFFFFF
; X86-NEXT:    andl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    retl
;
; FASTISEL-X86-LABEL: test_double_abs:
; FASTISEL-X86:       # %bb.0:
; FASTISEL-X86-NEXT:    pushl %ebp
; FASTISEL-X86-NEXT:    movl %esp, %ebp
; FASTISEL-X86-NEXT:    andl $-8, %esp
; FASTISEL-X86-NEXT:    subl $8, %esp
; FASTISEL-X86-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; FASTISEL-X86-NEXT:    andps {{\.?LCPI[0-9]+_[0-9]+}}, %xmm0
; FASTISEL-X86-NEXT:    movlps %xmm0, (%esp)
; FASTISEL-X86-NEXT:    movl (%esp), %eax
; FASTISEL-X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; FASTISEL-X86-NEXT:    movl %ebp, %esp
; FASTISEL-X86-NEXT:    popl %ebp
; FASTISEL-X86-NEXT:    retl
;
; GISEL-X86-LABEL: test_double_abs:
; GISEL-X86:       # %bb.0:
; GISEL-X86-NEXT:    movl $-1, %eax
; GISEL-X86-NEXT:    movl $2147483647, %edx # imm = 0x7FFFFFFF
; GISEL-X86-NEXT:    andl {{[0-9]+}}(%esp), %eax
; GISEL-X86-NEXT:    andl {{[0-9]+}}(%esp), %edx
; GISEL-X86-NEXT:    retl
    %abs = tail call double @llvm.fabs.f64(double %arg)
    ret double %abs
}
