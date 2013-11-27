
              CREATE OR REPLACE TRIGGER trg_t_export_execute_audit_id
                 BEFORE INSERT 
                 ON t_export_execute_audit
                 FOR EACH ROW
                 BEGIN
                    SELECT seq_t_export_execute_audit_id.NEXTVAL INTO :NEW.id_audit
                      FROM DUAL;
                 END;
			 