
begin 

	/*  First clip the start and end date with the effective date on the subscription */
	/*  and validate that the intersection of the effective date on the sub and the */
	/*  delete interval is non-empty. */
	/*  __UNSUBSCRIBE_INDIVIDUAL_BATCH__ */
	update tmp_unsubscribe_indiv_batch ub
	   set (vt_start, vt_end, status) =
	          (select dbo.mtmaxoftwodates(ub.vt_start, s.vt_start) as vtstart,
	                  dbo.mtminoftwodates(ub.vt_end, s.vt_end) as vtend,
	                  case
	                     when ub.vt_start < s.vt_end
	                          and ub.vt_end > s.vt_start then 0
	                     else 1
	                  end as status
	           from   t_sub s
	           where  s.id_sub = ub.id_sub)
	where exists
	          (select 1
	           from   t_sub s
	           where  s.id_sub = ub.id_sub);
			  

	insert into t_sub_history
	            (id_sub, id_sub_ext, id_acc, id_po, dt_crt, id_group, vt_start,
	             vt_end, tt_start, tt_end)
	   select sub.id_sub, sub.id_sub_ext, sub.id_acc, sub.id_po, sub.dt_crt,
	          sub.id_group, addsecond(ar.vt_end) as vt_start, sub.vt_end,
	          ar.tt_now as tt_start, dbo.mtmaxdate() as tt_end
	   from   t_sub_history sub 
		inner join tmp_unsubscribe_indiv_batch ar 
			on sub.id_sub = ar.id_sub 
			and sub.vt_start < ar.vt_start 
			and sub.vt_end > ar.vt_end 
			and sub.tt_end = dbo.mtmaxdate()
	   where  ar.status = 0;

	/* Valid time update becomes bi-temporal insert and update */
	insert into t_sub_history
	            (id_sub, id_sub_ext, id_acc, id_po, dt_crt, id_group, vt_start,
	             vt_end, tt_start, tt_end)
	   select sub.id_sub, sub.id_sub_ext, sub.id_acc, sub.id_po, sub.dt_crt,
	          sub.id_group, sub.vt_start, subtractsecond(ar.vt_start) as vt_end,
	          ar.tt_now as tt_start, dbo.mtmaxdate() as tt_end
	   from   t_sub_history sub 
		inner join tmp_unsubscribe_indiv_batch ar 
			on sub.id_sub = ar.id_sub 
			and sub.vt_start < ar.vt_start 
			and sub.vt_end >= ar.vt_start 
			and sub.tt_end = dbo.mtmaxdate()
	   where  ar.status = 0;

