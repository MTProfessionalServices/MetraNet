
		create proc InsertBaseProps 
			@id_lang_code int,
			@a_kind int,
			@a_approved char(1),
			@a_archive char(1),
			@a_nm_name NVARCHAR(255),
			@a_nm_desc NVARCHAR(255),
			@a_nm_display_name NVARCHAR(255),
			@a_id_prop int OUTPUT 
		AS
		begin
		  declare @id_desc_display_name int
      declare @id_desc_name int
      declare @id_desc_desc int
			exec UpsertDescription @id_lang_code, @a_nm_display_name, NULL, @id_desc_display_name output
			exec UpsertDescription @id_lang_code, @a_nm_name, NULL, @id_desc_name output
			exec UpsertDescription @id_lang_code, @a_nm_desc, NULL, @id_desc_desc output
			insert into t_base_props (n_kind, n_name, n_desc,nm_name,nm_desc,b_approved,b_archive,
			n_display_name, nm_display_name) values
			(@a_kind, @id_desc_name, @id_desc_desc, @a_nm_name,@a_nm_desc,@a_approved,@a_archive,
			 @id_desc_display_name,@a_nm_display_name)
			select @a_id_prop =@@identity
	   end
   