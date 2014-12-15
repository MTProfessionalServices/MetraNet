
					create proc AddCounterInstance
					            @id_lang_code int,
											@n_kind int,
											@nm_name nvarchar(255),
											@nm_desc nvarchar(255),
											@counter_type_id int, 
											@id_prop int OUTPUT 
					as
					begin
						DECLARE @identity_value int
						exec InsertBaseProps @id_lang_code, @n_kind, 'N', 'N', @nm_name, @nm_desc, null, @identity_value output
					INSERT INTO t_counter (id_prop, id_counter_type) values (@identity_value, @counter_type_id)
					SELECT 
						@id_prop = @identity_value
					end
        