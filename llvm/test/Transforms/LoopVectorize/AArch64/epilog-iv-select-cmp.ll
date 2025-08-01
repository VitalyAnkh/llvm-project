; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --check-globals none --version 5
; RUN: opt -passes=loop-vectorize -mtriple=arm64-apple-macosx -S %s | FileCheck %s

define i8 @select_icmp_var_start(ptr %a, i8 %n, i8 %start) {
; CHECK-LABEL: define i8 @select_icmp_var_start(
; CHECK-SAME: ptr [[A:%.*]], i8 [[N:%.*]], i8 [[START:%.*]]) {
; CHECK-NEXT:  [[ITER_CHECK:.*]]:
; CHECK-NEXT:    [[TMP0:%.*]] = add i8 [[N]], -1
; CHECK-NEXT:    [[TMP1:%.*]] = zext i8 [[TMP0]] to i32
; CHECK-NEXT:    [[TMP2:%.*]] = add nuw nsw i32 [[TMP1]], 1
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i32 [[TMP2]], 8
; CHECK-NEXT:    [[FR:%.*]] = freeze i8 [[START]]
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label %[[VEC_EPILOG_SCALAR_PH:.*]], label %[[VECTOR_MAIN_LOOP_ITER_CHECK:.*]]
; CHECK:       [[VECTOR_MAIN_LOOP_ITER_CHECK]]:
; CHECK-NEXT:    [[MIN_ITERS_CHECK1:%.*]] = icmp ult i32 [[TMP2]], 32
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK1]], label %[[VEC_EPILOG_PH:.*]], label %[[VECTOR_PH:.*]]
; CHECK:       [[VECTOR_PH]]:
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i32 [[TMP2]], 32
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i32 [[TMP2]], [[N_MOD_VF]]
; CHECK-NEXT:    [[TMP3:%.*]] = trunc i32 [[N_VEC]] to i8
; CHECK-NEXT:    br label %[[VECTOR_BODY:.*]]
; CHECK:       [[VECTOR_BODY]]:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i32 [ 0, %[[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], %[[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_IND:%.*]] = phi <16 x i8> [ <i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 14, i8 15>, %[[VECTOR_PH]] ], [ [[VEC_IND_NEXT:%.*]], %[[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <16 x i8> [ splat (i8 -128), %[[VECTOR_PH]] ], [ [[TMP10:%.*]], %[[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI2:%.*]] = phi <16 x i8> [ splat (i8 -128), %[[VECTOR_PH]] ], [ [[TMP11:%.*]], %[[VECTOR_BODY]] ]
; CHECK-NEXT:    [[STEP_ADD:%.*]] = add <16 x i8> [[VEC_IND]], splat (i8 16)
; CHECK-NEXT:    [[INDEX4:%.*]] = trunc i32 [[INDEX]] to i8
; CHECK-NEXT:    [[TMP8:%.*]] = getelementptr inbounds i8, ptr [[A]], i8 [[INDEX4]]
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr inbounds i8, ptr [[TMP8]], i32 16
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <16 x i8>, ptr [[TMP8]], align 8
; CHECK-NEXT:    [[WIDE_LOAD3:%.*]] = load <16 x i8>, ptr [[TMP7]], align 8
; CHECK-NEXT:    [[TMP17:%.*]] = icmp eq <16 x i8> [[WIDE_LOAD]], splat (i8 3)
; CHECK-NEXT:    [[TMP23:%.*]] = icmp eq <16 x i8> [[WIDE_LOAD3]], splat (i8 3)
; CHECK-NEXT:    [[TMP10]] = select <16 x i1> [[TMP17]], <16 x i8> [[VEC_IND]], <16 x i8> [[VEC_PHI]]
; CHECK-NEXT:    [[TMP11]] = select <16 x i1> [[TMP23]], <16 x i8> [[STEP_ADD]], <16 x i8> [[VEC_PHI2]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i32 [[INDEX]], 32
; CHECK-NEXT:    [[VEC_IND_NEXT]] = add <16 x i8> [[STEP_ADD]], splat (i8 16)
; CHECK-NEXT:    [[TMP12:%.*]] = icmp eq i32 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP12]], label %[[MIDDLE_BLOCK:.*]], label %[[VECTOR_BODY]], !llvm.loop [[LOOP0:![0-9]+]]
; CHECK:       [[MIDDLE_BLOCK]]:
; CHECK-NEXT:    [[RDX_MINMAX:%.*]] = call <16 x i8> @llvm.smax.v16i8(<16 x i8> [[TMP10]], <16 x i8> [[TMP11]])
; CHECK-NEXT:    [[TMP13:%.*]] = call i8 @llvm.vector.reduce.smax.v16i8(<16 x i8> [[RDX_MINMAX]])
; CHECK-NEXT:    [[RDX_SELECT_CMP12:%.*]] = icmp ne i8 [[TMP13]], -128
; CHECK-NEXT:    [[RDX_SELECT:%.*]] = select i1 [[RDX_SELECT_CMP12]], i8 [[TMP13]], i8 [[FR]]
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i32 [[TMP2]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label %[[EXIT:.*]], label %[[VEC_EPILOG_ITER_CHECK:.*]]
; CHECK:       [[VEC_EPILOG_ITER_CHECK]]:
; CHECK-NEXT:    [[IND_END:%.*]] = trunc i32 [[N_VEC]] to i8
; CHECK-NEXT:    [[N_VEC_REMAINING:%.*]] = sub i32 [[TMP2]], [[N_VEC]]
; CHECK-NEXT:    [[MIN_EPILOG_ITERS_CHECK:%.*]] = icmp ult i32 [[N_VEC_REMAINING]], 8
; CHECK-NEXT:    br i1 [[MIN_EPILOG_ITERS_CHECK]], label %[[VEC_EPILOG_SCALAR_PH]], label %[[VEC_EPILOG_PH]]
; CHECK:       [[VEC_EPILOG_PH]]:
; CHECK-NEXT:    [[VEC_EPILOG_RESUME_VAL:%.*]] = phi i32 [ [[N_VEC]], %[[VEC_EPILOG_ITER_CHECK]] ], [ 0, %[[VECTOR_MAIN_LOOP_ITER_CHECK]] ]
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i8 [ [[TMP3]], %[[VEC_EPILOG_ITER_CHECK]] ], [ 0, %[[VECTOR_MAIN_LOOP_ITER_CHECK]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX:%.*]] = phi i8 [ [[RDX_SELECT]], %[[VEC_EPILOG_ITER_CHECK]] ], [ [[FR]], %[[VECTOR_MAIN_LOOP_ITER_CHECK]] ]
; CHECK-NEXT:    [[TMP14:%.*]] = icmp eq i8 [[BC_MERGE_RDX]], [[FR]]
; CHECK-NEXT:    [[TMP15:%.*]] = select i1 [[TMP14]], i8 -128, i8 [[BC_MERGE_RDX]]
; CHECK-NEXT:    [[N_MOD_VF4:%.*]] = urem i32 [[TMP2]], 8
; CHECK-NEXT:    [[N_VEC5:%.*]] = sub i32 [[TMP2]], [[N_MOD_VF4]]
; CHECK-NEXT:    [[TMP16:%.*]] = trunc i32 [[N_VEC5]] to i8
; CHECK-NEXT:    [[DOTSPLATINSERT:%.*]] = insertelement <8 x i8> poison, i8 [[TMP15]], i64 0
; CHECK-NEXT:    [[DOTSPLAT:%.*]] = shufflevector <8 x i8> [[DOTSPLATINSERT]], <8 x i8> poison, <8 x i32> zeroinitializer
; CHECK-NEXT:    [[DOTSPLATINSERT10:%.*]] = insertelement <8 x i8> poison, i8 [[BC_RESUME_VAL]], i64 0
; CHECK-NEXT:    [[DOTSPLAT11:%.*]] = shufflevector <8 x i8> [[DOTSPLATINSERT10]], <8 x i8> poison, <8 x i32> zeroinitializer
; CHECK-NEXT:    [[INDUCTION:%.*]] = add <8 x i8> [[DOTSPLAT11]], <i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7>
; CHECK-NEXT:    br label %[[VEC_EPILOG_VECTOR_BODY:.*]]
; CHECK:       [[VEC_EPILOG_VECTOR_BODY]]:
; CHECK-NEXT:    [[INDEX6:%.*]] = phi i32 [ [[VEC_EPILOG_RESUME_VAL]], %[[VEC_EPILOG_PH]] ], [ [[INDEX_NEXT13:%.*]], %[[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_IND7:%.*]] = phi <8 x i8> [ [[INDUCTION]], %[[VEC_EPILOG_PH]] ], [ [[VEC_IND_NEXT8:%.*]], %[[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI9:%.*]] = phi <8 x i8> [ [[DOTSPLAT]], %[[VEC_EPILOG_PH]] ], [ [[TMP20:%.*]], %[[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[IV:%.*]] = trunc i32 [[INDEX6]] to i8
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr inbounds i8, ptr [[A]], i8 [[IV]]
; CHECK-NEXT:    [[WIDE_LOAD12:%.*]] = load <8 x i8>, ptr [[GEP]], align 8
; CHECK-NEXT:    [[TMP19:%.*]] = icmp eq <8 x i8> [[WIDE_LOAD12]], splat (i8 3)
; CHECK-NEXT:    [[TMP20]] = select <8 x i1> [[TMP19]], <8 x i8> [[VEC_IND7]], <8 x i8> [[VEC_PHI9]]
; CHECK-NEXT:    [[INDEX_NEXT13]] = add nuw i32 [[INDEX6]], 8
; CHECK-NEXT:    [[VEC_IND_NEXT8]] = add <8 x i8> [[VEC_IND7]], splat (i8 8)
; CHECK-NEXT:    [[TMP21:%.*]] = icmp eq i32 [[INDEX_NEXT13]], [[N_VEC5]]
; CHECK-NEXT:    br i1 [[TMP21]], label %[[VEC_EPILOG_MIDDLE_BLOCK:.*]], label %[[VEC_EPILOG_VECTOR_BODY]], !llvm.loop [[LOOP3:![0-9]+]]
; CHECK:       [[VEC_EPILOG_MIDDLE_BLOCK]]:
; CHECK-NEXT:    [[TMP22:%.*]] = call i8 @llvm.vector.reduce.smax.v8i8(<8 x i8> [[TMP20]])
; CHECK-NEXT:    [[RDX_SELECT_CMP14:%.*]] = icmp ne i8 [[TMP22]], -128
; CHECK-NEXT:    [[RDX_SELECT15:%.*]] = select i1 [[RDX_SELECT_CMP14]], i8 [[TMP22]], i8 [[FR]]
; CHECK-NEXT:    [[CMP_N16:%.*]] = icmp eq i32 [[TMP2]], [[N_VEC5]]
; CHECK-NEXT:    br i1 [[CMP_N16]], label %[[EXIT]], label %[[VEC_EPILOG_SCALAR_PH]]
; CHECK:       [[VEC_EPILOG_SCALAR_PH]]:
; CHECK-NEXT:    [[BC_RESUME_VAL17:%.*]] = phi i8 [ [[TMP16]], %[[VEC_EPILOG_MIDDLE_BLOCK]] ], [ [[IND_END]], %[[VEC_EPILOG_ITER_CHECK]] ], [ 0, %[[ITER_CHECK]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX18:%.*]] = phi i8 [ [[RDX_SELECT15]], %[[VEC_EPILOG_MIDDLE_BLOCK]] ], [ [[RDX_SELECT]], %[[VEC_EPILOG_ITER_CHECK]] ], [ [[START]], %[[ITER_CHECK]] ]
; CHECK-NEXT:    br label %[[LOOP:.*]]
; CHECK:       [[LOOP]]:
; CHECK-NEXT:    [[IV1:%.*]] = phi i8 [ [[BC_RESUME_VAL17]], %[[VEC_EPILOG_SCALAR_PH]] ], [ [[IV_NEXT:%.*]], %[[LOOP]] ]
; CHECK-NEXT:    [[RDX:%.*]] = phi i8 [ [[BC_MERGE_RDX18]], %[[VEC_EPILOG_SCALAR_PH]] ], [ [[SEL:%.*]], %[[LOOP]] ]
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr inbounds i8, ptr [[A]], i8 [[IV1]]
; CHECK-NEXT:    [[L:%.*]] = load i8, ptr [[GEP1]], align 8
; CHECK-NEXT:    [[C:%.*]] = icmp eq i8 [[L]], 3
; CHECK-NEXT:    [[SEL]] = select i1 [[C]], i8 [[IV1]], i8 [[RDX]]
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i8 [[IV1]], 1
; CHECK-NEXT:    [[EC:%.*]] = icmp eq i8 [[IV_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[EC]], label %[[EXIT]], label %[[LOOP]], !llvm.loop [[LOOP4:![0-9]+]]
; CHECK:       [[EXIT]]:
; CHECK-NEXT:    [[SEL_LCSSA:%.*]] = phi i8 [ [[SEL]], %[[LOOP]] ], [ [[RDX_SELECT]], %[[MIDDLE_BLOCK]] ], [ [[RDX_SELECT15]], %[[VEC_EPILOG_MIDDLE_BLOCK]] ]
; CHECK-NEXT:    ret i8 [[SEL_LCSSA]]
;
entry:
  br label %loop

loop:
  %iv = phi i8 [ 0, %entry ], [ %iv.next, %loop ]
  %rdx = phi i8 [ %start, %entry ], [ %sel, %loop ]
  %gep = getelementptr inbounds i8, ptr %a, i8 %iv
  %l = load i8, ptr %gep, align 8
  %c = icmp eq i8 %l, 3
  %sel = select i1 %c, i8 %iv, i8 %rdx
  %iv.next = add nuw nsw i8 %iv, 1
  %ec = icmp eq i8 %iv.next, %n
  br i1 %ec, label %exit, label %loop

exit:
  ret i8 %sel
}

define i32 @select_icmp_var_start_iv_trunc(i32 %N, i32 %start) #0 {
; CHECK-LABEL: define i32 @select_icmp_var_start_iv_trunc(
; CHECK-SAME: i32 [[N:%.*]], i32 [[START:%.*]]) #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:  [[ITER_CHECK:.*]]:
; CHECK-NEXT:    [[N_POS:%.*]] = icmp sgt i32 [[N]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[N_POS]])
; CHECK-NEXT:    [[N_EXT:%.*]] = zext i32 [[N]] to i64
; CHECK-NEXT:    [[FR:%.*]] = freeze i32 [[START]]
; CHECK-NEXT:    [[TMP0:%.*]] = add nuw nsw i64 [[N_EXT]], 1
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i64 [[TMP0]], 4
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label %[[VEC_EPILOG_SCALAR_PH:.*]], label %[[VECTOR_MAIN_LOOP_ITER_CHECK:.*]]
; CHECK:       [[VECTOR_MAIN_LOOP_ITER_CHECK]]:
; CHECK-NEXT:    [[MIN_ITERS_CHECK1:%.*]] = icmp ult i64 [[TMP0]], 16
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK1]], label %[[VEC_EPILOG_PH:.*]], label %[[VECTOR_PH:.*]]
; CHECK:       [[VECTOR_PH]]:
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[TMP0]], 16
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[TMP0]], [[N_MOD_VF]]
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT:%.*]] = insertelement <4 x i32> poison, i32 [[START]], i64 0
; CHECK-NEXT:    [[BROADCAST_SPLAT:%.*]] = shufflevector <4 x i32> [[BROADCAST_SPLATINSERT]], <4 x i32> poison, <4 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq <4 x i32> [[BROADCAST_SPLAT]], zeroinitializer
; CHECK-NEXT:    br label %[[VECTOR_BODY:.*]]
; CHECK:       [[VECTOR_BODY]]:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, %[[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], %[[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <4 x i32> [ splat (i32 -2147483648), %[[VECTOR_PH]] ], [ [[TMP3:%.*]], %[[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI2:%.*]] = phi <4 x i32> [ splat (i32 -2147483648), %[[VECTOR_PH]] ], [ [[TMP4:%.*]], %[[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI3:%.*]] = phi <4 x i32> [ splat (i32 -2147483648), %[[VECTOR_PH]] ], [ [[TMP5:%.*]], %[[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI4:%.*]] = phi <4 x i32> [ splat (i32 -2147483648), %[[VECTOR_PH]] ], [ [[TMP6:%.*]], %[[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_IND:%.*]] = phi <4 x i32> [ <i32 0, i32 1, i32 2, i32 3>, %[[VECTOR_PH]] ], [ [[VEC_IND_NEXT:%.*]], %[[VECTOR_BODY]] ]
; CHECK-NEXT:    [[STEP_ADD:%.*]] = add <4 x i32> [[VEC_IND]], splat (i32 4)
; CHECK-NEXT:    [[STEP_ADD_2:%.*]] = add <4 x i32> [[STEP_ADD]], splat (i32 4)
; CHECK-NEXT:    [[STEP_ADD_3:%.*]] = add <4 x i32> [[STEP_ADD_2]], splat (i32 4)
; CHECK-NEXT:    [[TMP3]] = select <4 x i1> [[TMP1]], <4 x i32> [[VEC_IND]], <4 x i32> [[VEC_PHI]]
; CHECK-NEXT:    [[TMP4]] = select <4 x i1> [[TMP1]], <4 x i32> [[STEP_ADD]], <4 x i32> [[VEC_PHI2]]
; CHECK-NEXT:    [[TMP5]] = select <4 x i1> [[TMP1]], <4 x i32> [[STEP_ADD_2]], <4 x i32> [[VEC_PHI3]]
; CHECK-NEXT:    [[TMP6]] = select <4 x i1> [[TMP1]], <4 x i32> [[STEP_ADD_3]], <4 x i32> [[VEC_PHI4]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 16
; CHECK-NEXT:    [[VEC_IND_NEXT]] = add <4 x i32> [[STEP_ADD_3]], splat (i32 4)
; CHECK-NEXT:    [[TMP7:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP7]], label %[[MIDDLE_BLOCK:.*]], label %[[VECTOR_BODY]], !llvm.loop [[LOOP5:![0-9]+]]
; CHECK:       [[MIDDLE_BLOCK]]:
; CHECK-NEXT:    [[RDX_MINMAX:%.*]] = call <4 x i32> @llvm.smax.v4i32(<4 x i32> [[TMP3]], <4 x i32> [[TMP4]])
; CHECK-NEXT:    [[RDX_MINMAX5:%.*]] = call <4 x i32> @llvm.smax.v4i32(<4 x i32> [[RDX_MINMAX]], <4 x i32> [[TMP5]])
; CHECK-NEXT:    [[RDX_MINMAX6:%.*]] = call <4 x i32> @llvm.smax.v4i32(<4 x i32> [[RDX_MINMAX5]], <4 x i32> [[TMP6]])
; CHECK-NEXT:    [[TMP8:%.*]] = call i32 @llvm.vector.reduce.smax.v4i32(<4 x i32> [[RDX_MINMAX6]])
; CHECK-NEXT:    [[RDX_SELECT_CMP:%.*]] = icmp ne i32 [[TMP8]], -2147483648
; CHECK-NEXT:    [[RDX_SELECT:%.*]] = select i1 [[RDX_SELECT_CMP]], i32 [[TMP8]], i32 [[FR]]
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[TMP0]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label %[[EXIT:.*]], label %[[VEC_EPILOG_ITER_CHECK:.*]]
; CHECK:       [[VEC_EPILOG_ITER_CHECK]]:
; CHECK-NEXT:    [[N_VEC_REMAINING:%.*]] = sub i64 [[TMP0]], [[N_VEC]]
; CHECK-NEXT:    [[MIN_EPILOG_ITERS_CHECK:%.*]] = icmp ult i64 [[N_VEC_REMAINING]], 4
; CHECK-NEXT:    br i1 [[MIN_EPILOG_ITERS_CHECK]], label %[[VEC_EPILOG_SCALAR_PH]], label %[[VEC_EPILOG_PH]]
; CHECK:       [[VEC_EPILOG_PH]]:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], %[[VEC_EPILOG_ITER_CHECK]] ], [ 0, %[[VECTOR_MAIN_LOOP_ITER_CHECK]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX:%.*]] = phi i32 [ [[RDX_SELECT]], %[[VEC_EPILOG_ITER_CHECK]] ], [ [[FR]], %[[VECTOR_MAIN_LOOP_ITER_CHECK]] ]
; CHECK-NEXT:    [[TMP9:%.*]] = icmp eq i32 [[BC_MERGE_RDX]], [[FR]]
; CHECK-NEXT:    [[TMP10:%.*]] = select i1 [[TMP9]], i32 -2147483648, i32 [[BC_MERGE_RDX]]
; CHECK-NEXT:    [[N_MOD_VF7:%.*]] = urem i64 [[TMP0]], 4
; CHECK-NEXT:    [[N_VEC8:%.*]] = sub i64 [[TMP0]], [[N_MOD_VF7]]
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT9:%.*]] = insertelement <4 x i32> poison, i32 [[START]], i64 0
; CHECK-NEXT:    [[BROADCAST_SPLAT10:%.*]] = shufflevector <4 x i32> [[BROADCAST_SPLATINSERT9]], <4 x i32> poison, <4 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP11:%.*]] = icmp eq <4 x i32> [[BROADCAST_SPLAT10]], zeroinitializer
; CHECK-NEXT:    [[DOTSPLATINSERT13:%.*]] = insertelement <4 x i32> poison, i32 [[TMP10]], i64 0
; CHECK-NEXT:    [[DOTSPLAT14:%.*]] = shufflevector <4 x i32> [[DOTSPLATINSERT13]], <4 x i32> poison, <4 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP12:%.*]] = trunc i64 [[BC_RESUME_VAL]] to i32
; CHECK-NEXT:    [[DOTSPLATINSERT:%.*]] = insertelement <4 x i32> poison, i32 [[TMP12]], i64 0
; CHECK-NEXT:    [[DOTSPLAT:%.*]] = shufflevector <4 x i32> [[DOTSPLATINSERT]], <4 x i32> poison, <4 x i32> zeroinitializer
; CHECK-NEXT:    [[INDUCTION:%.*]] = add <4 x i32> [[DOTSPLAT]], <i32 0, i32 1, i32 2, i32 3>
; CHECK-NEXT:    br label %[[VEC_EPILOG_VECTOR_BODY:.*]]
; CHECK:       [[VEC_EPILOG_VECTOR_BODY]]:
; CHECK-NEXT:    [[INDEX11:%.*]] = phi i64 [ [[BC_RESUME_VAL]], %[[VEC_EPILOG_PH]] ], [ [[INDEX_NEXT17:%.*]], %[[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI12:%.*]] = phi <4 x i32> [ [[DOTSPLAT14]], %[[VEC_EPILOG_PH]] ], [ [[TMP14:%.*]], %[[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_IND15:%.*]] = phi <4 x i32> [ [[INDUCTION]], %[[VEC_EPILOG_PH]] ], [ [[VEC_IND_NEXT16:%.*]], %[[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP14]] = select <4 x i1> [[TMP11]], <4 x i32> [[VEC_IND15]], <4 x i32> [[VEC_PHI12]]
; CHECK-NEXT:    [[INDEX_NEXT17]] = add nuw i64 [[INDEX11]], 4
; CHECK-NEXT:    [[VEC_IND_NEXT16]] = add <4 x i32> [[VEC_IND15]], splat (i32 4)
; CHECK-NEXT:    [[TMP15:%.*]] = icmp eq i64 [[INDEX_NEXT17]], [[N_VEC8]]
; CHECK-NEXT:    br i1 [[TMP15]], label %[[VEC_EPILOG_MIDDLE_BLOCK:.*]], label %[[VEC_EPILOG_VECTOR_BODY]], !llvm.loop [[LOOP6:![0-9]+]]
; CHECK:       [[VEC_EPILOG_MIDDLE_BLOCK]]:
; CHECK-NEXT:    [[TMP16:%.*]] = call i32 @llvm.vector.reduce.smax.v4i32(<4 x i32> [[TMP14]])
; CHECK-NEXT:    [[RDX_SELECT_CMP18:%.*]] = icmp ne i32 [[TMP16]], -2147483648
; CHECK-NEXT:    [[RDX_SELECT19:%.*]] = select i1 [[RDX_SELECT_CMP18]], i32 [[TMP16]], i32 [[FR]]
; CHECK-NEXT:    [[CMP_N20:%.*]] = icmp eq i64 [[TMP0]], [[N_VEC8]]
; CHECK-NEXT:    br i1 [[CMP_N20]], label %[[EXIT]], label %[[VEC_EPILOG_SCALAR_PH]]
; CHECK:       [[VEC_EPILOG_SCALAR_PH]]:
; CHECK-NEXT:    [[BC_RESUME_VAL23:%.*]] = phi i64 [ [[N_VEC8]], %[[VEC_EPILOG_MIDDLE_BLOCK]] ], [ [[N_VEC]], %[[VEC_EPILOG_ITER_CHECK]] ], [ 0, %[[ITER_CHECK]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX24:%.*]] = phi i32 [ [[RDX_SELECT19]], %[[VEC_EPILOG_MIDDLE_BLOCK]] ], [ [[RDX_SELECT]], %[[VEC_EPILOG_ITER_CHECK]] ], [ [[START]], %[[ITER_CHECK]] ]
; CHECK-NEXT:    br label %[[LOOP:.*]]
; CHECK:       [[LOOP]]:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[BC_RESUME_VAL23]], %[[VEC_EPILOG_SCALAR_PH]] ], [ [[IV_NEXT:%.*]], %[[LOOP]] ]
; CHECK-NEXT:    [[RED:%.*]] = phi i32 [ [[BC_MERGE_RDX24]], %[[VEC_EPILOG_SCALAR_PH]] ], [ [[RED_NEXT:%.*]], %[[LOOP]] ]
; CHECK-NEXT:    [[C:%.*]] = icmp eq i32 [[START]], 0
; CHECK-NEXT:    [[IV_TRUNC:%.*]] = trunc i64 [[IV]] to i32
; CHECK-NEXT:    [[RED_NEXT]] = select i1 [[C]], i32 [[IV_TRUNC]], i32 [[RED]]
; CHECK-NEXT:    [[IV_NEXT]] = add i64 [[IV]], 1
; CHECK-NEXT:    [[EC:%.*]] = icmp eq i64 [[IV]], [[N_EXT]]
; CHECK-NEXT:    br i1 [[EC]], label %[[EXIT]], label %[[LOOP]], !llvm.loop [[LOOP7:![0-9]+]]
; CHECK:       [[EXIT]]:
; CHECK-NEXT:    [[RED_NEXT_LCSSA:%.*]] = phi i32 [ [[RED_NEXT]], %[[LOOP]] ], [ [[RDX_SELECT]], %[[MIDDLE_BLOCK]] ], [ [[RDX_SELECT19]], %[[VEC_EPILOG_MIDDLE_BLOCK]] ]
; CHECK-NEXT:    ret i32 [[RED_NEXT_LCSSA]]
;
entry:
  %N.pos = icmp sgt i32 %N, 0
  call void @llvm.assume(i1 %N.pos)
  %N.ext = zext i32 %N to i64
  br label %loop

loop:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
  %red = phi i32 [ %start, %entry ], [ %red.next, %loop ]
  %c = icmp eq i32 %start, 0
  %iv.trunc = trunc i64 %iv to i32
  %red.next = select i1 %c, i32 %iv.trunc, i32 %red
  %iv.next = add i64 %iv, 1
  %ec = icmp eq i64 %iv, %N.ext
  br i1 %ec, label %exit, label %loop

exit:
  ret i32 %red.next
}

declare void @llvm.assume(i1 noundef)

attributes #0 = { "target-cpu"="apple-m1" }
