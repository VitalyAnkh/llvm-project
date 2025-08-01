// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py UTC_ARGS: --version 4
// REQUIRES: riscv-registered-target
// RUN: %clang_cc1 -triple riscv64 -target-feature +zve64x \
// RUN:   -target-feature +zvfbfmin -disable-O0-optnone \
// RUN:   -emit-llvm %s -o - | opt -S -passes=mem2reg | \
// RUN:   FileCheck --check-prefix=CHECK-RV64 %s

#include <riscv_vector.h>

// CHECK-RV64-LABEL: define dso_local target("riscv.vector.tuple", <vscale x 2 x i8>, 3) @test_vloxseg3ei16_v_bf16mf4x3(
// CHECK-RV64-SAME: ptr noundef [[RS1:%.*]], <vscale x 1 x i16> [[RS2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0:[0-9]+]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call target("riscv.vector.tuple", <vscale x 2 x i8>, 3) @llvm.riscv.vloxseg3.triscv.vector.tuple_nxv2i8_3t.p0.nxv1i16.i64(target("riscv.vector.tuple", <vscale x 2 x i8>, 3) poison, ptr [[RS1]], <vscale x 1 x i16> [[RS2]], i64 [[VL]], i64 4)
// CHECK-RV64-NEXT:    ret target("riscv.vector.tuple", <vscale x 2 x i8>, 3) [[TMP0]]
//
vbfloat16mf4x3_t test_vloxseg3ei16_v_bf16mf4x3(const __bf16 *rs1,
                                               vuint16mf4_t rs2, size_t vl) {
  return __riscv_vloxseg3ei16(rs1, rs2, vl);
}

// CHECK-RV64-LABEL: define dso_local target("riscv.vector.tuple", <vscale x 4 x i8>, 3) @test_vloxseg3ei16_v_bf16mf2x3(
// CHECK-RV64-SAME: ptr noundef [[RS1:%.*]], <vscale x 2 x i16> [[RS2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call target("riscv.vector.tuple", <vscale x 4 x i8>, 3) @llvm.riscv.vloxseg3.triscv.vector.tuple_nxv4i8_3t.p0.nxv2i16.i64(target("riscv.vector.tuple", <vscale x 4 x i8>, 3) poison, ptr [[RS1]], <vscale x 2 x i16> [[RS2]], i64 [[VL]], i64 4)
// CHECK-RV64-NEXT:    ret target("riscv.vector.tuple", <vscale x 4 x i8>, 3) [[TMP0]]
//
vbfloat16mf2x3_t test_vloxseg3ei16_v_bf16mf2x3(const __bf16 *rs1,
                                               vuint16mf2_t rs2, size_t vl) {
  return __riscv_vloxseg3ei16(rs1, rs2, vl);
}

// CHECK-RV64-LABEL: define dso_local target("riscv.vector.tuple", <vscale x 8 x i8>, 3) @test_vloxseg3ei16_v_bf16m1x3(
// CHECK-RV64-SAME: ptr noundef [[RS1:%.*]], <vscale x 4 x i16> [[RS2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call target("riscv.vector.tuple", <vscale x 8 x i8>, 3) @llvm.riscv.vloxseg3.triscv.vector.tuple_nxv8i8_3t.p0.nxv4i16.i64(target("riscv.vector.tuple", <vscale x 8 x i8>, 3) poison, ptr [[RS1]], <vscale x 4 x i16> [[RS2]], i64 [[VL]], i64 4)
// CHECK-RV64-NEXT:    ret target("riscv.vector.tuple", <vscale x 8 x i8>, 3) [[TMP0]]
//
vbfloat16m1x3_t test_vloxseg3ei16_v_bf16m1x3(const __bf16 *rs1, vuint16m1_t rs2,
                                             size_t vl) {
  return __riscv_vloxseg3ei16(rs1, rs2, vl);
}

// CHECK-RV64-LABEL: define dso_local target("riscv.vector.tuple", <vscale x 16 x i8>, 3) @test_vloxseg3ei16_v_bf16m2x3(
// CHECK-RV64-SAME: ptr noundef [[RS1:%.*]], <vscale x 8 x i16> [[RS2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call target("riscv.vector.tuple", <vscale x 16 x i8>, 3) @llvm.riscv.vloxseg3.triscv.vector.tuple_nxv16i8_3t.p0.nxv8i16.i64(target("riscv.vector.tuple", <vscale x 16 x i8>, 3) poison, ptr [[RS1]], <vscale x 8 x i16> [[RS2]], i64 [[VL]], i64 4)
// CHECK-RV64-NEXT:    ret target("riscv.vector.tuple", <vscale x 16 x i8>, 3) [[TMP0]]
//
vbfloat16m2x3_t test_vloxseg3ei16_v_bf16m2x3(const __bf16 *rs1, vuint16m2_t rs2,
                                             size_t vl) {
  return __riscv_vloxseg3ei16(rs1, rs2, vl);
}