update t_sub_history sub
   set sub.tt_end =
          (select subtractsecond(ar.tt_now)
           from   tmp_unsubscribe_indiv_batch ar
           where  sub.id_sub = ar.id_sub
                  and sub.vt_start < ar.vt_start
                  and sub.vt_end >= ar.vt_start
                  and sub.tt_end = dbo.mtmaxdate()
                  and ar.status = 0)
 where exists(
          select 1
          from   tmp_unsubscribe_indiv_batch ar
          where  sub.id_sub = ar.id_sub
                 and sub.vt_start < ar.vt_start
                 and sub.vt_end >= ar.vt_start
                 and sub.tt_end = dbo.mtmaxdate()
                 and ar.status = 0);
					  

	/* Valid time update becomes bi-temporal insert (of the modified existing history into the past history) and update (of the modified existing history) */
	insert into t_sub_history
	            (id_sub, id_sub_ext, id_acc, id_po, dt_crt, id_group, vt_start,
	             vt_end, tt_start, tt_end)
	   select sub.id_sub, sub.id_sub_ext, sub.id_acc, sub.id_po, sub.dt_crt,
	          sub.id_group, addsecond(ar.vt_end) as vt_start, sub.vt_end,
	          ar.tt_now as tt_start, dbo.mtmaxdate() as tt_end
	   from   t_sub_history sub 
		inner join tmp_unsubscribe_indiv_batch ar 
		on sub.id_sub = ar.id_sub 
		and sub.vt_start <= ar.vt_end 
		and sub.vt_end > ar.vt_end 
		and sub.tt_end = dbo.mtmaxdate()
	   where  ar.status = 0;

	update t_sub_history sub
	   set tt_end =
	          (select subtractsecond(ar.tt_now)
	           from   tmp_unsubscribe_indiv_batch ar
	           where  sub.id_sub = ar.id_sub
	                  and sub.vt_start <= ar.vt_end
	                  and sub.vt_end > ar.vt_end
	                  and sub.tt_end = dbo.mtmaxdate()
	                  and ar.status = 0)
	 where exists(
	          select 1
	          from   tmp_unsubscribe_indiv_batch ar
	          where  sub.id_sub = ar.id_sub
	                 and sub.vt_start <= ar.vt_end
	                 and sub.vt_end > ar.vt_end
	                 and sub.tt_end = dbo.mtmaxdate()
	                 and ar.status = 0);

	/*  Now we delete any interval contained entirely in the interval we are deleting. */
	/*  Transaction table delete is really an update of the tt_end */
	/*    [----------------]                 (interval that is being modified) */
	/*  [------------------------]           (interval we are deleting) */
	update t_sub_history sub
	   set tt_end =
	          (select subtractsecond(ar.tt_now)
	           from   tmp_unsubscribe_indiv_batch ar
	           where  sub.id_sub = ar.id_sub
	                  and sub.vt_start >= ar.vt_start
	                  and sub.vt_end <= ar.vt_end
	                  and sub.tt_end = dbo.mtmaxdate()
	                  and ar.status = 0)
	 where exists(
	          select 1
	          from   tmp_unsubscribe_indiv_batch ar
	          where  sub.id_sub = ar.id_sub
	                 and sub.vt_start <= ar.vt_end
	                 and sub.vt_end > ar.vt_end
	                 and sub.tt_end = dbo.mtmaxdate()
	                 and ar.status = 0);							

	/*  Deal with current time table  */
	insert into t_sub
	            (id_sub, id_sub_ext, id_acc, id_po, dt_crt, id_group, vt_start,
	             vt_end)
	   select sub.id_sub, sub.id_sub_ext, sub.id_acc, sub.id_po, sub.dt_crt,
	          sub.id_group, addsecond(ar.vt_end) as vt_start, sub.vt_end
	   from   t_sub sub 
		inner join tmp_unsubscribe_indiv_batch ar 
			on sub.id_sub = ar.id_sub 
			and sub.vt_start < ar.vt_start 
			and sub.vt_end > ar.vt_end 
	   where  ar.status = 0;
		
update t_sub sub
   set vt_end =
          (select subtractsecond(ar.vt_start)
           from   tmp_unsubscribe_indiv_batch ar
           where  sub.id_sub = ar.id_sub
                  and sub.vt_start < ar.vt_start
                  and sub.vt_end >= ar.vt_start
                  and ar.status = 0)
 where exists(
          select 1
          from   tmp_unsubscribe_indiv_batch ar
          where  sub.id_sub = ar.id_sub
                 and sub.vt_start < ar.vt_start
                 and sub.vt_end >= ar.vt_start
                 and ar.status = 0);

	update t_sub sub
	   set vt_start =
	          (select addsecond(ar.vt_end)
	           from   tmp_unsubscribe_indiv_batch ar
	           where  sub.id_sub = ar.id_sub
	                  and sub.vt_start <= ar.vt_end
	                  and sub.vt_end > ar.vt_end
	                  and ar.status = 0)
	 where exists(
	          select 1
	          from   tmp_unsubscribe_indiv_batch ar
	          where  sub.id_sub = ar.id_sub
	                 and sub.vt_start <= ar.vt_end
	                 and sub.vt_end > ar.vt_end
	                 and ar.status = 0);

	delete from t_sub sub
		where exists(
		   select 1
		   from   tmp_unsubscribe_indiv_batch ar
		   where  sub.id_sub = ar.id_sub
		      and sub.vt_start >= ar.vt_start
		      and sub.vt_end <= ar.vt_end
		      and ar.status = 0);

	/*  Update audit information. */
	update tmp_unsubscribe_indiv_batch ar
	   set ar.nm_display_name = ''
	 where ar.status = 0;

	insert into t_audit
	            (id_audit, id_event, id_userid, id_entitytype, id_entity, dt_crt)
	   select ar.id_audit, ar.id_event, ar.id_userid, ar.id_entitytype, ar.id_acc,
	          ar.tt_now
	   from   tmp_unsubscribe_indiv_batch ar
	   where  ar.status = 0;

	insert into t_audit_details
	            (id_auditdetails,id_audit, tx_details)
	   select seq_t_audit_details.nextval,ar.id_audit, ar.nm_display_name
	   from   tmp_unsubscribe_indiv_batch ar
	   where  ar.status = 0;

end;
		