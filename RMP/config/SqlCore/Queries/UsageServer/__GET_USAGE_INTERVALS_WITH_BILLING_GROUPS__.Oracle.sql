
/* ===========================================================
Create a Query which returns interval information [billing groups, unassigned accounts, 
progress (see definition below)] based on a user supplied 'where' clause, which determines
the type of intervals returned (All, Active, Billable, Expired, Open, Hard Closed)

 IntervalId
 CycleType
 StartDate
 EndDate
 TotalGroupCnt
 OpenGroupCnt
 SoftClosedGroupCnt
 HardClosedGroupCnt
 OpenUnassignedAcctsCnt 
 HardClosedUnassignedAcctsCnt
 Progress
 TotalBillGrpAdapterCnt
 SucceedBillGrpAdapterCnt
 FailedBillGrpAdapterCnt
 TotalIntervalOnlyAdapterCnt
 SucceedIntervalOnlyAdapterCnt
 FailedIntervalOnlyAdapterCnt
 TotalAdapterCnt
 CycleID
 HasBeenMaterialized
 Status
TotalPayerAcctsCnt
=========================================================== */
/* Collect the counts (Total, Hard Closed and Open) of the paying accounts for the given interval 
*/
with 
t_acc_usage_interval_count as (
  SELECT 
    count(CASE WHEN State = 'H' OR State = 'C' OR State = 'O' 
        THEN AccountID ELSE 0 END) AllPayingAccts,
   count(CASE WHEN State = 'H' THEN AccountID ELSE 0 END) HardClosedUnassignedAccts,
   count(CASE WHEN State = 'O' THEN AccountID ELSE 0 END) OpenUnassignedAccts,
   IntervalID id_interval
  FROM vw_paying_accounts 
  %%ID_INTERVAL_FILTER_1%% /* WHERE IntervalID = 728170533 */
  GROUP BY IntervalID),

t_billgroup_member_count as (
  SELECT count(CASE WHEN tx_status = 'H' THEN aui.id_acc ELSE 0 END) HardClosedUnassignedAccts,
         count(CASE WHEN tx_status = 'O' THEN aui.id_acc ELSE 0 END) OpenUnassignedAccts,
         bg.id_usage_interval id_interval
  FROM t_billgroup_member bgm 
  INNER JOIN t_billgroup bg on bg.id_billgroup = bgm.id_billgroup
  INNER JOIN t_acc_usage_interval aui 
    ON aui.id_acc = bgm.id_acc and
       aui.id_usage_interval = bg.id_usage_interval
  %%ID_INTERVAL_FILTER_2%% /* WHERE aui.id_usage_interval = 728170533 */
  GROUP BY bg.id_usage_interval),
  
t_billgroup_count as (
  SELECT id_usage_interval id_interval,
      totalgroupcount totalgroupcnt,
      opengroupcount opengroupcnt,
      softclosedgroupcount softclosedgroupcnt,
      hardclosedgroupcount hardclosedgroupcnt
  FROM vw_interval_billgroup_counts
  %%ID_INTERVAL_FILTER_BG%% /* WHERE id_usage_interval = 728170533 */
  )

SELECT IntervalID,
      CycleType,
      StartDate,
      EndDate,
      TotalGroupCnt,
      OpenGroupCnt,
      SoftClosedGroupCnt,
      HardClosedGroupCnt,
      OpenUnassignedAcctsCnt,
      0 Progress,  /* Progress calculation has been removed */
      HardClosedUnassignedAcctsCnt,
      TotalBillGrpAdapterCnt,
      SucceedBillGrpAdapterCnt,
      FailedBillGrpAdapterCnt,
      TotalIntervalOnlyAdapterCnt,
      SucceedIntervalOnlyAdapterCnt,
      FailedIntervalOnlyAdapterCnt,
      TotalAdapterCnt,
      CycleID,
      HasBeenMaterialized,
      Status,
      TotalPayingAcctsForInterval 
