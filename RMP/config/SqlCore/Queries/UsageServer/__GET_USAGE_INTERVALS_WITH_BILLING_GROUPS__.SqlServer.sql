
/* ===========================================================
Create a Query which returns interval information [billing groups, unassigned Accts, 
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
-- Collect the counts (Total, Hard Closed and Open) of the paying Accts for the given interval 
DECLARE @t_acc_usage_interval_count TABLE
( 
    AllPayingAccts INT NOT NULL,
    HardClosedAccts INT NOT NULL,
    OpenAccts INT NOT NULL,
    id_interval INT NOT NULL
)
INSERT INTO @t_acc_usage_interval_count
SELECT COUNT(CASE WHEN State = 'H' OR State = 'C' OR State = 'O' THEN AccountID ELSE 0 END) AllPayingAccts,
       COUNT(CASE WHEN State = 'H' THEN AccountID ELSE 0 END) HardClosedAccts,
       COUNT(CASE WHEN State = 'O' THEN AccountID ELSE 0 END) OpenAccts,
       IntervalID
FROM vw_paying_accounts 
%%ID_INTERVAL_FILTER_1%% -- WHERE IntervalID = 728170533 
GROUP BY IntervalID

DECLARE @t_billgroup_member_count TABLE
( 
    HardClosedAccts INT NOT NULL,
    OpenAccts INT NOT NULL,
    id_interval INT NOT NULL
)
INSERT INTO @t_billgroup_member_count
SELECT count(CASE WHEN tx_status = 'H' THEN aui.id_acc ELSE 0 END) HardClosedAccts,
       count(CASE WHEN tx_status = 'O' THEN aui.id_acc ELSE 0 END) OpenAccts,
       bg.id_usage_interval
FROM t_billgroup_member bgm 
INNER JOIN t_billgroup bg on bg.id_billgroup = bgm.id_billgroup
INNER JOIN t_acc_usage_interval aui 
  ON aui.id_acc = bgm.id_acc and
     aui.id_usage_interval = bg.id_usage_interval
%%ID_INTERVAL_FILTER_2%% -- WHERE aui.id_usage_interval = 728170533
GROUP BY bg.id_usage_interval

DECLARE @t_billgroup_count TABLE
( 
    id_interval INT NOT NULL,
    TotalGroupCnt INT NOT NULL,
    OpenGroupCnt INT NOT NULL,
    SoftClosedGroupCnt INT NOT NULL,
    HardClosedGroupCnt INT NOT NULL
)
INSERT INTO @t_billgroup_count
SELECT * FROM vw_interval_billgroup_counts
%%ID_INTERVAL_FILTER_BG%% -- WHERE id_usage_interval = 728170533

SELECT IntervalID,
      CycleType,
      StartDate,
      EndDate,
      TotalGroupCnt,
      OpenGroupCnt,
      SoftClosedGroupCnt,
      HardClosedGroupCnt,
      OpenUnassignedAcctsCnt,
      0 Progress,  -- Progress calculation has been removed
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
FROM
(
SELECT ui.id_interval IntervalID,
            uct.tx_desc CycleType,
            ui.dt_start StartDate,
            ui.dt_end EndDate,
            ISNULL(allBillGrps.TotalGroupCnt, 0) TotalGroupCnt, 
            ISNULL(allBillGrps.OpenGroupCnt, 0) OpenGroupCnt,
            ISNULL(allBillGrps.SoftClosedGroupCnt, 0) SoftClosedGroupCnt,
            ISNULL(allBillGrps.HardClosedGroupCnt, 0) HardClosedGroupCnt, 
	          
            ISNULL(openUnassignedAccts_t_acc_usage_interval.OpenUnassignedAccts, 0) -
            ISNULL(openUnassignedAccts_t_billgroup_member.OpenUnassignedAccts, 0) OpenUnassignedAcctsCnt,
          
            ISNULL(hardClosedUnassignedAccts_t_acc_usage_interval.HardClosedUnassignedAccts, 0) -
            ISNULL(hardClosedUnassignedAccts_t_billgroup_member.HardClosedUnassignedAccts, 0) HardClosedUnassignedAcctsCnt,
      
            ISNULL(totalBillGrpAdapters.adapterCnt, 0) TotalBillGrpAdapterCnt,
    	ISNULL(SucceedBillGrpAdapters.adapterCnt, 0) SucceedBillGrpAdapterCnt,    
            ISNULL(failedBillGrpAdapters.adapterCnt, 0) FailedBillGrpAdapterCnt,
            ISNULL(totalIntervalOnlyAdapters.adapterCnt, 0) TotalIntervalOnlyAdapterCnt,
            ISNULL(SucceedIntervalOnlyAdapters.adapterCnt, 0) SucceedIntervalOnlyAdapterCnt,
            ISNULL(failedIntervalOnlyAdapters.adapterCnt, 0) FailedIntervalOnlyAdapterCnt,
            ISNULL(totalBillGrpAdapters.adapterCnt, 0) +  ISNULL(totalIntervalOnlyAdapters.adapterCnt, 0) TotalAdapterCnt,

	uc.id_usage_cycle CycleID,
            (CASE WHEN materialization.id_usage_interval IS NULL THEN 'N' ELSE 'Y' END) HasBeenMaterialized,
            ui.tx_interval_status Status,
            payingAccts.AllPayingAccts TotalPayingAcctsForInterval
	
	FROM t_usage_interval ui
            -- get cycle type name
	INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ui.id_usage_cycle  
	INNER JOIN t_usage_cycle_type uct ON uct.id_cycle_type = uc.id_cycle_type 
            -- get full materialization information
            LEFT OUTER JOIN  
            (
                SELECT id_usage_interval
                FROM t_billgroup_materialization bm
                WHERE bm.tx_type = 'Full' 
                      AND bm.tx_status = 'Succeeded'
                %%ID_INTERVAL_FILTER_3%% -- AND bm.id_usage_interval = 728170533
            ) materialization ON materialization.id_usage_interval = ui.id_interval
            -- get billing group information
          LEFT OUTER JOIN 
          ( 
            SELECT id_interval, openAccts OpenUnassignedAccts -- SUM(OpenAccts) OpenUnassignedAccts 
            FROM @t_acc_usage_interval_count
            -- GROUP BY id_interval
             
          ) openUnassignedAccts_t_acc_usage_interval ON openUnassignedAccts_t_acc_usage_interval.id_interval = ui.id_interval
          LEFT OUTER JOIN 
          ( 
            SELECT id_interval, openAccts OpenUnassignedAccts -- SUM(OpenAccts) OpenUnassignedAccts 
            FROM @t_billgroup_member_count
            -- GROUP BY id_interval
             
          ) openUnassignedAccts_t_billgroup_member ON openUnassignedAccts_t_billgroup_member.id_interval = ui.id_interval
            
          LEFT OUTER JOIN 
          ( 
            SELECT id_interval, hardClosedAccts HardClosedUnassignedAccts  -- SUM(HardClosedAccts) HardClosedUnassignedAccts 
            FROM @t_acc_usage_interval_count
            -- GROUP BY id_interval
             
          ) hardClosedUnassignedAccts_t_acc_usage_interval ON 
              hardClosedUnassignedAccts_t_acc_usage_interval.id_interval = ui.id_interval

          LEFT OUTER JOIN 
          ( 
            SELECT id_interval, hardClosedAccts HardClosedUnassignedAccts -- SUM(HardClosedAccts) HardClosedUnassignedAccts 
            FROM @t_billgroup_member_count
            -- GROUP BY id_interval
             
          ) hardClosedUnassignedAccts_t_billgroup_member ON 
              hardClosedUnassignedAccts_t_billgroup_member.id_interval = ui.id_interval

          LEFT OUTER JOIN 
          (
            SELECT * FROM @t_billgroup_count
          ) allBillGrps  ON allBillGrps.id_interval = ui.id_interval 

         LEFT OUTER JOIN 
	     -- number of Succeed interval-only adapters for the interval
	    (SELECT inst.id_arg_interval, COUNT (*) adapterCnt 
	        FROM t_recevent_inst inst
	        INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
	        WHERE 
	     -- event is active
	   evt.dt_activated <= %%%SYSTEMDATE%%% AND
	   (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
	    evt.tx_type <> 'Root' AND
	                inst.tx_status = 'Succeeded' AND
	        inst.id_arg_billgroup IS NULL 
	        %%ID_INTERVAL_FILTER_5%% -- AND inst.id_arg_interval = 728170533
	       GROUP BY id_arg_interval) SucceedIntervalOnlyAdapters 
	         ON SucceedIntervalOnlyAdapters.id_arg_interval = ui.id_interval

        LEFT OUTER JOIN 
                        -- number of failed interval-only adapters for the interval
	    (SELECT inst.id_arg_interval, COUNT (*) adapterCnt 
                FROM t_recevent_inst inst
                INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
                WHERE 
	     -- event is active
	   evt.dt_activated <= %%%SYSTEMDATE%%% AND
	   (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
	    evt.tx_type <> 'Root' AND
                        inst.tx_status = 'Failed' AND
                inst.id_arg_billgroup IS NULL 
                %%ID_INTERVAL_FILTER_6%% -- AND inst.id_arg_interval = 728170533
               GROUP BY id_arg_interval)failedIntervalOnlyAdapters 
                 ON failedIntervalOnlyAdapters.id_arg_interval = ui.id_interval

        LEFT OUTER JOIN 
                        -- total number of interval-only adapters for the interval
	    (SELECT inst.id_arg_interval, COUNT (*) adapterCnt 
                FROM t_recevent_inst inst
                INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
                WHERE 
	     -- event is active
	   evt.dt_activated <= %%%SYSTEMDATE%%% AND
	   (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
	    evt.tx_type <> 'Root' AND
                        inst.id_arg_billgroup IS NULL 
                        %%ID_INTERVAL_FILTER_7%% -- AND inst.id_arg_interval = 728170533
               GROUP BY id_arg_interval)totalIntervalOnlyAdapters 
                 ON totalIntervalOnlyAdapters.id_arg_interval = ui.id_interval

        LEFT OUTER JOIN 
                        -- number of Succeed billing group Adapters for each interval
               (SELECT inst.id_arg_interval, COUNT (*) adapterCnt
	    FROM t_recevent_inst inst
	    INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
                WHERE 
		-- event is active
		evt.dt_activated <= %%%SYSTEMDATE%%% AND
		(evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
		inst.tx_status = 'Succeeded' AND
		evt.tx_type <> 'Root' AND evt.tx_type <> 'Checkpoint' AND
                        inst.id_arg_billgroup IS NOT NULL
		%%ID_INTERVAL_FILTER_8%% -- AND inst.id_arg_interval = 728170533
	    GROUP BY id_arg_interval) SucceedBillGrpAdapters 
                ON SucceedBillGrpAdapters.id_arg_interval = ui.id_interval

         LEFT OUTER JOIN 
                        -- number of failed billing group Adapters for each interval
               (SELECT inst.id_arg_interval, COUNT (*) adapterCnt
	    FROM t_recevent_inst inst
	    INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
                WHERE 
		-- event is active
		evt.dt_activated <= %%%SYSTEMDATE%%% AND
		(evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
		inst.tx_status = 'Failed' AND
		evt.tx_type <> 'Root' AND evt.tx_type <> 'Checkpoint' AND
                        inst.id_arg_billgroup IS NOT NULL
		%%ID_INTERVAL_FILTER_9%% -- AND inst.id_arg_interval = 728170533
	    GROUP BY id_arg_interval) failedBillGrpAdapters 
                ON failedBillGrpAdapters.id_arg_interval = ui.id_interval

          LEFT OUTER JOIN 
                        -- number of failed billing group Adapters for each interval
               (SELECT inst.id_arg_interval, COUNT (*) adapterCnt
	    FROM t_recevent_inst inst
	    INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
                WHERE 
		-- event is active
		evt.dt_activated <= %%%SYSTEMDATE%%% AND
		(evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
		evt.tx_type <> 'Root' AND evt.tx_type <> 'Checkpoint' AND
                        inst.id_arg_billgroup IS NOT NULL
		%%ID_INTERVAL_FILTER_10%% -- AND inst.id_arg_interval = 728170533
	    GROUP BY id_arg_interval) totalBillGrpAdapters 
                ON totalBillGrpAdapters.id_arg_interval = ui.id_interval
    LEFT OUTER JOIN
        (
	          SELECT id_interval,  AllPayingAccts
            FROM @t_acc_usage_interval_count
        ) payingAccts ON payingAccts.id_interval = ui.id_interval
) allIntervals
%%OPTIONAL_WHERE_CLAUSE%%
ORDER BY allIntervals.EndDate
	