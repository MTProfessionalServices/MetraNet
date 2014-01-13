
		insert into %%TABLE_NAME%%
		select id_source_sess from %%SERVICE_DEF_TABLE_NAME%% 
		where %%WHERE_CLAUSE%%
		