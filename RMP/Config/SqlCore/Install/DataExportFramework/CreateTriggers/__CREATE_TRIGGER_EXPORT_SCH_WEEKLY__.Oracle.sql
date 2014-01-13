
              CREATE OR REPLACE TRIGGER trg_t_sch_weekly_id_schedule
                 BEFORE INSERT 
                 ON t_sch_weekly
                 FOR EACH ROW
                 BEGIN
                    SELECT seq_t_sch_weekly_id_schedule.NEXTVAL INTO :NEW.id_schedule_weekly
                      FROM DUAL;
                 END;
			 