// CHECK-RV64-LABEL: define dso_local target("riscv.vector.tuple", <vscale x 2 x i8>, 3) @test_vloxseg3ei16_v_bf16mf4x3_m(
// CHECK-RV64-SAME: <vscale x 1 x i1> [[VM:%.*]], ptr noundef [[RS1:%.*]], <vscale x 1 x i16> [[RS2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call target("riscv.vector.tuple", <vscale x 2 x i8>, 3) @llvm.riscv.vloxseg3.mask.triscv.vector.tuple_nxv2i8_3t.p0.nxv1i16.nxv1i1.i64(target("riscv.vector.tuple", <vscale x 2 x i8>, 3) poison, ptr [[RS1]], <vscale x 1 x i16> [[RS2]], <vscale x 1 x i1> [[VM]], i64 [[VL]], i64 3, i64 4)
// CHECK-RV64-NEXT:    ret target("riscv.vector.tuple", <vscale x 2 x i8>, 3) [[TMP0]]
//
vbfloat16mf4x3_t test_vloxseg3ei16_v_bf16mf4x3_m(vbool64_t vm,
                                                 const __bf16 *rs1,
                                                 vuint16mf4_t rs2, size_t vl) {
  return __riscv_vloxseg3ei16(vm, rs1, rs2, vl);
}

// CHECK-RV64-LABEL: define dso_local target("riscv.vector.tuple", <vscale x 4 x i8>, 3) @test_vloxseg3ei16_v_bf16mf2x3_m(
// CHECK-RV64-SAME: <vscale x 2 x i1> [[VM:%.*]], ptr noundef [[RS1:%.*]], <vscale x 2 x i16> [[RS2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call target("riscv.vector.tuple", <vscale x 4 x i8>, 3) @llvm.riscv.vloxseg3.mask.triscv.vector.tuple_nxv4i8_3t.p0.nxv2i16.nxv2i1.i64(target("riscv.vector.tuple", <vscale x 4 x i8>, 3) poison, ptr [[RS1]], <vscale x 2 x i16> [[RS2]], <vscale x 2 x i1> [[VM]], i64 [[VL]], i64 3, i64 4)
// CHECK-RV64-NEXT:    ret target("riscv.vector.tuple", <vscale x 4 x i8>, 3) [[TMP0]]
//
vbfloat16mf2x3_t test_vloxseg3ei16_v_bf16mf2x3_m(vbool32_t vm,
                                                 const __bf16 *rs1,
                                                 vuint16mf2_t rs2, size_t vl) {
  return __riscv_vloxseg3ei16(vm, rs1, rs2, vl);
}

// CHECK-RV64-LABEL: define dso_local target("riscv.vector.tuple", <vscale x 8 x i8>, 3) @test_vloxseg3ei16_v_bf16m1x3_m(
// CHECK-RV64-SAME: <vscale x 4 x i1> [[VM:%.*]], ptr noundef [[RS1:%.*]], <vscale x 4 x i16> [[RS2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call target("riscv.vector.tuple", <vscale x 8 x i8>, 3) @llvm.riscv.vloxseg3.mask.triscv.vector.tuple_nxv8i8_3t.p0.nxv4i16.nxv4i1.i64(target("riscv.vector.tuple", <vscale x 8 x i8>, 3) poison, ptr [[RS1]], <vscale x 4 x i16> [[RS2]], <vscale x 4 x i1> [[VM]], i64 [[VL]], i64 3, i64 4)
// CHECK-RV64-NEXT:    ret target("riscv.vector.tuple", <vscale x 8 x i8>, 3) [[TMP0]]
//
vbfloat16m1x3_t test_vloxseg3ei16_v_bf16m1x3_m(vbool16_t vm, const __bf16 *rs1,
                                               vuint16m1_t rs2, size_t vl) {
  return __riscv_vloxseg3ei16(vm, rs1, rs2, vl);
}

// CHECK-RV64-LABEL: define dso_local target("riscv.vector.tuple", <vscale x 16 x i8>, 3) @test_vloxseg3ei16_v_bf16m2x3_m(
// CHECK-RV64-SAME: <vscale x 8 x i1> [[VM:%.*]], ptr noundef [[RS1:%.*]], <vscale x 8 x i16> [[RS2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call target("riscv.vector.tuple", <vscale x 16 x i8>, 3) @llvm.riscv.vloxseg3.mask.triscv.vector.tuple_nxv16i8_3t.p0.nxv8i16.nxv8i1.i64(target("riscv.vector.tuple", <vscale x 16 x i8>, 3) poison, ptr [[RS1]], <vscale x 8 x i16> [[RS2]], <vscale x 8 x i1> [[VM]], i64 [[VL]], i64 3, i64 4)
// CHECK-RV64-NEXT:    ret target("riscv.vector.tuple", <vscale x 16 x i8>, 3) [[TMP0]]
//
vbfloat16m2x3_t test_vloxseg3ei16_v_bf16m2x3_m(vbool8_t vm, const __bf16 *rs1,
                                               vuint16m2_t rs2, size_t vl) {
  return __riscv_vloxseg3ei16(vm, rs1, rs2, vl);
}
