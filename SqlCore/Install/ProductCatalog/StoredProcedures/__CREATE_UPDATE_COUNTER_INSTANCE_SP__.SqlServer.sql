
					create proc UpdateCounterInstance
											@id_lang_code int,
                      @id_prop int,
											@counter_type_id int,
											@nm_name nvarchar(255),
											@nm_desc nvarchar(255)
					AS
					DECLARE @updated_id_display_name int
					DECLARE @updated_id_display_desc int
					BEGIN TRAN
            exec UpdateBaseProps @id_prop, @id_lang_code, NULL, @nm_desc, NULL, @updated_id_display_name OUTPUT, @updated_id_display_desc OUTPUT
						UPDATE 
 							t_base_props  
						SET 
 							nm_name = @nm_name, nm_desc = @nm_desc 
						WHERE 
 							id_prop = @id_prop
 						UPDATE 
 							t_counter
						SET 
 							id_counter_type = @counter_type_id
						WHERE 
 							id_prop = @id_prop
					COMMIT TRAN
			 