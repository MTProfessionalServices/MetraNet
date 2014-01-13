
						CREATE PROC DeleteCounterParamTypes			
									@id_counter_type int
			AS
			BEGIN TRAN
				SELECT id_prop INTO #TempCounterType FROM t_counter_params_metadata WHERE id_counter_meta = @id_counter_type
				DELETE FROM t_counter_params_metadata WHERE id_prop IN (SELECT id_prop FROM #TempCounterType)
				DELETE FROM t_base_props WHERE id_prop IN (SELECT id_prop FROM #TempCounterType)
			COMMIT TRAN
		