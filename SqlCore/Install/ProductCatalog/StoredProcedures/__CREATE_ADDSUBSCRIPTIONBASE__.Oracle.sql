
CREATE OR REPLACE
PROCEDURE addsubscriptionbase (
   p_id_acc         IN       INTEGER,
   p_id_group       IN       INTEGER,
   p_id_po          IN       INTEGER,
   p_startdate      IN       DATE,
   p_enddate        IN       DATE,
   p_guid           IN       RAW,
   p_systemdate     IN       DATE,
   p_id_sub                  INTEGER,
   p_quoting_batchid  IN       VARCHAR2,
   p_status         OUT      INTEGER,
   p_datemodified   OUT      VARCHAR,   
   p_allow_acc_po_curr_mismatch INTEGER default 0,
   p_allow_multiple_pi_sub_rcnrc INTEGER default 0
)
AS
   varmaxdatetime   DATE;
   realstartdate    DATE;
   realenddate      DATE;
   realguid         RAW (16);
   dummy            INT;
   tx_quoting_batchid RAW (16);
BEGIN
   varmaxdatetime := dbo.mtmaxdate ();
   p_status := 0;
   adjustsubdates (p_id_po,
                   p_startdate,
                   p_enddate,
                   realstartdate,
                   realenddate,
                   p_datemodified,
                   p_status
                  );

   IF p_status <> 1
   THEN
      RETURN;
   END IF; /* Check availability of the product offering */

   FOR i IN (SELECT (CASE
                        WHEN ta.n_begintype = 0 OR ta.n_endtype = 0
                           THEN -289472451
                        WHEN ta.n_begintype <> 0
                             AND ta.dt_start > p_systemdate
                           THEN -289472449
                        WHEN ta.n_endtype <> 0 AND ta.dt_end < p_systemdate
                           THEN -289472450
                        ELSE 1
                     END
                    ) tatus
               FROM t_po po INNER JOIN t_effectivedate ta ON po.id_avail =
                                                                ta.id_eff_date
              WHERE po.id_po = p_id_po)
   LOOP
      p_status := i.tatus;
   END LOOP;

   IF (p_status <> 1)
   THEN
      RETURN;
   END IF;

   IF (p_id_acc IS NOT NULL)
   THEN
      p_status :=
         dbo.checksubscriptionconflicts (p_id_acc,
                                         p_id_po,
                                         realstartdate,
                                         realenddate,
                                         -1,
                                         p_allow_acc_po_curr_mismatch,
                                         p_allow_multiple_pi_sub_rcnrc
                                        );

      IF (p_status <> 1)
      THEN
         RETURN;
      END IF; /* check if the po is BCR constrained.  If it is, make sure that the  usage cycles for all the payers during the subscription interval  matches the cycle type on the po. */

      SELECT COUNT (1)
        INTO dummy
        FROM t_payment_redirection pr INNER JOIN t_acc_usage_cycle auc ON pr.id_payer =
                                                                            auc.id_acc
             INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle =
                                                            auc.id_usage_cycle
       WHERE pr.id_payee = p_id_acc
         AND pr.vt_start <= realenddate
         AND realstartdate <= pr.vt_end
         AND EXISTS (
                SELECT 1
                  FROM t_pl_map plm
                 WHERE plm.id_paramtable IS NULL
                   AND plm.id_po = p_id_po
                   AND (   EXISTS (
                              SELECT 1
                                FROM t_aggregate a
                               WHERE a.id_prop = plm.id_pi_instance
                                 AND a.id_cycle_type IS NOT NULL
                                 AND a.id_cycle_type <> uc.id_cycle_type)
                        OR EXISTS (
                              SELECT 1
                                FROM t_discount d
                               WHERE d.id_prop = plm.id_pi_instance
                                 AND d.id_cycle_type IS NOT NULL
                                 AND d.id_cycle_type <> uc.id_cycle_type)
                        OR EXISTS (
                              SELECT 1
                                FROM t_recur r
                               WHERE r.id_prop = plm.id_pi_instance
                                 AND r.tx_cycle_mode = 'BCR Constrained'
                                 AND r.id_cycle_type IS NOT NULL
                                 AND r.id_cycle_type <> uc.id_cycle_type)
                       ));

      IF (dummy > 0)
      THEN
         p_status := -289472464; /* MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE (0xEEBF0030) */
         RETURN;
      END IF;

      SELECT COUNT (1)
        INTO dummy
        FROM t_payment_redirection pr INNER JOIN t_acc_usage_cycle auc ON pr.id_payer =
                                                                            auc.id_acc
             INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle =
                                                            auc.id_usage_cycle
       WHERE pr.id_payee = p_id_acc
         AND pr.vt_start <= realenddate
         AND EXISTS (
                SELECT 1
                  FROM t_pl_map plm
                 WHERE plm.id_paramtable IS NULL
                   AND plm.id_po = p_id_po
                   AND EXISTS (
                          SELECT 1
                            FROM t_recur rc
                           WHERE rc.id_prop = plm.id_pi_instance
                             AND rc.tx_cycle_mode = 'EBCR'
                             /*Weekly and biweekly can coexist*/
                             AND NOT (    (   (rc.id_cycle_type = 4)
                                           OR (rc.id_cycle_type = 5)
                                          )
                                      AND (   (uc.id_cycle_type = 4)
                                           OR (uc.id_cycle_type = 5)
                                          )
                                     )
                             /*Monthly, quarterly, semiannually, annually can coexist*/
                             AND NOT ((rc.id_cycle_type in (1,7,8,9))
                                      AND (uc.id_cycle_type in (1,7,8,9))
                                     )));

      IF (dummy > 0)
      THEN
         p_status := -289472444; /*MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE (0xEEBF0044)*/
         RETURN;
      END IF;
   END IF;

   IF (p_guid IS NULL)
   THEN
      SELECT SYS_GUID ()
        INTO realguid
        FROM DUAL;
   ELSE
      realguid := p_guid;
   END IF;

   tx_quoting_batchid := p_quoting_batchid;   
   createsubscriptionrecord (p_id_sub,
                             realguid,
                             p_id_acc,
                             p_id_group,
                             p_id_po,
                             p_systemdate,
                             tx_quoting_batchid,
                             realstartdate,
                             realenddate,
                             p_systemdate,
                             p_status
                            );
END;
		