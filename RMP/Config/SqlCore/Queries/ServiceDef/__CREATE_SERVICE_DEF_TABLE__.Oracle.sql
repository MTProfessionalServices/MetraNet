
			execute IMMEDIATE '
			create table %%TABLE_NAME%% (
            id_source_sess raw(16) not null ,
            id_parent_source_sess raw(16) ,
            id_external raw(16)			
			%%ADDITIONAL_COLUMNS%%
			%%RESERVED_COLUMNS%% ,
			id_partition number(10) DEFAULT 1 NOT NULL)
			
			PARTITION BY LIST (ID_PARTITION) (PARTITION P1 VALUES(1))
			';
			%%CREATE_TABLE_DESCRIPTION%%
			%%CREATE_COLUMNS_DESCRIPTION%%
			
			execute IMMEDIATE '
			COMMENT ON COLUMN %%TABLE_NAME%%.id_source_sess IS ''Required column. Unique ID for the session. Associated with t_acc_usage(tx_UID), t_session(id_source_sess), t_session_state(id_sess) tables.''
			';
			execute IMMEDIATE '
			COMMENT ON COLUMN %%TABLE_NAME%%.id_parent_source_sess IS ''Required column. Any session can contain parent session which is indicate to which the current session is belonged to.''
			';
			execute IMMEDIATE '
			COMMENT ON COLUMN %%TABLE_NAME%%.id_external IS ''Required column. External identifier.''
			';
			execute IMMEDIATE '
			COMMENT ON COLUMN %%TABLE_NAME%%.id_partition IS ''Required column. The partition value that specifies on which partition 1,2,…X the current data is saved. Column for meter partitioning. It uses to simplify archive functionality.''
			';
			
		