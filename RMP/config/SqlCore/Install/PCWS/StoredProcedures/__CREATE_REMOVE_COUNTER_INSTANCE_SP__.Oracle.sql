
				CREATE OR REPLACE procedure RemoveCounterInstance
				(p_id_prop int)
				AS
		    BEGIN
					DELETE FROM T_COUNTER_PARAM_PREDICATE WHERE id_counter_param IN
				   (SELECT id_counter_param FROM t_counter_params WHERE id_counter = p_id_prop);
				   
					DELETE FROM T_COUNTER_PARAM_MAP WHERE id_counter_param IN 
					(SELECT id_counter_param FROM t_counter_params WHERE id_counter = p_id_prop);
							
					DELETE FROM T_COUNTER_PARAMS WHERE id_counter = p_id_prop;
					DELETE FROM T_COUNTER_MAP WHERE id_counter = p_id_prop;
					DELETE FROM T_COUNTER WHERE id_prop = p_id_prop;
					DELETE FROM T_BASE_PROPS WHERE id_prop = p_id_prop;
 		    end;
        