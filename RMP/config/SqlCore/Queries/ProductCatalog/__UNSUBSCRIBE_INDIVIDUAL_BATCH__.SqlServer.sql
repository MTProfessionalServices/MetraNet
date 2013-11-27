
/*  First clip the start and end date with the effective date on the subscription */
/*  and validate that the intersection of the effective date on the sub and the */
/*  delete interval is non-empty. */
/*  __UNSUBSCRIBE_INDIVIDUAL_BATCH__ */
UPDATE #tmp_unsubscribe_indiv_batch
SET
#tmp_unsubscribe_indiv_batch.vt_start = dbo.MTMaxOfTwoDates(ub.vt_start, s.vt_start),
#tmp_unsubscribe_indiv_batch.vt_end = dbo.MTMinOfTwoDates(ub.vt_end, s.vt_end),
#tmp_unsubscribe_indiv_batch.status = case when ub.vt_start < s.vt_end and ub.vt_end > s.vt_start then 0 else 1 end 
from 
#tmp_unsubscribe_indiv_batch ub
inner join t_sub s on s.id_sub = ub.id_sub

INSERT INTO t_sub_history(id_sub, id_sub_ext, id_acc, id_po, dt_crt, id_group, vt_start, vt_end, tt_start, tt_end) 
SELECT 
sub.id_sub, sub.id_sub_ext, sub.id_acc, sub.id_po, sub.dt_crt, sub.id_group, dateadd(s,1,ar.vt_end) AS vt_start, sub.vt_end, ar.tt_now as tt_start, dbo.MTMaxDate() as tt_end
FROM t_sub_history sub
INNER JOIN #tmp_unsubscribe_indiv_batch ar
ON sub.id_sub = ar.id_sub AND sub.vt_start < ar.vt_start AND sub.vt_end > ar.vt_end and sub.tt_end = dbo.MTMaxDate()
WHERE
ar.status=0;
		/* Valid time update becomes bi-temporal insert and update */
INSERT INTO t_sub_history(id_sub, id_sub_ext, id_acc, id_po, dt_crt, id_group, vt_start, vt_end, tt_start, tt_end) 
SELECT 
sub.id_sub, sub.id_sub_ext, sub.id_acc, sub.id_po, sub.dt_crt, sub.id_group, sub.vt_start, dateadd(s,-1,ar.vt_start) AS vt_end, ar.tt_now AS tt_start, dbo.MTMaxDate() AS tt_end 
FROM t_sub_history sub
INNER JOIN #tmp_unsubscribe_indiv_batch ar
ON sub.id_sub = ar.id_sub AND sub.vt_start < ar.vt_start AND sub.vt_end >= ar.vt_start AND sub.tt_end = dbo.MTMaxDate()
WHERE
ar.status=0;

UPDATE t_sub_history SET t_sub_history.tt_end = dateadd(s, -1, ar.tt_now) 
FROM t_sub_history sub
INNER JOIN #tmp_unsubscribe_indiv_batch ar
ON sub.id_sub = ar.id_sub AND sub.vt_start < ar.vt_start AND sub.vt_end >= ar.vt_start AND sub.tt_end = dbo.MTMaxDate()
WHERE
ar.status=0;
		/* Valid time update becomes bi-temporal insert (of the modified existing history into the past history) and update (of the modified existing history) */
INSERT INTO t_sub_history(id_sub, id_sub_ext, id_acc, id_po, dt_crt, id_group, vt_start, vt_end, tt_start, tt_end) 
SELECT 
sub.id_sub, sub.id_sub_ext, sub.id_acc, sub.id_po, sub.dt_crt, sub.id_group, dateadd(s,1,ar.vt_end) AS vt_start, sub.vt_end, ar.tt_now AS tt_start, dbo.MTMaxDate() AS tt_end 
FROM t_sub_history sub
INNER JOIN #tmp_unsubscribe_indiv_batch ar
ON sub.id_sub = ar.id_sub AND sub.vt_start <= ar.vt_end AND sub.vt_end > ar.vt_end AND sub.tt_end = dbo.MTMaxDate()
WHERE
ar.status=0;

UPDATE t_sub_history SET t_sub_history.tt_end = dateadd(s, -1, ar.tt_now) 
FROM t_sub_history sub
INNER JOIN #tmp_unsubscribe_indiv_batch ar
ON sub.id_sub = ar.id_sub AND sub.vt_start <= ar.vt_end AND sub.vt_end > ar.vt_end AND sub.tt_end = dbo.MTMaxDate()
WHERE
ar.status=0;
/*  Now we delete any interval contained entirely in the interval we are deleting. */
/*  Transaction table delete is really an update of the tt_end */
/*    [----------------]                 (interval that is being modified) */
/*  [------------------------]           (interval we are deleting) */
UPDATE t_sub_history SET t_sub_history.tt_end = dateadd(s, -1, ar.tt_now)
FROM t_sub_history sub
INNER JOIN #tmp_unsubscribe_indiv_batch ar
ON sub.id_sub = ar.id_sub AND sub.vt_start >= ar.vt_start AND sub.vt_end <= ar.vt_end AND sub.tt_end = dbo.MTMaxDate()
WHERE
ar.status=0;

/*  Deal with current time table  */
INSERT INTO t_sub(id_sub, id_sub_ext, id_acc, id_po, dt_crt, id_group, vt_start, vt_end) 
SELECT 
sub.id_sub, sub.id_sub_ext, sub.id_acc, sub.id_po, sub.dt_crt, sub.id_group, dateadd(s,1,ar.vt_end) AS vt_start, sub.vt_end
FROM t_sub sub
INNER JOIN #tmp_unsubscribe_indiv_batch ar
ON sub.id_sub = ar.id_sub AND sub.vt_start < ar.vt_start AND sub.vt_end > ar.vt_end
WHERE
ar.status=0;

UPDATE t_sub SET
t_sub.vt_end = dateadd(s, -1, ar.vt_start)
FROM t_sub sub
INNER JOIN #tmp_unsubscribe_indiv_batch ar
ON sub.id_sub = ar.id_sub AND sub.vt_start < ar.vt_start AND sub.vt_end >= ar.vt_start
WHERE
ar.status=0;

UPDATE t_sub SET
t_sub.vt_start = dateadd(s, 1, ar.vt_end)
FROM t_sub sub
INNER JOIN #tmp_unsubscribe_indiv_batch ar
ON sub.id_sub = ar.id_sub AND sub.vt_start <= ar.vt_end AND sub.vt_end > ar.vt_end
WHERE
ar.status=0;

DELETE sub
FROM t_sub sub
INNER JOIN #tmp_unsubscribe_indiv_batch ar
ON sub.id_sub = ar.id_sub AND sub.vt_start >= ar.vt_start AND sub.vt_end <= ar.vt_end
WHERE
ar.status=0;

/*  Update audit information. */
UPDATE ar
SET ar.nm_display_name = ''
FROM #tmp_unsubscribe_indiv_batch ar
WHERE ar.status = 0

INSERT INTO t_audit(id_audit, id_event, id_userid,
                    id_entitytype, id_entity, dt_crt)
SELECT ar.id_audit, ar.id_event, ar.id_userid,
       ar.id_entitytype, ar.id_acc, ar.tt_now
FROM #tmp_unsubscribe_indiv_batch ar WITH(READCOMMITTED)
WHERE ar.status = 0

INSERT INTO t_audit_details(id_audit, tx_details)
SELECT ar.id_audit, ar.nm_display_name
FROM #tmp_unsubscribe_indiv_batch ar WITH(READCOMMITTED)
WHERE ar.status = 0
		