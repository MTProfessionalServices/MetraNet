
			create proc sp_InsertBaseProps @a_kind int,
						@a_nameID int,
						@a_descID int,
						@a_approved char(1),
						@a_archive char(1),
						@a_nm_name NVARCHAR(255),
						@a_nm_desc NVARCHAR(255),
						@a_id_prop int OUTPUT
			as
			insert into t_base_props (n_kind,n_name,n_desc,nm_name,nm_desc,b_approved,b_archive) values
				(@a_kind,@a_nameID,@a_descID,@a_nm_name,@a_nm_desc,@a_approved,@a_archive)
			select @a_id_prop =@@identity
	 