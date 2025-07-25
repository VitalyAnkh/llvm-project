; RUN: opt < %s -msan-check-access-address=0 -S -passes=msan 2>&1 | FileCheck %s "--check-prefixes=CHECK,INLINE"
; RUN: opt < %s -msan-check-access-address=0 -msan-poison-stack-with-call=1 -S -passes=msan 2>&1 | FileCheck %s "--check-prefixes=CHECK,CALL"
; RUN: opt < %s -msan-check-access-address=0 -msan-track-origins=1 -S -passes=msan 2>&1 | FileCheck %s "--check-prefixes=CHECK,ORIGIN"
; RUN: opt < %s -msan-check-access-address=0 -msan-track-origins=2 -S -passes=msan 2>&1 | FileCheck %s "--check-prefixes=CHECK,ORIGIN"
; RUN: opt < %s -msan-check-access-address=0 -msan-track-origins=2 -msan-print-stack-names=false -S -passes=msan 2>&1 | FileCheck %s "--check-prefixes=CHECK,ORIGIN-LEAN"
; RUN: opt < %s -S -passes="msan<kernel>" 2>&1 | FileCheck %s "--check-prefixes=CHECK,KMSAN"
; RUN: opt < %s -msan-kernel=1 -S -passes=msan 2>&1 | FileCheck %s "--check-prefixes=CHECK,KMSAN"

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; ORIGIN: [[IDPTR:@[0-9]+]] = private global i32 0
; ORIGIN-LEAN: [[IDPTR:@[0-9]+]] = private global i32 0
; ORIGIN: [[DESCR:@[0-9]+]] = private constant [9 x i8] c"unique_x\00"

define void @static() sanitize_memory {
entry:
  %unique_x = alloca i32, align 4
  ret void
}

