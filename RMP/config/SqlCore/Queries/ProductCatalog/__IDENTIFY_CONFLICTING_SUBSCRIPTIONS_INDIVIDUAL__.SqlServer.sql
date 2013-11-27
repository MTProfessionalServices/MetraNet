
DECLARE @system_datetime DATETIME
/*  __IDENTIFY_CONFLICTING_SUBSCRIPTIONS_INDIVIDUAL__ */
DECLARE @max_datetime    DATETIME

SELECT @system_datetime = %%%SYSTEMDATE%%% /* GetUTCDate() */
SELECT @max_datetime = dbo.MTMaxDate()

/*  Start AddNewSub */

/*  compute usage cycle dates if necessary */

UPDATE tmp
SET    tmp.dt_end   = CASE WHEN tmp.dt_end IS NULL
                           THEN @max_datetime
                           ELSE tmp.dt_end
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

INSERT INTO #tmp_unsubscribe_indiv_batch(id_acc, id_po, id_sub, vt_start, vt_end, uncorrected_vt_start, uncorrected_vt_end, tt_now, status, id_audit, id_event, id_userid, id_entitytype)
select ar.id_acc, ar.id_po, s2.id_sub, ar.dt_adj_start, ar.dt_adj_end, ar.dt_adj_start, ar.dt_adj_end, %%TT_NOW%%, 0, ar.id_audit, %%ID_EVENT_SUB_DELETE%%, ar.id_userid, ar.id_entitytype
from %%DEBUG%%tmp_subscribe_individual_batch ar
inner join t_sub s2 on s2.id_acc=ar.id_acc  
and s2.vt_start <= ar.dt_adj_end and ar.dt_adj_start <= s2.vt_end
where
exists (
	select 1 
	from
 	t_pl_map plm1 
	inner join t_pl_map plm2 on s2.id_po=plm2.id_po and plm1.id_pi_template = plm2.id_pi_template
	where
	ar.id_po=plm1.id_po
	and
	plm1.id_paramtable is null
	and
	plm2.id_paramtable is null
)

INSERT INTO #tmp_unsubscribe_batch(id_acc, id_po, id_group, vt_start, vt_end, uncorrected_vt_start, uncorrected_vt_end, tt_now, id_gsub_corp_account, status,
										 id_audit, id_event, id_userid, id_entitytype)
select ar.id_acc, ar.id_po, s.id_group, ar.dt_adj_start, ar.dt_adj_end, ar.dt_adj_start, ar.dt_adj_end, %%TT_NOW%%, gs.id_corporate_account, 0, ar.id_audit, %%ID_EVENT_GSUBMEMBER_DELETE%%, ar.id_userid, ar.id_entitytype
from %%DEBUG%%tmp_subscribe_individual_batch ar
inner join t_gsubmember s on s.id_acc=ar.id_acc and s.vt_start <= ar.dt_adj_end and ar.dt_adj_start <= s.vt_end
inner join t_group_sub gs on gs.id_group = s.id_group
inner join t_sub s2 on gs.id_group = s2.id_group
where
exists (
	select 1 
	from
 	t_pl_map plm1 
	inner join t_pl_map plm2 on s2.id_po=plm2.id_po and plm1.id_pi_template = plm2.id_pi_template
	where
	ar.id_po=plm1.id_po
	and
	plm1.id_paramtable is null
	and
	plm2.id_paramtable is null
)
		