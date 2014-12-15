
					CREATE PROC UpdateCounterPropDef
											@id_lang_code int,
											@id_prop int,
											@nm_name nvarchar(255),
											@nm_display_name nvarchar(255),
											@id_pi int,
											@nm_servicedefprop nvarchar(255),
											@nm_preferredcountertype nvarchar(255),
											@n_order int
					AS
					DECLARE @identity_value int
						DECLARE @id_locale int
					BEGIN TRAN
						exec UpdateBaseProps @id_prop, @id_lang_code, @nm_name, NULL, @nm_display_name
						UPDATE t_counterpropdef 
						SET
							nm_servicedefprop = @nm_servicedefprop,
							n_order = @n_order,
							nm_preferredcountertype = @nm_preferredcountertype
						WHERE id_prop = @id_prop
					COMMIT TRAN
         