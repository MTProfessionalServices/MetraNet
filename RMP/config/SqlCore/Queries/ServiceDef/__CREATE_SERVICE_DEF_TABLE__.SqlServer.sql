
			create table %%TABLE_NAME%% (
            id_source_sess binary(16) not null ,
            id_parent_source_sess binary(16) ,
            id_external binary(16),
			id_partition INT NOT NULL DEFAULT %%DEFAULT_VALUE%%
			%%ADDITIONAL_COLUMNS%%
			%%RESERVED_COLUMNS%%
			primary key clustered (id_source_sess))
			%%CREATE_TABLE_DESCRIPTION%%
			%%CREATE_COLUMNS_DESCRIPTION%%
			
			IF NOT EXISTS (SELECT 1 FROM fn_listextendedproperty(N'MS_Description', N'SCHEMA', N'dbo', N'TABLE', '%%TABLE_NAME%%', N'COLUMN', 'id_source_sess'))
			BEGIN
				EXEC sp_addextendedproperty
					@name = N'MS_Description',
					@value = 'Required column. Unique ID for the session. Associated with t_acc_usage(tx_UID), t_session(id_source_sess), t_session_state(id_sess) tables.',
					@level0type = N'SCHEMA', @level0name = N'dbo',
					@level1type = N'TABLE', @level1name = '%%TABLE_NAME%%',
					@level2type = N'COLUMN', @level2name = 'id_source_sess'
			END
			
			IF NOT EXISTS (SELECT 1 FROM fn_listextendedproperty(N'MS_Description', N'SCHEMA', N'dbo', N'TABLE', '%%TABLE_NAME%%', N'COLUMN', 'id_parent_source_sess'))
			BEGIN
				EXEC sp_addextendedproperty
					@name = N'MS_Description',
					@value = 'Required column. Any session can contain parent session which is indicate to which the current session is belonged to.',
					@level0type = N'SCHEMA', @level0name = N'dbo',
					@level1type = N'TABLE', @level1name = '%%TABLE_NAME%%',
					@level2type = N'COLUMN', @level2name = 'id_parent_source_sess'
			END
			
			IF NOT EXISTS (SELECT 1 FROM fn_listextendedproperty(N'MS_Description', N'SCHEMA', N'dbo', N'TABLE', '%%TABLE_NAME%%', N'COLUMN', 'id_external'))
			BEGIN
				EXEC sp_addextendedproperty
					@name = N'MS_Description',
					@value = 'Required column. External identifier.',
					@level0type = N'SCHEMA', @level0name = N'dbo',
					@level1type = N'TABLE', @level1name = '%%TABLE_NAME%%',
					@level2type = N'COLUMN', @level2name = 'id_external'
			END
			
			IF NOT EXISTS (SELECT 1 FROM fn_listextendedproperty(N'MS_Description', N'SCHEMA', N'dbo', N'TABLE', '%%TABLE_NAME%%', N'COLUMN', 'id_partition'))
			BEGIN
				EXEC sp_addextendedproperty
					@name = N'MS_Description',
					@value = 'Required column. The partition value that specifies on which partition 1,2,�X the current data is saved. Column for meter partitioning. It uses to simplify archive functionality.',
					@level0type = N'SCHEMA', @level0name = N'dbo',
					@level1type = N'TABLE', @level1name = '%%TABLE_NAME%%',
					@level2type = N'COLUMN', @level2name = 'id_partition'
			END
			