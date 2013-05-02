
begin        
/*  First clip the start and end date with the effective date on the subscription */
/*  and validate that the intersection of the effective date on the sub and the */
/*  delete interval is non-empty. */
/*  __UNSUBSCRIBE_BATCH__ */
update tmp_unsubscribe_batch ub
set (vt_start, vt_end, status) =
       (select dbo.mtmaxoftwodates (ub.vt_start, s.vt_start) as vtstart,
               dbo.mtminoftwodates (ub.vt_end, s.vt_end) as vtend,
               case
                  when     ub.vt_start < s.vt_end
                       and ub.vt_end > s.vt_start then 0
                  else 1
               end as status
        from   t_sub s
        where  s.id_group = ub.id_group)
where  exists (select 1
               from   t_sub s
               where  s.id_group = ub.id_group);
					
INSERT INTO t_gsubmember_historical(id_group, id_acc, vt_start, vt_end, tt_start, tt_end) 
SELECT gsm.id_group, gsm.id_acc, addsecond(ar.vt_end) AS vt_start, gsm.vt_end, ar.tt_now as tt_start, dbo.MTMaxDate() as tt_end
FROM t_gsubmember_historical gsm
INNER JOIN tmp_unsubscribe_batch ar
ON gsm.id_acc = ar.id_acc AND gsm.id_group = ar.id_group AND gsm.vt_start < ar.vt_start AND gsm.vt_end > ar.vt_end and gsm.tt_end = dbo.MTMaxDate()
WHERE
ar.status=0;

		/* Valid time update becomes bi-temporal insert and update */
INSERT INTO t_gsubmember_historical(id_group, id_acc, vt_start, vt_end, tt_start, tt_end) 
SELECT gsm.id_group, gsm.id_acc, gsm.vt_start, subtractsecond(ar.vt_start) AS vt_end, ar.tt_now AS tt_start, dbo.MTMaxDate() AS tt_end 
FROM t_gsubmember_historical gsm
INNER JOIN tmp_unsubscribe_batch ar
ON gsm.id_acc = ar.id_acc AND gsm.id_group = ar.id_group AND gsm.vt_start < ar.vt_start AND gsm.vt_end >= ar.vt_start AND gsm.tt_end = dbo.MTMaxDate()
WHERE
ar.status=0;

update t_gsubmember_historical gsm
set tt_end =
       (select subtractsecond (ar.tt_now)
        from   tmp_unsubscribe_batch ar
        where      gsm.id_acc = ar.id_acc
               and gsm.id_group = ar.id_group
               and gsm.vt_start < ar.vt_start
               and gsm.vt_end >= ar.vt_start
               and gsm.tt_end = dbo.mtmaxdate ()
               and ar.status = 0)
where  exists (
          select 1
          from   tmp_unsubscribe_batch ar
          where      gsm.id_acc = ar.id_acc
                 and gsm.id_group = ar.id_group
                 and gsm.vt_start < ar.vt_start
                 and gsm.vt_end >= ar.vt_start
                 and gsm.tt_end = dbo.mtmaxdate ()
                 and ar.status = 0);

		/* Valid time update becomes bi-temporal insert (of the modified existing history into the past history) and update (of the modified existing history) */
INSERT INTO t_gsubmember_historical(id_group, id_acc, vt_start, vt_end, tt_start, tt_end) 
SELECT gsm.id_group, gsm.id_acc, addsecond(ar.vt_end) AS vt_start, gsm.vt_end, ar.tt_now AS tt_start, dbo.MTMaxDate() AS tt_end 
FROM t_gsubmember_historical gsm
INNER JOIN tmp_unsubscribe_batch ar
ON gsm.id_acc = ar.id_acc AND gsm.id_group = ar.id_group AND gsm.vt_start <= ar.vt_end AND gsm.vt_end > ar.vt_end AND gsm.tt_end = dbo.MTMaxDate()
WHERE
ar.status=0;

update t_gsubmember_historical gsm
set tt_end =
       (select subtractsecond (ar.tt_now)
        from   tmp_unsubscribe_batch ar
        where      gsm.id_acc = ar.id_acc
               and gsm.id_group = ar.id_group
               and gsm.vt_start <= ar.vt_end
               and gsm.vt_end > ar.vt_end
               and gsm.tt_end = dbo.mtmaxdate ()
               and ar.status = 0)
