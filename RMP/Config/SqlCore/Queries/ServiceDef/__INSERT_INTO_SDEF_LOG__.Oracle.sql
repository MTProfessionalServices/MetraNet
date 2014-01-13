
insert into t_service_def_log 
				(id_service_def, nm_service_def, id_revision, tx_checksum, nm_table_name)
values 
				(seq_t_service_def_log.nextval, N'%%SDEF_NAME%%', 1,'%%SDEF_CHECKSUM%%', '%%SDF_TABLE_NAME%%')
			