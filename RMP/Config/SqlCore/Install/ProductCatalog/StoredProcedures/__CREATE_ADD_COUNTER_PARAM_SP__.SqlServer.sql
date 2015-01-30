
			create proc AddCounterParam
                  @id_lang_code int,
									@id_counter int,
									@id_counter_param_type int,
									@nm_counter_Value nvarchar(255),
                  @nm_name nvarchar(255),
                  @nm_desc nvarchar(255),
                  @nm_display_name nvarchar(255),
									@identity int OUTPUT
			AS
			DECLARE @identity_value int
			DECLARE @id_display_name int
			DECLARE @id_display_desc int
			BEGIN TRAN
				exec InsertBaseProps @id_lang_code, 190, 'N', 'N', @nm_name, @nm_desc, @nm_display_name, @identity_value output, @id_display_name output, @id_display_desc output
				INSERT INTO t_counter_params 
					(id_counter_param, id_counter, id_counter_param_meta, Value) 
				VALUES 
					(@identity_value, @id_counter, @id_counter_param_type, @nm_counter_value)
				SELECT 
					@identity = @identity_value
			COMMIT TRAN
		