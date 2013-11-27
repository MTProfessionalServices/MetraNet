
declare 
/*  __IDENTIFY_CONFLICTING_SUBSCRIPTIONS_INDIVIDUAL__ */

	system_datetime date;
	max_datetime    date;

begin

	select %%%SYSTEMDATE%%% 
	into system_datetime from dual;/* GetUTCDate() */
	max_datetime := dbo.MTMaxDate();

/*  Start AddNewSub */

/*  compute usage cycle dates if necessary */

	update %%DEBUG%%tmp_subscribe_individual_batch tmp
	   set tmp.dt_end = case
	                      when tmp.dt_end is null then max_datetime
	                      else tmp.dt_end
	                   end
	 where tmp.status is null;

/*  This SQL used to call dbo.NextDateAfterBillingCycle */
	update %%DEBUG%%tmp_subscribe_individual_batch tmp
	   set tmp.dt_start =
		   (select addsecond(tpc.dt_end)
		      from t_pc_interval tpc 
				inner join t_acc_usage_cycle tauc 
					on tpc.id_cycle = tauc.id_usage_cycle
		     where tmp.next_cycle_after_startdate = 'Y'
		       and tauc.id_acc = tmp.id_acc
		       and tpc.dt_start <= tmp.dt_start
		       and tmp.dt_start <= tpc.dt_end
		       and tmp.status is null)
	 where exists(
	       select 1
	         from t_pc_interval tpc 
				inner join t_acc_usage_cycle tauc 
					on tpc.id_cycle = tauc.id_usage_cycle
	        where tmp.next_cycle_after_startdate = 'Y'
	          and tauc.id_acc = tmp.id_acc
	          and tpc.dt_start <= tmp.dt_start
	          and tmp.dt_start <= tpc.dt_end
	             and tmp.status is null);

/*  This SQL used to call dbo.NextDateAfterBillingCycle */
	update %%DEBUG%%tmp_subscribe_individual_batch tmp
	   set tmp.dt_end =
	          (select addsecond(tpc.dt_end)
	             from t_pc_interval tpc 
					 inner join t_acc_usage_cycle tauc 
					 	on tpc.id_cycle = tauc.id_usage_cycle
	            where tmp.next_cycle_after_enddate = 'Y'
	              and tauc.id_acc = tmp.id_acc
	              and tpc.dt_start <= tmp.dt_end
	              and tmp.dt_end <= tpc.dt_end
	              and tmp.dt_end <> max_datetime
	              and tmp.status is null)
	 where exists(
	          select 1
	            from t_pc_interval tpc 
					inner join t_acc_usage_cycle tauc 
						on tpc.id_cycle = tauc.id_usage_cycle
	           where tmp.next_cycle_after_enddate = 'Y'
	             and tauc.id_acc = tmp.id_acc
	             and tpc.dt_start <= tmp.dt_end
	             and tmp.dt_end <= tpc.dt_end
	             and tmp.dt_end <> max_datetime
	             and tmp.status is null);

/*  End AddNewSub */

/*  Start AddSubscriptionBase */

/*  Start AdjustSubDate */

	update %%DEBUG%%tmp_subscribe_individual_batch tmp
	   set (tmp.dt_adj_start, tmp.dt_adj_end) =
			(select te.dt_start,
			        case
			           when te.dt_end is null then max_datetime
			           else te.dt_end
			        end
			   from t_po po 
				inner join t_effectivedate te 
						on te.id_eff_date = po.id_eff_date
			  where tmp.status is null
			    and po.id_po = tmp.id_po)
	 where exists(
		select 1 
		  from t_po po 
		  inner join t_effectivedate te 
		  		on te.id_eff_date = po.id_eff_date
		 where tmp.status is null
		   and po.id_po = tmp.id_po);
	

/*  This SQL used to call dbo.MTMaxOfTwoDates and dbo.MTMinOfTwoDates */
	update %%DEBUG%%tmp_subscribe_individual_batch tmp
	   set tmp.dt_adj_start =
	          case
	             when tmp.dt_adj_start > tmp.dt_start then tmp.dt_adj_start
	             else tmp.dt_start
	          end,
	       tmp.dt_adj_end =
	          case
	             when tmp.dt_adj_end < tmp.dt_end then tmp.dt_adj_end
	             else tmp.dt_end
	          end
	 where tmp.status is null;
	 
	insert into %%DEBUG%%tmp_unsubscribe_indiv_batch
	            (id_acc, id_po, id_sub, vt_start, vt_end, uncorrected_vt_start,
	             uncorrected_vt_end, tt_now, status, id_audit, id_event,
	             id_userid, id_entitytype)
	   select ar.id_acc, ar.id_po, s2.id_sub, ar.dt_adj_start, ar.dt_adj_end,
	          ar.dt_adj_start, ar.dt_adj_end, %%TT_NOW%%, 0,
	          ar.id_audit, %%ID_EVENT_SUB_DELETE%%, ar.id_userid,
	          ar.id_entitytype
	     from tmp_subscribe_individual_batch ar 
		  inner join t_sub s2 
		  		on s2.id_acc = ar.id_acc 
				and s2.vt_start <= ar.dt_adj_end 
				and ar.dt_adj_start <= s2.vt_end
	    where exists(
	             select 1
	               from t_pl_map plm1 
						inner join t_pl_map plm2 
						 	on plm1.id_pi_template = plm2.id_pi_template
	             where  ar.id_po = plm1.id_po
	                and s2.id_po = plm2.id_po
	                and plm1.id_paramtable is null
	                and plm2.id_paramtable is null);

	insert into %%DEBUG%%tmp_unsubscribe_batch
	            (id_acc, id_po, id_group, vt_start, vt_end, uncorrected_vt_start,
	             uncorrected_vt_end, tt_now, id_gsub_corp_account, status,
	             id_audit, id_event, id_userid, id_entitytype)
	   select ar.id_acc, ar.id_po, s.id_group, ar.dt_adj_start, ar.dt_adj_end, ar.dt_adj_start, 
				 ar.dt_adj_end, %%TT_NOW%%, gs.id_corporate_account, 0, 
				 ar.id_audit, %%ID_EVENT_GSUBMEMBER_DELETE%%, ar.id_userid, ar.id_entitytype
	     from tmp_subscribe_individual_batch ar 
		  inner join t_gsubmember s 
		  		on s.id_acc = ar.id_acc 
				and s.vt_start <= ar.dt_adj_end 
				and ar.dt_adj_start <= s.vt_end
	     inner join t_group_sub gs on gs.id_group = s.id_group
	     inner join t_sub s2 on gs.id_group = s2.id_group
	    where exists(
	             select 1
	               from t_pl_map plm1 
						inner join t_pl_map plm2 
							on plm1.id_pi_template = plm2.id_pi_template
	              where ar.id_po = plm1.id_po
						 and s2.id_po = plm2.id_po 
	                and plm1.id_paramtable is null
	                and plm2.id_paramtable is null);

end;
		