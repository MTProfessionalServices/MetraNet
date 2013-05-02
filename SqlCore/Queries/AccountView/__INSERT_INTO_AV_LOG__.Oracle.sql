
insert into t_account_view_log 
	(id_account_view, nm_account_view, id_revision, tx_checksum, nm_table_name) values 
	(seq_t_account_view_log.nextval, N'%%AV_NAME%%', 1,'%%AV_CHECKSUM%%', '%%AV_TABLE_NAME%%')
        