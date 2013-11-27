
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
%%DEBUG%%tmp_subscribe_batch.status = case when ub.vt_start < s.vt_end and ub.vt_end > s.vt_start then 0 else 1 end,
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

INSERT INTO #tmp_unsubscribe_indiv_batch(id_acc, id_po, id_sub, vt_start, vt_end, uncorrected_vt_start, uncorrected_vt_end, tt_now, status, id_audit, id_event, id_userid, id_entitytype)
select ar.id_acc, ar.id_po, s2.id_sub, ar.vt_start, ar.vt_end, ar.vt_start, ar.vt_end, %%TT_NOW%%, 0, ar.id_audit, %%ID_EVENT_SUB_DELETE%%, ar.id_userid, ar.id_entitytype
from %%DEBUG%%tmp_subscribe_batch ar
inner join t_sub s2 on s2.id_acc=ar.id_acc  
and s2.vt_start <= ar.vt_end and ar.vt_start <= s2.vt_end
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
select ar.id_acc, ar.id_po, s.id_group, ar.vt_start, ar.vt_end, ar.vt_start, ar.vt_end, %%TT_NOW%%, gs.id_corporate_account, 0, ar.id_audit, %%ID_EVENT_GSUBMEMBER_DELETE%%, ar.id_userid, ar.id_entitytype
from %%DEBUG%%tmp_subscribe_batch ar
inner join t_gsubmember s on s.id_acc=ar.id_acc and s.vt_start <= ar.vt_end and ar.vt_start <= s.vt_end
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
		