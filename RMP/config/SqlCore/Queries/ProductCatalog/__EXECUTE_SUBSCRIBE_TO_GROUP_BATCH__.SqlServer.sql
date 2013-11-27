
/*  If the vt_end is null then use subscription end date */
UPDATE %%DEBUG%%tmp_subscribe_batch
SET 
%%DEBUG%%tmp_subscribe_batch.vt_end=dbo.MTMaxDate(),
%%DEBUG%%tmp_subscribe_batch.uncorrected_vt_end=dbo.MTMaxDate()
WHERE
%%DEBUG%%tmp_subscribe_batch.vt_end is null

/*  First clip the start and end date with the effective date on the subscription */
/*  and validate that the intersection of the effective date on the sub and the */
/*  delete interval is non-empty. */
UPDATE %%DEBUG%%tmp_subscribe_batch
SET
%%DEBUG%%tmp_subscribe_batch.vt_start = dbo.MTMaxOfTwoDates(ub.vt_start, s.vt_start),
%%DEBUG%%tmp_subscribe_batch.vt_end = dbo.MTMinOfTwoDates(ub.vt_end, s.vt_end),
%%DEBUG%%tmp_subscribe_batch.status = case when ub.vt_start < s.vt_end and ub.vt_end > s.vt_start then 0 else -486604712  end,
%%DEBUG%%tmp_subscribe_batch.id_sub = s.id_sub,
%%DEBUG%%tmp_subscribe_batch.id_po = s.id_po
from 
%%DEBUG%%tmp_subscribe_batch ub
inner join t_sub s on s.id_group = ub.id_group

/*  Next piece of data massaging is to clip the start date of the request */
/*  with the creation date of the account (provided the account was created  */
/*  before the end date of the subscription request). */
UPDATE %%DEBUG%%tmp_subscribe_batch
SET
%%DEBUG%%tmp_subscribe_batch.vt_start = dbo.MTMaxOfTwoDates(ub.vt_start, acc.dt_crt)
FROM
%%DEBUG%%tmp_subscribe_batch ub
INNER JOIN t_account acc on ub.id_acc=acc.id_acc AND acc.dt_crt <= ub.vt_end

/* Check that all potential group subscription members have the same currency on their profiles */
/* as the product offering. */
/* TODO: t_po table does not have an index on id_nonshared_pl. */
/*  if below query affects performance, create it later. */
UPDATE %%DEBUG%%tmp_subscribe_batch
/*  MT_ACCOUNT_PO_CURRENCY_MISMATCH */
SET
%%DEBUG%%tmp_subscribe_batch.status = -486604729 
FROM
%%DEBUG%%tmp_subscribe_batch ub
inner join t_av_internal avi on avi.id_acc = ub.id_acc
inner join t_po po ON po.id_po = ub.id_po
inner join t_pricelist pl on po.id_nonshared_pl = pl.id_pricelist
WHERE
%%%UPPER%%%(avi.c_currency) <> %%%UPPER%%%(pl.nm_currency_code)
AND
%%CURRENCYUPDATESTATUS%%
AND
ub.status=0

UPDATE %%DEBUG%%tmp_subscribe_batch
/*  Error out if the account doesn't exist until after the end date of the  */
/*  subscription request.  I don't want to create a new error message for */
/*  this corner case (porting back to 3.0 for BT); so borrow account state */
/*  message. */
/*  MT_ADD_TO_GROUP_SUB_BAD_STATE */
SET
%%DEBUG%%tmp_subscribe_batch.status = -486604774
FROM
%%DEBUG%%tmp_subscribe_batch ub
INNER JOIN t_account acc on ub.id_acc=acc.id_acc AND acc.dt_crt > ub.vt_end
WHERE
ub.status=0

UPDATE %%DEBUG%%tmp_subscribe_batch 
/*  Check to see if the account is in a state in which we can */
/*  subscribe it. */
/*  TODO: This is the business rule as implemented in 3.5 and 3.0 (check only */
/*  the account state in effect at the wall clock time that the subscription is made). */
/*  What would be better is to ensure that there is no overlap between */
/*  the valid time interval of any "invalid" account state and the subscription */
/*  interval.   */
/*  MT_ADD_TO_GROUP_SUB_BAD_STATE */
SET
%%DEBUG%%tmp_subscribe_batch.status = -486604774
FROM
%%DEBUG%%tmp_subscribe_batch ar
INNER JOIN t_account_state ast ON ar.id_acc=ast.id_acc AND ast.vt_start <= ar.tt_now AND ast.vt_end >= ar.tt_now
INNER JOIN %%DEBUG%%tmp_account_state_rules asr ON ast.status=asr.state
WHERE
asr.can_subscribe=0
AND
ar.status=0

