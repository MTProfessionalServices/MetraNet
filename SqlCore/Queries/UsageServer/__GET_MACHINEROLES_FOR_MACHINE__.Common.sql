
select role.c_Name MachineRole, machine.c_MachineIdentifier MachineIdentifier from t_be_cor_mr_r_machin_machin mapping
left join t_be_cor_mr_machine machine on mapping.c_Machine_Id = machine.c_Machine_Id
left join t_be_cor_mr_machinerole role on mapping.c_MachineRole_Id = role.c_MachineRole_Id
where machine.c_MachineIdentifier like '%%TX_MACHINE%%'
			