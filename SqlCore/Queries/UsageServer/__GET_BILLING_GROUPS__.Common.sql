
/* ===========================================================
Returns the following from t_billgroup for the given interval

BillingGroupID
Name
Description
Status
MemberCount
AdapterCount
AdapterSucceededCount
AdapterFailedCount
HasChildren
ParentBillingGroupID,
ParentBillingGroupName,
StartDate (for the interval)
EndDate (for the interval)
CycleType (for the interval)
CycleID (for the interval
 =========================================================== */
SELECT bg.id_billgroup BillingGroupID, 
  bg.tx_name Name, 
  bg.tx_description Description,
  (CASE 
    WHEN bgs.status = 'O' THEN 'Open'
    WHEN bgs.status = 'C' THEN 'Soft Closed'
    WHEN bgs.status = 'H' THEN 'Hard Closed' 
    ELSE 'Unknown' END) Status,
  numAccounts MemberCount,
  {fn ifnull(totalAdapters.totalAdapterCount, 0)} AdapterCount, 
  {fn ifnull(successfulAdapters.succeededAdapterCount, 0)} AdapterSucceededCount, 
  {fn ifnull(failedAdapters.failedAdapterCount, 0)} AdapterFailedCount,
  (CASE WHEN validParents.id_parent_billgroup IS NULL THEN 'N' ELSE 'Y' END) HasChildren,
  billgroupParent.id_parent_billgroup ParentBillingGroupID,
  billgroupParent.tx_name ParentBillingGroupName,
  ui.dt_start StartDate,
  ui.dt_end EndDate,
  uct.tx_desc CycleType,
  uc.id_usage_cycle CycleID,
  bg.id_usage_interval IntervalID,
  {fn ifnull(totalIntervalOnlyAdapters.totalIntervalOnlyAdapterCount,0)} IntervalOnlyAdapterCount,
  {fn ifnull(sucessfulIntervalOnlyAdapters.succeedIntervaOnlyAdapterCnt, 0)} IntervalOnlyAdapterSucceedCnt,
  {fn ifnull(failedIntervalOnlyAdapters.failedIntervaOnlyAdapterCount, 0)} IntervalOnlyAdapterFailedCount,
  bg.tx_type Type,
  	case when (
	(
		(
			{fn ifnull(totalAdapters.totalEventCount, 0)} + 
				{fn ifnull(totalIntervalOnlyAdapters.totalIntervalOnlyAdapterCount,0)}
		) = 
		(
			{fn ifnull(successfulAdapters.totalSucceededEventCount, 0)} + 
				{fn ifnull(sucessfulIntervalOnlyAdapters.succeedIntervaOnlyAdapterCnt, 0)}
		)
	)		
		and bgs.status = 'C'
	) then 'Y' else 'N' end CanBeHardClosed,
  bg.id_partition id_partition,
  partition_name.nm_login partition_name
FROM t_billgroup bg
INNER JOIN t_usage_interval ui ON ui.id_interval = bg.id_usage_interval
INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ui.id_usage_cycle  
INNER JOIN t_usage_cycle_type uct ON uct.id_cycle_type = uc.id_cycle_type 
LEFT OUTER JOIN
  (
    /* number of accounts for each billing group */
    SELECT id_billgroup, COUNT(id_acc) numAccounts
    FROM t_billgroup_member 
    GROUP BY id_billgroup
  ) bgAcc ON bgAcc.id_billgroup = bg.id_billgroup
/* status for each billing group 'O', 'C' or 'H' */
LEFT OUTER JOIN 
  (
    SELECT * FROM vw_all_billing_groups_status %%LOCK%%
    %%OPTIONAL_BILLING_GROUP_WHERE_CLAUSE%%
  ) bgs ON bgs.id_billgroup = bg.id_billgroup
