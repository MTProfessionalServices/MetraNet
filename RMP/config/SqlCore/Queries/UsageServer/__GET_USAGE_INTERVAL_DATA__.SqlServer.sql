
select ui.id_interval IntervalID,
       uct.tx_desc CycleType,
       ui.dt_start StartDate,
       ui.dt_end EndDate,
       ui.tx_interval_status Status,
       (case when mat.id_usage_interval is null then 'N' else 'Y' end) HasBeenMaterialized,
       accounts.TotalPayingAcctsForInterval,
       accounts.HardClosedUnassignedAcctsCnt,
       accounts.OpenUnassignedAcctsCnt
from t_usage_interval ui
inner join t_usage_cycle uc ON uc.id_usage_cycle = ui.id_usage_cycle  
inner join t_usage_cycle_type uct ON uct.id_cycle_type = uc.id_cycle_type 
left outer join  /* materialization */
  (select id_usage_interval
   from t_billgroup_materialization 
   where tx_type = 'Full' and
         tx_status = 'Succeeded') mat on mat.id_usage_interval = ui.id_interval
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
	  on bg.id_billgroup = bgm.id_billgroup) unassigned on unassigned.id_acc = aui.id_acc and
                                             unassigned.id_usage_interval = aui.id_usage_interval
   where  nmspace.tx_typ_space = 'system_mps' 
   group by aui.id_usage_interval) accounts on accounts.id_usage_interval = ui.id_interval
   
where ui.id_interval = %%ID_INTERVAL%%
