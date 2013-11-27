
	   		DECLARE @nCnt3 int
			SELECT @nCnt3 = count(*) from t_mview_catalog where update_mode = 'T'		
			insert into %%DELTA_DELETE_MAX_SESS%% select * from %%MAX_SESS%%
			if (@nCnt3 >= 4)
				begin 
					update %%MAX_SESS%% set id_sess= 922337203685477580
				end
			else
				begin			
			update %%MAX_SESS%% set id_sess= tmp.id_sess from
			(select 
			isnull(max(id_sess),(select id_current-1 from t_current_long_id where nm_current='id_sess')) id_sess
						from t_acc_usage) tmp
				end
			insert into %%DELTA_INSERT_MAX_SESS%% select * from %%MAX_SESS%%
			