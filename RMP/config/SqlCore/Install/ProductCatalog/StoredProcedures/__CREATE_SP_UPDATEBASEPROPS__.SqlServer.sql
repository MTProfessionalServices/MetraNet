
			create procedure UpdateBaseProps(
			@a_id_prop int,
			@a_id_lang int,
			@a_nm_name NVARCHAR(255),
			@a_nm_desc NVARCHAR(4000),
			@a_nm_display_name NVARCHAR(255))
		AS
		begin
      declare @old_id_name int
      declare @id_name int
      declare @old_id_desc int
      declare @id_desc int
      declare @old_id_display_name int
      declare @id_display_name int
			select @old_id_name = n_name, @old_id_desc = n_desc, 
			@old_id_display_name = n_display_name
     	from t_base_props where id_prop = @a_id_prop
			exec UpsertDescription @a_id_lang, @a_nm_name, @old_id_name, @id_name output
			exec UpsertDescription @a_id_lang, @a_nm_desc, @old_id_desc, @id_desc output
			exec UpsertDescription @a_id_lang, @a_nm_display_name, @old_id_display_name, @id_display_name output
			UPDATE t_base_props
				SET n_name = @id_name, n_desc = @id_desc, n_display_name = @id_display_name,
						nm_name = @a_nm_name, nm_desc = @a_nm_desc, nm_display_name = @a_nm_display_name
				WHERE id_prop = @a_id_prop
		END
		