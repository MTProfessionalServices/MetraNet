
					CREATE PROC RemoveCounterPropDef
											@id_prop int
					AS
					DECLARE @id_locale int
					BEGIN TRAN
						DELETE FROM t_counter_map 
							WHERE id_cpd = @id_prop 
						DELETE FROM t_counterpropdef WHERE id_prop = @id_prop
            /* CR 14459 */
            exec DeleteBaseProps @id_prop
					COMMIT TRAN
        