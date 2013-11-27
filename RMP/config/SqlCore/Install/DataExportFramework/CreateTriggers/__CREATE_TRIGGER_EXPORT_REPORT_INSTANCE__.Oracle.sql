
              CREATE OR REPLACE TRIGGER trg_t_export_report_instance
                 BEFORE INSERT 
                 ON t_export_report_instance
                 FOR EACH ROW
                 BEGIN
                    SELECT seq_t_export_report_instance.NEXTVAL INTO :NEW.id_rep_instance_id
                      FROM DUAL;
                 END;
			 