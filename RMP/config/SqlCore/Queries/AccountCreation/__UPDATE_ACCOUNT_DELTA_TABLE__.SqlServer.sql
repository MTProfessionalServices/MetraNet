
    begin
      select 1 from %%DELTA_TABLE_NAME%% with(tablockx) where 0=1 
      insert into %%DELTA_TABLE_NAME%% select * from %%TABLE_NAME%% where id_acc in
      (select distinct id_descendent from t_account_ancestor where id_ancestor in (%%ID_ACC_LIST%%))
    end
			