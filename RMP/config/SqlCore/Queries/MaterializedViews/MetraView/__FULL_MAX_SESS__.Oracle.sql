
			declare i1 number(20);
			nCnt1 int; 
			begin
			exec_ddl ('truncate table %%MAX_SESS%%');			
			select count(*) into nCnt1 from t_mview_catalog where update_mode = 'T';             
            if (nCnt1>=4) then 
				insert into %%MAX_SESS%%(id_sess) values(2147483647);
			else
				select id_current-1 into i1 from t_current_long_id where nm_current='id_sess'; 
				insert into %%MAX_SESS%% select nvl(max(id_sess),i1) from t_acc_usage;
			end if;
			end;
			