/*  Check that we're not already in the group sub with overlapping date */
/*  MT_ACCOUNT_ALREADY_IN_GROUP_SUBSCRIPTION */
update %%DEBUG%%tmp_subscribe_batch
set %%DEBUG%%tmp_subscribe_batch.status = -486604790
from
%%DEBUG%%tmp_subscribe_batch ar
inner join t_gsubmember s on s.id_acc=ar.id_acc and s.id_group=ar.id_group and s.vt_start <= ar.vt_end and ar.vt_start <= s.vt_end
where
ar.status = 0

/*  Check for different subscription to the same PO by the same account with overlapping date */
update %%DEBUG%%tmp_subscribe_batch 
set %%DEBUG%%tmp_subscribe_batch.status = -289472485 
from
%%DEBUG%%tmp_subscribe_batch ar 
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
ar.status = 0 

/*  Check to make sure that effective date of PO intersects the corrected interval */
/* MTPCUSER_PRODUCTOFFERING_NOT_EFFECTIVE */
update %%DEBUG%%tmp_subscribe_batch 
set %%DEBUG%%tmp_subscribe_batch.status = -289472472 
from 
%%DEBUG%%tmp_subscribe_batch ar 
inner join t_po p on ar.id_po=p.id_po
inner join t_effectivedate ed on ed.id_eff_date=p.id_eff_date
where 
(ed.dt_start > ar.vt_start or ed.dt_end < ar.vt_end)
and
ar.status = 0

/*  Check to see if there is another PO with the same PI template for which an overlapping subscription exists. */
/*  Only do this if other business rules have passed. */
/*  MTPCUSER_CONFLICTING_PO_SUB_PRICEABLEITEM  */
update %%DEBUG%%tmp_subscribe_batch 
set %%DEBUG%%tmp_subscribe_batch.status = -289472484
where
exists (
	select * 
	from
 	t_pl_map plm1 
	inner join t_vw_effective_subs s2 on s2.id_acc=%%DEBUG%%tmp_subscribe_batch.id_acc and s2.id_po<>%%DEBUG%%tmp_subscribe_batch.id_po and s2.dt_start < %%DEBUG%%tmp_subscribe_batch.vt_end and %%DEBUG%%tmp_subscribe_batch.vt_start < s2.dt_end
	inner join t_pl_map plm2 on s2.id_po=plm2.id_po and plm1.id_pi_template = plm2.id_pi_template
	where
	%%DEBUG%%tmp_subscribe_batch.id_po=plm1.id_po
	and
	plm1.id_paramtable is null
	and
	plm2.id_paramtable is null
)
and
%%DEBUG%%tmp_subscribe_batch.status = 0

/*  MT_GSUB_DATERANGE_NOT_IN_SUB_RANGE */
update %%DEBUG%%tmp_subscribe_batch
set %%DEBUG%%tmp_subscribe_batch.status = -486604789
from
%%DEBUG%%tmp_subscribe_batch ar
inner join t_sub s on s.id_group=ar.id_group
where
(ar.vt_start < s.vt_start or ar.vt_end > s.vt_end)
and
ar.status = 0

/*  Check that the group subscription exists */
/*  MT_GROUP_SUBSCRIPTION_DOES_NOT_EXIST */
update %%DEBUG%%tmp_subscribe_batch
set %%DEBUG%%tmp_subscribe_batch.status = -486604788
from
%%DEBUG%%tmp_subscribe_batch ar
where
not exists (
	select *
	from t_group_sub 
	where
	t_group_sub.id_group=ar.id_group
)
and
ar.status = 0

/*  If corp account business rule is enforced, check that */
/*  all potential gsub members are located in the same corporate hierarchy */
/*  as group subscription */
/*  MT_ACCOUNT_NOT_IN_GSUB_CORPORATE_ACCOUNT */
IF %%CORP_BUSINESS_RULE_ENFORCED%% = 1
BEGIN
	update %%DEBUG%%tmp_subscribe_batch
	set %%DEBUG%%tmp_subscribe_batch.status = -486604769 
	from
	%%DEBUG%%tmp_subscribe_batch ar
	inner join t_group_sub gs on ar.id_group=gs.id_group
	inner join t_account_ancestor aa1 on aa1.id_descendent=ar.id_acc and aa1.id_ancestor=1 and aa1.vt_start <= ar.tt_now and ar.tt_now <= aa1.vt_end
	inner join t_account_ancestor aa2 on aa2.id_descendent=ar.id_acc and aa2.num_generations+1=aa1.num_generations and aa2.vt_start <= ar.tt_now and ar.tt_now <= aa2.vt_end
	where
	aa2.id_ancestor <> gs.id_corporate_account
	and
	ar.status = 0
