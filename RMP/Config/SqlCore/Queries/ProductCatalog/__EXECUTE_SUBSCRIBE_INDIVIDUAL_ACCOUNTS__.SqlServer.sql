
DECLARE @system_datetime DATETIME
/*  __EXECUTE_SUBSCRIBE_INDIVIDUAL_ACCOUNTS__ */
DECLARE @max_datetime    DATETIME

SELECT @system_datetime = %%%SYSTEMDATE%%% /* GetUTCDate() */
SELECT @max_datetime = dbo.MTMaxDate()

/*  Check to see if the account is in a state in which we can subscribe it. */
/*  */
/*  TODO: This is the business rule as implemented in 3.5 and 3.0 (check only */
/*  the account state in effect at the wall clock time that the subscription is made). */
/*  What would be better is to ensure that there is no overlap between the valid time */
/*  interval of any "invalid" account state and the subscription interval. */
/*  */
/*  This check was taken from the SQL for __EXECUTE_SUBSCRIBE_TO_GROUP_BATCH__. */
UPDATE tmp 
SET    tmp.status = -486604774 /* MT_ADD_TO_GROUP_SUB_BAD_STATE */
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
INNER JOIN t_account_state ast ON tmp.id_acc = ast.id_acc
                              AND ast.vt_start <= @system_datetime
                              AND ast.vt_end >= @system_datetime
INNER JOIN %%DEBUG%%tmp_account_state_rules asr ON ast.status = asr.state
WHERE asr.can_subscribe = 0
  AND tmp.status IS NULL

/*  check that account type of each member is compatible with the product offering */
/*  since the absense of ANY mappings for the product offering means that PO is "wide open" */
/*  we need to do 2 EXISTS queries. */

UPDATE tmp  
set tmp.status = -289472435 /* MTPCUSER_CONFLICTING_PO_ACCOUNT_TYPE */
from
%%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED) 
where
(
exists (

SELECT 1
FROM t_po_account_type_map atmap
WHERE atmap.id_po = tmp.id_po

)

/* PO is not wide open - see if susbcription is permitted for the account type */

AND
not exists (

SELECT 1
FROM t_account tacc
INNER JOIN t_po_account_type_map atmap ON atmap.id_account_type = tacc.id_type
WHERE atmap.id_po = tmp.id_po AND tmp.id_acc = tacc.id_acc

)
)

AND tmp.status IS NULL

/* Check MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE 0xEEBF004EL -289472434 */
UPDATE tmp 
SET    tmp.status = -289472434 /* MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE */
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
inner join t_account acc ON tmp.id_acc = acc.id_acc
inner join t_account_type acctype on acc.id_type = acctype.id_type
where
acctype.b_CanSubscribe = '0' AND tmp.status IS NULL


/*  Start AddNewSub */

/*  compute usage cycle dates if necessary */

UPDATE tmp
SET    tmp.dt_end   = CASE WHEN tmp.dt_end IS NULL
                           THEN @max_datetime
                           ELSE tmp.dt_end
                           END,
       tmp.sub_guid = CASE WHEN tmp.sub_guid IS NULL
                           THEN newid()
                           ELSE tmp.sub_guid
                           END
FROM   %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE  tmp.status IS NULL

/*  This SQL used to call dbo.NextDateAfterBillingCycle */
UPDATE tmp
SET    tmp.dt_start = DATEADD(s, 1, tpc.dt_end)
FROM t_pc_interval tpc
INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
INNER JOIN %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED) ON tauc.id_acc = tmp.id_acc
WHERE tmp.next_cycle_after_startdate = 'Y'
  AND tpc.dt_start <= tmp.dt_start
  AND tmp.dt_start <= tpc.dt_end
  AND tmp.status IS NULL

/*  This SQL used to call dbo.NextDateAfterBillingCycle */
UPDATE tmp
SET    tmp.dt_end = DATEADD(s, 1, tpc.dt_end)
FROM t_pc_interval tpc
INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
INNER JOIN %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED) ON tauc.id_acc = tmp.id_acc
WHERE tmp.next_cycle_after_enddate = 'Y'
  AND tpc.dt_start <= tmp.dt_end
  AND tmp.dt_end   <= tpc.dt_end
  AND tmp.dt_end <> @max_datetime
  AND tmp.status IS NULL

/*  End AddNewSub */

/*  Start AddSubscriptionBase */

