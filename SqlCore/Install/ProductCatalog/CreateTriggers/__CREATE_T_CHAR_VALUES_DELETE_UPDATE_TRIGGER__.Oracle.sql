              if updating THEN
                if :NEW.nm_value <> :OLD.nm_value THEN
                  insert into t_char_values_history
                  (id_scv, id_entity, nm_value, c_start_date, c_end_date, c_spec_name, c_spec_type)
                  values 
                  (:OLD.id_scv, :OLD.id_entity, :OLD.nm_value, :OLD.c_start_date, sysdate, :OLD.c_spec_name, :OLD.c_spec_type);
                END IF;
              END IF;
  
              if deleting THEN
                  insert into t_char_values_history
                  (id_scv, id_entity, nm_value, c_start_date, c_end_date, c_spec_name, c_spec_type)
                  values 
                  (:OLD.id_scv, :OLD.id_entity, :OLD.nm_value, :OLD.c_start_date, sysdate, :OLD.c_spec_name,:OLD.c_spec_type); 
              END IF;
  