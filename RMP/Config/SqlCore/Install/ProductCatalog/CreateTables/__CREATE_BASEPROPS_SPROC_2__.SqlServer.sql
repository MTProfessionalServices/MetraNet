
		create proc InsertBaseProps 
			@id_lang_code int,
			@a_kind int,
			@a_approved char(1),
			@a_archive char(1),
			@a_nm_name NVARCHAR(255),
			@a_nm_desc NVARCHAR(255),
			@a_nm_display_name NVARCHAR(255),
			@a_id_prop int OUTPUT,
			@id_display_name int OUTPUT,
			@id_display_desc int OUTPUT 
			
		AS
		begin
		  declare @id_name int
			exec UpsertDescription @id_lang_code, @a_nm_display_name, NULL, @id_display_name output
			exec UpsertDescription @id_lang_code, @a_nm_name, NULL, @id_name output
			exec UpsertDescription @id_lang_code, @a_nm_desc, NULL, @id_display_desc output
			insert into t_base_props (n_kind, n_name, n_desc,nm_name,nm_desc,b_approved,b_archive,
			n_display_name, nm_display_name) values
			(@a_kind, @id_name, @id_display_desc, @a_nm_name,@a_nm_desc,@a_approved,@a_archive,
			 @id_display_name,@a_nm_display_name)
			select @a_id_prop =@@identity
	   end
   