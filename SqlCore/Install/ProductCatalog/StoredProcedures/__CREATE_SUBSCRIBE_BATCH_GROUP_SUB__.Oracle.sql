
CREATE OR REPLACE PROCEDURE subscribebatchgroupsub (
   tmp_subscribe_batch_tmp           NVARCHAR2,
   tmp_account_state_rules_tmp       NVARCHAR2,
   corp_business_rule_enforced   NUMBER,
   dt_now                        DATE,
   p_allow_acc_po_curr_mismatch INTEGER default 0,
   p_allow_multiple_pi_sub_rcnrc INTEGER default 0
)
AS
BEGIN 
   UPDATE tmp_subscribe_batch
      SET vt_end = dbo.mtmaxdate (),
          uncorrected_vt_end = dbo.mtmaxdate ()
    WHERE vt_end IS NULL; /* First clip the start and end date with the effective date on the subscription   * and validate that the intersection of the effective date on the sub and the   * delete interval is non-empty.   */

   UPDATE tmp_subscribe_batch ub
      SET (vt_start, vt_end, status, id_sub, id_po) =
             (SELECT dbo.mtmaxoftwodates (ub.vt_start,
                                          s.vt_start) AS vt_start,
                     dbo.mtminoftwodates (ub.vt_end, s.vt_end) AS vt_end,
                     CASE
                        WHEN ub.vt_start < s.vt_end
                        AND ub.vt_end > s.vt_start
                           THEN 0
                        ELSE -486604712
                     END AS status,
                     s.id_sub AS id_sub, s.id_po AS id_po
                FROM t_sub s
               WHERE s.id_group = ub.id_group)
    WHERE EXISTS (
             SELECT dbo.mtmaxoftwodates (ub.vt_start, s.vt_start) AS vt_start,
                    dbo.mtminoftwodates (ub.vt_end, s.vt_end) AS vt_end,
                    CASE
                       WHEN ub.vt_start < s.vt_end
                       AND ub.vt_end > s.vt_start
                          THEN 0
                       ELSE 1
                    END AS status,
                    s.id_sub AS id_sub, s.id_po AS id_po
               FROM t_sub s
              WHERE s.id_group = ub.id_group); /* Next piece of data massaging is to clip the start date of the request   * with the creation date of the account (provided the account was created    * before the end date of the subscription request).   */

   UPDATE tmp_subscribe_batch ub
      SET ub.vt_start =
                   (SELECT dbo.mtmaxoftwodates (ub.vt_start, acc.dt_crt)
                      FROM t_account acc
                     WHERE ub.id_acc = acc.id_acc AND acc.dt_crt <= ub.vt_end)
    WHERE EXISTS (SELECT dbo.mtmaxoftwodates (ub.vt_start, acc.dt_crt)
                    FROM t_account acc
                   WHERE ub.id_acc = acc.id_acc AND acc.dt_crt <= ub.vt_end); 
   
   /* CR 13298: Eliminate duplicates   * MTPCUSER_DUPLICATE_ITEMS_IN_BATCH -289472432   */

   UPDATE tmp_subscribe_batch args
	   SET status = -289472432 
	  WHERE EXISTS (SELECT 1 from
                     (SELECT id_acc,  id_group
                                  FROM tmp_subscribe_batch
                                  GROUP BY id_acc, id_group
                                  HAVING COUNT (*) > 1) args1   
                       WHERE args.id_acc = args1.id_acc
                       AND args.id_group = args1.id_group
                       AND args.status = 0
                    ) ;

  /* Check that all potential group subscription members have the same currency on their profiles   * as the product offering.   * TODO: t_po table does not have an index on id_nonshared_pl.   * if below query affects performance, create it later.   */