END

/*  MT_GROUP_SUB_MEMBER_CYCLE_MISMATCH */
/*  Check for billing cycle relative  */
update %%DEBUG%%tmp_subscribe_batch
set %%DEBUG%%tmp_subscribe_batch.status = -486604730
from
%%DEBUG%%tmp_subscribe_batch ar
inner join t_sub s on ar.id_group=s.id_group
inner join t_group_sub gs on ar.id_group=gs.id_group
where
s.vt_end >= ar.tt_now
and
(
	/* Only consider this business rule when the target PO */
	/* has a billing cycle relative instance */
	exists (
		select * 
		from 
		t_pl_map plm 
		inner join t_discount piinst on piinst.id_prop=plm.id_pi_instance
		where
		plm.id_po=s.id_po
		and
		plm.id_paramtable is null
		and
		piinst.id_usage_cycle is null
	)
	or
	exists (
		select * 
		from 
		t_pl_map plm
		inner join t_recur piinst on piinst.id_prop=plm.id_pi_instance
		where
		plm.id_po=s.id_po
		and
		plm.id_paramtable is null
		and
		piinst.tx_cycle_mode IN ('BCR', 'BCR Constrained')
	) 
	or
	exists (
		select * 
		from 
		t_pl_map plm 
		inner join t_aggregate piinst on piinst.id_prop=plm.id_pi_instance
		where
		plm.id_po=s.id_po
		and
		plm.id_paramtable is null
		and
		piinst.id_usage_cycle is null
	)
)
and
exists (
	/* All payers must have the same cycle as the cycle as the group sub itself */
	select * 
	from 
	t_payment_redirection pr 
	inner join t_acc_usage_cycle auc on auc.id_acc=pr.id_payer
	where
	pr.id_payee=ar.id_acc 
	and 
	pr.vt_start <= s.vt_end 
	and 
	s.vt_start <= pr.vt_end
	and
	auc.id_usage_cycle <> gs.id_usage_cycle
)
and
ar.status = 0

/*  */
/*  EBCR membership business rules */
/*  */

DECLARE @ebcrResults TABLE 
(
  id_acc INT, /* member account (payee) */
  id_usage_cycle INT, /* payer's cycle */
  b_compatible INT /* EBCR compatibility: 1 or 0 */
)

/*  fills the results table with a row for each member/payer combination */
INSERT INTO @ebcrResults
SELECT 
  batch.id_acc,
  payercycle.id_usage_cycle,
  dbo.CheckEBCRCycleTypeCompatibility(payercycle.id_cycle_type, rc.id_cycle_type)
FROM %%DEBUG%%tmp_subscribe_batch batch
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
  batch.status = 0

/*  checks that members' payers are compatible with the EBCR cycle type */
UPDATE %%DEBUG%%tmp_subscribe_batch 
SET status = -289472443 /* MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_PAYER_OF_MEMBER */
FROM %%DEBUG%%tmp_subscribe_batch batch
INNER JOIN @ebcrResults res ON res.id_acc = batch.id_acc
WHERE res.b_compatible = 0

/*  checks that each member has only one billing cycle across all payers */
UPDATE %%DEBUG%%tmp_subscribe_batch 
SET status = -289472442 /* MTPCUSER_EBCR_MEMBERS_CONFLICT_WITH_EACH_OTHER */
FROM %%DEBUG%%tmp_subscribe_batch batch
INNER JOIN @ebcrResults res ON res.id_acc = batch.id_acc
INNER JOIN @ebcrResults res2 ON res2.id_acc = res.id_acc AND
                                res2.b_compatible = res.b_compatible AND
                                res2.id_usage_cycle <> res.id_usage_cycle
WHERE 
  res.b_compatible = 1 AND
  batch.status = 0


