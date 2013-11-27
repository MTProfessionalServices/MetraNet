
              CREATE OR REPLACE TRIGGER trg_t_sch_daily_id_schedule
                 BEFORE INSERT 
                 ON t_sch_daily
                 FOR EACH ROW
                 BEGIN
                    SELECT seq_t_sch_daily_id_schedule.NEXTVAL INTO :NEW.id_schedule_daily
                      FROM DUAL;
                 END;
			 