/*  Start AdjustSubDate */

UPDATE tmp
SET    tmp.dt_adj_start = te.dt_start,
       tmp.dt_adj_end   = CASE WHEN te.dt_end IS NULL
                               THEN @max_datetime
                               ELSE te.dt_end
                               END
FROM  %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
INNER JOIN t_po po ON po.id_po = tmp.id_po
INNER JOIN t_effectivedate te on te.id_eff_date = po.id_eff_date
WHERE tmp.status IS NULL

/*  This SQL used to call dbo.MTMaxOfTwoDates and dbo.MTMinOfTwoDates */
UPDATE tmp
SET    tmp.dt_adj_start = CASE WHEN tmp.dt_adj_start > tmp.dt_start
                               THEN tmp.dt_adj_start
                               ELSE tmp.dt_start
                               END,
       tmp.dt_adj_end   = CASE WHEN tmp.dt_adj_end < tmp.dt_end
                               THEN tmp.dt_adj_end
                               ELSE tmp.dt_end
                               END
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE  tmp.status IS NULL

UPDATE tmp
SET    tmp.status = -289472472 /* MTPCUSER_PRODUCTOFFERING_NOT_EFFECTIVE (0xEEBF0028) */
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE tmp.dt_adj_end < tmp.dt_adj_start
  AND tmp.status IS NULL

UPDATE tmp
SET    tmp.date_modified = CASE WHEN (tmp.dt_start <> tmp.dt_adj_start) OR (tmp.dt_end <> tmp.dt_adj_end)
                                THEN 'Y'
                                ELSE 'N'
                                END
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE tmp.status IS NULL

/*  End AdjustSubDate */

/*  Check availability of the product offering. */

UPDATE tmp
SET    tmp.status = CASE WHEN (ta.n_begintype = 0) OR (ta.n_endtype = 0)
                         THEN -289472451 /* MTPCUSER_AVAILABILITY_DATE_NOT_SET (0xEEBF003D) */
                         WHEN (ta.n_begintype <> 0) AND (ta.dt_start > @system_datetime)
                         THEN -289472449 /* MTPCUSER_AVAILABILITY_DATE_IN_FUTURE (0xEEBF003F) */
                         WHEN (ta.n_endtype <> 0) AND (ta.dt_end < @system_datetime)
                         THEN -289472450 /* MTPCUSER_AVAILABILITY_DATE_IN_PAST (0xEEBF003E) */
                         ELSE NULL
                         END
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
INNER JOIN t_po po ON po.id_po = tmp.id_po
INNER JOIN t_effectivedate ta ON po.id_avail = ta.id_eff_date
WHERE tmp.status IS NULL

/*  Start CheckSubscriptionConflicts */

UPDATE tmp1
SET tmp1.status = -289472485 /* MTPCUSER_CONFLICTING_PO_SUBSCRIPTION (0xEEBF001B) */
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp1 WITH(READCOMMITTED)
WHERE 
(
EXISTS(
  SELECT 1
  FROM 
  t_sub s1 
  WHERE
	s1.id_po=tmp1.id_po AND s1.id_acc=tmp1.id_acc AND
  s1.id_sub <> tmp1.id_acc
  AND
  s1.vt_start <= tmp1.dt_adj_end AND tmp1.dt_adj_start <= s1.vt_end
  AND
	s1.id_group IS NULL
             )
OR
EXISTS(
  SELECT 1
  FROM 
  t_gsubmember gsm1
  INNER JOIN t_sub  s1 ON gsm1.id_group=s1.id_group
  WHERE
	s1.id_po=tmp1.id_po AND gsm1.id_acc=tmp1.id_acc AND
  s1.id_sub <> tmp1.id_acc
  AND
  gsm1.vt_start <= tmp1.dt_adj_end AND tmp1.dt_adj_start <= gsm1.vt_end
             )
)
  AND tmp1.status IS NULL

UPDATE tmp
                         /* This SQL used to call dbo.OverlappingDateRange(). */
SET    tmp.status = CASE WHEN ((tmp.dt_adj_start > te.dt_end)
                            OR (te.dt_start IS NOT NULL AND te.dt_start > tmp.dt_adj_end))
                         THEN -289472472 /* MTPCUSER_PRODUCTOFFERING_NOT_EFFECTIVE (0xEEBF0028) */
                         ELSE NULL
                         END
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
INNER JOIN t_po ON tmp.id_po = t_po.id_po
INNER JOIN t_effectivedate te ON te.id_eff_date = t_po.id_eff_date
WHERE tmp.status IS NULL


