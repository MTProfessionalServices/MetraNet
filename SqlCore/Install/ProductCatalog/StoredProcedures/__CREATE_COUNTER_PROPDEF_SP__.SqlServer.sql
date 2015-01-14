
					CREATE PROC CreateCounterPropDef
											@id_lang_code int,
											@n_kind int,
											@nm_name nvarchar(255),
											@nm_display_name nvarchar(255),
											@id_pi int,
											@nm_servicedefprop nvarchar(255),
											@nm_preferredcountertype nvarchar(255),
											@n_order int, 
											@id_prop int OUTPUT 
					AS
					DECLARE @identity_value int
					DECLARE @id_locale int
					DECLARE @id_display_name int
					DECLARE @id_display_desc int
					BEGIN TRAN
						exec InsertBaseProps @id_lang_code, @n_kind, 'N', 'N', @nm_name, NULL, @nm_display_name, @identity_value output, @id_display_name output, @id_display_desc output
						INSERT INTO t_counterpropdef 
							(id_prop, id_pi, nm_servicedefprop, n_order, nm_preferredcountertype) 
						VALUES 
							(@identity_value, @id_pi, @nm_servicedefprop, @n_order, @nm_preferredcountertype)
						SELECT 
						@id_prop = @identity_value
					COMMIT TRAN
       