/*  This is a sequenced insert.  For sequenced updates/upsert, run the delete (unsubscribe) first. */
INSERT INTO t_gsubmember_historical (id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
SELECT ar.id_group, ar.id_acc, ar.vt_start, ar.vt_end, ar.tt_now, dbo.MTMaxDate()
FROM
%%DEBUG%%tmp_subscribe_batch ar
WHERE
ar.status=0;
INSERT INTO t_gsubmember (id_group, id_acc, vt_start, vt_end)
SELECT ar.id_group, ar.id_acc, ar.vt_start, ar.vt_end
FROM
%%DEBUG%%tmp_subscribe_batch ar
WHERE
ar.status=0;

/*  Coalecse to merge abutting records */
/*  Implement coalescing to merge any gsubmember records to the */
/*  same subscription that are adjacent.  Still need to work on */
/*  what a bitemporal coalesce looks like. */
WHILE 1=1
BEGIN
update t_gsubmember
set t_gsubmember.vt_end = (
	select max(aa2.vt_end)
	from
	t_gsubmember as aa2
	where
	t_gsubmember.id_group=aa2.id_group
	and
	t_gsubmember.id_acc=aa2.id_acc
	and
	t_gsubmember.vt_start < aa2.vt_start
	and
	dateadd(s,1,t_gsubmember.vt_end) >= aa2.vt_start
	and
	t_gsubmember.vt_end < aa2.vt_end
)
where
exists (
	select *
	from
	t_gsubmember as aa2
	where
	t_gsubmember.id_group=aa2.id_group
	and
	t_gsubmember.id_acc=aa2.id_acc
	and
	t_gsubmember.vt_start < aa2.vt_start
	and
	dateadd(s,1,t_gsubmember.vt_end) >= aa2.vt_start
	and
	t_gsubmember.vt_end < aa2.vt_end
)
and
exists (
  select * from %%DEBUG%%tmp_subscribe_batch ar 
  where ar.id_group = t_gsubmember.id_group and ar.id_acc = t_gsubmember.id_acc
)

IF @@rowcount <= 0 BREAK
END

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
  select * from %%DEBUG%%tmp_subscribe_batch ar 
  where ar.id_group = t_gsubmember.id_group and ar.id_acc = t_gsubmember.id_acc
)

if object_id( 'tempdb..#coalesce_args' ) is not null
  DROP TABLE #coalesce_args

CREATE TABLE #coalesce_args(id_acc int, id_group int, vt_start datetime, vt_end datetime, tt_start datetime, tt_end datetime, update_tt_start datetime, update_tt_end datetime, update_vt_end datetime)

CREATE CLUSTERED INDEX idx_acc_group ON #coalesce_args(id_acc, id_group)

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
WHILE 1=1
BEGIN
insert into #coalesce_args(id_group, id_acc, vt_start, vt_end, tt_start, tt_end, update_tt_start, update_tt_end, update_vt_end)
select 
gsm.id_group,
gsm.id_acc,
gsm.vt_start,
gsm.vt_end,
gsm.tt_start,
gsm.tt_end,
dbo.MTMaxOfTwoDates(gsm.tt_start, gsm2.tt_start) as update_tt_start,
dbo.MTMinOfTwoDates(gsm.tt_end, gsm2.tt_end) as update_tt_end,
max(gsm2.vt_end) as update_vt_end
from 
t_gsubmember_historical gsm
inner join t_gsubmember_historical gsm2 on
gsm.id_group=gsm2.id_group
and
gsm.id_acc=gsm2.id_acc
and
gsm.vt_start < gsm2.vt_start
and
gsm2.vt_start <= dateadd(s, 1, gsm.vt_end)
and
gsm.vt_end < gsm2.vt_end
and
gsm.tt_start <= gsm2.tt_end
and
gsm2.tt_start <= gsm.tt_end
where
exists (
  select * from %%DEBUG%%tmp_subscribe_batch ar 
  where ar.id_group = gsm.id_group and ar.id_acc = gsm.id_acc
)
group by
gsm.id_group,
gsm.id_acc,
gsm.vt_start,
gsm.vt_end,
gsm.tt_start,
gsm.tt_end,
dbo.MTMaxOfTwoDates(gsm.tt_start, gsm2.tt_start),
dbo.MTMinOfTwoDates(gsm.tt_end, gsm2.tt_end)

IF @@rowcount <= 0 BREAK

