          
/* GET_USAGE_INTERVAL_DATA_FOR_BILLGROUPS_WITHOUT_ACCT_STATS */
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
       (case when adapters.FailedBillGrpAdapterCnt is null then 0 else adapters.FailedBillGrpAdapterCnt end) FailedBillGrpAdapterCnt
from t_usage_interval ui
inner join t_usage_cycle uc ON uc.id_usage_cycle = ui.id_usage_cycle  
inner join t_usage_cycle_type uct ON uct.id_cycle_type = uc.id_cycle_type 
left outer join  /* materialization */
  (select id_usage_interval
   from t_billgroup_materialization 
   where tx_type = 'Full' and
         tx_status = 'Succeeded') mat on mat.id_usage_interval = ui.id_interval
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
         where bg.id_usage_interval = %%ID_INTERVAL%%
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
		where -- event is active
			re.dt_activated <= %%%SYSTEMDATE%%% AND
			(re.dt_deactivated is null or %%%SYSTEMDATE%%% < re.dt_deactivated)
        group by ri.id_arg_interval) adapters on adapters.id_arg_interval = ui.id_interval

   
where ui.id_interval = %%ID_INTERVAL%%
