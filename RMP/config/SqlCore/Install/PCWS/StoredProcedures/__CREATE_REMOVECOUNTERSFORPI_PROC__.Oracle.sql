
Create or Replace procedure RemoveCountersForPI( p_piID int )
AS
	l_counterId int;
BEGIN
	DECLARE cursor counterCursor is select id_counter from t_counter_map where id_pi = p_piID;

			BEGIN
                OPEN counterCursor;
                IF counterCursor%ISOPEN THEN
                LOOP
                    FETCH counterCursor INTO l_counterId;
                    EXIT WHEN counterCursor%NOTFOUND;
                    
					delete from t_counter_param_predicate where id_counter_param in
						(select id_counter_param from t_counter_params where id_counter = l_counterId);

					delete from t_counter_param_map where id_counter_param in
						(select id_counter_param from t_counter_params where id_counter = l_counterId);						
						
					delete from t_counter_params where id_counter = l_counterId;
					
					delete from t_counter_map where id_counter = l_counterId;
										
					delete from t_counter where id_prop = l_counterId;
				
					delete from t_base_props where id_prop = l_counterId;
                    
                END LOOP;
                END IF;
                CLOSE counterCursor;
            END;		
END;