IF p_allow_acc_po_curr_mismatch <> 1
THEN 

   UPDATE tmp_subscribe_batch ub
      SET status = -486604729 /* mt_account_po_currency_mismatch */
    WHERE EXISTS (
             SELECT 1
               FROM t_po po,
                    t_payment_redirection pr,
                    t_av_internal tav,
                    t_pricelist pl1
              WHERE 	
                (pr.vt_start <= ub.vt_end AND pr.vt_end >= ub.vt_start) 
                AND tav.id_acc = pr.id_payer
                AND pr.id_payee = ub.id_acc
                AND ub.id_po = po.id_po
                AND pl1.id_pricelist = po.id_nonshared_pl
                AND tav.c_currency <> pl1.nm_currency_code
                AND ub.status = 0);
END IF;
                                    /* subscription request.  I don't want to create a new error message for   * this corner case (porting back to 3.0 for BT); so borrow account state   * message.   * MT_ADD_TO_GROUP_SUB_BAD_STATE   */

   UPDATE tmp_subscribe_batch ub
      SET status = -486604774
    WHERE EXISTS (
             SELECT 1
               FROM t_account acc
              WHERE ub.id_acc = acc.id_acc
                AND acc.dt_crt > ub.vt_end
                AND ub.status = 0); /* Check to see if the account is in a state in which we can   * subscribe it.   * TODO: This is the business rule as implemented in 3.5 and 3.0 (check only   * the account state in effect at the wall clock time that the subscription is made).   * What would be better is to ensure that there is no overlap between   * the valid time interval of any "invalid" account state and the subscription   * interval.     * MT_ADD_TO_GROUP_SUB_BAD_STATE   */

   UPDATE tmp_subscribe_batch ar
      SET status = -486604774
    WHERE EXISTS (
             SELECT 1
               FROM t_account_state ast INNER JOIN tmp_account_state_rules asr ON ast.status =
                                                                                          asr.state
              WHERE asr.can_subscribe = 0
                AND ar.status = 0
                AND ar.id_acc = ast.id_acc
                AND ast.vt_start <= ar.tt_now
                AND ast.vt_end >= ar.tt_now);
        /* Check that we're not already in the group sub with overlapping date
* MT_ACCOUNT_ALREADY_IN_GROUP_SUBSCRIPTION
*/

   UPDATE tmp_subscribe_batch ar
      SET status = -486604790
    WHERE EXISTS (
             SELECT 1
               FROM t_gsubmember s
              WHERE s.id_acc = ar.id_acc
                AND s.id_group = ar.id_group
                AND s.vt_start <= ar.vt_end
                AND ar.vt_start <= s.vt_end
                AND ar.status = 0);

   /* Check for different subscription to the same PO by the same account with overlapping date
   */
   UPDATE tmp_subscribe_batch ar
      SET status = -289472485
    WHERE EXISTS (
             /* Check for conflicting individual sub */
             SELECT 1
               FROM t_sub s
              WHERE s.id_po = ar.id_po
                AND s.id_acc = ar.id_acc
                AND s.id_sub <> ar.id_sub
                AND s.vt_start <= ar.vt_end
                AND ar.vt_start <= s.vt_end
                AND s.id_group IS NULL)
       OR     EXISTS (
                 /* Check for conflicting group sub */
                 SELECT 1
                   FROM t_gsubmember gs INNER JOIN t_sub s ON gs.id_group =
                                                                    s.id_group
                  WHERE gs.id_acc = ar.id_acc
                    AND s.id_po = ar.id_po
                    AND s.id_sub <> ar.id_sub
                    AND gs.vt_start <= ar.vt_end
                    AND ar.vt_start <= gs.vt_end)
          AND ar.status = 0;

   /* Check to make sure that effective date of PO intersects the corrected interval
    */
   UPDATE tmp_subscribe_batch ar
      SET status = -289472472
    WHERE EXISTS (
             SELECT 1
               FROM t_po p INNER JOIN t_effectivedate ed ON ed.id_eff_date =
                                                                 p.id_eff_date
              WHERE ar.id_po = p.id_po
                AND (ed.dt_start > ar.vt_start OR ed.dt_end < ar.vt_end)
                AND ar.status = 0);

   /* Check to see if there is another PO with the same PI template for which an overlapping subscription exists.
    * Only do this if other business rules have passed.
    */
   UPDATE tmp_subscribe_batch sb
      SET status = -289472484
    WHERE EXISTS (
             SELECT 1
               FROM t_pl_map plm1, t_vw_effective_subs s2, t_pl_map plm2
              WHERE sb.id_po = plm1.id_po
                AND s2.id_po = plm2.id_po
                AND plm1.id_pi_template = plm2.id_pi_template
                AND s2.id_acc = sb.id_acc
                AND s2.id_po <> sb.id_po
                AND s2.dt_start < sb.vt_end
                AND plm1.id_paramtable IS NULL
                AND plm2.id_paramtable IS NULL
                AND sb.vt_start < s2.dt_end
                AND sb.status = 0);

   /* MT_GSUB_DATERANGE_NOT_IN_SUB_RANGE
    */
   UPDATE tmp_subscribe_batch ar
      SET status = -486604789
    WHERE EXISTS (
             SELECT 1
               FROM t_sub s
              WHERE s.id_group = ar.id_group
                AND (ar.vt_start < s.vt_start OR ar.vt_end > s.vt_end)
                AND ar.status = 0);

   /* Check that the group subscription exists
    * MT_GROUP_SUBSCRIPTION_DOES_NOT_EXIST
    */
   UPDATE tmp_subscribe_batch ar
      SET status = -486604788
    WHERE NOT EXISTS (SELECT 1
                        FROM t_group_sub
                       WHERE t_group_sub.id_group = ar.id_group)
      AND ar.status = 0;

   /* If corp account business rule is enforced, check that
    * all potential gsub members are located in the same corporate hierarchy
    * as group subscription
    * bug fix 13689 corporate account need not be under root.
    * MT_ACCOUNT_NOT_IN_GSUB_CORPORATE_ACCOUNT
    */
   IF (corp_business_rule_enforced = 1)
   THEN
      UPDATE tmp_subscribe_batch ar
         SET status = -486604769
       WHERE EXISTS (
                SELECT 1
                  FROM t_group_sub gs,
                       t_account_ancestor aa,
                       t_account acc,
                       t_account_type atype
                 WHERE ar.id_group = gs.id_group
                   AND atype.id_type = acc.id_type
                   AND aa.id_ancestor = acc.id_acc
                   AND aa.id_descendent = ar.id_acc
                   AND aa.vt_start <= ar.tt_now
                   AND ar.tt_now <= aa.vt_end
                   AND atype.b_iscorporate = '1'
                   AND aa.num_generations = 0
                   AND aa.id_ancestor <> gs.id_corporate_account
                   AND ar.status = 0);
   END IF;

   /* MT_GROUP_SUB_MEMBER_CYCLE_MISMATCH
    * Check for billing cycle relative
    */
   UPDATE tmp_subscribe_batch ar
      SET status = -486604730
    WHERE EXISTS (
             SELECT 1
               FROM t_sub s, t_group_sub gs
              WHERE s.vt_end >= ar.tt_now
                AND ar.id_group = gs.id_group
                AND ar.id_group = s.id_group
                AND (
                        /* Only consider this business rule when the target PO
                         * has a billing cycle relative instance
                         */
                        EXISTS (
                           SELECT 1
                             FROM t_pl_map plm JOIN t_discount piinst ON piinst.id_prop =
                                                                           plm.id_pi_instance
                            WHERE plm.id_po = s.id_po
                              AND plm.id_paramtable IS NULL
                              AND piinst.id_usage_cycle IS NULL)
                     OR EXISTS (
                           SELECT 1
                             FROM t_pl_map plm JOIN t_recur piinst ON piinst.id_prop =
                                                                        plm.id_pi_instance
                            WHERE plm.id_po = s.id_po
                              AND plm.id_paramtable IS NULL
                              AND piinst.tx_cycle_mode IN
                                                   ('BCR', 'BCR Constrained'))
                     OR EXISTS (
                           SELECT 1
                             FROM t_pl_map plm JOIN t_aggregate piinst ON piinst.id_prop =
                                                                            plm.id_pi_instance
                            WHERE plm.id_po = s.id_po
                              AND plm.id_paramtable IS NULL
                              AND piinst.id_usage_cycle IS NULL)
                    )
                AND EXISTS (
                       /* All payers must have the same cycle as the cycle as the group sub itself
                        */
                       SELECT 1
                         FROM t_payment_redirection pr JOIN t_acc_usage_cycle auc ON auc.id_acc =
                                                                                       pr.id_payer
                        WHERE pr.id_payee = ar.id_acc
                          AND pr.vt_start <= s.vt_end
                          AND s.vt_start <= pr.vt_end
                          AND auc.id_usage_cycle <> gs.id_usage_cycle)
                AND ar.status = 0);

   /* fills the results table with a row for each member/payer combination
    */
   INSERT INTO ebcrresults
      SELECT batch.id_acc, payercycle.id_usage_cycle,
             dbo.checkebcrcycletypecompatible (payercycle.id_cycle_type,
                                               rc.id_cycle_type
                                              )
        FROM tmp_subscribe_batch batch INNER JOIN t_group_sub gs ON gs.id_group =
                                                                            batch.id_group
             INNER JOIN t_sub sub ON sub.id_group = gs.id_group
             INNER JOIN t_pl_map plmap ON plmap.id_po = sub.id_po
             INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_instance
             INNER JOIN t_payment_redirection pay ON pay.id_payee =
                                                                  batch.id_acc
                                                AND
                                                    /* checks all payer's who overlap with the group sub */
                                                    pay.vt_end >= sub.vt_start
                                                AND pay.vt_start <= sub.vt_end
             INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = pay.id_payer
             INNER JOIN t_usage_cycle payercycle ON payercycle.id_usage_cycle =
                                                            auc.id_usage_cycle
       WHERE rc.tx_cycle_mode = 'EBCR'
         AND rc.b_charge_per_participant = 'Y'
         AND plmap.id_paramtable IS NULL
         AND                                                                                                                                                                                                                                                                                                                                                                                                    /* todo: it would be better if we didn't consider subscriptions that ended
             * in a hard closed interval so that retroactive changes would be properly guarded.
             * only consider current or future group subs
             * don't worry about group subs in the past    */ (   (dt_now
                                                                      BETWEEN sub.vt_start
                                                                          AND sub.vt_end
                                                                  )
                                                               OR (sub.vt_start >
                                                                        dt_now
                                                                  )
                                                              )
         AND batch.status = 0;
        /* checks that members' payers are compatible with the EBCR cycle type
*/

   UPDATE tmp_subscribe_batch batch
      SET status =
             -289472443
                      /* mtpcuser_ebcr_cycle_conflicts_with_payer_of_member */
    WHERE EXISTS (SELECT 1
                    FROM ebcrresults res
                   WHERE res.id_acc = batch.id_acc AND res.b_compatible = 0);

   /* checks that each member has only one billing cycle across all payers
    */
   UPDATE tmp_subscribe_batch batch
      SET status =
                -289472442
                          /* mtpcuser_ebcr_members_conflict_with_each_other */
    WHERE EXISTS (
             SELECT 1
               FROM ebcrresults res INNER JOIN ebcrresults res2 ON res2.id_acc =
                                                                     res.id_acc
                                                              AND res2.b_compatible =
                                                                     res.b_compatible
                                                              AND res2.id_usage_cycle <>
                                                                     res.id_usage_cycle
              WHERE res.id_acc = batch.id_acc
                AND res.b_compatible = 1
                AND batch.status = 0);

   /* check that account type of each member is compatible with the product offering
    * since the absense of ANY mappings for the product offering means that PO is "wide open"
    * we need to do 2 EXISTS queries.
    */
   UPDATE tmp_subscribe_batch ar
      SET status = -289472435       /* mtpcuser_conflicting_po_account_type */
    WHERE (    EXISTS (SELECT 1
                         FROM t_po_account_type_map atmap
                        WHERE atmap.id_po = ar.id_po)
           /* PO is not wide open - see if susbcription is permitted for the account type
            */
           AND NOT EXISTS (
                      SELECT 1
                        FROM t_account tacc INNER JOIN t_po_account_type_map atmap ON atmap.id_account_type =
                                                                                        tacc.id_type
                       WHERE atmap.id_po = ar.id_po
                             AND ar.id_acc = tacc.id_acc)
          )
      AND status = 0;

   /* Check MTPCUSER_ACCOUNT_TYPE_CANNOT_PARTICIPATE_IN_GSUB 0xEEBF004FL -289472433
    */
   UPDATE tmp_subscribe_batch ar
      SET status = -289472433
    WHERE EXISTS (
             SELECT 1
               FROM t_account acc INNER JOIN t_account_type acctype ON acc.id_type =
                                                                         acctype.id_type
              WHERE ar.id_acc = acc.id_acc
                AND acctype.b_canparticipateingsub = '0'
                AND status = 0);

   /* This is a sequenced insert.  For sequenced updates/upsert, run the delete (unsubscribe) first.
    */
   INSERT INTO t_gsubmember_historical
               (id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
      SELECT ar.id_group, ar.id_acc, ar.vt_start, ar.vt_end, ar.tt_now,
             dbo.mtmaxdate ()
        FROM tmp_subscribe_batch ar
       WHERE ar.status = 0;

   INSERT INTO t_gsubmember
               (id_group, id_acc, vt_start, vt_end)
      SELECT ar.id_group, ar.id_acc, ar.vt_start, ar.vt_end
        FROM tmp_subscribe_batch ar
       WHERE ar.status = 0;

   /* Coalecse to merge abutting records
    * Implement coalescing to merge any gsubmember records to the
    * same subscription that are adjacent.  Still need to work on
    * what a bitemporal coalesce looks like.
    */
   LOOP
      UPDATE t_gsubmember gsm
         SET vt_end =
                (SELECT MAX (aa2.vt_end) AS maxend
                   FROM t_gsubmember aa2
                  WHERE gsm.id_group = aa2.id_group
                    AND gsm.id_acc = aa2.id_acc
                    AND gsm.vt_start < aa2.vt_start
                    AND gsm.vt_end + NUMTODSINTERVAL (1, 'second') >=
                                                                  aa2.vt_start
                    AND gsm.vt_end < aa2.vt_end)
       WHERE EXISTS (
                SELECT 1
                  FROM t_gsubmember aa2
                 WHERE gsm.id_group = aa2.id_group
                   AND gsm.id_acc = aa2.id_acc
                   AND gsm.vt_start < aa2.vt_start
                   AND gsm.vt_end + NUMTODSINTERVAL (1, 'second') >=
                                                                  aa2.vt_start
                   AND gsm.vt_end < aa2.vt_end)
         AND EXISTS (
                   SELECT 1
                     FROM tmp_subscribe_batch ar
                    WHERE ar.id_group = gsm.id_group
                          AND ar.id_acc = gsm.id_acc);

      EXIT WHEN SQL%ROWCOUNT <= 0;
   END LOOP;

   DELETE FROM t_gsubmember
         WHERE EXISTS (
                  SELECT 1
                    FROM t_gsubmember aa2
                   WHERE t_gsubmember.id_group = aa2.id_group
                     AND t_gsubmember.id_acc = aa2.id_acc
                     AND (   (    aa2.vt_start < t_gsubmember.vt_start
                              AND t_gsubmember.vt_end <= aa2.vt_end
                             )
                          OR (    aa2.vt_start <= t_gsubmember.vt_start
                              AND t_gsubmember.vt_end < aa2.vt_end
                             )
                         ))
           AND EXISTS (
                  SELECT 1
                    FROM tmp_subscribe_batch ar
                   WHERE ar.id_group = t_gsubmember.id_group
                     AND ar.id_acc = t_gsubmember.id_acc);

   /* Here is another approach.
    * Select a record that can be extended in valid time direction.
    * Issue an update statement to extend the vt_end and to set the
    * [tt_start, tt_end] to be the intersection of the original records
    * transaction time interval and the transaction time interval of the
    * extender.
    * Issue an insert statement to create 0,1 or 2 records that have the
    * same valid time interval as the original record but that have a new
    * tt_end or tt_start in the case that their associated tt_start or tt_end
    * extends beyond that of the extending record.
    *
    *  --------
    *  |      |
    *  |      |
    *  |   ---------
    *  |   |  |    |
    *  |   |  |    |
    *  |   |  |    |
    *  --------    |
    *      |       |
    *      |       |
    *      ---------
    */
   LOOP
      INSERT INTO tmp_coalesce_args
                  (id_group, id_acc, vt_start, vt_end, tt_start, tt_end,
                   update_tt_start, update_tt_end, update_vt_end)
         SELECT   gsm.id_group, gsm.id_acc, gsm.vt_start, gsm.vt_end,
                  gsm.tt_start, gsm.tt_end,
                  dbo.mtmaxoftwodates (gsm.tt_start,
                                       gsm2.tt_start
                                      ) AS update_tt_start,
                  dbo.mtminoftwodates (gsm.tt_end,
                                       gsm2.tt_end
                                      ) AS update_tt_end,
                  MAX (gsm2.vt_end) AS update_vt_end
             FROM t_gsubmember_historical gsm INNER JOIN t_gsubmember_historical gsm2 ON gsm.id_group =
                                                                                           gsm2.id_group
                                                                                    AND gsm.id_acc =
                                                                                           gsm2.id_acc
                                                                                    AND gsm.vt_start <
                                                                                           gsm2.vt_start
                                                                                    AND gsm2.vt_start <=
                                                                                             gsm.vt_end
                                                                                           + NUMTODSINTERVAL
                                                                                                (1,
                                                                                                 'second'
                                                                                                )
                                                                                    AND gsm.vt_end <
                                                                                           gsm2.vt_end
                                                                                    AND gsm.tt_start <=
                                                                                           gsm2.tt_end
                                                                                    AND gsm2.tt_start <=
                                                                                           gsm.tt_end
            WHERE EXISTS (
                     SELECT 1
                       FROM tmp_subscribe_batch ar
                      WHERE ar.id_group = gsm.id_group
                        AND ar.id_acc = gsm.id_acc)
         GROUP BY gsm.id_group,
                  gsm.id_acc,
                  gsm.vt_start,
                  gsm.vt_end,
                  gsm.tt_start,
                  gsm.tt_end,
                  dbo.mtmaxoftwodates (gsm.tt_start, gsm2.tt_start),
                  dbo.mtminoftwodates (gsm.tt_end, gsm2.tt_end);

      EXIT WHEN SQL%ROWCOUNT <= 0;

      /* These are the records whose extender transaction time ends strictly within the record being
       * extended
       */
      INSERT INTO t_gsubmember_historical
                  (id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
         SELECT gsm.id_group, gsm.id_acc, gsm.vt_start, gsm.vt_end,
                gsm2.vt_end + NUMTODSINTERVAL (1, 'second') AS tt_start,
                gsm.tt_end
           FROM t_gsubmember_historical gsm INNER JOIN t_gsubmember_historical gsm2 ON gsm.id_group =
                                                                                         gsm2.id_group
                                                                                  AND gsm.id_acc =
                                                                                         gsm2.id_acc
                                                                                  AND gsm.vt_start <
                                                                                         gsm2.vt_start
                                                                                  AND gsm2.vt_start <=
                                                                                           gsm.vt_end
                                                                                         + NUMTODSINTERVAL
                                                                                              (1,
                                                                                               'second'
                                                                                              )
                                                                                  AND gsm.vt_end <
                                                                                         gsm2.vt_end
                                                                                  AND gsm.tt_start <=
                                                                                         gsm2.tt_end
                                                                                  AND gsm2.tt_end <
                                                                                         gsm.tt_end
          WHERE EXISTS (
                   SELECT *
                     FROM tmp_subscribe_batch ar
                    WHERE ar.id_group = gsm.id_group
                          AND ar.id_acc = gsm.id_acc);

      /* These are the records whose extender starts strictly within the record being
       * extended
       */
      INSERT INTO t_gsubmember_historical
                  (id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
         SELECT gsm.id_group, gsm.id_acc, gsm.vt_start, gsm.vt_end,
                gsm.tt_start,
                gsm2.tt_start - NUMTODSINTERVAL (1, 'second') AS tt_end
           FROM t_gsubmember_historical gsm INNER JOIN t_gsubmember_historical gsm2 ON gsm.id_group =
                                                                                         gsm2.id_group
                                                                                  AND gsm.id_acc =
                                                                                         gsm2.id_acc
                                                                                  AND gsm.vt_start <
                                                                                         gsm2.vt_start
                                                                                  AND gsm2.vt_start <=
                                                                                           gsm.vt_end
                                                                                         + NUMTODSINTERVAL
                                                                                              (1,
                                                                                               'second'
                                                                                              )
                                                                                  AND gsm.vt_end <
                                                                                         gsm2.vt_end
                                                                                  AND gsm.tt_start <
                                                                                         gsm2.tt_start
                                                                                  AND gsm2.tt_start <=
                                                                                         gsm.tt_end
          WHERE EXISTS (
                   SELECT 1
                     FROM tmp_subscribe_batch ar
                    WHERE ar.id_group = gsm.id_group
                          AND ar.id_acc = gsm.id_acc);

      UPDATE t_gsubmember_historical gsm
         SET (vt_end, tt_start, tt_end) =
                (SELECT ca.update_vt_end, ca.update_tt_start,
                        ca.update_tt_end
                   FROM tmp_coalesce_args ca
                  WHERE gsm.id_group = ca.id_group
                    AND gsm.id_acc = ca.id_acc
                    AND gsm.vt_start = ca.vt_start
                    AND gsm.vt_end = ca.vt_end
                    AND gsm.tt_start = ca.tt_start
                    AND gsm.tt_end = ca.tt_end);

      DELETE FROM tmp_coalesce_args;
   END LOOP;

   /*  Here we select stuff to "delete"
    * In all cases we have containment invalid time.
    * Consider the four overlapping cases for transaction time.
    */
   UPDATE t_gsubmember_historical gsmh
      SET tt_start =
             (SELECT MAX (tt_end) + NUMTODSINTERVAL (1, 'second')
                FROM t_gsubmember_historical gsm
               WHERE gsmh.id_group = gsm.id_group
                 AND gsmh.id_acc = gsm.id_acc
                 AND gsm.vt_start <= gsmh.vt_start
                 AND gsmh.vt_end <= gsm.vt_end
                 AND gsm.tt_end >= gsmh.tt_start
                 AND gsm.tt_end < gsmh.tt_end)
    WHERE EXISTS (
             SELECT 1
               FROM t_gsubmember_historical gsm
              WHERE gsmh.id_group = gsm.id_group
                AND gsmh.id_acc = gsm.id_acc
                AND gsm.vt_start <= gsmh.vt_start
                AND gsmh.vt_end <= gsm.vt_end
                AND gsm.tt_end >= gsmh.tt_start
                AND gsm.tt_end < gsmh.tt_end)
      AND EXISTS (
                 SELECT 1
                   FROM tmp_subscribe_batch ar
                  WHERE ar.id_group = gsmh.id_group
                        AND ar.id_acc = gsmh.id_acc);

   UPDATE t_gsubmember_historical gsmh
      SET tt_end =
             (SELECT MIN (tt_start) - NUMTODSINTERVAL (1, 'second')
                FROM t_gsubmember_historical gsm
               WHERE gsmh.id_group = gsm.id_group
                 AND gsmh.id_acc = gsm.id_acc
                 AND gsm.vt_start <= gsmh.vt_start
                 AND gsmh.vt_end <= gsm.vt_end
                 AND gsm.tt_start > gsmh.tt_start
                 AND gsm.tt_start <= gsmh.tt_end)
    WHERE EXISTS (
             SELECT 1
               FROM t_gsubmember_historical gsm
              WHERE gsmh.id_group = gsm.id_group
                AND gsmh.id_acc = gsm.id_acc
                AND gsm.vt_start <= gsmh.vt_start
                AND gsmh.vt_end <= gsm.vt_end
                AND gsm.tt_start > gsmh.tt_start
                AND gsm.tt_start <= gsmh.tt_end)
      AND EXISTS (
                 SELECT 1
                   FROM tmp_subscribe_batch ar
                  WHERE ar.id_group = gsmh.id_group
                        AND ar.id_acc = gsmh.id_acc);

  /* ES2698  added the "ar" predicate to improve the performace of the delete 
    adding gsm.id_group,gsm.id_acc to the where clause and exists predicate 
    prevents a table scan on t_gsubmemember_historical  */ 
   DELETE      t_gsubmember_historical gsm
      WHERE (gsm.id_group, gsm.id_acc) in
                                    (SELECT   ar.id_group col1,
                                              ar.id_acc col2
                                         FROM tmp_subscribe_batch ar
                                     GROUP BY ar.id_group, ar.id_acc)
        AND EXISTS (
                  SELECT 1
                 FROM t_gsubmember_historical gsm2,
                      (SELECT   ar.id_group col1, ar.id_acc col2
                           FROM tmp_subscribe_batch ar
                       GROUP BY ar.id_group, ar.id_acc) temp0
                   WHERE gsm.id_group = gsm2.id_group
                     AND gsm.id_acc = gsm2.id_acc
                     AND (   (    gsm2.vt_start < gsm.vt_start
                              AND gsm.vt_end <= gsm2.vt_end
                             )
                          OR (    gsm2.vt_start <= gsm.vt_start
                              AND gsm.vt_end < gsm2.vt_end
                             )
                         )
                     AND gsm2.tt_start <= gsm.tt_start
                     AND gsm.tt_end <= gsm2.tt_end
                  AND gsm.id_group = temp0.col1
                  AND gsm.id_acc = temp0.col2); 

   /* Update audit information.
    */
   UPDATE tmp_subscribe_batch tmp
      SET tmp.nm_display_name =
                      (SELECT gsub.tx_name
                         FROM t_group_sub gsub
                        WHERE gsub.id_group = tmp.id_group AND tmp.status = 0);

   INSERT INTO t_audit
               (id_audit, id_event, id_userid, id_entitytype, id_entity,
                dt_crt)
      SELECT tmp.id_audit, tmp.id_event, tmp.id_userid, tmp.id_entitytype,
             tmp.id_acc, tmp.tt_now
        FROM tmp_subscribe_batch tmp
       WHERE tmp.status = 0;

   INSERT INTO t_audit_details
               (ID_AUDITDETAILS,id_audit, tx_details)
      SELECT SEQ_T_AUDIT_DETAILS.nextval,tmp.id_audit, tmp.nm_display_name
        FROM tmp_subscribe_batch tmp
       WHERE tmp.status = 0;

   END subscribebatchgroupsub;
		