
/*  __EXECUTE_SUBSCRIBE_INDIVIDUAL_ACCOUNTS__ */
declare
	system_datetime date;
	max_datetime    date;

begin
	system_datetime := %%%SYSTEMDATE%%%; /* GetUTCDate() */
	max_datetime := dbo.MTMaxDate();

/*  Check to see if the account is in a state in which we can subscribe it. */
/*  */
/*  TODO: This is the business rule as implemented in 3.5 and 3.0 (check only */
/*  the account state in effect at the wall clock time that the subscription is made). */
/*  What would be better is to ensure that there is no overlap between the valid time */
/*  interval of any "invalid" account state and the subscription interval. */
/*  */
/*  This check was taken from the SQL for __EXECUTE_SUBSCRIBE_TO_GROUP_BATCH__. */
update  %%DEBUG%%tmp_subscribe_individual_batch tmp
set tmp.status = -486604774   /* MT_ADD_TO_GROUP_SUB_BAD_STATE */
where  tmp.id_acc in (
	select tmp.id_acc
   from  t_account_state ast 
	inner join tmp_account_state_rules asr on ast.status = asr.state
   where asr.can_subscribe = 0
		and tmp.id_acc = ast.id_acc
         and ast.vt_start <= system_datetime
         and ast.vt_end >= system_datetime
     and tmp.status is null);

/*  check that account type of each member is compatible with the product offering */
/*  since the absense of ANY mappings for the product offering means that PO is "wide open" */
/*  we need to do 2 EXISTS queries. */

update %%DEBUG%%tmp_subscribe_individual_batch tmp  
set tmp.status = -289472435 /* MTPCUSER_CONFLICTING_PO_ACCOUNT_TYPE */
where (
	exists (
		select 1
		from t_po_account_type_map atmap
		where atmap.id_po = tmp.id_po)
	/* po is not wide open - see if susbcription is permitted for the account type */
	and not exists (
		select 1
		from t_account tacc
		inner join t_po_account_type_map atmap 
			on atmap.id_account_type = tacc.id_type
		where atmap.id_po = tmp.id_po 
			and tmp.id_acc = tacc.id_acc)
	)
and tmp.status is null;

/* Check MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE 0xEEBF004EL -289472434 */
update  %%DEBUG%%tmp_subscribe_individual_batch tmp
set    tmp.status = -289472434 /* MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE */
where exists (
	select 1 from t_account acc 
	inner join t_account_type acctype 
		on acc.id_type = acctype.id_type
	where tmp.id_acc = acc.id_acc
	and acctype.b_cansubscribe = '0' 
	and tmp.status is null
	);

/*  Start AddNewSub */

/*  compute usage cycle dates if necessary */

update  %%DEBUG%%tmp_subscribe_individual_batch tmp
set    tmp.dt_end   = case when tmp.dt_end is null
                           then max_datetime
                           else tmp.dt_end
                           end,
       tmp.sub_guid = case when tmp.sub_guid is null
                           then sys_guid()
                           else tmp.sub_guid
                           end
where  tmp.status is null;

/*  This SQL used to call dbo.NextDateAfterBillingCycle */
update  %%DEBUG%%tmp_subscribe_individual_batch tmp 
set tmp.dt_start = (
	select tpc.dt_end + numtodsinterval(1, 'second')
	from t_pc_interval tpc
	inner join t_acc_usage_cycle tauc 
		on tpc.id_cycle = tauc.id_usage_cycle
	where tauc.id_acc = tmp.id_acc
	and tmp.next_cycle_after_startdate = 'Y'
	  and tpc.dt_start <= tmp.dt_start
	  and tmp.dt_start <= tpc.dt_end
	  and tmp.status is null
	  )
where exists (
	select 1
	from t_pc_interval tpc
	inner join t_acc_usage_cycle tauc 
		on tpc.id_cycle = tauc.id_usage_cycle
	where tauc.id_acc = tmp.id_acc
	and tmp.next_cycle_after_startdate = 'Y'
	  and tpc.dt_start <= tmp.dt_start
	  and tmp.dt_start <= tpc.dt_end
	  and tmp.status is null
	  );

