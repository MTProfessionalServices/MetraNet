
begin

	/*  If the vt_end is null then use subscription end date */
	update %%DEBUG%%tmp_subscribe_batch
	   set vt_end = dbo.mtmaxdate(),
	       uncorrected_vt_end = dbo.mtmaxdate()
	 where %%DEBUG%%tmp_subscribe_batch.vt_end is null;
	 
 
/*  First clip the start and end date with the effective date on the subscription */
/*  and validate that the intersection of the effective date on the sub and the */
/*  delete interval is non-empty. */
	update %%DEBUG%%tmp_subscribe_batch ub
	   set (vt_start, vt_end,status, id_sub,id_po) =
	          (select dbo.mtmaxoftwodates(ub.vt_start, s.vt_start) as vtstart,
	                  dbo.mtminoftwodates(ub.vt_end, s.vt_end) as vtend,
	                  case
	                     when ub.vt_start < s.vt_end
	                  and    ub.vt_end > s.vt_start then 0
	                     else 1
	                  end as status,
	                  s.id_sub as idsub, s.id_po as idpo
	           from   t_sub s
	           where  s.id_group = ub.id_group)
	 where exists(select 1
	              from   t_sub s
	              where  s.id_group = ub.id_group);
				  

/*  Next piece of data massaging is to clip the start date of the request */
/*  with the creation date of the account (provided the account was created  */
/*  before the end date of the subscription request). */
	update %%DEBUG%%tmp_subscribe_batch ub
	   set vt_start =
	       (select dbo.mtmaxoftwodates(ub.vt_start, acc.dt_crt)
	          from t_account acc
	         where ub.id_acc = acc.id_acc
	           and acc.dt_crt <= ub.vt_end)
	 where exists(select 1
	         from t_account acc
	        where ub.id_acc = acc.id_acc
	          and acc.dt_crt <= ub.vt_end);

			 
	insert into %%DEBUG%%tmp_unsubscribe_indiv_batch
	            (id_acc, id_po, id_sub, vt_start, vt_end, uncorrected_vt_start,
	             uncorrected_vt_end, tt_now, status, id_audit, id_event,
	             id_userid, id_entitytype)
	   select ar.id_acc, ar.id_po, s2.id_sub, ar.vt_start, ar.vt_end, ar.vt_start,
	          ar.vt_end, %%TT_NOW%%, 0, ar.id_audit,
	          %%ID_EVENT_SUB_DELETE%%, ar.id_userid, ar.id_entitytype
	   from   %%DEBUG%%tmp_subscribe_batch ar 
		inner join t_sub s2 
			on s2.id_acc = ar.id_acc
			and s2.vt_start <= ar.vt_end 
			and ar.vt_start <= s2.vt_end
	   where  exists(
	             select 1
	             from   t_pl_map plm1 
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
	   select ar.id_acc, ar.id_po, s.id_group, ar.vt_start, ar.vt_end,
	          ar.vt_start, ar.vt_end, sysdate /*%%TT_NOW%%*/,
	          gs.id_corporate_account, 0, ar.id_audit,
	          %%ID_EVENT_GSUBMEMBER_DELETE%%, ar.id_userid,
	          ar.id_entitytype
	   from   %%DEBUG%%tmp_subscribe_batch ar 
		inner join t_gsubmember s 
			on s.id_acc = ar.id_acc 
			and s.vt_start <= ar.vt_end 
			and ar.vt_start <= s.vt_end
	   inner join t_group_sub gs 
			on gs.id_group = s.id_group
	   inner join t_sub s2 
			on gs.id_group = s2.id_group
	   where  exists(
	             select 1
	             from   t_pl_map plm1 
					 inner join t_pl_map plm2 
						 on plm1.id_pi_template = plm2.id_pi_template
	             where  ar.id_po = plm1.id_po
						 and s2.id_po = plm2.id_po 
	                and plm1.id_paramtable is null
	                and plm2.id_paramtable is null);

end;
		