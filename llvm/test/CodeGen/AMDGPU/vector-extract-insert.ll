; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=amdgcn -mcpu=tahiti < %s | FileCheck -check-prefix=GCN %s

; Test that when extracting the same unknown vector index from an
; insertelement the dynamic indexing is folded away.

declare i32 @llvm.amdgcn.workitem.id.x() #0

; No dynamic indexing required
define amdgpu_kernel void @extract_insert_same_dynelt_v4i32(ptr addrspace(1) %out, ptr addrspace(1) %in, i32 %val, i32 %idx) #1 {
; GCN-LABEL: extract_insert_same_dynelt_v4i32:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x9
; GCN-NEXT:    s_load_dword s4, s[4:5], 0xd
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_mov_b32 s3, 0xf000
; GCN-NEXT:    s_mov_b32 s2, 0
; GCN-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GCN-NEXT:    v_mov_b32_e32 v1, 0
; GCN-NEXT:    v_mov_b32_e32 v2, s4
; GCN-NEXT:    buffer_store_dword v2, v[0:1], s[0:3], 0 addr64
; GCN-NEXT:    s_endpgm
  %id = call i32 @llvm.amdgcn.workitem.id.x()
  %id.ext = sext i32 %id to i64
  %gep.in = getelementptr inbounds <4 x i32>, ptr addrspace(1) %in, i64 %id.ext
  %gep.out = getelementptr inbounds i32, ptr addrspace(1) %out, i64 %id.ext
  %vec = load <4 x i32>, ptr addrspace(1) %gep.in
  %insert = insertelement <4 x i32> %vec, i32 %val, i32 %idx
  %extract = extractelement <4 x i32> %insert, i32 %idx
  store i32 %extract, ptr addrspace(1) %gep.out
  ret void
}

define amdgpu_kernel void @extract_insert_different_dynelt_v4i32(ptr addrspace(1) %out, ptr addrspace(1) %in, i32 %val, i32 %idx0, i32 %idx1) #1 {
; GCN-LABEL: extract_insert_different_dynelt_v4i32:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_load_dwordx8 s[8:15], s[4:5], 0x9
; GCN-NEXT:    s_mov_b32 s3, 0xf000
; GCN-NEXT:    s_mov_b32 s2, 0
; GCN-NEXT:    v_lshlrev_b32_e32 v4, 4, v0
; GCN-NEXT:    v_mov_b32_e32 v5, 0
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_mov_b64 s[0:1], s[10:11]
; GCN-NEXT:    buffer_load_dwordx4 v[1:4], v[4:5], s[0:3], 0 addr64
; GCN-NEXT:    s_cmp_eq_u32 s13, 3
; GCN-NEXT:    s_cselect_b64 vcc, -1, 0
; GCN-NEXT:    s_cmp_eq_u32 s13, 2
; GCN-NEXT:    s_cselect_b64 s[0:1], -1, 0
; GCN-NEXT:    s_cmp_eq_u32 s13, 1
; GCN-NEXT:    s_mov_b64 s[10:11], s[2:3]
; GCN-NEXT:    s_cselect_b64 s[2:3], -1, 0
; GCN-NEXT:    s_cmp_eq_u32 s13, 0
; GCN-NEXT:    v_lshlrev_b32_e32 v6, 2, v0
; GCN-NEXT:    v_mov_b32_e32 v0, s12
; GCN-NEXT:    s_cselect_b64 s[4:5], -1, 0
; GCN-NEXT:    s_cmp_eq_u32 s14, 1
; GCN-NEXT:    v_mov_b32_e32 v7, v5
; GCN-NEXT:    s_waitcnt vmcnt(0)
; GCN-NEXT:    v_cndmask_b32_e32 v4, v4, v0, vcc
; GCN-NEXT:    v_cndmask_b32_e64 v3, v3, v0, s[0:1]
; GCN-NEXT:    v_cndmask_b32_e64 v2, v2, v0, s[2:3]
; GCN-NEXT:    v_cndmask_b32_e64 v0, v1, v0, s[4:5]
; GCN-NEXT:    s_cselect_b64 vcc, -1, 0
; GCN-NEXT:    s_cmp_eq_u32 s14, 2
; GCN-NEXT:    v_cndmask_b32_e32 v0, v0, v2, vcc
; GCN-NEXT:    s_cselect_b64 vcc, -1, 0
; GCN-NEXT:    s_cmp_eq_u32 s14, 3
; GCN-NEXT:    v_cndmask_b32_e32 v0, v0, v3, vcc
; GCN-NEXT:    s_cselect_b64 vcc, -1, 0
; GCN-NEXT:    v_cndmask_b32_e32 v0, v0, v4, vcc
; GCN-NEXT:    buffer_store_dword v0, v[6:7], s[8:11], 0 addr64
; GCN-NEXT:    s_endpgm
  %id = call i32 @llvm.amdgcn.workitem.id.x()
  %id.ext = sext i32 %id to i64
  %gep.in = getelementptr inbounds <4 x i32>, ptr addrspace(1) %in, i64 %id.ext
  %gep.out = getelementptr inbounds i32, ptr addrspace(1) %out, i64 %id.ext
  %vec = load <4 x i32>, ptr addrspace(1) %gep.in
  %insert = insertelement <4 x i32> %vec, i32 %val, i32 %idx0
  %extract = extractelement <4 x i32> %insert, i32 %idx1
  store i32 %extract, ptr addrspace(1) %gep.out
  ret void
}

