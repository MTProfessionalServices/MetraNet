
      begin
	      delete from t_description where id_desc = 0;
	      /*delete from t_description where id_desc in (select id_enum_data from t_enum_data);*/
	   end;
      