/*  This SQL used to call dbo.NextDateAfterBillingCycle */
update  %%DEBUG%%tmp_subscribe_individual_batch tmp
SET    tmp.dt_end = (
	select tpc.dt_end + numtodsinterval(1, 'second') as new_dt_end
	from t_pc_interval tpc
	inner join t_acc_usage_cycle tauc 
		on tpc.id_cycle = tauc.id_usage_cycle
	where tauc.id_acc = tmp.id_acc
	and tmp.next_cycle_after_enddate = 'Y'
	  and tpc.dt_start <= tmp.dt_end
	  and tmp.dt_end   <= tpc.dt_end
	  and tmp.dt_end <> max_datetime
	  and tmp.status is null
	  )
where exists (
	select 1
	from t_pc_interval tpc
	inner join t_acc_usage_cycle tauc 
		on tpc.id_cycle = tauc.id_usage_cycle
	where tauc.id_acc = tmp.id_acc
	and tmp.next_cycle_after_enddate = 'Y'
	  and tpc.dt_start <= tmp.dt_end
	  and tmp.dt_end   <= tpc.dt_end
	  and tmp.dt_end <> max_datetime
	  and tmp.status is null
	);

/*  End AddNewSub */

/*  Start AddSubscriptionBase */

/*  Start AdjustSubDate */

UPDATE  %%DEBUG%%tmp_subscribe_individual_batch tmp
set (tmp.dt_adj_start, tmp.dt_adj_end) = ( 
		select te.dt_start, nvl(te.dt_end, max_datetime)
		from t_po po 
		inner join t_effectivedate te 
		 on te.id_eff_date = po.id_eff_date
		where tmp.status is null 
		 and po.id_po = tmp.id_po
		)
where exists (
		select te.dt_start, nvl(te.dt_end, max_datetime)
		from t_po po 
		inner join t_effectivedate te 
		 on te.id_eff_date = po.id_eff_date
		where tmp.status is null 
		 and po.id_po = tmp.id_po
		);

/*  This SQL used to call dbo.MTMaxOfTwoDates and dbo.MTMinOfTwoDates */
update %%DEBUG%%tmp_subscribe_individual_batch tmp
set    tmp.dt_adj_start = case when tmp.dt_adj_start > tmp.dt_start
                               then tmp.dt_adj_start
                               else tmp.dt_start
                               end,
       tmp.dt_adj_end   = case when tmp.dt_adj_end < tmp.dt_end
                               then tmp.dt_adj_end
                               else tmp.dt_end
                               end
where  tmp.status is null;

update  %%DEBUG%%tmp_subscribe_individual_batch tmp
set    tmp.status = -289472472 /* mtpcuser_productoffering_not_effective (0xeebf0028) */
where tmp.dt_adj_end < tmp.dt_adj_start
  and tmp.status is null;

update  %%DEBUG%%tmp_subscribe_individual_batch tmp
set tmp.date_modified = case 
		when (tmp.dt_start <> tmp.dt_adj_start) 
			or (tmp.dt_end <> tmp.dt_adj_end)
      then 'Y' else 'N' end
where tmp.status is null;

/*  End AdjustSubDate */

/*  Check availability of the product offering. */

update  %%DEBUG%%tmp_subscribe_individual_batch tmp
set    tmp.status = ( 
		select case 
			when (ta.n_begintype = 0) or (ta.n_endtype = 0)
		    	then -289472451 /* mtpcuser_availability_date_not_set (0xeebf003d) */
		   when (ta.n_begintype <> 0) and (ta.dt_start > system_datetime)
		    	then -289472449 /* mtpcuser_availability_date_in_future (0xeebf003f) */
		   when (ta.n_endtype <> 0) and (ta.dt_end < system_datetime)
				then -289472450 /* mtpcuser_availability_date_in_past (0xeebf003e) */
		   else null
		   end
		from t_po po 
		inner join t_effectivedate ta 
			on po.id_avail = ta.id_eff_date
		where tmp.status is null 
			and po.id_po = tmp.id_po
		)
where exists (
		select case 
			when (ta.n_begintype = 0) or (ta.n_endtype = 0)
		    	then -289472451 /* mtpcuser_availability_date_not_set (0xeebf003d) */
		   when (ta.n_begintype <> 0) and (ta.dt_start > system_datetime)
		    	then -289472449 /* mtpcuser_availability_date_in_future (0xeebf003f) */
		   when (ta.n_endtype <> 0) and (ta.dt_end < system_datetime)
				then -289472450 /* mtpcuser_availability_date_in_past (0xeebf003e) */
		   else null
		   end
		from t_po po 
		inner join t_effectivedate ta 
			on po.id_avail = ta.id_eff_date
		where tmp.status is null 
			and po.id_po = tmp.id_po
		);

