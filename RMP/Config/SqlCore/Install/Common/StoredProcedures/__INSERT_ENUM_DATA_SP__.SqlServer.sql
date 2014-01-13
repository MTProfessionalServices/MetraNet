
				CREATE PROC InsertEnumData	@nm_enum_data nvarchar(255),
											@id_enum_data int OUTPUT
				as
				begin tran

				if not exists (select * from t_enum_data where nm_enum_data = @nm_enum_data )
				begin
					insert into t_mt_id default values
					select @id_enum_data = @@identity

					insert into t_enum_data (nm_enum_data, id_enum_data) values ( @nm_enum_data, @id_enum_data )
					if ((@@error != 0) OR (@@rowCount != 1))
					begin
						rollback transaction
						select @id_enum_data = -99
					end
				end
				else
				begin
					select @id_enum_data = id_enum_data from t_enum_data
					where nm_enum_data = @nm_enum_data
				end
				commit transaction
			 