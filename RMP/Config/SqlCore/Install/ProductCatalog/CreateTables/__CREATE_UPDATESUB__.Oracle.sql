
CREATE OR REPLACE PROCEDURE updatesub (
   p_id_sub                          INT,
   p_dt_start                        DATE,
   p_dt_end                          DATE,
   p_nextcycleafterstartdate         VARCHAR2,
   p_nextcycleafterenddate           VARCHAR2,
   p_id_po                           INT,
   p_id_acc                          INT,
   p_systemdate                      DATE,
   p_status                    OUT   INT,
   p_datemodified              OUT   VARCHAR2,
   p_allow_acc_po_curr_mismatch int := 0,
   p_allow_multiple_pi_sub_rcnrc int :=0
)
AS
   real_begin_date        DATE;
   real_end_date          DATE;
   temp_id_acc            INT;
   temp_guid              RAW (16);
   varmaxdatetime         DATE;
   varsystemgmtdatetime   DATE;
   id_group               INTEGER;
   cycle_type             INTEGER;
   po_cycle               INTEGER;
   dummy                  INT;
BEGIN
   varmaxdatetime := dbo.mtmaxdate ();
   /* step 1: compute usage cycle dates if necessary */
   p_status := 0;

   BEGIN
      SELECT id_sub_ext
        INTO temp_guid
        FROM t_sub
       WHERE id_sub = p_id_sub;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;

   IF p_id_acc IS NOT NULL
   THEN
      IF (p_nextcycleafterstartdate = 'Y')
      THEN
         real_begin_date :=
                         dbo.nextdateafterbillingcycle (p_id_acc, p_dt_start);
      ELSE
         real_begin_date := p_dt_start;
      END IF;

      IF (p_nextcycleafterenddate = 'Y')
      THEN
         /* CR 5785: make sure the end date of the subscription if using billing cycle */
         /* relative is at the end of the current billing cycle */
         real_end_date :=
            dbo.subtractsecond (dbo.nextdateafterbillingcycle (p_id_acc,
                                                               p_dt_end
                                                              )
                               );
      ELSE
         real_end_date := p_dt_end;
      END IF;

      /* step 2: if the begin date is after the end date, make the begin date match the end date */
      IF (real_begin_date > real_end_date)
      THEN
         real_begin_date := real_end_date;
      END IF;

      p_status :=
         dbo.checksubscriptionconflicts (p_id_acc,
                                         p_id_po,
                                         real_begin_date,
                                         real_end_date,
                                         p_id_sub,
                                         p_allow_acc_po_curr_mismatch,
                                         p_allow_multiple_pi_sub_rcnrc
                                        );

      IF (p_status <> 1)
      THEN
         RETURN;
      END IF;

      /* check if the po is BCR constrained.  If it is, make sure that the
       usage cycles for all the payers during the subscription interval
       matches the cycle type on the po. */
      SELECT COUNT (1)
        INTO dummy
        FROM t_payment_redirection pr INNER JOIN t_acc_usage_cycle auc
             ON pr.id_payer = auc.id_acc
             INNER JOIN t_usage_cycle uc
             ON uc.id_usage_cycle = auc.id_usage_cycle
       WHERE pr.id_payee = p_id_acc
         AND pr.vt_start <= real_end_date
         AND real_begin_date <= pr.vt_end
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
         p_status := -289472464;
         /* MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE (0xEEBF0030) */
         RETURN;
      END IF;

      SELECT COUNT (1)
        INTO dummy
        FROM t_payment_redirection pr INNER JOIN t_acc_usage_cycle auc
             ON pr.id_payer = auc.id_acc
             INNER JOIN t_usage_cycle uc
             ON uc.id_usage_cycle = auc.id_usage_cycle
       WHERE pr.id_payee = p_id_acc
         AND pr.vt_start <= real_end_date
         AND real_begin_date <= pr.vt_end
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
                             AND NOT (    (   (rc.id_cycle_type = 4)
                                           OR (rc.id_cycle_type = 5)
                                          )
                                      AND (   (uc.id_cycle_type = 4)
                                           OR (uc.id_cycle_type = 5)
                                          )
                                     )
                             AND NOT (    (   (rc.id_cycle_type = 1)
                                           OR (rc.id_cycle_type = 7)
                                           OR (rc.id_cycle_type = 8)
                                           OR (rc.id_cycle_type = 9)
                                          )
                                      AND (   (uc.id_cycle_type = 1)
                                           OR (uc.id_cycle_type = 7)
                                           OR (uc.id_cycle_type = 8)
                                           OR (uc.id_cycle_type = 9)
                                          )
                                     )));

      IF (dummy > 0)
      THEN
         p_status := -289472444;
         /* MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE (0xEEBF0044) */
         RETURN;
      END IF;
   ELSE
      FOR i IN (SELECT p_dt_start, p_dt_end, id_group
                  FROM t_sub
                 WHERE id_sub = p_id_sub)
      LOOP
         real_begin_date := i.p_dt_start;
         real_end_date := i.p_dt_end;
         id_group := i.id_group;
      END LOOP;
   END IF;

   /* verify that the start and end dates are inside the product offering effective */
   /* date */
   adjustsubdates (p_id_po,
                   real_begin_date,
                   real_end_date,
                   real_begin_date,
                   real_end_date,
                   p_datemodified,
                   p_status
                  );

   IF p_status <> 1
   THEN
      RETURN;
   END IF;

   createsubscriptionrecord (p_id_sub,
                             temp_guid,
                             p_id_acc,
                             id_group,
                             p_id_po,
                             p_systemdate,                             
                             null,
                             real_begin_date,
                             real_end_date,
                             p_systemdate,
                             p_status                             
                            );
   RETURN;
END;
					