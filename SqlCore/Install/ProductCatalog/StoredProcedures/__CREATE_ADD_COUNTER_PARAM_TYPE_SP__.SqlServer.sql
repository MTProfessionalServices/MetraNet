
						CREATE PROC AddCounterParamType			
									@id_lang_code int,
									@n_kind int,
									@nm_name nvarchar(255),
									@id_counter_type int,
									@nm_param_type varchar(255),
									@nm_param_dbtype varchar(255),
									@id_prop int OUTPUT 
			      AS
			      DECLARE @identity_value int
				  DECLARE @id_display_name int
				  DECLARE @id_display_desc int
			      BEGIN TRAN
			      exec InsertBaseProps @id_lang_code, @n_kind, 'N', 'N', @nm_name, NULL, NULL, @identity_value output, @id_display_name output, @id_display_desc output
			      INSERT INTO t_counter_params_metadata
					              (id_prop, id_counter_meta, ParamType, DBType) 
				    VALUES 
					              (@identity_value, @id_counter_type, @nm_param_type, @nm_param_dbtype)
            select @id_prop = @identity_value
      			COMMIT TRAN
    