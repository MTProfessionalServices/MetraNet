
CREATE OR REPLACE PROCEDURE updatebatchstatus (
   tx_batch           IN   RAW,
   tx_batch_encoded   IN   VARCHAR2,
   n_completed        IN   INT,
   sysdate_           IN   DATE
)
AS
   tx_batch_           RAW (255)      := tx_batch;
   tx_batch_encoded_   VARCHAR2 (24)  := tx_batch_encoded;
   n_completed_        NUMBER (10, 0) := n_completed;
   sysdate__           DATE           := sysdate_;
   stoo_selcnt         INTEGER;
   initialstatus       CHAR (1);
   finalstatus         CHAR (1);

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
      stoo_selcnt := 0;

      SELECT count(1)
        INTO stoo_selcnt
                    FROM t_batch
                   WHERE tx_batch =
                                           hextoraw(updatebatchstatus.tx_batch_)
                                           ;
   IF stoo_selcnt = 0
   THEN
      INSERT INTO t_batch
                  (id_batch, tx_namespace,
                   tx_name,
                   tx_batch,
                   tx_batch_encoded, tx_status, n_completed, n_failed,
                   dt_first, dt_crt
                  )
           VALUES (seq_t_batch.NEXTVAL, 'pipeline',
                   updatebatchstatus.tx_batch_encoded_,
                   updatebatchstatus.tx_batch_,
                   updatebatchstatus.tx_batch_encoded_, 'A', 0, 0,
                   updatebatchstatus.sysdate__, updatebatchstatus.sysdate__
                  );
   END IF;

   SELECT tx_status into initialstatus
                 FROM t_batch
                WHERE tx_batch= hextoraw(updatebatchstatus.tx_batch_)
                for update;

   UPDATE t_batch
      SET t_batch.n_completed =
                          t_batch.n_completed + updatebatchstatus.n_completed_,
          t_batch.tx_status =
             CASE
                WHEN (   (  t_batch.n_completed
                          + t_batch.n_failed
                          + nvl(t_batch.n_dismissed, 0)
                          + updatebatchstatus.n_completed_
                         ) = t_batch.n_expected
                      OR (    ((  t_batch.n_completed
                                + t_batch.n_failed
                                + nvl(t_batch.n_dismissed, 0)
                                + updatebatchstatus.n_completed_
                               ) = t_batch.n_metered
                              )
                          AND t_batch.n_expected = 0
                         )
                     )
                   THEN 'C'
                WHEN (   (  t_batch.n_completed
                          + t_batch.n_failed
                          + nvl(t_batch.n_dismissed, 0)
                          + updatebatchstatus.n_completed_
                         ) < t_batch.n_expected
                      OR (    ((  t_batch.n_completed
                                + t_batch.n_failed
                                + nvl(t_batch.n_dismissed, 0)
                                + updatebatchstatus.n_completed_
                               ) < t_batch.n_metered
                              )
                          AND t_batch.n_expected = 0
                         )
                     )
                   THEN 'A'
                WHEN ((  t_batch.n_completed
                       + t_batch.n_failed
                       + nvl(t_batch.n_dismissed, 0)
                       + updatebatchstatus.n_completed_
                      ) > t_batch.n_expected
                     )
                AND t_batch.n_expected > 0
                   THEN 'F'
                ELSE t_batch.tx_status
             END,
          t_batch.dt_last = updatebatchstatus.sysdate__,
          t_batch.dt_first =
             CASE
                WHEN t_batch.n_completed = 0
                   THEN updatebatchstatus.sysdate__
                ELSE t_batch.dt_first
             END
    WHERE tx_batch = hextoraw(updatebatchstatus.tx_batch_);

   SELECT tx_status into finalstatus
                 FROM t_batch
                WHERE tx_batch = hextoraw(updatebatchstatus.tx_batch_);
				 COMMIT;
END updatebatchstatus;
  