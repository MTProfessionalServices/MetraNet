
						create proc DeleteCounterParamInstances
											(@id_counter	int)
						AS
						BEGIN
               -- delete mappings for shared parameters
               DELETE FROM t_counter_param_map WHERE id_counter =  @id_counter
               DELETE FROM T_BASE_PROPS WHERE id_prop IN
              (SELECT id_counter_param FROM t_counter_params WHERE id_counter = @id_counter)
              DELETE FROM T_COUNTER_PARAM_PREDICATE WHERE id_counter_param IN
              (SELECT id_counter_param FROM t_counter_params WHERE id_counter = @id_counter)
						  DELETE FROM T_COUNTER_PARAMS WHERE id_counter = @id_counter
            END
        