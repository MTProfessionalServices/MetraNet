
              CREATE OR REPLACE TRIGGER trg_t_export_default_param_val
                 BEFORE INSERT 
                 ON t_export_default_param_values
                 FOR EACH ROW
                 BEGIN
                    SELECT seq_t_export_default_param_val.NEXTVAL INTO :NEW.id_param_values
                      FROM DUAL;
                 END;
			 