/* GET_USAGE_INTERVAL_DATA_FOR_BILLGROUPS_WITHOUT_ACCT_STATS_FOR_PARTITION */
select ui.id_interval IntervalID,
       uct.tx_desc CycleType,
       uc.id_usage_cycle CycleID,
       ui.dt_start StartDate,
       ui.dt_end EndDate,
       ui.tx_interval_status Status,
       (case when mat.id_usage_interval is null then 'N' else 'Y' end) HasBeenMaterialized,
       (case when billgroups.TotalGroupCnt is null then 0 else billgroups.TotalGroupCnt end) TotalGroupCnt,
       (case when billgroups.OpenGroupCnt is null then 0 else billgroups.OpenGroupCnt end) OpenGroupCnt,
       (case when billgroups.SoftClosedGroupCnt is null then 0 else billgroups.SoftClosedGroupCnt end) SoftClosedGroupCnt,
       (case when billgroups.HardClosedGroupCnt is null then 0 else billgroups.HardClosedGroupCnt end) HardClosedGroupCnt,
       (case when adapters.TotalIntervalOnlyAdapterCnt is null then 0 else adapters.TotalIntervalOnlyAdapterCnt end) TotalIntervalOnlyAdapterCnt,
       (case when adapters.SucceedIntervalOnlyAdapterCnt is null then 0 else adapters.SucceedIntervalOnlyAdapterCnt end) SucceedIntervalOnlyAdapterCnt,
       (case when adapters.FailedIntervalOnlyAdapterCnt is null then 0 else adapters.FailedIntervalOnlyAdapterCnt end) FailedIntervalOnlyAdapterCnt,
       (case when adapters.TotalBillGrpAdapterCnt is null then 0 else adapters.TotalBillGrpAdapterCnt end) TotalBillGrpAdapterCnt,
       (case when adapters.SucceedBillGrpAdapterCnt is null then 0 else adapters.SucceedBillGrpAdapterCnt end) SucceedBillGrpAdapterCnt,
       (case when adapters.FailedBillGrpAdapterCnt is null then 0 else adapters.FailedBillGrpAdapterCnt end) FailedBillGrpAdapterCnt,
       (ISNULL(accounts.HardClosedUnassignedAcctsCnt,0) + ISNULL(partition_root_account.HardClosedUnassignedAcctsCnt,0)) HardClosedUnassignedAcctsCnt,
       (ISNULL(accounts.OpenUnassignedAcctsCnt,0) + ISNULL(partition_root_account.OpenUnassignedAcctsCnt,0)) OpenUnassignedAcctsCnt
from t_usage_interval ui
inner join t_usage_cycle uc ON uc.id_usage_cycle = ui.id_usage_cycle  
inner join t_usage_cycle_type uct ON uct.id_cycle_type = uc.id_cycle_type 
left outer join  /* materialization */
  (select tbm.id_usage_interval
    from t_billgroup_materialization tbm
    inner join t_billgroup on t_billgroup.id_billgroup = tbm.id_materialization and t_billgroup.id_partition = %%ID_PARTITION%%
    where tbm.tx_type = 'Full' and
         tbm.tx_status = 'Succeeded' and
         tbm.id_parent_billgroup is null
  union all
  select tbm.id_usage_interval
    from t_billgroup_materialization tbm
    inner join t_billgroup on t_billgroup.id_billgroup = tbm.id_parent_billgroup and t_billgroup.id_partition = %%ID_PARTITION%%
    where tbm.tx_type = 'Full' and
          tbm.tx_status = 'Succeeded' and
          tbm.id_parent_billgroup is not null
         ) mat on mat.id_usage_interval = ui.id_interval
 left outer join /* aggregate paying accounts and unassigned account status */
  (select count (case when unassigned.id_acc is null and aui.tx_status = 'H' then aui.id_acc end) HardClosedUnassignedAcctsCnt,
          count (case when unassigned.id_acc is null and aui.tx_status = 'O' then aui.id_acc end) OpenUnassignedAcctsCnt,       
          count (*) TotalPayingAcctsForInterval,
          aui.id_usage_interval         
   from t_acc_usage_interval aui
   inner join t_account_mapper amap ON amap.id_acc = aui.id_acc 
   inner join t_namespace nmspace ON nmspace.nm_space = amap.nm_space
   /*filter for the partition*/
   JOIN t_namespace ns on amap.nm_space = ns.nm_space and lower(ns.tx_typ_space) = 'system_mps' and lower(ns.nm_method) = 'partition'
   JOIN t_account_mapper tamap on lower(tamap.nm_login) = lower(ns.nm_space) and lower(tamap.nm_space) = 'mt' and tamap.id_acc = %%ID_PARTITION%%
   left outer join /* unassigned accounts */
     (select id_acc, id_usage_interval
	  from t_billgroup_member bgm 
	  inner join t_billgroup bg 
	  on bg.id_billgroup = bgm.id_billgroup and bg.id_partition = %%ID_PARTITION%%) unassigned on unassigned.id_acc = aui.id_acc and
                                             unassigned.id_usage_interval = aui.id_usage_interval
   where  nmspace.tx_typ_space = 'system_mps' and
          aui.id_usage_interval = %%ID_INTERVAL%% and
          aui.id_acc != %%ID_PARTITION%%
   group by aui.id_usage_interval) accounts on accounts.id_usage_interval = ui.id_interval
 left outer join /* aggregate paying accounts and unassigned account status */
  (select count (case when unassigned.id_acc is null and aui.tx_status = 'H' then aui.id_acc end) HardClosedUnassignedAcctsCnt,
          count (case when unassigned.id_acc is null and aui.tx_status = 'O' then aui.id_acc end) OpenUnassignedAcctsCnt,       
          count (*) TotalPayingAcctsForInterval,
          aui.id_usage_interval         
   from t_acc_usage_interval aui
   inner join t_account_mapper amap ON amap.id_acc = aui.id_acc
   inner join t_namespace nmspace ON nmspace.nm_space = amap.nm_space
   left outer join /* unassigned accounts */
     (select id_acc, id_usage_interval
	  from t_billgroup_member bgm 
	  inner join t_billgroup bg 
	  on bg.id_billgroup = bgm.id_billgroup and bg.id_partition = %%ID_PARTITION%%) unassigned on unassigned.id_acc = aui.id_acc and
                                             unassigned.id_usage_interval = aui.id_usage_interval
   where  nmspace.tx_typ_space = 'system_mps' and
          aui.id_usage_interval = %%ID_INTERVAL%% and 
          aui.id_acc = %%ID_PARTITION%%
   group by aui.id_usage_interval) partition_root_account on partition_root_account.id_usage_interval = ui.id_interval