where  exists (
          select 1
          from   tmp_unsubscribe_batch ar
          where      gsm.id_acc = ar.id_acc
                 and gsm.id_group = ar.id_group
                 and gsm.vt_start <= ar.vt_end
                 and gsm.vt_end > ar.vt_end
                 and gsm.tt_end = dbo.mtmaxdate ()
                 and ar.status = 0);

/*  Now we delete any interval contained entirely in the interval we are deleting. */
/*  Transaction table delete is really an update of the tt_end */
/*    [----------------]                 (interval that is being modified) */
/*  [------------------------]           (interval we are deleting) */
update t_gsubmember_historical gsm
set tt_end =
       (select subtractsecond (ar.tt_now)
        from   tmp_unsubscribe_batch ar
        where      gsm.id_acc = ar.id_acc
               and gsm.id_group = ar.id_group
               and gsm.vt_start >= ar.vt_start
               and gsm.vt_end <= ar.vt_end
               and gsm.tt_end = dbo.mtmaxdate ()
               and status = 0)
where  exists (
          select 1
          from   tmp_unsubscribe_batch ar
          where      gsm.id_acc = ar.id_acc
                 and gsm.id_group = ar.id_group
                 and gsm.vt_start >= ar.vt_start
                 and gsm.vt_end <= ar.vt_end
                 and gsm.tt_end = dbo.mtmaxdate ()
                 and status = 0);

/*  Deal with current time table  */
INSERT INTO t_gsubmember(id_group, id_acc, vt_start, vt_end) 
SELECT gsm.id_group, gsm.id_acc, addsecond(ar.vt_end) AS vt_start, gsm.vt_end
FROM t_gsubmember gsm
INNER JOIN tmp_unsubscribe_batch ar
ON gsm.id_acc = ar.id_acc AND gsm.id_group = ar.id_group AND gsm.vt_start < ar.vt_start AND gsm.vt_end > ar.vt_end
WHERE
ar.status=0;

update t_gsubmember gsm
set vt_end =
       (select subtractsecond (ar.vt_start)
        from   tmp_unsubscribe_batch ar
        where      gsm.id_acc = ar.id_acc
               and gsm.id_group = ar.id_group
               and gsm.vt_start < ar.vt_start
               and gsm.vt_end >= ar.vt_start
               and ar.status = 0)
where  exists (
          select 1
          from   tmp_unsubscribe_batch ar
          where      gsm.id_acc = ar.id_acc
                 and gsm.id_group = ar.id_group
                 and gsm.vt_start < ar.vt_start
                 and gsm.vt_end >= ar.vt_start
                 and ar.status = 0);

update t_gsubmember gsm
set vt_start =
       (select addsecond (ar.vt_end)
        from   tmp_unsubscribe_batch ar
        where      gsm.id_acc = ar.id_acc
               and gsm.id_group = ar.id_group
               and gsm.vt_start <= ar.vt_end
               and gsm.vt_end > ar.vt_end
               and ar.status = 0)
where  exists (
          select addsecond (ar.vt_end)
          from   tmp_unsubscribe_batch ar
          where      gsm.id_acc = ar.id_acc
                 and gsm.id_group = ar.id_group
                 and gsm.vt_start <= ar.vt_end
                 and gsm.vt_end > ar.vt_end
                 and ar.status = 0);

delete t_gsubmember gsm
where exists (
          select 1
          from   tmp_unsubscribe_batch ar
          where      gsm.id_acc = ar.id_acc
                 and gsm.id_group = ar.id_group
                 and gsm.vt_start >= ar.vt_start
                 and gsm.vt_end <= ar.vt_end
                 and ar.status = 0);
					  

/*  Update audit information. */
update tmp_unsubscribe_batch ar
set ar.nm_display_name =
                        (select gsub.tx_name
                         from   t_group_sub gsub
                         where      gsub.id_group = ar.id_group
                                and ar.status = 0)
where  exists (select gsub.tx_name
               from   t_group_sub gsub
               where      gsub.id_group = ar.id_group
                      and ar.status = 0);

INSERT INTO t_audit(id_audit, id_event, id_userid,
                    id_entitytype, id_entity, dt_crt)
SELECT ar.id_audit, ar.id_event, ar.id_userid,
       ar.id_entitytype, ar.id_acc, ar.tt_now
FROM tmp_unsubscribe_batch ar 
WHERE ar.status = 0;
							 
INSERT INTO t_audit_details(id_auditdetails,id_audit, tx_details)
SELECT seq_t_audit_details.nextval,ar.id_audit, ar.nm_display_name
FROM tmp_unsubscribe_batch ar 
WHERE ar.status = 0;
end;
        