
        /*  If the vt_end is null then use subscription end date */

        BEGIN
        UPDATE tmp_unsubscribe_batch
        SET 
        tmp_unsubscribe_batch.vt_end=dbo.MTMaxDate(),
        tmp_unsubscribe_batch.uncorrected_vt_end=dbo.MTMaxDate()
        WHERE
        tmp_unsubscribe_batch.vt_end is null;

        /*  First clip the start and end date with the effective date on the subscription */
        /*  and validate that the intersection of the effective date on the sub and the */
        /*  delete interval is non-empty. */

        for i in (  select ub.rowid ub_rowid, ub.vt_start ub_vt_start, s.vt_start s_vt_start ,ub.vt_end ub_vt_end, s.vt_end s_vt_end, s.id_sub s_id_sub, 
                    s.id_po s_id_po from
                    tmp_unsubscribe_batch ub
                    inner join t_sub s on s.id_group = ub.id_group)
        loop
            UPDATE tmp_unsubscribe_batch
            SET
            tmp_unsubscribe_batch.vt_start = dbo.MTMaxOfTwoDates(i.ub_vt_start, i.s_vt_start),
            tmp_unsubscribe_batch.vt_end   = dbo.MTMinOfTwoDates(i.ub_vt_end, i.s_vt_end),
            tmp_unsubscribe_batch.status   = case when i.ub_vt_start < i.s_vt_end and i.ub_vt_end > i.s_vt_start then 0 else 1 end,
            tmp_unsubscribe_batch.id_sub   = i.s_id_sub,
            tmp_unsubscribe_batch.id_po    = i.s_id_po
            where rowid = i.ub_rowid;
        end loop;

        /*  Next piece of data massaging is to clip the start date of the request */
        /*  with the creation date of the account (provided the account was created  */
        /*  before the end date of the subscription request). */
        FOR I IN (  select ub.rowid ub_rowid, ub.vt_start ub_vt_start, acc.dt_crt acc_dt_crt FROM
                    tmp_unsubscribe_batch ub
                    INNER JOIN t_account acc on ub.id_acc=acc.id_acc AND acc.dt_crt <= ub.vt_end) 
        LOOP
                    UPDATE tmp_unsubscribe_batch
                    SET
                    tmp_unsubscribe_batch.vt_start = dbo.MTMaxOfTwoDates(i.ub_vt_start, i.acc_dt_crt)
                    where rowid = i.ub_rowid;
        END LOOP;

        /* Check that all potential group subscription members have the same currency on their profiles */
        /* as the product offering. */
        /* TODO: t_po table does not have an index on id_nonshared_pl. */
        /*  if below query affects performance, create it later. */
        UPDATE tmp_unsubscribe_batch ub
        /*  MT_ACCOUNT_PO_CURRENCY_MISMATCH */
        SET
        status =  -486604729
        WHERE EXISTS
        ( SELECT 'x' FROM
        t_av_internal avi,t_po po,t_pricelist pl 
        WHERE
        avi.id_acc = ub.id_acc
        AND
        po.id_po = ub.id_po
        AND
        po.id_nonshared_pl = pl.id_pricelist
        AND
        avi.c_currency <> pl.nm_currency_code)
        AND
	%%CURRENCYUPDATESTATUS%%
	AND
        ub.status=0;

        UPDATE tmp_unsubscribe_batch ub
        /*  Error out if the account doesn't exist until after the end date of the  */
        /*  subscription request.  I don't want to create a new error message for */
        /*  this corner case (porting back to 3.0 for BT); so borrow account state */
        /*  message. */
        /*  MT_ADD_TO_GROUP_SUB_BAD_STATE */
        SET
        status = -486604774
        where exists(
        select 'x' FROM
        t_account acc where ub.id_acc=acc.id_acc AND acc.dt_crt > ub.vt_end)
        and
        ub.status=0;

        UPDATE tmp_unsubscribe_batch ar
        /*  Check to see if the account is in a state in which we can */
        /*  subscribe it. */
        /*  TODO: This is the business rule as implemented in 3.5 and 3.0 (check only */
        /*  the account state in effect at the wall clock time that the subscription is made). */
        /*  What would be better is to ensure that there is no overlap between */
        /*  the valid time interval of any "invalid" account state and the subscription */
        /*  interval.   */
        /*  MT_ADD_TO_GROUP_SUB_BAD_STATE */
        SET
        status = -486604774
        where exists
        (select 'x' FROM
        t_account_state ast,tmp_account_state_rules asr 
        WHERE
        ar.id_acc=ast.id_acc AND ast.vt_start <= ar.tt_now AND ast.vt_end >= ar.tt_now
        and 
        ast.status=asr.state
        and
        asr.can_subscribe=0)
        AND
        ar.status=0;

        /*  Check that we're not already in the group sub with overlapping date */
        /*  MT_ACCOUNT_ALREADY_IN_GROUP_SUBSCRIPTION */
        update tmp_unsubscribe_batch ar
        set status = -486604790
        where
        exists (select 'x' from t_gsubmember s where s.id_acc=ar.id_acc and s.id_group=ar.id_group and s.vt_start <= ar.vt_end and ar.vt_start <= s.vt_end)
        and
        ar.status = 0;

        /*  Check for different subscription to the same PO by the same account with overlapping date */
        update tmp_unsubscribe_batch ar
        set status = -289472485 
        where 
        exists (
         /* Check for conflicting individual sub */
         select * from t_sub s 
         where
         s.id_po=ar.id_po and s.id_acc=ar.id_acc and s.id_sub<>ar.id_sub and s.vt_start <= ar.vt_end and ar.vt_start <= s.vt_end
         and
         s.id_group is null
        )
        or
        exists (
         /* Check for conflicting group sub */
         select * from t_gsubmember gs
         inner join t_sub s on gs.id_group = s.id_group
         where
         gs.id_acc=ar.id_acc and s.id_po=ar.id_po and s.id_sub<>ar.id_sub and gs.vt_start <= ar.vt_end and ar.vt_start <= gs.vt_end
        )
        and
        ar.status = 0; 

        /*  Check to make sure that effective date of PO intersects the corrected interval */
        update tmp_unsubscribe_batch ar
        set status = -289472472 
        where exists (
        select 'x' from 
        t_po p,t_effectivedate ed 
        where ar.id_po=p.id_po
        and ed.id_eff_date=p.id_eff_date
        and 
        (ed.dt_start > ar.vt_start or ed.dt_end < ar.vt_end))
        and
        ar.status = 0;

        /*  Check to see if there is another PO with the same PI template for which an overlapping subscription exists. */
        /*  Only do this if other business rules have passed. */
        UPDATE tmp_unsubscribe_batch tsb
        SET tsb.status = -289472484
        WHERE
        EXISTS (
            SELECT 'x' 
            FROM
            t_pl_map plm1,t_vw_effective_subs s2,t_pl_map plm2  
            WHERE 
            s2.id_acc=tsb.id_acc AND s2.id_po<>tsb.id_po AND s2.dt_start < tsb.vt_end AND tsb.vt_start < s2.dt_end
            AND s2.id_po=plm2.id_po AND plm1.id_pi_template = plm2.id_pi_template
            AND
            tsb.id_po=plm1.id_po
            AND
            plm1.id_paramtable IS NULL
            AND
            plm2.id_paramtable IS NULL
        )
        AND
        tsb.status = 0;

        /*  MT_GSUB_DATERANGE_NOT_IN_SUB_RANGE */
        update tmp_unsubscribe_batch ar
        set status = -486604789
        where exists
        (select 'x' from t_sub s where s.id_group=ar.id_group
        and
        (ar.vt_start < s.vt_start or ar.vt_end > s.vt_end))
        and
        ar.status = 0;

        /*  Check that the group subscription exists */
        /*  MT_GROUP_SUBSCRIPTION_DOES_NOT_EXIST */
        update tmp_unsubscribe_batch ar
        set status = -486604788
        where
        not exists (
            select *
            from t_group_sub 
            where
            t_group_sub.id_group=ar.id_group
        )
        and
        ar.status = 0;

        /*  If corp account business rule is enforced, check that */
        /*  all potential gsub members are located in the same corporate hierarchy */
        /*  as group subscription */
        /*  MT_ACCOUNT_NOT_IN_GSUB_CORPORATE_ACCOUNT */

        BEGIN
          IF %%CORP_BUSINESS_RULE_ENFORCED%% = 1 THEN
            update tmp_unsubscribe_batch ar
            set status = -486604769 
          where exists
            (select 'x' from t_group_sub gs,t_account_ancestor aa1,t_account_ancestor aa2 where ar.id_group=gs.id_group
             and aa1.id_descendent=ar.id_acc and aa1.id_ancestor=1 and aa1.vt_start <= ar.tt_now and ar.tt_now <= aa1.vt_end
             and aa2.id_descendent=ar.id_acc and aa2.num_generations+1=aa1.num_generations and aa2.vt_start <= ar.tt_now and ar.tt_now <= aa2.vt_end
             and aa2.id_ancestor <> gs.id_corporate_account)
            and
            ar.status = 0;
          END IF;
        END;

        /*  MT_GROUP_SUB_MEMBER_CYCLE_MISMATCH */
        /*  Check for billing cycle relative  */
        BEGIN
        FOR i IN (SELECT ar.ROWID row_id FROM
        tmp_unsubscribe_batch ar
        INNER JOIN t_sub s ON ar.id_group=s.id_group
        INNER JOIN t_group_sub gs ON ar.id_group=gs.id_group
        WHERE
        s.vt_end >= ar.tt_now
        AND
        (
            /* Only consider this business rule when the target PO */
            /* has a billing cycle relative instance */
            EXISTS (
                SELECT * 
                FROM 
                t_pl_map plm 
                INNER JOIN t_discount piinst ON piinst.id_prop=plm.id_pi_instance
                WHERE
                plm.id_po=s.id_po
                AND
                plm.id_paramtable IS NULL
                AND
                piinst.id_usage_cycle IS NULL
            )
            OR
            EXISTS (
                SELECT * 
                FROM 
                t_pl_map plm
                INNER JOIN t_recur piinst ON piinst.id_prop=plm.id_pi_instance
                WHERE
                plm.id_po=s.id_po
                AND
                plm.id_paramtable IS NULL
                AND
                piinst.tx_cycle_mode IN ('BCR', 'BCR Constrained')
            ) 
            OR
            EXISTS (
                SELECT * 
                FROM 
                t_pl_map plm 
                INNER JOIN t_aggregate piinst ON piinst.id_prop=plm.id_pi_instance
                WHERE
                plm.id_po=s.id_po
                AND
                plm.id_paramtable IS NULL
                AND
                piinst.id_usage_cycle IS NULL
            )
        )
        AND
        EXISTS (
            /* All payers must have the same cycle as the cycle as the group sub itself */
            SELECT * 
            FROM 
            t_payment_redirection pr 
            INNER JOIN t_acc_usage_cycle auc ON auc.id_acc=pr.id_payer
            WHERE
            pr.id_payee=ar.id_acc 
            AND 
            pr.vt_start <= s.vt_end 
            AND 
            s.vt_start <= pr.vt_end
            AND
            auc.id_usage_cycle <> gs.id_usage_cycle
        )
        AND
        ar.status = 0)
        LOOP
          UPDATE tmp_unsubscribe_batch
          SET tmp_unsubscribe_batch.status = -486604730
          WHERE ROWID=i.row_id;
        END LOOP;
        END;

        /*  */
        /*  EBCR membership business rules */
        /*  */

        /*  fills the results table with a row for each member/payer combination */
        INSERT INTO ebcrResults
        SELECT 
          batch.id_acc,
          payercycle.id_usage_cycle,
          dbo.CheckEBCRCycleTypeCompatible(payercycle.id_cycle_type, rc.id_cycle_type)
        FROM tmp_unsubscribe_batch batch
        INNER JOIN t_group_sub gs ON gs.id_group = batch.id_group
        INNER JOIN t_sub sub ON sub.id_group = gs.id_group
        INNER JOIN t_pl_map plmap ON plmap.id_po = sub.id_po
        INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_instance
        INNER JOIN t_payment_redirection pay ON 
          pay.id_payee = batch.id_acc AND
          /* checks all payer's who overlap with the group sub */
          pay.vt_end >= sub.vt_start AND
          pay.vt_start <= sub.vt_end
        INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = pay.id_payer
        INNER JOIN t_usage_cycle payercycle ON payercycle.id_usage_cycle = auc.id_usage_cycle
        WHERE 
          rc.tx_cycle_mode = 'EBCR' AND
          rc.b_charge_per_participant = 'Y' AND
          plmap.id_paramtable IS NULL AND
          /* TODO: it would be better if we didn't consider subscriptions that ended */
          /*       in a hard closed interval so that retroactive changes would be properly guarded. */
          /* only consider current or future group subs */
          /* don't worry about group subs in the past */
          ((%%%SYSTEMDATE%%% BETWEEN sub.vt_start AND sub.vt_end) OR
           (sub.vt_start > %%%SYSTEMDATE%%%)) AND
          batch.status = 0;

        /*  checks that members' payers are compatible with the EBCR cycle type */
        UPDATE tmp_unsubscribe_batch batch
        SET status = -289472443 /* MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_PAYER_OF_MEMBER */
        where exists ( select 'x' FROM
        ebcrResults res where res.id_acc = batch.id_acc
        and res.b_compatible = 0);

        /*  checks that each member has only one billing cycle across all payers */
        UPDATE tmp_unsubscribe_batch batch
        SET status = -289472442 /* MTPCUSER_EBCR_MEMBERS_CONFLICT_WITH_EACH_OTHER */
        where exists( select 'x' FROM
        ebcrResults res , ebcrResults res2 where res.id_acc = batch.id_acc
        and res2.id_acc = res.id_acc AND res2.b_compatible = res.b_compatible AND
        res2.id_usage_cycle <> res.id_usage_cycle AND 
        res.b_compatible = 1 )
        AND
        batch.status = 0;


        /*  This is a sequenced insert.  For sequenced updates/upsert, run the delete (unsubscribe) first. */
        INSERT INTO t_gsubmember_historical (id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
        SELECT ar.id_group, ar.id_acc, ar.vt_start, ar.vt_end, ar.tt_now, dbo.MTMaxDate()
        FROM
        tmp_unsubscribe_batch ar
        WHERE
        ar.status=0;
        INSERT INTO t_gsubmember (id_group, id_acc, vt_start, vt_end)
        SELECT ar.id_group, ar.id_acc, ar.vt_start, ar.vt_end
        FROM
        tmp_unsubscribe_batch ar
        WHERE
        ar.status=0;

        /*  Coalecse to merge abutting records */
        /*  Implement coalescing to merge any gsubmember records to the */
        /*  same subscription that are adjacent.  Still need to work on */
        /*  what a bitemporal coalesce looks like. */
        BEGIN
        LOOP
          UPDATE t_gsubmember
          SET t_gsubmember.vt_end = (
            SELECT MAX(aa2.vt_end)
            FROM
            t_gsubmember aa2
            WHERE
            t_gsubmember.id_group=aa2.id_group
            AND
            t_gsubmember.id_acc=aa2.id_acc
            AND
            t_gsubmember.vt_start < aa2.vt_start
            AND
            dbo.addsecond(t_gsubmember.vt_end) >= aa2.vt_start
            AND
            t_gsubmember.vt_end < aa2.vt_end
          )
          WHERE
          EXISTS (
            SELECT *
            FROM
            t_gsubmember  aa2
            WHERE
            t_gsubmember.id_group=aa2.id_group
            AND
            t_gsubmember.id_acc=aa2.id_acc
            AND
            t_gsubmember.vt_start < aa2.vt_start
            AND
            dbo.addsecond(t_gsubmember.vt_end) >= aa2.vt_start
            AND
            t_gsubmember.vt_end < aa2.vt_end
          )
          AND
          EXISTS (
            SELECT * FROM tmp_unsubscribe_batch ar 
            WHERE ar.id_group = t_gsubmember.id_group AND ar.id_acc = t_gsubmember.id_acc
          );
          IF SQL%ROWCOUNT <= 0 then
            exit;
          end if;
        END LOOP;
        END;

        delete 
        from t_gsubmember 
        where
        exists (
            select *
            from t_gsubmember aa2
            where
            t_gsubmember.id_group=aa2.id_group
            and
            t_gsubmember.id_acc=aa2.id_acc
            and
            (
            (aa2.vt_start < t_gsubmember.vt_start and t_gsubmember.vt_end <= aa2.vt_end)
            or
            (aa2.vt_start <= t_gsubmember.vt_start and t_gsubmember.vt_end < aa2.vt_end)
            )
        )
        and
        exists (
          select * from tmp_unsubscribe_batch ar 
          where ar.id_group = t_gsubmember.id_group and ar.id_acc = t_gsubmember.id_acc
        );

        delete tmp_coalesce_args;

        /*  Here is another approach. */
        /*  Select a record that can be extended in valid time direction. */
        /*  Issue an update statement to extend the vt_end and to set the */
        /*  [tt_start, tt_end] to be the intersection of the original records */
        /*  transaction time interval and the transaction time interval of the */
        /*  extender. */
        /*  Issue an insert statement to create 0,1 or 2 records that have the */
        /*  same valid time interval as the original record but that have a new */
        /*  tt_end or tt_start in the case that their associated tt_start or tt_end */
        /*  extends beyond that of the extending record. */
        /*  */
        /*   -------- */
        /*   |      | */
        /*   |      | */
        /*   |   --------- */
        /*   |   |  |    | */
        /*   |   |  |    | */
        /*   |   |  |    | */
        /*   --------    | */
        /*       |       |  */
        /*       |       |   */
        /*       --------- */
        BEGIN
        LOOP
          INSERT INTO TMP_COALESCE_ARGS(id_group, id_acc, vt_start, vt_end, tt_start, tt_end, update_tt_start, update_tt_end, update_vt_end)
          SELECT 
          gsm.id_group,
          gsm.id_acc,
          gsm.vt_start,
          gsm.vt_end,
          gsm.tt_start,
          gsm.tt_end,
          dbo.MTMaxOfTwoDates(gsm.tt_start, gsm2.tt_start) AS update_tt_start,
          dbo.MTMinOfTwoDates(gsm.tt_end, gsm2.tt_end) AS update_tt_end,
          MAX(gsm2.vt_end) AS update_vt_end
          FROM 
          T_GSUBMEMBER_HISTORICAL gsm
          INNER JOIN T_GSUBMEMBER_HISTORICAL gsm2 ON
          gsm.id_group=gsm2.id_group
          AND
          gsm.id_acc=gsm2.id_acc
          AND
          gsm.vt_start < gsm2.vt_start
          AND
          gsm2.vt_start <= dbo.addsecond(gsm.vt_end)
          AND
          gsm.vt_end < gsm2.vt_end
          AND
          gsm.tt_start <= gsm2.tt_end
          AND
          gsm2.tt_start <= gsm.tt_end
          WHERE
          EXISTS (
            SELECT * FROM TMP_UNSUBSCRIBE_BATCH ar 
            WHERE ar.id_group = gsm.id_group AND ar.id_acc = gsm.id_acc
          )
          GROUP BY
          gsm.id_group,
          gsm.id_acc,
          gsm.vt_start,
          gsm.vt_end,
          gsm.tt_start,
          gsm.tt_end,
          dbo.MTMaxOfTwoDates(gsm.tt_start, gsm2.tt_start),
          dbo.MTMinOfTwoDates(gsm.tt_end, gsm2.tt_end);
          IF SQL%rowcount <= 0 THEN EXIT;
          END IF;
          /*  These are the records whose extender transaction time ends strictly within the record being */
          /*  extended */
          INSERT INTO T_GSUBMEMBER_HISTORICAL(id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
          SELECT 
          gsm.id_group, gsm.id_acc, gsm.vt_start, gsm.vt_end, dbo.addsecond( gsm2.vt_end) AS tt_start, gsm.tt_end
          FROM 
          T_GSUBMEMBER_HISTORICAL gsm
          INNER JOIN T_GSUBMEMBER_HISTORICAL gsm2 ON
          gsm.id_group=gsm2.id_group
          AND
          gsm.id_acc=gsm2.id_acc
          AND
          gsm.vt_start < gsm2.vt_start
          AND
          gsm2.vt_start <= dbo.addsecond( gsm.vt_end)
          AND
          gsm.vt_end < gsm2.vt_end
          AND
          gsm.tt_start <= gsm2.tt_end
          AND
          gsm2.tt_end < gsm.tt_end
          WHERE
          EXISTS (
            SELECT * FROM TMP_UNSUBSCRIBE_BATCH ar 
            WHERE ar.id_group = gsm.id_group AND ar.id_acc = gsm.id_acc
          );
          /*  These are the records whose extender starts strictly within the record being */
          /*  extended */
          INSERT INTO T_GSUBMEMBER_HISTORICAL(id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
          SELECT 
          gsm.id_group, gsm.id_acc, gsm.vt_start, gsm.vt_end, gsm.tt_start, dbo.subtractsecond(gsm2.tt_start) AS tt_end
          FROM 
          T_GSUBMEMBER_HISTORICAL gsm
          INNER JOIN T_GSUBMEMBER_HISTORICAL gsm2 ON
          gsm.id_group=gsm2.id_group
          AND
          gsm.id_acc=gsm2.id_acc
          AND
          gsm.vt_start < gsm2.vt_start
          AND
          gsm2.vt_start <= dbo.addsecond( gsm.vt_end)
          AND
          gsm.vt_end < gsm2.vt_end
          AND
          gsm.tt_start < gsm2.tt_start
          AND
          gsm2.tt_start <= gsm.tt_end
          WHERE
          EXISTS (
            SELECT * FROM TMP_UNSUBSCRIBE_BATCH ar 
            WHERE ar.id_group = gsm.id_group AND ar.id_acc = gsm.id_acc
          );
          FOR i IN ( SELECT gsm.ROWID gsm_rowid,ca.update_vt_end ca_update_vt_end,  
                      ca.update_tt_start ca_update_tt_start, ca.update_tt_end ca_update_tt_end
                  FROM T_GSUBMEMBER_HISTORICAL gsm
                  INNER JOIN TMP_COALESCE_ARGS ca ON
                  gsm.id_group=ca.id_group AND gsm.id_acc=ca.id_acc
                  AND gsm.vt_start=ca.vt_start
                  AND gsm.vt_end=ca.vt_end
                  AND gsm.tt_start=ca.tt_start
                  AND gsm.tt_end=ca.tt_end) 
          LOOP
            UPDATE  T_GSUBMEMBER_HISTORICAL
            SET T_GSUBMEMBER_HISTORICAL.vt_end = i.ca_update_vt_end,
            T_GSUBMEMBER_HISTORICAL.tt_start   = i.ca_update_tt_start,
            T_GSUBMEMBER_HISTORICAL.tt_end     = i.ca_update_tt_end
            WHERE ROWID = i.gsm_rowid;
          END LOOP;
          delete TMP_COALESCE_ARGS;
        END LOOP;
        END;

        /*  Here we select stuff to "delete" */
        /*  In all cases we have containment invalid time. */
        /*  Consider the four overlapping cases for transaction time. */
        /*   */
        update t_gsubmember_historical
        set
        t_gsubmember_historical.tt_start = (
            select dbo.subtractsecond(max(tt_end))
            from
            t_gsubmember_historical gsm
            where
            t_gsubmember_historical.id_group=gsm.id_group
            and
            t_gsubmember_historical.id_acc=gsm.id_acc
            and
            gsm.vt_start <= t_gsubmember_historical.vt_start 
            and 
            t_gsubmember_historical.vt_end <= gsm.vt_end
            and
            gsm.tt_end >= t_gsubmember_historical.tt_start
            and
            gsm.tt_end < t_gsubmember_historical.tt_end
        )
        where
        exists (
            select *
            from
            t_gsubmember_historical gsm
            where
            t_gsubmember_historical.id_group=gsm.id_group
            and
            t_gsubmember_historical.id_acc=gsm.id_acc
            and
            gsm.vt_start <= t_gsubmember_historical.vt_start 
            and 
            t_gsubmember_historical.vt_end <= gsm.vt_end
            and
            gsm.tt_end >= t_gsubmember_historical.tt_start
            and
            gsm.tt_end < t_gsubmember_historical.tt_end
        )
        and
        exists (
          select * from tmp_unsubscribe_batch ar 
          where ar.id_group = t_gsubmember_historical.id_group and ar.id_acc = t_gsubmember_historical.id_acc
        );

        update t_gsubmember_historical
        set
        t_gsubmember_historical.tt_end = (
            select dbo.subtractsecond(min(tt_start))
            from
            t_gsubmember_historical gsm
            where
            t_gsubmember_historical.id_group=gsm.id_group
            and
            t_gsubmember_historical.id_acc=gsm.id_acc
            and
            gsm.vt_start <= t_gsubmember_historical.vt_start 
            and 
            t_gsubmember_historical.vt_end <= gsm.vt_end
            and
            gsm.tt_start > t_gsubmember_historical.tt_start
            and
            gsm.tt_start <= t_gsubmember_historical.tt_end
        )
        where
        exists (
            select *
            from
            t_gsubmember_historical gsm
            where
            t_gsubmember_historical.id_group=gsm.id_group
            and
            t_gsubmember_historical.id_acc=gsm.id_acc
            and
            gsm.vt_start <= t_gsubmember_historical.vt_start 
            and 
            t_gsubmember_historical.vt_end <= gsm.vt_end
            and
            gsm.tt_start > t_gsubmember_historical.tt_start
            and
            gsm.tt_start <= t_gsubmember_historical.tt_end
        )
        and
        exists (
          select * from tmp_unsubscribe_batch ar 
          where ar.id_group = t_gsubmember_historical.id_group and ar.id_acc = t_gsubmember_historical.id_acc
        );

        DELETE
        /* select * */
        FROM 
        t_gsubmember_historical gsm
        WHERE EXISTS (SELECT 'x' FROM t_gsubmember_historical gsm2 WHERE
        gsm.id_group=gsm2.id_group
        AND
        gsm.id_acc=gsm2.id_acc
        AND
        (
        (gsm2.vt_start < gsm.vt_start AND gsm.vt_end <= gsm2.vt_end)
        OR
        (gsm2.vt_start <= gsm.vt_start AND gsm.vt_end < gsm2.vt_end)
        )
        AND
        gsm2.tt_start <= gsm.tt_start
        AND
        gsm.tt_end <= gsm2.tt_end)
        AND
        EXISTS (
          SELECT * FROM tmp_unsubscribe_batch ar 
          WHERE ar.id_group = gsm.id_group AND ar.id_acc = gsm.id_acc
        );
        END;
        