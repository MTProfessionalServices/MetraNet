
				CREATE OR REPLACE PROCedure DeleteCounterParamTypes(temp_id_counter_type int)
				AS
					   str varchar2(100);
				BEGIN

					insert into TempCounterType	SELECT id_prop FROM t_counter_params_metadata WHERE id_counter_meta = temp_id_counter_type;
					DELETE FROM t_counter_params_metadata WHERE id_prop IN (SELECT id_prop FROM TempCounterType);
					DELETE FROM t_base_props WHERE id_prop IN (SELECT id_prop FROM TempCounterType);
				end;
			