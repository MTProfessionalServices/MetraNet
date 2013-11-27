
      create procedure DeleteDescription(
				@a_id_desc int)
			as
			BEGIN
				IF (@a_id_desc <> 0)
					begin
					delete from t_description where id_desc=@a_id_desc
					delete from t_mt_id where id_mt=@a_id_desc
	     		end 
			END
		