/*  These are the records whose extender transaction time ends strictly within the record being */
/*  extended */
insert into t_gsubmember_historical(id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
select 
gsm.id_group, gsm.id_acc, gsm.vt_start, gsm.vt_end, dateadd(s, 1, gsm2.vt_end) as tt_start, gsm.tt_end
from 
t_gsubmember_historical gsm
inner join t_gsubmember_historical gsm2 on
gsm.id_group=gsm2.id_group
and
gsm.id_acc=gsm2.id_acc
and
gsm.vt_start < gsm2.vt_start
and
gsm2.vt_start <= dateadd(s, 1, gsm.vt_end)
and
gsm.vt_end < gsm2.vt_end
and
gsm.tt_start <= gsm2.tt_end
and
gsm2.tt_end < gsm.tt_end
where
exists (
  select * from %%DEBUG%%tmp_subscribe_batch ar 
  where ar.id_group = gsm.id_group and ar.id_acc = gsm.id_acc
)

/*  These are the records whose extender starts strictly within the record being */
/*  extended */
insert into t_gsubmember_historical(id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
select 
gsm.id_group, gsm.id_acc, gsm.vt_start, gsm.vt_end, gsm.tt_start, dateadd(s, -1, gsm2.tt_start) as tt_end
from 
t_gsubmember_historical gsm
inner join t_gsubmember_historical gsm2 on
gsm.id_group=gsm2.id_group
and
gsm.id_acc=gsm2.id_acc
and
gsm.vt_start < gsm2.vt_start
and
gsm2.vt_start <= dateadd(s, 1, gsm.vt_end)
and
gsm.vt_end < gsm2.vt_end
and
gsm.tt_start < gsm2.tt_start
and
gsm2.tt_start <= gsm.tt_end
where
exists (
  select * from %%DEBUG%%tmp_subscribe_batch ar 
  where ar.id_group = gsm.id_group and ar.id_acc = gsm.id_acc
)

update  t_gsubmember_historical
set t_gsubmember_historical.vt_end = ca.update_vt_end,
t_gsubmember_historical.tt_start = ca.update_tt_start,
t_gsubmember_historical.tt_end = ca.update_tt_end
from 
t_gsubmember_historical gsm
inner join #coalesce_args ca on
gsm.id_group=ca.id_group
and
gsm.id_acc=ca.id_acc
and
gsm.vt_start=ca.vt_start
and
gsm.vt_end=ca.vt_end
and
gsm.tt_start=ca.tt_start
and
gsm.tt_end=ca.tt_end

TRUNCATE TABLE #coalesce_args
END

/*  Don't need #coalesce_args table anymore, delete it here.  There are some goofy */
/*  interactions between temp tables and DTC that we want to avoid. */
DROP TABLE #coalesce_args

/*  Here we select stuff to "delete" */
/*  In all cases we have containment invalid time. */
/*  Consider the four overlapping cases for transaction time. */
/*   */
update t_gsubmember_historical
set
t_gsubmember_historical.tt_start = (
	select dateadd(s, 1, max(tt_end))
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
  select * from %%DEBUG%%tmp_subscribe_batch ar 
  where ar.id_group = t_gsubmember_historical.id_group and ar.id_acc = t_gsubmember_historical.id_acc
)

update t_gsubmember_historical
set
t_gsubmember_historical.tt_end = (
	select dateadd(s, -1, min(tt_start))
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
  select * from %%DEBUG%%tmp_subscribe_batch ar 
  where ar.id_group = t_gsubmember_historical.id_group and ar.id_acc = t_gsubmember_historical.id_acc
)

delete gsm
/* select * */
from 
t_gsubmember_historical gsm
inner join t_gsubmember_historical gsm2 on
gsm.id_group=gsm2.id_group
and
gsm.id_acc=gsm2.id_acc
and
(
(gsm2.vt_start < gsm.vt_start and gsm.vt_end <= gsm2.vt_end)
or
(gsm2.vt_start <= gsm.vt_start and gsm.vt_end < gsm2.vt_end)
)
and
gsm2.tt_start <= gsm.tt_start
and
gsm.tt_end <= gsm2.tt_end
where
exists (
  select * from %%DEBUG%%tmp_subscribe_batch ar 
  where ar.id_group = gsm.id_group and ar.id_acc = gsm.id_acc
)

/*  Update audit information. */

UPDATE tmp
SET tmp.nm_display_name = gsub.tx_name
FROM %%DEBUG%%tmp_subscribe_batch tmp
  INNER JOIN t_group_sub gsub ON gsub.id_group = tmp.id_group
WHERE tmp.status = 0

INSERT INTO t_audit(id_audit,      id_event,  id_userid,
                    id_entitytype, id_entity, dt_crt)
SELECT tmp.id_audit,      tmp.id_event, tmp.id_userid,
       tmp.id_entitytype, tmp.id_acc,   tmp.tt_now
FROM %%DEBUG%%tmp_subscribe_batch tmp WITH(READCOMMITTED)
WHERE tmp.status = 0

INSERT INTO t_audit_details(id_audit, tx_details)
SELECT tmp.id_audit, tmp.nm_display_name
FROM %%DEBUG%%tmp_subscribe_batch tmp WITH(READCOMMITTED)
WHERE tmp.status = 0
		