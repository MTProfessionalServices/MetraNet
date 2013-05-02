
              CREATE OR REPLACE TRIGGER trg_t_export_reports_id
                 BEFORE INSERT 
                 ON t_export_reports
                 FOR EACH ROW
                 BEGIN
                    SELECT seq_t_export_reports_id.NEXTVAL INTO :NEW.id_rep
                      FROM DUAL;
                 END;
			 