define amdgpu_kernel void @extract_insert_same_elt2_v4i32(ptr addrspace(1) %out, ptr addrspace(1) %in, i32 %val, i32 %idx) #1 {
; GCN-LABEL: extract_insert_same_elt2_v4i32:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x9
; GCN-NEXT:    s_load_dword s4, s[4:5], 0xd
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_mov_b32 s3, 0xf000
; GCN-NEXT:    s_mov_b32 s2, 0
; GCN-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GCN-NEXT:    v_mov_b32_e32 v1, 0
; GCN-NEXT:    v_mov_b32_e32 v2, s4
; GCN-NEXT:    buffer_store_dword v2, v[0:1], s[0:3], 0 addr64
; GCN-NEXT:    s_endpgm
  %id = call i32 @llvm.amdgcn.workitem.id.x()
  %id.ext = sext i32 %id to i64
  %gep.in = getelementptr inbounds <4 x i32>, ptr addrspace(1) %in, i64 %id.ext
  %gep.out = getelementptr inbounds i32, ptr addrspace(1) %out, i64 %id.ext
  %vec = load <4 x i32>, ptr addrspace(1) %gep.in
  %insert = insertelement <4 x i32> %vec, i32 %val, i32 %idx
  %extract = extractelement <4 x i32> %insert, i32 %idx
  store i32 %extract, ptr addrspace(1) %gep.out
  ret void
}

define amdgpu_kernel void @extract_insert_same_dynelt_v4f32(ptr addrspace(1) %out, ptr addrspace(1) %in, float %val, i32 %idx) #1 {
; GCN-LABEL: extract_insert_same_dynelt_v4f32:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x9
; GCN-NEXT:    s_load_dword s8, s[4:5], 0xd
; GCN-NEXT:    s_mov_b32 s7, 0xf000
; GCN-NEXT:    s_mov_b32 s6, 0
; GCN-NEXT:    v_lshlrev_b32_e32 v4, 4, v0
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_mov_b64 s[4:5], s[2:3]
; GCN-NEXT:    v_mov_b32_e32 v5, 0
; GCN-NEXT:    buffer_load_dwordx4 v[1:4], v[4:5], s[4:7], 0 addr64 glc
; GCN-NEXT:    s_waitcnt vmcnt(0)
; GCN-NEXT:    s_mov_b64 s[2:3], s[6:7]
; GCN-NEXT:    v_lshlrev_b32_e32 v4, 2, v0
; GCN-NEXT:    v_mov_b32_e32 v0, s8
; GCN-NEXT:    buffer_store_dword v0, v[4:5], s[0:3], 0 addr64
; GCN-NEXT:    s_endpgm
  %id = call i32 @llvm.amdgcn.workitem.id.x()
  %id.ext = sext i32 %id to i64
  %gep.in = getelementptr inbounds <4 x float>, ptr addrspace(1) %in, i64 %id.ext
  %gep.out = getelementptr inbounds float, ptr addrspace(1) %out, i64 %id.ext
  %vec = load volatile <4 x float>, ptr addrspace(1) %gep.in
  %insert = insertelement <4 x float> %vec, float %val, i32 %idx
  %extract = extractelement <4 x float> %insert, i32 %idx
  store float %extract, ptr addrspace(1) %gep.out
  ret void
}

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind }
