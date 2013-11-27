
				declare @id as int
				exec sp_InsertBaseProps @a_kind = %%TYPE%%,@a_nameID = NULL,
				@a_descID = NULL,@a_approved = 'N',@a_archive = 'N',@a_nm_name = N'%%NAME_STR%%',@a_nm_desc = N'%%DESC_STR%%',
				@a_id_prop = @id OUTPUT
				select @id
			