FROM (
  SELECT ui.id_interval IntervalID,
        uct.tx_desc CycleType,
        ui.dt_start StartDate,
        ui.dt_end EndDate,
        nvl(allBillGrps.TotalGroupCnt, 0) TotalGroupCnt, 
        nvl(allBillGrps.OpenGroupCnt, 0) OpenGroupCnt,
        nvl(allBillGrps.SoftClosedGroupCnt, 0) SoftClosedGroupCnt,
        nvl(allBillGrps.HardClosedGroupCnt, 0) HardClosedGroupCnt, 
        nvl(openUnassignedAccts_aui.OpenUnassignedAccts, 0) -
        nvl(openUnassignedAccts_bm.OpenUnassignedAccts, 0) OpenUnassignedAcctsCnt,
        nvl(hardClosedUnassignedAccts_aui.HardClosedUnassignedAccts, 0) -
        nvl(hardClosedUnassignedAccts_bm.HardClosedUnassignedAccts, 0) HardClosedUnassignedAcctsCnt,
        nvl(totalBillGrpAdapters.adapterCnt, 0) TotalBillGrpAdapterCnt,
        nvl(succeededBillGrpAdapters.adapterCnt, 0) SucceedBillGrpAdapterCnt,    
        nvl(failedBillGrpAdapters.adapterCnt, 0) FailedBillGrpAdapterCnt,
        nvl(totalIntervalOnlyAdapters.adapterCnt, 0) TotalIntervalOnlyAdapterCnt,
        nvl(succeededIntervalOnlyAdapters.adapterCnt, 0) SucceedIntervalOnlyAdapterCnt,
        nvl(failedIntervalOnlyAdapters.adapterCnt, 0)  FailedIntervalOnlyAdapterCnt,
        nvl(totalBillGrpAdapters.adapterCnt, 0) +  nvl(totalIntervalOnlyAdapters.adapterCnt, 0) TotalAdapterCnt,
        uc.id_usage_cycle CycleID,
        (CASE WHEN materialization.id_usage_interval IS NULL THEN 'N' ELSE 'Y' END) HasBeenMaterialized,
        ui.tx_interval_status Status,
        payingAccts.AllPayingAccts TotalPayingAcctsForInterval
  FROM t_usage_interval ui
  /* get cycle type name */
  INNER JOIN t_usage_cycle uc 
	  ON uc.id_usage_cycle = ui.id_usage_cycle  
  INNER JOIN t_usage_cycle_type uct 
	  ON uct.id_cycle_type = uc.id_cycle_type 
  /* get full materialization information */
  LEFT OUTER JOIN  (
      SELECT id_usage_interval
      FROM t_billgroup_materialization bm
      WHERE bm.tx_type = 'Full' 
            AND bm.tx_status = 'Succeeded'
      %%ID_INTERVAL_FILTER_3%% /* AND bm.id_usage_interval = 728170533 */
      ) materialization 
    ON materialization.id_usage_interval = ui.id_interval
  /* get billing group information */
  LEFT OUTER JOIN  t_acc_usage_interval_count openUnassignedAccts_aui
    ON openUnassignedAccts_aui.id_interval = ui.id_interval
  LEFT OUTER JOIN t_billgroup_member_count openUnassignedAccts_bm
    ON openUnassignedAccts_bm.id_interval = ui.id_interval
  LEFT OUTER JOIN t_acc_usage_interval_count hardClosedUnassignedAccts_aui
    ON hardClosedUnassignedAccts_aui.id_interval = ui.id_interval
  LEFT OUTER JOIN t_billgroup_member_count hardClosedUnassignedAccts_bm
    ON hardClosedUnassignedAccts_bm.id_interval = ui.id_interval
  LEFT OUTER JOIN t_billgroup_count allBillGrps
    ON allBillGrps.id_interval = ui.id_interval 
  LEFT OUTER JOIN (
	/* number of succeeded interval-only adapters for the interval */
      SELECT inst.id_arg_interval, COUNT (*) adapterCnt 
      FROM t_recevent_inst inst
      INNER JOIN t_recevent evt 
        ON evt.id_event = inst.id_event
      WHERE 
      /* event is active */
        evt.dt_activated <= %%%SYSTEMDATE%%% AND
        (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
        evt.tx_type <> 'Root' AND
        inst.tx_status = 'Succeeded' AND
        inst.id_arg_billgroup IS NULL 
        %%ID_INTERVAL_FILTER_5%% /* AND inst.id_arg_interval = 728170533 */
      GROUP BY id_arg_interval
      ) succeededIntervalOnlyAdapters 
    ON succeededIntervalOnlyAdapters.id_arg_interval = ui.id_interval
  LEFT OUTER JOIN (
  /* number of failed interval-only adapters for the interval */
      SELECT inst.id_arg_interval, COUNT (*) adapterCnt 
      FROM t_recevent_inst inst
      INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
      WHERE 
        /* event is active */
        evt.dt_activated <= %%%SYSTEMDATE%%% AND
        (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
        evt.tx_type <> 'Root' AND
        inst.tx_status = 'Failed' AND
        inst.id_arg_billgroup IS NULL 
        %%ID_INTERVAL_FILTER_6%% /* AND inst.id_arg_interval = 728170533 */
        GROUP BY id_arg_interval
      ) failedIntervalOnlyAdapters 
    ON failedIntervalOnlyAdapters.id_arg_interval = ui.id_interval
  LEFT OUTER JOIN (
  /* total number of interval-only adapters for the interval */
      SELECT inst.id_arg_interval, COUNT (*) adapterCnt 
      FROM t_recevent_inst inst
      INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
      WHERE 
        /* event is active */
        evt.dt_activated <= %%%SYSTEMDATE%%% AND
        (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
        evt.tx_type <> 'Root' AND 
        inst.id_arg_billgroup IS NULL 
        %%ID_INTERVAL_FILTER_7%% /* AND inst.id_arg_interval = 728170533*/
      GROUP BY id_arg_interval
      ) totalIntervalOnlyAdapters 
    ON totalIntervalOnlyAdapters.id_arg_interval = ui.id_interval
  LEFT OUTER JOIN (
  /* number of succeeded billing group Adapters for each interval */
      SELECT inst.id_arg_interval, COUNT (*) adapterCnt
      FROM t_recevent_inst inst
      INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
      WHERE 
        /* event is active */
        evt.dt_activated <= %%%SYSTEMDATE%%% AND
        (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
        inst.tx_status = 'Succeeded' AND
        evt.tx_type <> 'Root' AND evt.tx_type <> 'Checkpoint' AND
        inst.id_arg_billgroup IS NOT NULL
        %%ID_INTERVAL_FILTER_8%% /* AND inst.id_arg_interval = 728170533 */
      GROUP BY id_arg_interval
      ) succeededBillGrpAdapters 
    ON succeededBillGrpAdapters.id_arg_interval = ui.id_interval
  LEFT OUTER JOIN (
  /* number of failed billing group Adapters for each interval */
      SELECT inst.id_arg_interval, COUNT (*) adapterCnt
      FROM t_recevent_inst inst
      INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
      WHERE 
        /* event is active */
        evt.dt_activated <= %%%SYSTEMDATE%%% AND
        (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
        inst.tx_status = 'Failed' AND
        evt.tx_type <> 'Root' AND evt.tx_type <> 'Checkpoint' AND
        inst.id_arg_billgroup IS NOT NULL
        %%ID_INTERVAL_FILTER_9%% /* AND inst.id_arg_interval = 728170533 */
      GROUP BY id_arg_interval
      ) failedBillGrpAdapters 
    ON failedBillGrpAdapters.id_arg_interval = ui.id_interval
  LEFT OUTER JOIN (
  /* number of failed billing group Adapters for each interval */
      SELECT inst.id_arg_interval, COUNT (*) adapterCnt
      FROM t_recevent_inst inst
      INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
      WHERE 
        /* event is active */
        evt.dt_activated <= %%%SYSTEMDATE%%%  AND
        (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
        evt.tx_type <> 'Root' AND evt.tx_type <> 'Checkpoint' AND
        inst.id_arg_billgroup IS NOT NULL
        %%ID_INTERVAL_FILTER_10%% /* AND inst.id_arg_interval = 728170533 */
      GROUP BY id_arg_interval) totalBillGrpAdapters 
    ON totalBillGrpAdapters.id_arg_interval = ui.id_interval
  LEFT OUTER JOIN t_acc_usage_interval_count payingAccts
    ON payingAccts.id_interval = ui.id_interval
) allIntervals
%%OPTIONAL_WHERE_CLAUSE%%
ORDER BY allIntervals.EndDate
	