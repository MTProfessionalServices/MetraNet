
			 declare i2 number(20);
			 nCnt2 int; 
			 begin
				insert into %%DELTA_DELETE_MAX_SESS%% select * from %%MAX_SESS%%;				
				select count(*) into nCnt2 from t_mview_catalog where update_mode = 'T';             
				if (nCnt2>=4) then 
					update %%MAX_SESS%% set id_sess = 2147483647;          
				else     				
					select id_current-1 into i2 from t_current_long_id where nm_current='id_sess';
					update %%MAX_SESS%% set id_sess=  (select nvl(max(id_sess),i2)
					from t_acc_usage);
				end if;
				insert into %%DELTA_INSERT_MAX_SESS%% select * from %%MAX_SESS%%;
			 end;
			