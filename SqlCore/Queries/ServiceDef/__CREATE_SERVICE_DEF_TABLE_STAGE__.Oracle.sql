
			execute IMMEDIATE '
			create table %%TABLE_NAME%% (
            id_source_sess raw(16) not null ,
            id_parent_source_sess raw(16) ,
            id_external raw(16)			
			%%ADDITIONAL_COLUMNS%%
			%%RESERVED_COLUMNS%%)
			';
			%%CREATE_TABLE_DESCRIPTION%%
			%%CREATE_COLUMNS_DESCRIPTION%%
		