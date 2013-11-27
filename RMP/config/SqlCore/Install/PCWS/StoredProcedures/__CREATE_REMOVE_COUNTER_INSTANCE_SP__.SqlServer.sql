
					create proc RemoveCounterInstance
											@id_prop int
					AS
					BEGIN TRAN
						DELETE FROM T_COUNTER_PARAM_PREDICATE WHERE id_counter_param IN 
						(SELECT id_counter_param FROM t_counter_params WHERE id_counter = @id_prop)
			  
						DELETE FROM T_COUNTER_PARAM_MAP WHERE id_counter_param IN 
						(SELECT id_counter_param FROM t_counter_params WHERE id_counter = @id_prop)
							
						DELETE FROM T_COUNTER_PARAMS WHERE id_counter = @id_prop
						delete from t_counter_map where id_counter = @id_prop
						
						DELETE FROM T_COUNTER WHERE id_prop = @id_prop
						DELETE FROM T_BASE_PROPS WHERE id_prop = @id_prop
 					COMMIT TRAN
        