LEFT OUTER JOIN
  (
    /* total number of Interval-only adapters */
    SELECT inst.id_arg_interval, COUNT (*) totalIntervalOnlyAdapterCount 
    FROM t_recevent_inst inst
    INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
    WHERE 
      /* event is active */
      evt.dt_activated <= %%%SYSTEMDATE%%% AND
      (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
        evt.tx_type <> 'Root' AND
        inst.id_arg_billgroup IS NULL
    GROUP BY id_arg_interval
  ) totalIntervalOnlyAdapters ON totalIntervalOnlyAdapters.id_arg_interval = bg.id_usage_interval
LEFT OUTER JOIN
  (
    /* number of successful Interval-only adapters */
    SELECT inst.id_arg_interval, COUNT (*) succeedIntervaOnlyAdapterCnt
    FROM t_recevent_inst inst
    INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
    WHERE 
    /* event is active */
    evt.dt_activated <= %%%SYSTEMDATE%%% AND
    (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
      evt.tx_type <> 'Root' AND
      inst.tx_status = 'Succeeded' AND
      inst.id_arg_billgroup IS NULL
    GROUP BY id_arg_interval
  ) sucessfulIntervalOnlyAdapters ON sucessfulIntervalOnlyAdapters.id_arg_interval = bg.id_usage_interval
LEFT OUTER JOIN
  (
    /* number of failed Interval-only adapters */
    SELECT inst.id_arg_interval, COUNT (*) failedIntervaOnlyAdapterCount 
    FROM t_recevent_inst inst
    INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
    WHERE 
    /* event is active */
    evt.dt_activated <= %%%SYSTEMDATE%%% AND
    (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
      evt.tx_type <> 'Root' AND
      inst.tx_status = 'Failed' AND
      inst.id_arg_billgroup IS NULL
    GROUP BY id_arg_interval
  ) failedIntervalOnlyAdapters ON failedIntervalOnlyAdapters.id_arg_interval = bg.id_usage_interval
LEFT OUTER JOIN 
  (
    /*  number of total Adapters for each billing group */
    SELECT inst.id_arg_billgroup, 
		  SUM(case when evt.tx_type <> 'Root' AND evt.tx_type <> 'Checkpoint' then 1 else 0 end) totalAdapterCount,
		  COUNT (*) totalEventCount
    FROM t_recevent_inst inst
    INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
    WHERE 
    /* event is active */
    evt.dt_activated <= %%%SYSTEMDATE%%% AND
    (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated)
    GROUP BY id_arg_billgroup
  ) totalAdapters ON totalAdapters.id_arg_billgroup = bg.id_billgroup
LEFT OUTER JOIN 
  (
    /* number of succeeded Adapters for each billing group */
    SELECT inst.id_arg_billgroup, 
		  SUM(case when evt.tx_type <> 'Root' AND evt.tx_type <> 'Checkpoint' then 1 else 0 end) succeededAdapterCount,
		  COUNT (*) totalSucceededEventCount
    FROM t_recevent_inst inst
    INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
    WHERE 
    /* event is active */
    evt.dt_activated <= %%%SYSTEMDATE%%% AND
    (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
      inst.tx_status = 'Succeeded'
      GROUP BY id_arg_billgroup
  ) successfulAdapters ON successfulAdapters.id_arg_billgroup = bg.id_billgroup 
LEFT OUTER JOIN 
  (
    /* number of failed Adapters for each billing group */
    SELECT inst.id_arg_billgroup, COUNT (*) failedAdapterCount
    FROM t_recevent_inst inst
    INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
    WHERE 
    /* event is active */
    evt.dt_activated <= %%%SYSTEMDATE%%% AND
    (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
    inst.tx_status = 'Failed' AND
    evt.tx_type <> 'Root' AND evt.tx_type <> 'Checkpoint'
    GROUP BY id_arg_billgroup
  ) failedAdapters ON failedAdapters.id_arg_billgroup = bg.id_billgroup
LEFT OUTER JOIN
  (
    /* get the set of parents */
    SELECT DISTINCT(parent.id_parent_billgroup) 
    FROM t_billgroup child 
    INNER JOIN t_billgroup parent 
        ON child.id_parent_billgroup = parent.id_parent_billgroup
    WHERE child.id_parent_billgroup <> child.id_billgroup
  ) validParents ON validParents.id_parent_billgroup = bg.id_billgroup
LEFT OUTER JOIN
  (
    /* gets the id_parent_billgroup and the name of the parent */
    SELECT bg.id_billgroup, bg.id_parent_billgroup, bgp.tx_name
    FROM t_billgroup bg
    INNER JOIN t_billgroup bgp 
        ON bgp.id_billgroup = bg.id_parent_billgroup
    GROUP BY bg.id_billgroup, bg.id_parent_billgroup, bgp.tx_name
  )  billgroupParent ON billgroupParent.id_billgroup = bg.id_billgroup
/* The following '%%OPTIONAL_WHERE_CLAUSE%%' can filter on the interval id or
   on the billing group id.
   Hence: "WHERE bg.id_usage_interval = INTERVAL_ID"
   Or: "WHERE bg.id_billgroup = BILLING_GROUP_ID"
   Or: WHERE bg.id_billgroup IN (SELECT * FROM GetBillingGroupDescendants(1001))
*/
LEFT OUTER JOIN t_account_mapper partition_name on bg.id_partition = partition_name.id_acc and partition_name.nm_space = 'mt'
%%OPTIONAL_WHERE_CLAUSE%%
%%OPTIONAL_ORDER_BY_CLAUSE%%
   