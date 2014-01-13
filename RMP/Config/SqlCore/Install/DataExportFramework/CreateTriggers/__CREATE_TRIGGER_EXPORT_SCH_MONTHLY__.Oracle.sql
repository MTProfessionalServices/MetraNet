
              CREATE OR REPLACE TRIGGER trg_t_sch_monthly_id_schedule
                 BEFORE INSERT 
                 ON t_sch_monthly
                 FOR EACH ROW
                 BEGIN
                    SELECT seq_t_sch_monthly_id_schedule.NEXTVAL INTO :NEW.id_schedule_monthly
                      FROM DUAL;
                 END;
			 