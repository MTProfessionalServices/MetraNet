
      begin
			insert into t_recur_value
         select * from t_recur_value_temp
         where id_sub = %%ID_SUB%%;
         
      delete from t_recur_value_temp
         where id_sub = %%ID_SUB%%;
      end;
		