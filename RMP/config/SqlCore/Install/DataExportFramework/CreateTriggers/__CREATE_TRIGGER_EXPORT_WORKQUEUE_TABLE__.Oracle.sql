
              CREATE OR REPLACE TRIGGER TRG_t_export_workqueue
                 BEFORE INSERT 
                 ON t_export_workqueue
                 FOR EACH ROW
                 BEGIN
                    SELECT t_export_workqueue_c_id_work_q.NEXTVAL INTO :NEW.c_id_work_queue_int
                      FROM DUAL;
                 END;
			 