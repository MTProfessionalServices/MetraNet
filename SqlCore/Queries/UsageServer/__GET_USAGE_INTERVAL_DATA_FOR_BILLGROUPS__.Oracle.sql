/* __GET_USAGE_INTERVAL_DATA_FOR_BILLGROUPS__ */              
WITH 
mat AS
(
	  SELECT id_usage_interval
	  FROM t_billgroup_materialization
	  WHERE tx_type = 'Full' 
	  AND tx_status = 'Succeeded'
),
accounts AS
(
	  SELECT   
	  /*+
	  index(aui fk2idx_t_acc_usage_interval)
	  no_merge(unassigned)
	  no_push_pred(unassigned)
	  */
	  COUNT (CASE WHEN unassigned.id_acc IS NULL AND aui.tx_status = 'H' THEN aui.id_acc END) hardclosedunassignedacctscnt,
	  COUNT (CASE WHEN unassigned.id_acc IS NULL AND aui.tx_status = 'O' THEN aui.id_acc END) openunassignedacctscnt,
	  COUNT (*) totalpayingacctsforinterval, 
	  aui.id_usage_interval
	  FROM t_acc_usage_interval aui 
	  INNER JOIN t_account_mapper amap ON amap.id_acc = aui.id_acc
	  INNER JOIN t_namespace nmspace ON nmspace.nm_space = amap.nm_space
	  LEFT OUTER JOIN /* unassigned accounts */
	  (
			SELECT id_acc, id_usage_interval
			FROM t_billgroup_member bgm 
			INNER JOIN t_billgroup bg
			ON bg.id_billgroup = bgm.id_billgroup
	  ) unassigned ON unassigned.id_acc = aui.id_acc AND unassigned.id_usage_interval = aui.id_usage_interval
	  WHERE 1 = 1
	  AND nmspace.tx_typ_space = 'system_mps'
	  AND aui.id_usage_interval = %%ID_INTERVAL%%
	  GROUP BY aui.id_usage_interval
),
bga AS
(
	  SELECT bgm.id_acc, bg.id_usage_interval, bg.id_billgroup
	  FROM t_billgroup_member bgm 
	  INNER JOIN t_billgroup bg ON bg.id_billgroup = bgm.id_billgroup
),
bgs AS
(
	  SELECT 
	  /*+
	  index(aui fk2idx_t_acc_usage_interval)
	  no_merge(bga)
	  no_push_pred(bga)
	  */
	  bga.id_billgroup, aui.tx_status, aui.id_usage_interval
	  FROM t_acc_usage_interval aui 
	  INNER JOIN bga ON bga.id_acc = aui.id_acc AND bga.id_usage_interval = aui.id_usage_interval
	  WHERE aui.id_usage_interval = %%ID_INTERVAL%%
	  GROUP BY bga.id_billgroup, aui.tx_status, aui.id_usage_interval
),
billgroups AS
(
	  select 
	  count(*) TotalGroupCnt,
	  count (case when tx_status = 'O' then id_billgroup end) OpenGroupCnt,
	  count (case when tx_status = 'C' then id_billgroup end) SoftClosedGroupCnt,
	  count (case when tx_status = 'H' then id_billgroup end) HardClosedGroupCnt, 
	  id_usage_interval
	  FROM bgs
	  GROUP BY bgs.id_usage_interval
),
adapters as 
(
	  select  count(case when re.tx_type <> 'Root' and ri.id_arg_billgroup is null then id_instance end) TotalIntervalOnlyAdapterCnt,
	  count(case when re.tx_type <> 'Root' and ri.tx_status = 'Succeeded' and ri.id_arg_billgroup is null then id_instance end) SucceedIntervalOnlyAdapterCnt,
	  count(case when re.tx_type <> 'Root' and ri.tx_status = 'Failed' and ri.id_arg_billgroup is null then id_instance end) FailedIntervalOnlyAdapterCnt,
	  count(case when re.tx_type <> 'Root' and re.tx_type <> 'Checkpoint' and ri.id_arg_billgroup is not null then id_instance end) TotalBillGrpAdapterCnt,
	  count(case when re.tx_type <> 'Root' and re.tx_type <> 'Checkpoint' and ri.tx_status = 'Succeeded' and ri.id_arg_billgroup is not null then id_instance end) SucceedBillGrpAdapterCnt, 
	  count(case when re.tx_type <> 'Root' and ri.tx_status = 'Failed' and re.tx_type <> 'Checkpoint' and ri.id_arg_billgroup is not null then id_instance end) FailedBillGrpAdapterCnt,
	  ri.id_arg_interval
	  from t_recevent_inst ri 
	  inner join t_recevent re ON re.id_event = ri.id_event
	  /*event is active*/
	  where  re.dt_activated <= %%%SYSTEMDATE%%% 
	  and (re.dt_deactivated is null or %%%SYSTEMDATE%%% < re.dt_deactivated)
	  group by ri.id_arg_interval
)
select 
	  ui.id_interval IntervalID,
	  uct.tx_desc CycleType,
	  uc.id_usage_cycle CycleID,
	  ui.dt_start StartDate,
	  ui.dt_end EndDate,
	  ui.tx_interval_status Status,
	  (case when mat.id_usage_interval is null then 'N' else 'Y' end) HasBeenMaterialized,
	  accounts.TotalPayingAcctsForInterval,
	  accounts.HardClosedUnassignedAcctsCnt,
	  accounts.OpenUnassignedAcctsCnt,
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
left outer join  /* materialization */ mat on mat.id_usage_interval = ui.id_interval
left outer join /* aggregate paying accounts and unassigned account status */ accounts on accounts.id_usage_interval = ui.id_interval
left outer join /* billing group status */ billgroups on billgroups.id_usage_interval = ui.id_interval
left outer join /* adapter data */ adapters on adapters.id_arg_interval = ui.id_interval
where ui.id_interval = %%ID_INTERVAL%%
		