left outer join /* billing group status */
  (select count(*) TotalGroupCnt,
          count (case when tx_status = 'O' then id_billgroup end) OpenGroupCnt,
          count (case when tx_status = 'C' then id_billgroup end) SoftClosedGroupCnt,
          count (case when tx_status = 'H' then id_billgroup end) HardClosedGroupCnt, 
          id_usage_interval 
   from (select bg.id_billgroup, aui.tx_status, bg.id_usage_interval /* status by billing group*/
         from t_billgroup bg
		 inner join t_billgroup_member bgm on bgm.id_billgroup = bg.id_billgroup
		 inner join t_acc_usage_interval aui on aui.id_usage_interval = bg.id_usage_interval and
                                         aui.id_acc = bgm.id_acc
         where bg.id_usage_interval = %%ID_INTERVAL%% and bg.id_partition = %%ID_PARTITION%%
         group by bg.id_billgroup, aui.tx_status, bg.id_usage_interval) bgs 
   group by bgs.id_usage_interval) billgroups on billgroups.id_usage_interval = ui.id_interval
left outer join /* adapter data */
  (select   count(case when re.tx_type <> 'Root' and 
                            ri.id_arg_billgroup is null 
                       then id_instance 
                  end) TotalIntervalOnlyAdapterCnt,

		    count(case when re.tx_type <> 'Root' and 
						  ri.tx_status = 'Succeeded' and 
						  ri.id_arg_billgroup is null 
				  	   then id_instance 
				  end) SucceedIntervalOnlyAdapterCnt, 

			count(case when re.tx_type <> 'Root' and 
			     		    ri.tx_status = 'Failed' and 
							ri.id_arg_billgroup is null 
					    then id_instance 
				  end) FailedIntervalOnlyAdapterCnt,

		    count(case when re.tx_type <> 'Root' and 
					  	    re.tx_type <> 'Checkpoint' and
						    ri.id_arg_billgroup is not null 
					   then id_instance 
				  end) TotalBillGrpAdapterCnt,

			count(case when re.tx_type <> 'Root' and 
			  			    re.tx_type <> 'Checkpoint' and
							ri.tx_status = 'Succeeded' and 
							ri.id_arg_billgroup is not null 
					   then id_instance 
				  end) SucceedBillGrpAdapterCnt, 

		    count(case when re.tx_type <> 'Root' and 
						    ri.tx_status = 'Failed' and 
						    re.tx_type <> 'Checkpoint' and
						    ri.id_arg_billgroup is not null 
					   then id_instance 
				  end) FailedBillGrpAdapterCnt,
            ri.id_arg_interval
		from t_recevent_inst ri 
		inner join t_recevent re ON re.id_event = ri.id_event
    inner join t_billgroup bg ON (case when ri.id_arg_billgroup is null then ri.id_arg_root_billgroup else ri.id_arg_billgroup end) = bg.id_billgroup and bg.id_partition = %%ID_PARTITION%%  
		where -- event is active
			re.dt_activated <= %%%SYSTEMDATE%%% AND
			(re.dt_deactivated is null or %%%SYSTEMDATE%%% < re.dt_deactivated)
        group by ri.id_arg_interval) adapters on adapters.id_arg_interval = ui.id_interval

   
where ui.id_interval = %%ID_INTERVAL%%
