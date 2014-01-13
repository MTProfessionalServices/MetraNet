
              CREATE OR REPLACE TRIGGER trg_t_export_param_names_id
                 BEFORE INSERT 
                 ON t_export_param_names
                 FOR EACH ROW
                 BEGIN
                    SELECT seq_t_export_param_names_id.NEXTVAL INTO :NEW.id_param_name
                      FROM DUAL;
                 END;
			 