/*  Start CheckSubscriptionConflicts */

update  %%DEBUG%%tmp_subscribe_individual_batch tmp1
	set tmp1.status = -289472485 /* mtpcuser_conflicting_po_subscription (0xeebf001b) */
where (
	exists(select 1
	  from t_sub s1 
	  where s1.id_po=tmp1.id_po 
	  	and s1.id_acc=tmp1.id_acc 
		and s1.id_sub <> tmp1.id_acc
	  	and s1.vt_start <= tmp1.dt_adj_end 
		and tmp1.dt_adj_start <= s1.vt_end
	  	and s1.id_group is null
   )
	or
	exists (select 1
	  from t_gsubmember gsm1
	  inner join t_sub  s1 
	  	  on gsm1.id_group=s1.id_group
	  where s1.id_po = tmp1.id_po 
	  	and gsm1.id_acc=tmp1.id_acc 
		and s1.id_sub <> tmp1.id_acc
	  	and gsm1.vt_start <= tmp1.dt_adj_end and tmp1.dt_adj_start <= gsm1.vt_end
	))
	and tmp1.status is null;
 

	/* This SQL used to call dbo.OverlappingDateRange(). */
update  %%DEBUG%%tmp_subscribe_individual_batch tmp
set tmp.status =
       (select case
                  when ((tmp.dt_adj_start > te.dt_end)
                        or (te.dt_start is not null
                            and te.dt_start > tmp.dt_adj_end
                           )
                       ) then -289472472   /* mtpcuser_productoffering_not_effective (0xeebf0028) */
                  else null
               end
          from t_po 
			 inner join t_effectivedate te 
			 	on te.id_eff_date = t_po.id_eff_date
         where tmp.status is null
           and tmp.id_po = t_po.id_po)
where exists 
       (select 1
          from t_po 
			 inner join t_effectivedate te 
			 	on te.id_eff_date = t_po.id_eff_date
         where tmp.status is null
           and tmp.id_po = t_po.id_po);

/* Update all Conflicting PI if Allow Same PI Subscription Business Rule is Disabled regardless of PI Type */ 

update  %%DEBUG%%tmp_subscribe_individual_batch tmp
set tmp.status =
        -289472484   /* MTPCUSER_CONFLICTING_PO_SUB_PRICEABLEITEM (0xEEBF001C) */
where  exists (
          select 1
		from t_vw_effective_subs s2
            inner join t_pl_map plm2 on s2.id_po = plm2.id_po
            inner join t_pl_map plm1 on plm1.id_pi_template = plm2.id_pi_template
	    where s2.id_acc = tmp.id_acc
	               and s2.id_po <> tmp.id_po
	               and s2.dt_start <= tmp.dt_adj_end
	               and tmp.dt_adj_start <= s2.dt_end
           and tmp.id_po = plm1.id_po
             and plm1.id_paramtable is null
             and plm2.id_paramtable is null)
   and tmp.status is null
   and %%CONFLICTINGPINOTALLOWED%%;	


/* Update POs having Non RC/NRC PI In it eventhough Allow Same PI Subscription Business Rule is enabled */

update  %%DEBUG%%tmp_subscribe_individual_batch tmp
set tmp.status =
        -289472484   /* MTPCUSER_CONFLICTING_PO_SUB_PRICEABLEITEM (0xEEBF001C) */
where  exists (
          select 1
		from t_vw_effective_subs s2
            inner join t_pl_map plm2 on s2.id_po = plm2.id_po
            inner join t_pl_map plm1 on plm1.id_pi_template = plm2.id_pi_template
	    inner join t_base_props bp ON plm1.id_pi_template = bp.id_prop
	    where s2.id_acc = tmp.id_acc
	               and s2.id_po <> tmp.id_po
	               and s2.dt_start <= tmp.dt_adj_end
	               and tmp.dt_adj_start <= s2.dt_end
           and tmp.id_po = plm1.id_po
             and plm1.id_paramtable is null
             and plm2.id_paramtable is null
	     and bp.n_kind in (10,40))
   and tmp.status is null
   and NOT (%%CONFLICTINGPINOTALLOWED%%);	






/*  Start IsAccountAndPOSameCurrency */