; CHECK-LABEL: define void @static(
; INLINE: call void @llvm.memset.p0.i64(ptr align 4 {{.*}}, i8 -1, i64 4, i1 false)
; CALL: call void @__msan_poison_stack(ptr {{.*}}, i64 4)
; ORIGIN: call void @__msan_set_alloca_origin_with_descr(ptr %unique_x, i64 4, ptr [[IDPTR]], ptr [[DESCR]])
; ORIGIN-LEAN: call void @__msan_set_alloca_origin_no_descr(ptr %unique_x, i64 4, ptr [[IDPTR]])
; KMSAN: call void @__msan_poison_alloca(ptr {{.*}}, i64 4,
; CHECK: ret void


define void @dynamic() sanitize_memory {
entry:
  br label %l
l:
  %x = alloca i32, align 4
  ret void
}

; CHECK-LABEL: define void @dynamic(
; INLINE: call void @llvm.memset.p0.i64(ptr align 4 {{.*}}, i8 -1, i64 4, i1 false)
; CALL: call void @__msan_poison_stack(ptr {{.*}}, i64 4)
; ORIGIN: call void @__msan_set_alloca_origin_with_descr(ptr {{.*}}, i64 4,
; ORIGIN-LEAN: call void @__msan_set_alloca_origin_no_descr(ptr {{.*}}, i64 4,
; KMSAN: call void @__msan_poison_alloca(ptr {{.*}}, i64 4,
; CHECK: ret void

define void @array() sanitize_memory {
entry:
  %x = alloca i32, i64 5, align 4
  ret void
}

; CHECK-LABEL: define void @array(
; INLINE: call void @llvm.memset.p0.i64(ptr align 4 {{.*}}, i8 -1, i64 20, i1 false)
; CALL: call void @__msan_poison_stack(ptr {{.*}}, i64 20)
; ORIGIN: call void @__msan_set_alloca_origin_with_descr(ptr {{.*}}, i64 20,
; ORIGIN-LEAN: call void @__msan_set_alloca_origin_no_descr(ptr {{.*}}, i64 20,
; KMSAN: call void @__msan_poison_alloca(ptr {{.*}}, i64 20,
; CHECK: ret void

define void @array32() sanitize_memory {
entry:
  %x = alloca i32, i32 5, align 4
  ret void
}

; CHECK-LABEL: define void @array32(
; INLINE: call void @llvm.memset.p0.i64(ptr align 4 {{.*}}, i8 -1, i64 20, i1 false)
; CALL: call void @__msan_poison_stack(ptr {{.*}}, i64 20)
; ORIGIN: call void @__msan_set_alloca_origin_with_descr(ptr {{.*}}, i64 20,
; ORIGIN-LEAN: call void @__msan_set_alloca_origin_no_descr(ptr {{.*}}, i64 20,
; KMSAN: call void @__msan_poison_alloca(ptr {{.*}}, i64 20,
; CHECK: ret void

define void @array_non_const(i64 %cnt) sanitize_memory {
entry:
  %x = alloca i32, i64 %cnt, align 4
  ret void
}

; CHECK-LABEL: define void @array_non_const(
; CHECK: %[[A:.*]] = mul i64 4, %cnt
; INLINE: call void @llvm.memset.p0.i64(ptr align 4 {{.*}}, i8 -1, i64 %[[A]], i1 false)
; CALL: call void @__msan_poison_stack(ptr {{.*}}, i64 %[[A]])
; ORIGIN: call void @__msan_set_alloca_origin_with_descr(ptr {{.*}}, i64 %[[A]],
; ORIGIN-LEAN: call void @__msan_set_alloca_origin_no_descr(ptr {{.*}}, i64 %[[A]],
; KMSAN: call void @__msan_poison_alloca(ptr {{.*}}, i64 %[[A]],
; CHECK: ret void

define void @array_non_const32(i32 %cnt) sanitize_memory {
entry:
  %x = alloca i32, i32 %cnt, align 4
  ret void
}

; CHECK-LABEL: define void @array_non_const32(
; CHECK: %[[Z:.*]] = zext i32 %cnt to i64
; CHECK: %[[A:.*]] = mul i64 4, %[[Z]]
; INLINE: call void @llvm.memset.p0.i64(ptr align 4 {{.*}}, i8 -1, i64 %[[A]], i1 false)
; CALL: call void @__msan_poison_stack(ptr {{.*}}, i64 %[[A]])
; ORIGIN: call void @__msan_set_alloca_origin_with_descr(ptr {{.*}}, i64 %[[A]],
; ORIGIN-LEAN: call void @__msan_set_alloca_origin_no_descr(ptr {{.*}}, i64 %[[A]],
; KMSAN: call void @__msan_poison_alloca(ptr {{.*}}, i64 %[[A]],
; CHECK: ret void

; Check that the local is unpoisoned in the absence of sanitize_memory
define void @unpoison_local() {
entry:
  %x = alloca i32, i64 5, align 4
  ret void
}

; CHECK-LABEL: define void @unpoison_local(
; INLINE: call void @llvm.memset.p0.i64(ptr align 4 {{.*}}, i8 0, i64 20, i1 false)
; CALL: call void @llvm.memset.p0.i64(ptr align 4 {{.*}}, i8 0, i64 20, i1 false)
; ORIGIN-NOT: call void @__msan_set_alloca_origin_with_descr(ptr {{.*}}, i64 20,
; ORIGIN-LEAN-NOT: call void @__msan_set_alloca_origin_no_descr(ptr {{.*}}, i64 20,
; KMSAN: call void @__msan_unpoison_alloca(ptr {{.*}}, i64 20)
; CHECK: ret void

; Check that every llvm.lifetime.start() causes poisoning of locals.
define void @lifetime_start() sanitize_memory {
entry:
  %x = alloca i32, align 4
  br label %another_bb

another_bb:
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %x)
  store i32 7, ptr %x
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %x)
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %x)
  store i32 8, ptr %x
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %x)
  ret void
}

; CHECK-LABEL: define void @lifetime_start(
; CHECK-LABEL: entry:
; CHECK: %x = alloca i32
; CHECK-LABEL: another_bb:

; CHECK: call void @llvm.lifetime.start
; INLINE: call void @llvm.memset.p0.i64(ptr align 4 {{.*}}, i8 -1, i64 4, i1 false)
; CALL: call void @__msan_poison_stack(ptr {{.*}}, i64 4)
; ORIGIN: call void @__msan_set_alloca_origin_with_descr(ptr {{.*}}, i64 4,
; ORIGIN-LEAN: call void @__msan_set_alloca_origin_no_descr(ptr {{.*}}, i64 4,
; KMSAN: call void @__msan_poison_alloca(ptr {{.*}}, i64 4,

; CHECK: call void @llvm.lifetime.start
; INLINE: call void @llvm.memset.p0.i64(ptr align 4 {{.*}}, i8 -1, i64 4, i1 false)
; CALL: call void @__msan_poison_stack(ptr {{.*}}, i64 4)
; ORIGIN: call void @__msan_set_alloca_origin_with_descr(ptr {{.*}}, i64 4,
; ORIGIN-LEAN: call void @__msan_set_alloca_origin_no_descr(ptr {{.*}}, i64 4,
; KMSAN: call void @__msan_poison_alloca(ptr {{.*}}, i64 4,
; CHECK: ret void

; Make sure variable-length arrays are handled correctly.
define void @lifetime_start_var(i64 %cnt) sanitize_memory {
entry:
  %x = alloca i32, i64 %cnt, align 4
  call void @llvm.lifetime.start.p0(i64 -1, ptr nonnull %x)
  call void @llvm.lifetime.end.p0(i64 -1, ptr nonnull %x)
  ret void
}

; CHECK-LABEL: define void @lifetime_start_var(
; CHECK-LABEL: entry:
; CHECK: %x = alloca i32, i64 %cnt
; CHECK: call void @llvm.lifetime.start
; CHECK: %[[A:.*]] = mul i64 4, %cnt
; INLINE: call void @llvm.memset.p0.i64(ptr align 4 {{.*}}, i8 -1, i64 %[[A]], i1 false)
; CALL: call void @__msan_poison_stack(ptr {{.*}}, i64 %[[A]])
; ORIGIN: call void @__msan_set_alloca_origin_with_descr(ptr {{.*}}, i64 %[[A]],
; ORIGIN-LEAN: call void @__msan_set_alloca_origin_no_descr(ptr {{.*}}, i64 %[[A]],
; KMSAN: call void @__msan_poison_alloca(ptr {{.*}}, i64 %[[A]],
; CHECK: call void @llvm.lifetime.end
; CHECK: ret void

declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture)
