begin
  if (table_exists('%%TMP_T_ACC_USAGE_TABLE%%')) then
	begin
		/* disable all constraints */
		execute immediate 'ALTER TABLE t_usage_interval DISABLE CONSTRAINT FK1_T_USAGE_INTERVAL';
		execute immediate 'ALTER TABLE t_usage_interval DISABLE CONSTRAINT CK1_T_USAGE_INTERVAL';
		execute immediate 'ALTER TABLE t_billgroup DISABLE CONSTRAINT FK1_t_billgroup';
		execute immediate 'ALTER TABLE t_acc_usage_interval DISABLE CONSTRAINT FK2_t_acc_usage_interval';
		execute immediate 'ALTER TABLE t_billgroup_constraint  DISABLE CONSTRAINT FK1_t_billgroup_constraint';
		execute immediate 'ALTER TABLE t_billgroup_constraint_tmp DISABLE  CONSTRAINT FK1_t_billgroup_constraint_tmp';
		execute immediate 'ALTER TABLE t_billgroup_materialization  DISABLE  CONSTRAINT FK3_billgroup_materialization';
		
		execute immediate 'truncate table t_usage_interval'; 
	
		execute immediate 'INSERT INTO t_usage_interval  ( id_interval,
										id_usage_cycle,
										dt_start,
										dt_end,
										tx_interval_status)
		SELECT  id_interval,
				id_usage_cycle,
				dt_start,
				dt_end,
				tx_interval_status
		FROM %%TMP_T_ACC_USAGE_TABLE%%';
		
		/* enable all constraints */
		execute immediate 'ALTER TABLE t_usage_interval ENABLE CONSTRAINT FK1_T_USAGE_INTERVAL';
		execute immediate 'ALTER TABLE t_usage_interval ENABLE CONSTRAINT CK1_T_USAGE_INTERVAL';
		execute immediate 'ALTER TABLE t_billgroup ENABLE CONSTRAINT FK1_t_billgroup';
		execute immediate 'ALTER TABLE t_acc_usage_interval ENABLE CONSTRAINT FK2_t_acc_usage_interval';
		execute immediate 'ALTER TABLE t_billgroup_constraint  ENABLE CONSTRAINT FK1_t_billgroup_constraint';
		execute immediate 'ALTER TABLE t_billgroup_constraint_tmp ENABLE  CONSTRAINT FK1_t_billgroup_constraint_tmp';
		execute immediate 'ALTER TABLE t_billgroup_materialization  ENABLE  CONSTRAINT FK3_billgroup_materialization';
	
		execute immediate 'drop table %%TMP_T_ACC_USAGE_TABLE%%';
	 end;    
  end if;
end;