/* Update all Conflicting PI if Allow Same PI Subscription Business Rule is Disabled regardless of PI Type */ 
UPDATE tmp
SET tmp.status = -289472484 /* MTPCUSER_CONFLICTING_PO_SUB_PRICEABLEITEM (0xEEBF001C) */
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE
EXISTS (
	SELECT * 
	FROM
 	t_pl_map plm1 
	INNER JOIN t_vw_effective_subs s2 ON s2.id_acc=tmp.id_acc and s2.id_po<>tmp.id_po and s2.dt_start <= tmp.dt_adj_end and tmp.dt_adj_start <= s2.dt_end
	INNER JOIN t_pl_map plm2 ON s2.id_po=plm2.id_po AND plm1.id_pi_template = plm2.id_pi_template
	WHERE
	tmp.id_po=plm1.id_po
	AND
	plm1.id_paramtable is null
	AND
	plm2.id_paramtable is null
	
)
and
tmp.status IS NULL
and
%%CONFLICTINGPINOTALLOWED%%


/* Update POs having Non RC/NRC PI In it eventhough Allow Same PI Subscription Business Rule is enabled */

UPDATE tmp
SET tmp.status = -289472484 /* MTPCUSER_CONFLICTING_PO_SUB_PRICEABLEITEM (0xEEBF001C) */
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE
EXISTS (
	SELECT * 
	FROM
 	t_pl_map plm1 
	INNER JOIN t_vw_effective_subs s2 ON s2.id_acc=tmp.id_acc and s2.id_po<>tmp.id_po and s2.dt_start <= tmp.dt_adj_end and tmp.dt_adj_start <= s2.dt_end
	INNER JOIN t_pl_map plm2 ON s2.id_po=plm2.id_po AND plm1.id_pi_template = plm2.id_pi_template
	INNER JOIN t_base_props bp ON plm1.id_pi_template = bp.id_prop 
	WHERE
	tmp.id_po=plm1.id_po
	AND
	plm1.id_paramtable is null
	AND
	plm2.id_paramtable is null
	AND
	bp.n_kind in (10,40)
)
and
tmp.status IS NULL
and
NOT (%%CONFLICTINGPINOTALLOWED%%)


/*  Start IsAccountAndPOSameCurrency */

/*  This SQL used to call (dbo.IsAccountAndPOSameCurrency() = '0') */
UPDATE tmp
SET tmp.status = -486604729 /* MT_ACCOUNT_PO_CURRENCY_MISMATCH (0xE2FF0047) */
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
INNER JOIN t_po po ON po.id_po = tmp.id_po
INNER JOIN t_av_internal av ON av.id_acc = tmp.id_acc
INNER JOIN t_pricelist pl ON po.id_nonshared_pl = pl.id_pricelist
WHERE av.c_currency <> pl.nm_currency_code
and %%CURRENCYUPDATESTATUS%%  
and tmp.status IS NULL

/*  End IsAccountAndPOSameCurrency */

UPDATE tmp
SET tmp.status = -289472430 /* MTPCUSER_SUBSCRIPTION_START_DATE_LESS_THAN_ACCOUNT_CREATION_DATE (0xEEBF0052) */
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
INNER JOIN t_account ac ON ac.id_acc = tmp.id_acc
WHERE ac.dt_crt > tmp.dt_adj_start
and tmp.status IS NULL

/*  End CheckSubscriptionConflicts */

-- flag as errors any subscription request for which there is
-- a payer whose cycle conflicts with cycle type of a BCR priceable item.
UPDATE tmp
SET    tmp.status = -289472464 -- MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE (0xEEBF0030)
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)


