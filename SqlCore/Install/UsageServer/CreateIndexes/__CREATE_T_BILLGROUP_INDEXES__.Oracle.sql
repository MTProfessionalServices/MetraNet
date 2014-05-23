    create index idx_billgroup_constraint on t_billgroup_constraint(id_group,id_usage_interval);

    create index idx_billgroup_constraint_tmp on t_billgroup_constraint_tmp(id_group,id_usage_interval);
  
    create index idx1_t_bg_constraint_tmp on t_billgroup_constraint_tmp(id_acc,id_usage_interval);
  
    create index idx_billgroup_source_acc on t_billgroup_source_acc(id_materialization,id_acc);

    create index idx_billgroup_member on t_billgroup_member(id_billgroup,id_acc);
  
    create index idx_billgroup_member_history on t_billgroup_member_history(id_materialization);
  
    create index idx_billgroup_tmp on t_billgroup_tmp(id_materialization);

    create index idx_billgroup_member_tmp on t_billgroup_member_tmp(id_materialization,id_acc);
	
	create index idx_s_billgroup_member_history on t_billgroup_member_history (DECODE (tx_status, 'Failed', 1, NULL));  
