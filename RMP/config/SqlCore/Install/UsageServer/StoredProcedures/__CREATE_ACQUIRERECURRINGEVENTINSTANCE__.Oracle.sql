
CREATE OR REPLACE PROCEDURE AcquireRecurringEventInstance (
   p_id_instance      IN     t_recevent_inst.ID_INSTANCE%TYPE,
   p_current_status   IN     t_recevent_inst.TX_STATUS%TYPE,
   p_new_status       IN     t_recevent_inst.TX_STATUS%TYPE,
   p_id_run           IN     t_recevent_run.ID_RUN%TYPE,
   p_tx_type          IN     t_recevent_run.TX_TYPE%TYPE,
   p_reversed_run     IN     t_recevent_run.ID_REVERSED_RUN%TYPE,
   p_tx_machine       IN     t_recevent_run.TX_MACHINE%TYPE,
   p_dt_start         IN     t_recevent_run.DT_START%TYPE,
   p_status              OUT INT)
AS
   v_eventName   VARCHAR2 (255);
   v_className   VARCHAR2 (255);
   v_rowCount    INT;                                 /* Oracle, I love you */
BEGIN
   p_status := -1; /*  ESR-2885 , update using a stored procedure instead of sql block*/

  /* Take lock on run table as we will query it, make decisions and then update it */
  LOCK TABLE t_recevent_run IN EXCLUSIVE MODE;

   /* Check that the event is still compatible with running events */
BEGIN
   SELECT evt.tx_name
     INTO v_eventName
     FROM    t_recevent evt
          INNER JOIN
             t_recevent_inst evt_inst
          ON evt.id_event = evt_inst.id_event
             AND evt_inst.id_instance = p_id_instance;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN  p_status := -4;
END;

   SELECT COUNT (*)
     INTO v_rowCount
     FROM TABLE (dbo.GetCompatibleConcurrentEvents)
    WHERE tx_compatible_eventname = v_eventName;

   IF (v_rowCount = 0)
   THEN
      COMMIT;
      p_status := -2; /*Can not run concurrently with other running adapters at the moment*/
      RETURN;
   END IF;     
                                                                                                                                                                                                                                                                                                                                                                                            
    /* Check that if this is a adapter of a class that has MultiInstance set to false, don't allow it to run if other instances of the class are running */
   BEGIN
      SELECT tx_class_name
        INTO v_classname
        FROM    t_recevent_inst evt_inst
             INNER JOIN
                t_recevent evt
             ON evt_inst.id_event = evt.id_event
       WHERE evt_inst.id_instance = p_id_instance
             AND evt.b_multiinstance = 'N';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         v_classname := NULL;
   END;

   IF (v_classname IS NOT NULL)
   THEN
      /* Class doesn't allow multiple instances, see if any other events with this class are running */
      SELECT COUNT (*)
        INTO v_rowCount
        FROM t_recevent_run evt_run
             INNER JOIN t_recevent_inst evt_inst2
                ON evt_inst2.id_instance = evt_run.id_instance
             INNER JOIN t_recevent evt2
                ON evt2.id_event = evt_inst2.id_event
       WHERE evt_run.tx_status = 'InProgress'
             AND evt2.tx_class_name = v_classname;

      IF (v_rowCount > 0)
      THEN                   /* Another event with the same clas is running */
         COMMIT;
         p_status := -3; /*Can not run concurrently with other running adapters at the moment*/
         RETURN;
      END IF;
   END IF;

   UPDATE t_recevent_inst
      SET tx_status = p_new_status, b_ignore_deps = 'N', dt_effective = NULL
    WHERE id_instance = p_id_instance AND tx_status = p_current_status; /* the instance may not have been acquired if       another billing server picked it up first   */

   IF (SQL%ROWCOUNT > 0)
   THEN
      INSERT INTO t_recevent_run (id_run,
                                  id_instance,
                                  tx_type,
                                  id_reversed_run,
                                  tx_machine,
                                  dt_start,
                                  dt_end,
                                  tx_status,
                                  tx_detail)
           VALUES (p_id_run,
                   p_id_instance,
                   p_tx_type,
                   p_reversed_run,
                   p_tx_machine,
                   p_dt_start,
                   NULL,
                   'InProgress',
                   NULL);

      COMMIT;   /* success   */
      p_status := 0;
   END IF;
END AcquireRecurringEventInstance;
  