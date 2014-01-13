
              CREATE OR REPLACE TRIGGER trg_t_export_schedule_id
                 BEFORE INSERT 
                 ON t_export_schedule
                 FOR EACH ROW
                 BEGIN
                    SELECT seq_t_export_schedule_id.NEXTVAL INTO :NEW.id_rp_schedule
                      FROM DUAL;
                 END;
			 