/*  This SQL used to call (dbo.IsAccountAndPOSameCurrency() = '0') */
update %%DEBUG%%tmp_subscribe_individual_batch tmp
set tmp.status =  -486604729 /* MT_ACCOUNT_PO_CURRENCY_MISMATCH (0xE2FF0047) */
where  exists (
          select 1
            from t_po po 
            inner join t_pricelist pl 
					on po.id_nonshared_pl = pl.id_pricelist
				inner join t_av_internal av on av.c_currency <> pl.nm_currency_code
					
           where av.id_acc = tmp.id_acc
             and tmp.status is null
             and po.id_po = tmp.id_po
             and  %%CURRENCYUPDATESTATUS%%);

/*  End IsAccountAndPOSameCurrency */

UPDATE %%DEBUG%%tmp_subscribe_individual_batch tmp
SET tmp.status = -289472430 /* MTPCUSER_SUBSCRIPTION_START_DATE_LESS_THAN_ACCOUNT_CREATION_DATE (0xEEBF0052) */
where exists (
	select 1 
		from t_account ac
		where ac.id_acc = tmp.id_acc
		  and ac.dt_crt > tmp.dt_adj_start
		  and tmp.status is null
);

/*  End CheckSubscriptionConflicts */

/* flag as errors any subscription request for which there is
 a payer whose cycle conflicts with cycle type of a BCR priceable item. */
UPDATE %%DEBUG%%tmp_subscribe_individual_batch tmp
SET    tmp.status = -289472464 /* MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE (0xEEBF0030) */
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
);

/*  checks the subscriber's billing cycle for EBCR cycle conflicts */
update %%DEBUG%%tmp_subscribe_individual_batch tmp
   set tmp.status =
          -289472444   /* MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE (0xEEBF0044) */
 where tmp.status IS NULL
	and exists (
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
);

/*  End AddSubscriptionBase */

/*  Start CreateSubscriptionRecord */

/*  Create the new subscription history record. */
insert into t_sub_history
            (id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start,
             vt_end, tt_start, tt_end)
   select tmp.id_sub, tmp.sub_guid, tmp.id_acc, null, tmp.id_po,
          system_datetime, tmp.dt_adj_start, tmp.dt_adj_end, system_datetime,
          max_datetime
     from %%DEBUG%%tmp_subscribe_individual_batch tmp
    where tmp.status is null;
	 
/*  Create the new subscription record. */
insert into t_sub
            (id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start,
             vt_end)
   select tmp.id_sub, tmp.sub_guid, tmp.id_acc, null, tmp.id_po,
          system_datetime, tmp.dt_adj_start, tmp.dt_adj_end
     from %%DEBUG%%tmp_subscribe_individual_batch tmp
    where tmp.status is null;
	 
/*  End CreateSubscriptionRecord */

/*  Update audit information. */

update %%DEBUG%%tmp_subscribe_individual_batch tmp
   set tmp.nm_display_name =
          (select dscrpt.tx_desc
             from t_description dscrpt 
				 left outer join t_base_props bp 
				 		on dscrpt.id_desc = bp.n_display_name
             inner join t_po 
				 		on bp.id_prop = t_po.id_po
            where bp.n_kind = 100
              and dscrpt.id_lang_code = %%ID_LANG%%
              and tmp.id_po = t_po.id_po
              and tmp.status is null)
where exists 
          (select dscrpt.tx_desc
             from t_description dscrpt 
				 left outer join t_base_props bp 
				 		on dscrpt.id_desc = bp.n_display_name
             inner join t_po 
				 		on bp.id_prop = t_po.id_po
            where bp.n_kind = 100
              and dscrpt.id_lang_code = %%ID_LANG%%
              and tmp.id_po = t_po.id_po
              and tmp.status is null);

insert into t_audit
            (id_audit, id_event, id_userid, id_entitytype, 
				id_entity, dt_crt)
   select tmp.id_audit, tmp.id_event, tmp.id_userid, tmp.id_entitytype,
          tmp.id_acc, system_datetime
     from %%DEBUG%%tmp_subscribe_individual_batch tmp
    where tmp.status is null;

insert into t_audit_details
            (id_auditdetails,id_audit, tx_details)
   select seq_t_audit_details.nextval,tmp.id_audit, tmp.nm_display_name
     from %%DEBUG%%tmp_subscribe_individual_batch tmp
    where tmp.status is null;
	 
end;
        