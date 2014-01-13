
      create procedure DeleteBaseProps(
				@a_id_prop int) 
      as
			begin
        declare @id_desc_display_name int
        declare @id_desc_name int
        declare @id_desc_desc int
     		SELECT @id_desc_name = n_name, @id_desc_desc = n_desc, 
				@id_desc_display_name = n_display_name
		 		from t_base_props where id_prop = @a_id_prop
				exec DeleteDescription @id_desc_display_name
				exec DeleteDescription @id_desc_name
				exec DeleteDescription @id_desc_desc
				DELETE FROM t_base_props WHERE id_prop = @a_id_prop
			end
		