
/*  First clip the start and end date with the effective date on the subscription */
/*  and validate that the intersection of the effective date on the sub and the */
/*  delete interval is non-empty. */
/*  __UNSUBSCRIBE_BATCH__ */
UPDATE #tmp_unsubscribe_batch
SET
#tmp_unsubscribe_batch.vt_start = dbo.MTMaxOfTwoDates(ub.vt_start, s.vt_start),
#tmp_unsubscribe_batch.vt_end = dbo.MTMinOfTwoDates(ub.vt_end, s.vt_end),
#tmp_unsubscribe_batch.status = case when ub.vt_start < s.vt_end and ub.vt_end > s.vt_start then 0 else 1 end 
from 
#tmp_unsubscribe_batch ub
inner join t_sub s on s.id_group = ub.id_group

INSERT INTO t_gsubmember_historical(id_group, id_acc, vt_start, vt_end, tt_start, tt_end) 
SELECT gsm.id_group, gsm.id_acc, dateadd(s,1,ar.vt_end) AS vt_start, gsm.vt_end, ar.tt_now as tt_start, dbo.MTMaxDate() as tt_end
FROM t_gsubmember_historical gsm
INNER JOIN #tmp_unsubscribe_batch ar
ON gsm.id_acc = ar.id_acc AND gsm.id_group = ar.id_group AND gsm.vt_start < ar.vt_start AND gsm.vt_end > ar.vt_end and gsm.tt_end = dbo.MTMaxDate()
WHERE
ar.status=0;
		/* Valid time update becomes bi-temporal insert and update */
INSERT INTO t_gsubmember_historical(id_group, id_acc, vt_start, vt_end, tt_start, tt_end) 
SELECT gsm.id_group, gsm.id_acc, gsm.vt_start, dateadd(s,-1,ar.vt_start) AS vt_end, ar.tt_now AS tt_start, dbo.MTMaxDate() AS tt_end 
FROM t_gsubmember_historical gsm
INNER JOIN #tmp_unsubscribe_batch ar
ON gsm.id_acc = ar.id_acc AND gsm.id_group = ar.id_group AND gsm.vt_start < ar.vt_start AND gsm.vt_end >= ar.vt_start AND gsm.tt_end = dbo.MTMaxDate()
WHERE
ar.status=0;

UPDATE t_gsubmember_historical SET t_gsubmember_historical.tt_end = dateadd(s, -1, ar.tt_now) 
FROM t_gsubmember_historical gsm
INNER JOIN #tmp_unsubscribe_batch ar
ON gsm.id_acc = ar.id_acc AND gsm.id_group = ar.id_group AND gsm.vt_start < ar.vt_start AND gsm.vt_end >= ar.vt_start AND gsm.tt_end = dbo.MTMaxDate()
WHERE
ar.status=0;
		/* Valid time update becomes bi-temporal insert (of the modified existing history into the past history) and update (of the modified existing history) */
INSERT INTO t_gsubmember_historical(id_group, id_acc, vt_start, vt_end, tt_start, tt_end) 
SELECT gsm.id_group, gsm.id_acc, dateadd(s,1,ar.vt_end) AS vt_start, gsm.vt_end, ar.tt_now AS tt_start, dbo.MTMaxDate() AS tt_end 
FROM t_gsubmember_historical gsm
INNER JOIN #tmp_unsubscribe_batch ar
ON gsm.id_acc = ar.id_acc AND gsm.id_group = ar.id_group AND gsm.vt_start <= ar.vt_end AND gsm.vt_end > ar.vt_end AND gsm.tt_end = dbo.MTMaxDate()
WHERE
ar.status=0;

UPDATE t_gsubmember_historical SET t_gsubmember_historical.tt_end = dateadd(s, -1, ar.tt_now) 
FROM t_gsubmember_historical gsm
INNER JOIN #tmp_unsubscribe_batch ar
ON gsm.id_acc = ar.id_acc AND gsm.id_group = ar.id_group AND gsm.vt_start <= ar.vt_end AND gsm.vt_end > ar.vt_end AND gsm.tt_end = dbo.MTMaxDate()
WHERE
ar.status=0;
/*  Now we delete any interval contained entirely in the interval we are deleting. */
/*  Transaction table delete is really an update of the tt_end */
/*    [----------------]                 (interval that is being modified) */
/*  [------------------------]           (interval we are deleting) */
UPDATE t_gsubmember_historical SET t_gsubmember_historical.tt_end = dateadd(s, -1, ar.tt_now)
FROM t_gsubmember_historical gsm
INNER JOIN #tmp_unsubscribe_batch ar
ON gsm.id_acc = ar.id_acc AND gsm.id_group = ar.id_group AND gsm.vt_start >= ar.vt_start AND gsm.vt_end <= ar.vt_end AND gsm.tt_end = dbo.MTMaxDate()
WHERE
ar.status=0;

/*  Deal with current time table  */
INSERT INTO t_gsubmember(id_group, id_acc, vt_start, vt_end) 
SELECT gsm.id_group, gsm.id_acc, dateadd(s,1,ar.vt_end) AS vt_start, gsm.vt_end
FROM t_gsubmember gsm
INNER JOIN #tmp_unsubscribe_batch ar
ON gsm.id_acc = ar.id_acc AND gsm.id_group = ar.id_group AND gsm.vt_start < ar.vt_start AND gsm.vt_end > ar.vt_end
WHERE
ar.status=0;

UPDATE t_gsubmember SET
t_gsubmember.vt_end = dateadd(s, -1, ar.vt_start)
FROM t_gsubmember gsm
INNER JOIN #tmp_unsubscribe_batch ar
ON gsm.id_acc = ar.id_acc AND gsm.id_group = ar.id_group AND gsm.vt_start < ar.vt_start AND gsm.vt_end >= ar.vt_start
WHERE
ar.status=0;

UPDATE t_gsubmember SET
t_gsubmember.vt_start = dateadd(s, 1, ar.vt_end)
FROM t_gsubmember gsm
INNER JOIN #tmp_unsubscribe_batch ar
ON gsm.id_acc = ar.id_acc AND gsm.id_group = ar.id_group AND gsm.vt_start <= ar.vt_end AND gsm.vt_end > ar.vt_end
WHERE
ar.status=0;

DELETE gsm
FROM t_gsubmember gsm
INNER JOIN #tmp_unsubscribe_batch ar
ON gsm.id_acc = ar.id_acc AND gsm.id_group = ar.id_group AND gsm.vt_start >= ar.vt_start AND gsm.vt_end <= ar.vt_end
WHERE
ar.status=0;

/*  Update audit information. */
UPDATE ar
SET ar.nm_display_name = gsub.tx_name
FROM #tmp_unsubscribe_batch ar
  INNER JOIN t_group_sub gsub ON gsub.id_group = ar.id_group
WHERE ar.status = 0

INSERT INTO t_audit(id_audit, id_event, id_userid,
                    id_entitytype, id_entity, dt_crt)
SELECT ar.id_audit, ar.id_event, ar.id_userid,
       ar.id_entitytype, ar.id_acc, ar.tt_now
FROM #tmp_unsubscribe_batch ar WITH(READCOMMITTED)
WHERE ar.status = 0

INSERT INTO t_audit_details(id_audit, tx_details)
SELECT ar.id_audit, ar.nm_display_name
FROM #tmp_unsubscribe_batch ar WITH(READCOMMITTED)
WHERE ar.status = 0
		