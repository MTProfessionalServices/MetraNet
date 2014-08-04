BEGIN TRANSACTION

	IF OBJECT_ID('%%TMP_T_ACC_USAGE_TABLE%%') IS NOT NULL
	BEGIN
		drop table %%TMP_T_ACC_USAGE_TABLE%%
	END
	SELECT * INTO %%TMP_T_ACC_USAGE_TABLE%% FROM t_usage_interval

	/* removes constraints fro t_usage_interval table 
		don't know why, but disable constrains didn't help, so start dropping ...
	*/
	ALTER TABLE t_usage_interval DROP CONSTRAINT CK1_t_usage_interval
	ALTER TABLE t_usage_interval DROP CONSTRAINT FK1_T_USAGE_INTERVAL
	ALTER TABLE t_billgroup DROP CONSTRAINT FK1_t_billgroup
	ALTER TABLE t_acc_usage_interval DROP CONSTRAINT fk2_t_acc_usage_interval
	ALTER TABLE t_billgroup_constraint  DROP CONSTRAINT FK1_t_billgroup_constraint
	ALTER TABLE t_billgroup_constraint_tmp DROP  CONSTRAINT FK1_t_billgroup_constraint_tmp
	ALTER TABLE t_billgroup_materialization  DROP  CONSTRAINT FK3_t_billgroup_materialization

	TRUNCATE TABLE t_usage_interval

	INSERT t_usage_interval ( id_interval,
								   id_usage_cycle,
								   dt_start,
								   dt_end,
								   tx_interval_status)
	SELECT  tpc.id_interval,
			tpc.id_cycle,
			tpc.dt_start,
			tpc.dt_end,
			'O'
	FROM t_pc_interval tpc
	
	/* restore constraints fro t_usage_interval table */										
	ALTER TABLE t_usage_interval  WITH CHECK ADD  CONSTRAINT FK1_T_USAGE_INTERVAL FOREIGN KEY(id_usage_cycle)
	REFERENCES t_usage_cycle (id_usage_cycle)

	ALTER TABLE t_usage_interval CHECK CONSTRAINT FK1_T_USAGE_INTERVAL

	ALTER TABLE t_usage_interval  WITH CHECK ADD  CONSTRAINT CK1_t_usage_interval CHECK  ((tx_interval_status='H' OR tx_interval_status='B' OR tx_interval_status='O'))

	ALTER TABLE t_usage_interval CHECK CONSTRAINT CK1_t_usage_interval

	ALTER TABLE t_billgroup  WITH CHECK ADD  CONSTRAINT FK1_t_billgroup FOREIGN KEY(id_usage_interval)
	REFERENCES t_usage_interval (id_interval)

	ALTER TABLE t_billgroup CHECK CONSTRAINT FK1_t_billgroup

	ALTER TABLE t_acc_usage_interval  WITH CHECK ADD  CONSTRAINT fk2_t_acc_usage_interval FOREIGN KEY(id_usage_interval)
	REFERENCES t_usage_interval (id_interval)

	ALTER TABLE t_acc_usage_interval CHECK CONSTRAINT fk2_t_acc_usage_interval

	ALTER TABLE t_billgroup_constraint  WITH CHECK ADD  CONSTRAINT FK1_t_billgroup_constraint FOREIGN KEY(id_usage_interval)
	REFERENCES t_usage_interval (id_interval)

	ALTER TABLE t_billgroup_constraint CHECK CONSTRAINT FK1_t_billgroup_constraint

	ALTER TABLE t_billgroup_constraint_tmp  WITH CHECK ADD  CONSTRAINT FK1_t_billgroup_constraint_tmp FOREIGN KEY(id_usage_interval)
	REFERENCES t_usage_interval (id_interval)

	ALTER TABLE t_billgroup_constraint_tmp CHECK CONSTRAINT FK1_t_billgroup_constraint_tmp

	ALTER TABLE t_billgroup_materialization  WITH CHECK ADD  CONSTRAINT FK3_t_billgroup_materialization FOREIGN KEY(id_usage_interval)
	REFERENCES t_usage_interval (id_interval)

	ALTER TABLE t_billgroup_materialization CHECK CONSTRAINT FK3_t_billgroup_materialization
	
COMMIT TRANSACTION 
