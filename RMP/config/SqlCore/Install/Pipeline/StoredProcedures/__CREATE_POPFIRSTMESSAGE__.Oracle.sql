
CREATE OR REPLACE PROCEDURE popfirstmessage (
   p_pipelineid         INT,
   p_systemtime         DATE,
   p_messageid    OUT   INT,
   p_cur          OUT   sys_refcursor
)
AS
   v_messageid1   INT;

   CURSOR c1
   IS
      SELECT   id_message
          FROM t_message m
         WHERE m.dt_assigned IS NULL
           AND NOT EXISTS (
                  SELECT *
                    FROM t_session_set ss
                   WHERE ss.id_message = m.id_message
                     AND ss.id_svc NOT IN (
                            SELECT ps.id_svc
                              FROM t_pipeline_service ps INNER JOIN t_pipeline p
                                   ON ps.id_pipeline = p.id_pipeline
                             WHERE p.id_pipeline = p_pipelineid
                               AND p.b_paused = '0'
                               AND tt_end = dbo.mtmaxdate ()))
      ORDER BY id_message ASC;
BEGIN
   OPEN c1;

   LOOP
      BEGIN
         FETCH c1
          INTO v_messageid1;

         EXIT WHEN c1%NOTFOUND;

         SELECT        id_message
                  INTO p_messageid
                  FROM t_message
                 WHERE id_message = v_messageid1
				 and dt_assigned IS NULL
         FOR UPDATE OF id_pipeline, dt_assigned SKIP LOCKED;

         EXIT;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            p_messageid := NULL;
      END;
   END LOOP;

   CLOSE c1;

   IF p_messageid IS NOT NULL
   THEN
      UPDATE t_message
         SET dt_assigned = p_systemtime,
             id_pipeline = p_pipelineid
       WHERE id_message = p_messageid;

      OPEN p_cur FOR
         SELECT ss.id_message, ss.id_svc, ss.session_count, m.id_feedback
           FROM t_session_set ss INNER JOIN t_message m
                ON ss.id_message = m.id_message
          WHERE ss.id_message = p_messageid;

      COMMIT;
   ELSE
/* next line is a hack for now: don't know how to handle conditional rowsets */
      OPEN p_cur FOR
         select cast(-1 as number(10)) as id_message from dual;
   END IF;
END;
			