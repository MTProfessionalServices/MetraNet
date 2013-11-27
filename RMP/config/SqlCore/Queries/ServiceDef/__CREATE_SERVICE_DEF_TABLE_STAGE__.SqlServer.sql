
			create table %%TABLE_NAME%% (
            id_source_sess binary(16) not null ,
            id_parent_source_sess binary(16) ,
            id_external binary(16)	
			%%ADDITIONAL_COLUMNS%%
			%%RESERVED_COLUMNS%% )
			%%CREATE_TABLE_DESCRIPTION%%
			%%CREATE_COLUMNS_DESCRIPTION%%
		