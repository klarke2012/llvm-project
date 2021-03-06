; RUN: llc -march=amdgcn -mcpu=gfx900 -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s


; GCN-LABEL: {{^}}add_var_var_i1:
; GCN: s_xor_b64
define amdgpu_kernel void @add_var_var_i1(i1 addrspace(1)* %out, i1 addrspace(1)* %in0, i1 addrspace(1)* %in1) {
  %a = load volatile i1, i1 addrspace(1)* %in0
  %b = load volatile i1, i1 addrspace(1)* %in1
  %add = add i1 %a, %b
  store i1 %add, i1 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}add_var_imm_i1:
; GCN: s_not_b64
define amdgpu_kernel void @add_var_imm_i1(i1 addrspace(1)* %out, i1 addrspace(1)* %in) {
  %a = load volatile i1, i1 addrspace(1)* %in
  %add = add i1 %a, 1
  store i1 %add, i1 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}add_i1_cf:
; GCN: ; %endif
; GCN: s_not_b64
define amdgpu_kernel void @add_i1_cf(i1 addrspace(1)* %out, i1 addrspace(1)* %a, i1 addrspace(1)* %b) {
entry:
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %d_cmp = icmp ult i32 %tid, 16
  br i1 %d_cmp, label %if, label %else

if:
  %0 = load volatile i1, i1 addrspace(1)* %a
  br label %endif

else:
  %1 = load volatile i1, i1 addrspace(1)* %b
  br label %endif

endif:
  %2 = phi i1 [%0, %if], [%1, %else]
  %3 = add i1 %2, -1
  store i1 %3, i1 addrspace(1)* %out
  ret void
}

declare i32 @llvm.amdgcn.workitem.id.x()