WHERE tmp.status IS NULL
AND
EXISTS (
  SELECT 1
  FROM
	t_payment_redirection pr 
  INNER JOIN t_acc_usage_cycle auc ON pr.id_payer=auc.id_acc
  INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = auc.id_usage_cycle
	WHERE
  pr.id_payee = tmp.id_acc
  AND
	pr.vt_start <= tmp.dt_adj_end 
  AND
  tmp.dt_adj_start <= pr.vt_end
	AND
  EXISTS (
    SELECT 1 FROM t_pl_map plm
    WHERE plm.id_paramtable IS NULL AND plm.id_po=tmp.id_po
    AND
    (
      EXISTS (
        SELECT 1 FROM t_aggregate a WHERE a.id_prop = plm.id_pi_instance 
        AND a.id_cycle_type IS NOT NULL AND a.id_cycle_type <> uc.id_cycle_type
      ) OR EXISTS (
        SELECT 1 FROM t_discount d WHERE d.id_prop = plm.id_pi_instance 
        AND d.id_cycle_type IS NOT NULL AND d.id_cycle_type <> uc.id_cycle_type
      ) OR EXISTS (
        SELECT 1 FROM t_recur r WHERE r.id_prop = plm.id_pi_instance AND r.tx_cycle_mode = 'BCR Constrained'
        AND r.id_cycle_type IS NOT NULL AND r.id_cycle_type <> uc.id_cycle_type
      )
    )
  )
)

UPDATE tmp
SET    tmp.status = -289472444 -- MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE (0xEEBF0044)
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE tmp.status IS NULL
AND
EXISTS (
  SELECT 1
  FROM
	t_payment_redirection pr 
  INNER JOIN t_acc_usage_cycle auc ON pr.id_payer=auc.id_acc
  INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = auc.id_usage_cycle
	WHERE
  pr.id_payee = tmp.id_acc
  AND
	pr.vt_start <= tmp.dt_adj_end 
  AND
  tmp.dt_adj_start <= pr.vt_end
	AND
  EXISTS (
    SELECT 1 FROM t_pl_map plm
    WHERE plm.id_paramtable IS NULL AND plm.id_po=tmp.id_po
    AND EXISTS (
        SELECT 1 FROM t_recur rc WHERE rc.id_prop = plm.id_pi_instance AND rc.tx_cycle_mode = 'EBCR'
        AND NOT (((rc.id_cycle_type = 4) OR (rc.id_cycle_type = 5))
        AND ((uc.id_cycle_type = 4) OR (uc.id_cycle_type = 5)))
        AND NOT (((rc.id_cycle_type = 1) OR (rc.id_cycle_type = 7) OR (rc.id_cycle_type = 8))
        AND ((uc.id_cycle_type = 1) OR (uc.id_cycle_type = 7) OR (uc.id_cycle_type = 8)))  
    )
  )
)

-- End AddSubscriptionBase

-- Start CreateSubscriptionRecord

-- Create the new subscription history record.
INSERT INTO t_sub_history (id_sub, id_sub_ext, id_acc, id_group,
                           id_po, dt_crt, vt_start, vt_end,
                           tt_start, tt_end)
SELECT tmp.id_sub, tmp.sub_guid, tmp.id_acc, NULL,
       tmp.id_po, @system_datetime, tmp.dt_adj_start, tmp.dt_adj_end,
       @system_datetime, @max_datetime
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE tmp.status IS NULL

-- Create the new subscription record.
INSERT INTO t_sub (id_sub, id_sub_ext, id_acc, id_group,
                   id_po, dt_crt, vt_start, vt_end)
SELECT tmp.id_sub, tmp.sub_guid, tmp.id_acc, NULL,
       tmp.id_po, @system_datetime, tmp.dt_adj_start, tmp.dt_adj_end
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE tmp.status IS NULL

-- End CreateSubscriptionRecord

-- Update audit information.

UPDATE tmp
SET    tmp.nm_display_name = dscrpt.tx_desc
FROM t_description dscrpt
  LEFT OUTER JOIN t_base_props bp ON dscrpt.id_desc = bp.n_display_name
  INNER JOIN t_po ON bp.id_prop = t_po.id_po
  INNER JOIN %%DEBUG%%tmp_subscribe_individual_batch tmp ON tmp.id_po = t_po.id_po
                                                AND tmp.status IS NULL
WHERE bp.n_kind = 100
  AND dscrpt.id_lang_code = %%ID_LANG%%

INSERT INTO t_audit(id_audit,      id_event,  id_userid,
                    id_entitytype, id_entity, dt_crt)
SELECT tmp.id_audit,      tmp.id_event, tmp.id_userid,
       tmp.id_entitytype, tmp.id_acc,   @system_datetime
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE tmp.status IS NULL

INSERT INTO t_audit_details(id_audit, tx_details)
SELECT tmp.id_audit, tmp.nm_display_name
FROM %%DEBUG%%tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE tmp.status IS NULL
        