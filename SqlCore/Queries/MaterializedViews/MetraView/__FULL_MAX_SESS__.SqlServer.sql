
	   		DECLARE @nCnt1 int
			SELECT @nCnt1 = count(*) from t_mview_catalog where update_mode = 'T'
			truncate table %%MAX_SESS%%
            if (@nCnt1 >= 4)
			  begin 
				insert into %%MAX_SESS%% select 922337203685477580
			  end
			else
               begin			
			insert into %%MAX_SESS%% select isnull(max(id_sess),(select id_current-1 from t_current_long_id where nm_current='id_sess')) from t_acc_usage
			  end					
			