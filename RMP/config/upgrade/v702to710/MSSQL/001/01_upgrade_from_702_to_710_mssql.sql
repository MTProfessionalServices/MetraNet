/*
Run this script on:

        NetMeter  702 will be upgraded to 710

We are recommended to back up your database before running this script

Script created by SQL Compare version 10.4.8 from Red Gate Software Ltd at 11/26/2013 10:39:13 AM

*/
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id=OBJECT_ID('tempdb..#tmpErrors')) DROP TABLE #tmpErrors
GO
CREATE TABLE #tmpErrors (Error int)
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
GO
PRINT N'Dropping constraints from [dbo].[agg_decision_audit_trail]'
GO
ALTER TABLE [dbo].[agg_decision_audit_trail] DROP CONSTRAINT [agg_dec_audit_trail_pk]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[agg_decision_rollover]'
GO
ALTER TABLE [dbo].[agg_decision_rollover] DROP CONSTRAINT [agg_dec_rollover_pk]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[mvm_change_tracking_status]'
GO
ALTER TABLE [dbo].[mvm_change_tracking_status] DROP CONSTRAINT [mvm_change_tracking_status_pk]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[mvm_scheduled_tasks]'
GO
ALTER TABLE [dbo].[mvm_scheduled_tasks] DROP CONSTRAINT [pk_mvm_scheduled_tasks]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[mvm_scheduled_tasks]'
GO
ALTER TABLE [dbo].[mvm_scheduled_tasks] DROP CONSTRAINT [DF__mvm_sched__mvm_s__65570293]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[mvm_scheduled_tasks]'
GO
ALTER TABLE [dbo].[mvm_scheduled_tasks] DROP CONSTRAINT [DF__mvm_sched__mvm_s__664B26CC]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[mvm_scheduled_tasks]'
GO
ALTER TABLE [dbo].[mvm_scheduled_tasks] DROP CONSTRAINT [DF__mvm_sched__mvm_s__673F4B05]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[mvm_scheduled_tasks]'
GO
ALTER TABLE [dbo].[mvm_scheduled_tasks] DROP CONSTRAINT [DF__mvm_sched__mvm_t__68336F3E]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[mvm_scheduled_tasks]'
GO
ALTER TABLE [dbo].[mvm_scheduled_tasks] DROP CONSTRAINT [DF__mvm_sched__mvm_p__69279377]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping index [agg_dec_audit_ndx] from [dbo].[agg_decision_audit_trail]'
GO
DROP INDEX [agg_dec_audit_ndx] ON [dbo].[agg_decision_audit_trail]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[mvm_resubmitted_messages]'
GO
DROP TABLE [dbo].[mvm_resubmitted_messages]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[RemoveGroupSubscription_Quoting]'
GO
DROP PROCEDURE [dbo].[RemoveGroupSubscription_Quoting]
GO
PRINT N'Dropping index [idx_tax_run1] from [dbo].[t_tax_run]'
GO
DROP INDEX [idx_tax_run1] ON [dbo].[t_tax_run]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[prtn_DeployServiceDefinitionPartitionedTable]'
GO
DROP PROCEDURE [dbo].[prtn_DeployServiceDefinitionPartitionedTable]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[prtn_CreateMeterPartitionSchema]'
GO
DROP PROCEDURE [dbo].[prtn_CreateMeterPartitionSchema]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[DeployAllPartitionedTables]'
GO
DROP PROCEDURE [dbo].[DeployAllPartitionedTables]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[DeployPartitionedTable]'
GO
DROP PROCEDURE [dbo].[DeployPartitionedTable]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[prtn_DeployAllMeterPartitionedTables]'
GO
DROP PROCEDURE [dbo].[prtn_DeployAllMeterPartitionedTables]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[prtn_CreatePartitionedTable]'
GO
DROP PROCEDURE [dbo].[prtn_CreatePartitionedTable]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Create [dbo].[mvm_change_tracking_nodes]'
GO
CREATE TABLE [dbo].[mvm_change_tracking_nodes]
(
[logical_cluster_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[node_count] [int] NOT NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Dropping [dbo].[CreateUsagePartitions]'
GO
DROP PROCEDURE [dbo].[CreateUsagePartitions]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[prtn_AlterPartitionSchema]'
GO
DROP PROCEDURE [dbo].[prtn_AlterPartitionSchema]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[prtn_CreatePartitionSchema]'
GO
DROP PROCEDURE [dbo].[prtn_CreatePartitionSchema]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[prtn_AddFileGroup]'
GO
DROP PROCEDURE [dbo].[prtn_AddFileGroup]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[CreateTaxDetailPartitions]'
GO
DROP PROCEDURE [dbo].[CreateTaxDetailPartitions]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[prtn_GetNextAllowRunDate]'
GO
DROP PROCEDURE [dbo].[prtn_GetNextAllowRunDate]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[MeterInitialFromRecurWindow]'
GO
ALTER PROCEDURE [dbo].[MeterInitialFromRecurWindow]
     @currentDate dateTime
    AS
    BEGIN
	IF ((SELECT value FROM t_db_values WHERE parameter = N'InstantRc') = 'false') return;
	
	-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

SELECT
    'Initial' AS c_RCActionType
    ,pci.dt_start      AS c_RCIntervalStart
    ,pci.dt_end      AS c_RCIntervalEnd
    ,ui.dt_start      AS c_BillingIntervalStart
    ,ui.dt_end          AS c_BillingIntervalEnd
    ,dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)          AS c_RCIntervalSubscriptionStart
    ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
    ,rw.c_SubscriptionStart          AS c_SubscriptionStart
    ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
    --Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.
    ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
    ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
    ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
    ,rw.c_UnitValueStart AS c_UnitValueStart
    ,rw.c_UnitValueEnd AS c_UnitValueEnd
    ,rw.c_UnitValue AS c_UnitValue
    ,rcr.n_rating_type AS c_RatingType
    ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
    ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
    ,dbo.MTMinOfTwoDates(pci.dt_end,rw.c_SubscriptionEnd)  AS c_BilledRateDate
    ,rw.c__subscriptionid      AS c__SubscriptionID
    ,rw.c__accountid AS c__AccountID
    ,rw.c__payingaccount      AS c__PayingAccount
    ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
    ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
    ,rw.c__productofferingid      AS c__ProductOfferingID
    ,currentui.id_interval AS c__IntervalID
    ,NEWID() AS idSourceSess
INTO #tmp_rc
FROM #recur_window_holder rw
    INNER JOIN t_usage_interval ui on
        rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
    AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* next interval overlaps with cycle */
    AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
    AND rw.c_SubscriptionStart < ui.dt_end AND rw.c_SubscriptionEnd > ui.dt_start
    AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */
    INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__AccountID AND auc.id_usage_cycle = ui.id_usage_cycle
    /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER LOOP JOIN t_pc_interval pci WITH(INDEX(fk1idx_t_pc_interval))
      ON pci.id_cycle = CASE
        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
        ELSE NULL END
    AND ((rcr.b_advance = 'Y' AND pci.dt_start BETWEEN ui.dt_start     AND ui.dt_end) /* If this is in advance, check if rc start falls in this interval */
        or pci.dt_end BETWEEN ui.dt_start     AND ui.dt_end                           /* or check if the cycle end falls into this interval */
		or (pci.dt_start < ui.dt_start and pci.dt_end > ui.dt_end))                   /* or this interval could be in the middle of the cycle */
    AND pci.dt_end BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
    AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
    AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
    AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
    AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
    INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE
        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
        ELSE NULL END
    INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
	inner join t_usage_interval currentui on @currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = ui.id_usage_cycle
where 1=1
--Only meter new subscriptions as initial -- so select only items that have at most one entry in t_sub_history
    AND NOT EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.C__SubscriptionID AND tsh.id_acc = rw.c__AccountID
      AND tsh.tt_end < dbo.MTMaxDate())
--Also no old unit values
    AND NOT EXISTS (SELECT 1 FROM t_recur_value trv WHERE trv.id_sub = rw.c__SubscriptionID AND trv.tt_end < dbo.MTMaxDate())
-- Don't meter in the current interval for initial
    AND ui.dt_start < @currentDate
	AND rw.c__IsAllowGenChargeByTrigger = 1;
    

--If no charges to meter, return immediately
    IF (NOT EXISTS (SELECT 1 FROM #tmp_rc)) RETURN;

   EXEC InsertChargesIntoSvcTables;

	UPDATE rw
	SET c_BilledThroughDate = @currentDate
	FROM #recur_window_holder rw
	where rw.c__IsAllowGenChargeByTrigger = 1;
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[MeterCreditFromRecurWindow]'
GO
ALTER PROCEDURE [dbo].[MeterCreditFromRecurWindow]
      @currentDate dateTime
	  AS
    BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;
	
    
	IF ((SELECT value FROM t_db_values WHERE parameter = N'InstantRc') = 'false') return;
	
SELECT DISTINCT
/* First, credit or debit the difference in the ending of the subscription.  If the new one is later, this will be a debit, otherwise a credit.
* There's a weird exception when this is (a) an arrears charge, (b) the old subscription end was after the pci end date, 
* and (c) the new sub end is inside the pci end date.*/
    CASE WHEN new_sub.vt_end > current_sub.vt_end THEN 'Debit' ELSE 'Credit' END AS c_RCActionType
    ,pci.dt_start      AS c_RCIntervalStart
    ,pci.dt_end      AS c_RCIntervalEnd
    ,paymentInterval.dt_start      AS c_BillingIntervalStart
    ,paymentInterval.dt_end          AS c_BillingIntervalEnd
    ,dbo.mtmaxoftwodates(pci.dt_start, dbo.MTMinOfTwoDates(new_sub.vt_end, current_sub.vt_end)) AS c_RCIntervalSubscriptionStart
    ,dbo.mtminoftwodates(pci.dt_end, dbo.MTMaxOfTwoDates(new_sub.vt_end, current_sub.vt_end)) AS c_RCIntervalSubscriptionEnd
    ,dbo.MTMinOfTwoDates(new_sub.vt_end, current_sub.vt_end)   AS c_SubscriptionStart
    ,dbo.MTMaxOfTwoDates(new_sub.vt_end, current_sub.vt_end) AS c_SubscriptionEnd
    --Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.
    ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
    ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
    ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly -- NOTE: No longer used
    ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
    ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
    ,rw.c_UnitValueStart AS c_UnitValueStart
    ,rw.c_UnitValueEnd AS c_UnitValueEnd
    ,rw.c_UnitValue AS c_UnitValue
    ,rcr.n_rating_type AS c_RatingType
    ,rw.c__accountid AS c__AccountID
    ,rw.c__payingaccount      AS c__PayingAccount
    ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
    ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
    ,rw.c__productofferingid      AS c__ProductOfferingID
    ,dbo.MTMinOfTwoDates(new_sub.vt_end, current_sub.vt_end)  AS c_BilledRateDate
    ,rw.c__subscriptionid      AS c__SubscriptionID
    ,currentui.id_interval AS c__IntervalID
	INTO #tmp_rc_1
 FROM #recur_window_holder rw
    INNER LOOP JOIN t_sub_history new_sub on new_sub.id_acc = rw.c__AccountID and new_sub.id_sub = rw.c__SubscriptionID AND new_sub.tt_end = dbo.MTMaxDate()
    INNER LOOP JOIN t_sub_history current_sub on current_sub.id_acc = rw.c__AccountID and current_sub.id_sub = rw.c__SubscriptionID
      AND current_sub.tt_end  = dbo.SubtractSecond(new_sub.tt_start)
    INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__AccountID
    /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER LOOP JOIN t_pc_interval pci WITH(INDEX(pci_cycle_dt_idx))
      ON pci.id_cycle =
      CASE
        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
        ELSE NULL END
      AND dbo.MTMinOfTwoDates(pci.dt_end, current_sub.vt_end)!= dbo.MTMinOfTwoDates(pci.dt_end, new_sub.vt_end)
      AND pci.dt_start < dbo.MTMaxOfTwoDates(current_sub.vt_end, new_sub.vt_end)
      AND pci.dt_end > dbo.MTMinOfTwoDates(current_sub.vt_start, new_sub.vt_start)
	  AND pci.dt_end BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
	  AND pci.dt_start < @currentDate /* Don't go into the future*/
      AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
      AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
      INNER LOOP JOIN t_usage_interval paymentInterval ON pci.dt_start between paymentInterval.dt_start AND paymentInterval.dt_end
        and paymentInterval.id_usage_cycle = pci.id_cycle
      INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle =
      CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
           WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle
           WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
           ELSE NULL END
    INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
    inner join t_usage_interval currentui on @currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = paymentInterval.id_usage_cycle
   where 1=1
    AND EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.C__SubscriptionID AND tsh.id_acc = rw.c__AccountID AND tsh.tt_end < dbo.MTMaxDate())
	/* We have one exceptional case: (a) an arrears charge, (b) old sub end date was after the end of the pci, (c) new sub end date is inside the pci.  We'll deal with this 
    * elsewhere.
    */
    AND NOT (rcr.b_advance = 'N' AND current_sub.vt_end > pci.dt_end AND new_sub.vt_end < pci.dt_end)
	AND rw.c__IsAllowGenChargeByTrigger = 1
 UNION
 SELECT DISTINCT
/* Now, credit or debit the difference in the start of the subscription.  If the new one is earlier, this will be a debit, otherwise a credit*/
    CASE WHEN new_sub.vt_start < current_sub.vt_start THEN 'InitialDebit' ELSE 'InitialCredit' END AS c_RCActionType
    ,pci.dt_start      AS c_RCIntervalStart
    ,pci.dt_end      AS c_RCIntervalEnd
    ,paymentInterval.dt_start      AS c_BillingIntervalStart
    ,paymentInterval.dt_end          AS c_BillingIntervalEnd
    ,dbo.mtmaxoftwodates(pci.dt_start, dbo.MTMinOfTwoDates(new_sub.vt_start, current_sub.vt_start)) AS c_RCIntervalSubscriptionStart
    ,dbo.mtminoftwodates(pci.dt_end, dbo.MTMaxOfTwoDates(new_sub.vt_start, current_sub.vt_start)) AS c_RCIntervalSubscriptionEnd
    ,dbo.MTMinOfTwoDates(new_sub.vt_start, current_sub.vt_start)   AS c_SubscriptionStart
    ,dbo.MTMaxOfTwoDates(new_sub.vt_start, current_sub.vt_start) AS c_SubscriptionEnd
    --Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.
    ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
    ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
    ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly -- NOTE: No longer used
    ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
    ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
    ,rw.c_UnitValueStart AS c_UnitValueStart
    ,rw.c_UnitValueEnd AS c_UnitValueEnd
    ,rw.c_UnitValue AS c_UnitValue
    ,rcr.n_rating_type AS c_RatingType
    ,rw.c__accountid AS c__AccountID
    ,rw.c__payingaccount      AS c__PayingAccount
    ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
    ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
    ,rw.c__productofferingid      AS c__ProductOfferingID
    ,dbo.MTMaxOfTwoDates(new_sub.vt_start, current_sub.vt_start)  AS c_BilledRateDate
    ,rw.c__subscriptionid      AS c__SubscriptionID
    ,currentui.id_interval AS c__IntervalID
  FROM #recur_window_holder rw
    INNER LOOP JOIN t_sub_history new_sub on new_sub.id_acc = rw.c__AccountID and new_sub.id_sub = rw.c__SubscriptionID AND new_sub.tt_end = dbo.MTMaxDate()
    INNER LOOP JOIN t_sub_history current_sub on current_sub.id_acc = rw.c__AccountID and current_sub.id_sub = rw.c__SubscriptionID
      AND current_sub.tt_end  = dbo.SubtractSecond(new_sub.tt_start)
    INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__AccountID
    /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER LOOP JOIN t_pc_interval pci WITH(INDEX(pci_cycle_dt_idx))
      ON pci.id_cycle =
      CASE
        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
        ELSE NULL END
      /*Check where the intersection of the pci interval and the subscription is different between the new & the old subs.*/
      AND dbo.MTMaxOfTwoDates(pci.dt_start, current_sub.vt_start) != dbo.MTMaxOfTwoDates(pci.dt_start, new_sub.vt_start)
      AND pci.dt_start < dbo.MTMaxOfTwoDates(current_sub.vt_end, new_sub.vt_end)
      AND pci.dt_end > dbo.MTMinOfTwoDates(current_sub.vt_start, new_sub.vt_start)
      AND pci.dt_end BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
	  AND pci.dt_start < @currentDate /* Don't go into the future*/
      AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
      AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
          INNER LOOP JOIN t_usage_interval paymentInterval ON pci.dt_start between paymentInterval.dt_start AND paymentInterval.dt_end
            and paymentInterval.id_usage_cycle = pci.id_cycle
    INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle =
      CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
           WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle
           WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
           ELSE NULL END
    INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
	inner join t_usage_interval currentui on @currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = paymentInterval.id_usage_cycle
 where 1=1
    AND EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.C__SubscriptionID AND tsh.id_acc = rw.c__AccountID AND tsh.tt_end < dbo.MTMaxDate())
    /* We have one exceptional case: (a) an arrears charge, (b) old sub end date was after the end of the pci, (c) new sub end date is inside the pci.  
    * We'll deal with this elsewhere.
    */
    AND NOT (rcr.b_advance = 'N' AND current_sub.vt_end > pci.dt_end AND new_sub.vt_end < pci.dt_end)
    AND rw.c__IsAllowGenChargeByTrigger = 1

 UNION
  SELECT DISTINCT
/* Now, handle the exceptional case above, where (a) an arrears charge, (b) old sub end date was after the end of the pci, (c) new sub end date is inside the pci.
* In this case, issue a debit from the pci start to the subscription end immediately. */
    'Debit' AS c_RCActionType
    ,pci.dt_start      AS c_RCIntervalStart
    ,pci.dt_end      AS c_RCIntervalEnd
    ,paymentInterval.dt_start      AS c_BillingIntervalStart
    ,paymentInterval.dt_end          AS c_BillingIntervalEnd
    ,dbo.mtmaxoftwodates(pci.dt_start, new_sub.vt_start) AS c_RCIntervalSubscriptionStart
    ,new_sub.vt_end AS c_RCIntervalSubscriptionEnd
    ,new_sub.vt_start  AS c_SubscriptionStart
    ,new_sub.vt_end AS c_SubscriptionEnd
    --Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.
    ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
    ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
    ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly -- NOTE: No longer used
    ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
    ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
    ,rw.c_UnitValueStart AS c_UnitValueStart
    ,rw.c_UnitValueEnd AS c_UnitValueEnd
    ,rw.c_UnitValue AS c_UnitValue
    ,rcr.n_rating_type AS c_RatingType
    ,rw.c__accountid AS c__AccountID
    ,rw.c__payingaccount      AS c__PayingAccount
    ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
    ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
    ,rw.c__productofferingid      AS c__ProductOfferingID
    ,new_sub.vt_start AS c_BilledRateDate
    ,rw.c__subscriptionid      AS c__SubscriptionID
    ,currentui.id_interval AS c__IntervalID
 FROM #recur_window_holder rw
    INNER LOOP JOIN t_sub_history new_sub on new_sub.id_acc = rw.c__AccountID and new_sub.id_sub = rw.c__SubscriptionID AND new_sub.tt_end = dbo.MTMaxDate()
    INNER LOOP JOIN t_sub_history current_sub on current_sub.id_acc = rw.c__AccountID and current_sub.id_sub = rw.c__SubscriptionID
      AND current_sub.tt_end  = dbo.SubtractSecond(new_sub.tt_start)
    INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__AccountID
    /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER LOOP JOIN t_pc_interval pci WITH(INDEX(pci_cycle_dt_idx))
      ON pci.id_cycle =
      CASE
        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
        ELSE NULL END
      AND dbo.MTMinOfTwoDates(pci.dt_end, current_sub.vt_end)!= dbo.MTMinOfTwoDates(pci.dt_end, new_sub.vt_end)
      AND pci.dt_start < dbo.MTMaxOfTwoDates(current_sub.vt_end, new_sub.vt_end)
      AND pci.dt_end > dbo.MTMinOfTwoDates(current_sub.vt_start, new_sub.vt_start)
	  AND pci.dt_end BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
      AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
      AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
      INNER LOOP JOIN t_usage_interval paymentInterval ON pci.dt_start between paymentInterval.dt_start AND paymentInterval.dt_end
        and paymentInterval.id_usage_cycle = pci.id_cycle
      INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle =
      CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
           WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle
           WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
           ELSE NULL END
    INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
	inner join t_usage_interval currentui on @currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = paymentInterval.id_usage_cycle
 where 1=1
    and (rcr.b_prorate_on_deactivate='Y' or pci.dt_start > dbo.mtendofday(rw.c_SubscriptionEnd))
    AND EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.C__SubscriptionID AND tsh.id_acc = rw.c__AccountID AND tsh.tt_end < dbo.MTMaxDate())
    /* Deal with the above-mentioned exceptional case here.
    */
    AND (rcr.b_advance = 'N' AND current_sub.vt_end > pci.dt_end AND new_sub.vt_end < pci.dt_end)
	AND rw.c__IsAllowGenChargeByTrigger = 1;
	
	
 /* Now determine if th interval and if the RC adapter has run, if no remove those adavanced charge credits */
    DECLARE @prev_interval INT, @cur_interval INT, @do_credit INT

select @prev_interval = pui.id_interval, @cur_interval = cui.id_interval
from t_usage_interval cui WITH(NOLOCK)
inner join #tmp_rc_1 on #tmp_rc_1.c__IntervalID = cui.id_interval
inner join t_usage_cycle uc WITH(NOLOCK) on cui.id_usage_cycle = uc.id_usage_cycle
inner join t_usage_interval pui WITH(NOLOCK) ON pui.dt_end = dbo.SubtractSecond( cui.dt_start ) AND pui.id_usage_cycle = cui.id_usage_cycle
select @do_credit = (CASE WHEN ISNULL(rei.id_arg_interval, 0) = 0 THEN 0
ELSE
CASE WHEN (rr.tx_type = 'Execute' AND rei.tx_status = 'Succeeded') THEN 1 ELSE 0 END
END)
from t_recevent re
left outer join t_recevent_inst rei on re.id_event = rei.id_event and rei.id_arg_interval = @prev_interval
left outer join t_recevent_run rr on rr.id_instance = rei.id_instance
where 1=1
and re.dt_deactivated is null
and re.tx_name = 'RecurringCharges'
and rr.id_run = (
select MAX(rr.id_run)
from t_recevent re
left outer join t_recevent_inst rei on re.id_event = rei.id_event and rei.id_arg_interval = @prev_interval
left outer join t_recevent_run rr on rr.id_instance = rei.id_instance
where 1=1
and re.dt_deactivated is null
and re.tx_name = 'RecurringCharges'
)

    IF @do_credit = 0
    BEGIN
        delete rcred
        from #tmp_rc_1 rcred
        inner join t_usage_interval ui on ui.id_interval = @cur_interval and rcred.c_BillingIntervalStart = ui.dt_start
    END;
	SELECT *,NEWID() AS idSourceSess INTO #tmp_rc FROM #tmp_rc_1;
--If no charges to meter, return immediately
    IF (NOT EXISTS (SELECT 1 FROM #tmp_rc)) RETURN;
 
   EXEC InsertChargesIntoSvcTables;
	  
	UPDATE rw
	SET c_BilledThroughDate = @currentDate
	FROM #recur_window_holder rw
	where rw.c__IsAllowGenChargeByTrigger = 1;

 END;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[AllowInitialArrersCharge]'
GO
CREATE FUNCTION [dbo].[AllowInitialArrersCharge](@b_advance char, @id_acc int, @sub_end datetime, @current_date datetime) RETURNS bit
AS
BEGIN
	IF @b_advance = 'Y'
	BEGIN
	   /* allows to create initial for ADVANCE */
		RETURN 1
	END

	IF @current_date IS NULL
		SET @current_date = dbo.metratime(1,'RC')
		
	/* Creates Initial charges in case it fits inder current interval*/
	IF EXISTS (select 1 from t_usage_interval us_int
				join t_acc_usage_cycle acc
				on us_int.id_usage_cycle = acc.id_usage_cycle
				where acc.id_acc = @id_acc
				AND @current_date BETWEEN DT_START AND DT_END
				AND @sub_end BETWEEN DT_START AND DT_END)
				
		RETURN 1

	RETURN 0
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[MeterUdrcFromRecurWindow]'
GO
ALTER PROCEDURE [dbo].[MeterUdrcFromRecurWindow]
@currentDate dateTime
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @id_run INT
	declare @idMessage BIGINT
	DECLARE @idService INT
	DECLARE @numBlocks INT
	
IF ((SELECT value FROM t_db_values WHERE parameter = N'InstantRc') = 'false') return;

	SELECT      DISTINCT
      pci.dt_start      AS c_RCIntervalStart
      ,pci.dt_end      AS c_RCIntervalEnd
      ,ui.dt_start      AS c_BillingIntervalStart
      ,ui.dt_end          AS c_BillingIntervalEnd
      ,CASE WHEN rcr.tx_cycle_mode <> 'Fixed' AND ui.dt_start <> rw_new.c_cycleEffectiveDate
       THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(rw_new.c_cycleEffectiveDate), pci.dt_start)
       ELSE pci.dt_start END as c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw_new.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
      ,rw_new.c_SubscriptionStart          AS c_SubscriptionStart
      ,rw_new.c_SubscriptionEnd          AS c_SubscriptionEnd
    --Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.
    ,case when rw_new.c_advance  ='Y' then '1' else '0' end          AS c_Advance
    ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
      ,dbo.MTMaxOfTwoDates(rw_new.c_UnitValueStart, trv.vt_start) AS c_UnitValueStart
      ,dbo.MTMinOfTwoDates(rw_new.c_UnitValueEnd, trv.vt_end) AS c_UnitValueEnd
      ,tou.n_value AS c_UnitValueAdvanceCorrection
      ,rw_new.c_UnitValue AS c_UnitValueDebitCorrection
      ,rcr.n_rating_type AS c_RatingType
      ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
      ,dbo.MTMinOfTwoDates(pci.dt_end,rw_new.c_SubscriptionEnd)  AS c_BilledRateDate
      ,rw_new.c__subscriptionid      AS c__SubscriptionID
      ,rw_new.c__accountid AS c__AccountID
      ,rw_new.c__payingaccount      AS c__PayingAccount
      ,rw_new.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
      ,rw_new.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
      ,rw_new.c__productofferingid      AS c__ProductOfferingID
      ,currentui.id_interval AS c__IntervalID
    INTO #tmp_udrc_1
    FROM #recur_window_holder rw_new
	INNER JOIN t_recur_window trw ON rw_new.c__AccountID = trw.c__AccountID AND rw_new.c__SubscriptionID = trw.c__SubscriptionID
	   -- AND (rw_new.c_UnitValueStart <= trw.c_UnitValueStart OR rw_new.c_UnitValueEnd >= trw.c_UnitValueEnd)
	INNER JOIN t_recur_value trv on trv.id_sub = rw_new.C__SubscriptionID AND trv.tt_end = dbo.MTMaxDate()
	  and trv.vt_start < rw_new.c_UnitValueEnd AND trv.vt_end > rw_new.c_UnitValueStart
	INNER JOIN t_usage_interval ui ON
	  rw_new.c_UnitValueStart < ui.dt_end and rw_new.c_UnitValueEnd > ui.dt_start
	INNER JOIN t_recur rcr ON rw_new.c__priceableiteminstanceid = rcr.id_prop
    INNER JOIN t_usage_cycle ccl ON ccl.id_usage_cycle =
        CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw_new.c_SubscriptionStart, rcr.id_cycle_type)
        ELSE NULL END
    JOIN t_acc_usage_cycle auc on auc.id_acc = rw_new.c__AccountID and auc.id_usage_cycle = ccl.id_usage_cycle
    /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_start BETWEEN ui.dt_start     AND ui.dt_end                            /* rc start falls in this interval */
                                   AND pci.dt_start < dbo.MTMinOfTwoDates(rw_new.c_PayerEnd, rw_new.c_payerend)
                                   AND pci.dt_end > dbo.MTMaxOfTwoDates(rw_new.c_payerstart, rw_new.c_PayerStart)             /* rc start goes to this payer */
                                   AND rw_new.c_membershipstart     < pci.dt_end AND rw_new.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw_new.c_cycleeffectivestart < pci.dt_end AND rw_new.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw_new.c_SubscriptionStart   < pci.dt_end AND rw_new.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */

    INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
	inner join t_usage_interval currentui on @currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = ui.id_usage_cycle
    INNER JOIN #tmp_old_units tou ON tou.n_value IS NOT NULL
  where
      --Don't issue corrections for old values that are going to stay the same.
      NOT EXISTS (SELECT 1 FROM #tmp_old_units tou WHERE rw_new.c_UnitValueStart = tou.vt_start OR rw_new.c_UnitValueEnd = tou.vt_end)
      --Only issue corrections if there's a previous iteration.
      AND EXISTS (SELECT 1 FROM t_recur_value trv WHERE trv.id_sub = rw_new.c__SubscriptionID AND trv.tt_end < dbo.MTMaxDate())
      AND rw_new.c_UnitValue IS NOT NULL
      AND rw_new.c__IsAllowGenChargeByTrigger = 1;
 
      	SELECT 'AdvanceCorrection' AS c_RCActionType
           ,c_RCIntervalStart
           ,c_RCIntervalEnd
           ,c_BillingIntervalStart
           ,c_BillingIntervalEnd
           ,c_RCIntervalSubscriptionStart
           ,c_RCIntervalSubscriptionEnd
           ,c_SubscriptionStart
           ,c_SubscriptionEnd
           ,c_Advance
           ,c_ProrateOnSubscription
           ,'N' AS c_ProrateInstantly
           ,c_UnitValueStart
           ,c_UnitValueEnd
           ,c_UnitValueAdvanceCorrection AS c_UnitValue
           ,c_RatingType
           ,c_ProrateOnUnsubscription
           ,c_ProrationCycleLength
           ,c_BilledRateDate
           ,c__SubscriptionID
           ,c__AccountID
           ,c__PayingAccount
           ,c__PriceableItemInstanceID
           ,c__PriceableItemTemplateID
           ,c__ProductOfferingID
           ,c__IntervalID
           ,NEWID() AS idSourceSess INTO #tmp_rc FROM #tmp_udrc_1
           
           UNION ALL
           
      	SELECT 'DebitCorrection' AS c_RCActionType
           ,c_RCIntervalStart
           ,c_RCIntervalEnd
           ,c_BillingIntervalStart
           ,c_BillingIntervalEnd
           ,c_RCIntervalSubscriptionStart
           ,c_RCIntervalSubscriptionEnd
           ,c_SubscriptionStart
           ,c_SubscriptionEnd
           ,c_Advance
           ,c_ProrateOnSubscription
           ,'N' AS c_ProrateInstantly
           ,c_UnitValueStart
           ,c_UnitValueEnd
           ,c_UnitValueDebitCorrection AS c_UnitValue
           ,c_RatingType
           ,c_ProrateOnUnsubscription
           ,c_ProrationCycleLength
           ,c_BilledRateDate
           ,c__SubscriptionID
           ,c__AccountID
           ,c__PayingAccount
           ,c__PriceableItemInstanceID
           ,c__PriceableItemTemplateID
           ,c__ProductOfferingID
           ,c__IntervalID
           ,NEWID() AS idSourceSess FROM #tmp_udrc_1 ;
    --If no charges to meter, return immediately
    IF (NOT EXISTS (SELECT 1 FROM #tmp_rc)) RETURN;
     
     EXEC InsertChargesIntoSvcTables;
	 
	UPDATE rw
	SET c_BilledThroughDate = @currentDate
	FROM #recur_window_holder rw
	where rw.c__IsAllowGenChargeByTrigger = 1;

  
 end;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[MeterPayerChangesFromRecurWindow]'
GO
ALTER  PROCEDURE [dbo].[MeterPayerChangesFromRecurWindow]
@currentDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF ((SELECT value FROM t_db_values WHERE parameter = N'InstantRc') = 'false') return;
	SELECT DISTINCT
       pci.dt_start      AS c_RCIntervalStart
      ,pci.dt_end      AS c_RCIntervalEnd
      ,ui.dt_start      AS c_BillingIntervalStart
      ,ui.dt_end          AS c_BillingIntervalEnd
      ,CASE WHEN rcr.tx_cycle_mode <> 'Fixed' AND ui.dt_start <> rw.c_cycleEffectiveDate
        THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(rw.c_cycleEffectiveDate), pci.dt_start)
        ELSE pci.dt_start END as c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart          AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
      --Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.
      ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
      ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly -- NOTE: No longer used
      ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
      ,rw.c_UnitValueStart AS c_UnitValueStart
      ,rw.c_UnitValueEnd AS c_UnitValueEnd
      ,rw.c_UnitValue AS c_UnitValue
      ,rcr.n_rating_type AS c_RatingType
      ,rw.c__accountid AS c__AccountID
      ,rw.c__payingaccount      AS c__PayingAccountCredit
      ,rwnew.c__payingaccount AS c__PayingAccountDebit
      ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
      ,rw.c__productofferingid      AS c__ProductOfferingID
      ,dbo.MTMinOfTwoDates(pci.dt_end,rw.c_SubscriptionEnd)  AS c_BilledRateDate
      ,rw.c__subscriptionid      AS c__SubscriptionID
      ,currentui.id_interval AS c__IntervalID
    INTO #tmp_rc_1
	FROM #tmp_oldrw rw INNER JOIN t_usage_interval ui
         on rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* next interval overlaps with cycle */
           AND rw.c_subscriptionstart   < ui.dt_end AND rw.c_subscriptionend   > ui.dt_start /* next interval overlaps with subscription */
           AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend > ui.dt_start /* next interval overlaps with membership */
    /*Between the new and old values, one contains the other, depending on if we've added a payer in the middle or taken one out.
    * Whichever is smaller is the one we actually have to debit/credit, because it's the part that has changed.
    */
    INNER JOIN #tmp_newrw rwnew ON rwnew.c__AccountID = rw.c__AccountID AND rwnew.c__PayingAccount != rw.c__PayingAccount
        and dbo.MTMaxOfTwoDates(rwnew.c_payerstart, rw.c_PayerStart) < ui.dt_end AND dbo.MTMinOfTwoDates(rw.c_PayerEnd,rwnew.c_payerend) > ui.dt_start
          --we only want the cases where the new payer contains the old payer or vice versa.
        AND ((rw.c_PayerStart >= rwnew.c_PayerStart AND rw.c_PayerEnd <= rwnew.c_PayerEnd)
            OR (rw.c_PayerStart <= rwnew.c_PayerStart AND rw.c_PayerEnd >= rwnew.c_PayerEnd))
      INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
      INNER JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
	    WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
	    WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
	    ELSE NULL END
      JOIN t_acc_usage_cycle auc on auc.id_acc = rw.c__AccountID and auc.id_usage_cycle = ccl.id_usage_cycle
      /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
      INNER JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_start BETWEEN ui.dt_start     AND ui.dt_end                            /* rc start falls in this interval */
                                   AND pci.dt_start < dbo.MTMinOfTwoDates(rw.c_PayerEnd, rwnew.c_payerend)
                                   AND pci.dt_end > dbo.MTMaxOfTwoDates(rwnew.c_payerstart, rw.c_PayerStart)             /* rc start goes to this payer */
                                   /*Also, RC end needs to be for this payer -- otherwise the other payer gets it.*/
                                   AND pci.dt_end <= dbo.MTMinOfTwoDates(rw.c_PayerEnd, rwnew.c_payerend)
                                   AND rwnew.c_membershipstart     < pci.dt_end AND rwnew.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
								   and pci.dt_start < @currentDate /* Don't go into the future*/
      INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      inner join t_usage_interval currentui on @currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = ui.id_usage_cycle
	  where rwnew.c__IsAllowGenChargeByTrigger = 1;

		SELECT 'InitialDebit' AS c_RCActionType
           ,c_RCIntervalStart
           ,c_RCIntervalEnd
           ,c_BillingIntervalStart
           ,c_BillingIntervalEnd
           ,c_RCIntervalSubscriptionStart
           ,c_RCIntervalSubscriptionEnd
           ,c_SubscriptionStart
           ,c_SubscriptionEnd
           ,c_Advance
           ,c_ProrateOnSubscription
           ,c_ProrateInstantly
           ,c_UnitValueStart
           ,c_UnitValueEnd
           ,c_UnitValue
           ,c_RatingType
           ,c_ProrateOnUnsubscription
           ,c_ProrationCycleLength
           ,c_BilledRateDate
           ,c__SubscriptionID
           ,c__AccountID
           ,c__PayingAccountDebit AS c__PayingAccount
           ,c__PriceableItemInstanceID
           ,c__PriceableItemTemplateID
           ,c__ProductOfferingID
           ,c__IntervalID
           ,NEWID() AS idSourceSess INTO #tmp_rc FROM #tmp_rc_1
           
           UNION ALL
           		SELECT 'InitialCredit' AS c_RCActionType
           ,c_RCIntervalStart
           ,c_RCIntervalEnd
           ,c_BillingIntervalStart
           ,c_BillingIntervalEnd
           ,c_RCIntervalSubscriptionStart
           ,c_RCIntervalSubscriptionEnd
           ,c_SubscriptionStart
           ,c_SubscriptionEnd
           ,c_Advance
           ,c_ProrateOnSubscription
           ,c_ProrateInstantly
           ,c_UnitValueStart
           ,c_UnitValueEnd
           ,c_UnitValue
           ,c_RatingType
           ,c_ProrateOnUnsubscription
           ,c_ProrationCycleLength
           ,c_BilledRateDate
           ,c__SubscriptionID
           ,c__AccountID
           ,c__PayingAccountCredit AS c__PayingAccount
           ,c__PriceableItemInstanceID
           ,c__PriceableItemTemplateID
           ,c__ProductOfferingID
           ,c__IntervalID
           ,NEWID() AS idSourceSess FROM #tmp_rc_1 ;
           
	--If no charges to meter, return immediately
    IF NOT EXISTS (SELECT 1 FROM #tmp_rc) RETURN;
	
	exec InsertChargesIntoSvcTables;
	
	  
	UPDATE rw
	SET c_BilledThroughDate = @currentDate
	FROM #tmp_newrw rw
	where rw.c__IsAllowGenChargeByTrigger = 1;

END;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[VW_AJ_INFO]'
GO
ALTER view [dbo].[VW_AJ_INFO]
        -- Returns exactly 1 record	per	usage	record
        -- For adjusment related numeric fields	that come	back as	NULLs
        -- because adjustment	does not exist (eg id_aj_template, id_aj_instance)
        -- return	-1;	For	string fields	(AdjustmentDescription,	AdjustmentTemplateDescription) return	empty	strings
        as
        select

        au.id_sess,
		au.tx_UID,
		au.id_acc,
		au.id_payee,
		au.id_view,
		au.id_usage_interval,
		au.id_parent_sess,
		ISNULL(au.id_prod,(Select top 1 id_prod from t_acc_usage where id_parent_sess= au.id_sess)) id_prod,
		au.id_svc,
		au.dt_session,
		au.amount,
		au.am_currency,
		au.dt_crt,
		au.tx_batch,
		au.tax_federal,
		au.tax_state,
		au.tax_county,
		au.tax_local,
		au.tax_other,
		au.id_pi_instance,
		au.id_pi_template,
		au.id_se,
		au.div_currency,
		au.div_amount,
		au.is_implied_tax,
        au.tax_informational,

		
        -- 1. Return Different Amounts: 

        -- PREBILL ADJUSTMENTS:

        -- CompoundPrebillAdjAmt -- parent and children prebill adjustments for a compound transaction
        -- AtomicPrebillAdjAmt -- parent prebill adjustments for a compound transaction. For an atomic transaction
        --                                 CompoundPrebillAdjAmt always equals AtomicPrebillAdjAmt
        -- CompoundPrebillAdjedAmt -- Charge Amount + CompoundPrebillAdjAmt
        -- AtomicPrebillAdjedAmt -- Charge amount + parent prebill adjustments for a compound transaction. For an atomic transaction
        --                                 CompoundPrebillAdjedAmt always equals AtomicPrebillAdjedAmt


        -- POSTBILL ADJUSTMENTS:

        -- CompoundPostbillAdjAmt -- parent and children postbill adjustments for a compound transaction
        -- AtomicPostbillAdjAmt -- parent postbill adjustments for a compound transaction. For an atomic transaction
        --                                 CompoundPostbillAdjAmt always equals AtomicPostbillAdjAmt
        -- CompoundPostbillAdjedAmt -- Charge Amount + CompoundPrebillAdjAmt + CompoundPostbillAdjedAmt
        -- AtomicPostbillAdjedAmt - Charge amount + parent prebill adjustments for a compound transaction +
        --                                parent postbill adjustments for a compound transaction. For an atomic transaction
        --                                AtomicPostbillAdjedAmt always equals CompoundPostbillAdjedAmt


        -- PREBILL ADJUSTMENTS:

        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
            THEN prebillajs.AdjustmentAmount
            ELSE 0 END
            +
            {fn IFNULL((ChildPreBillAdjustments.PrebillCompoundAdjAmt), 0.0)} AS CompoundPrebillAdjAmt,

        (au.amount + CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
            THEN prebillajs.AdjustmentAmount
            ELSE 0 END + {fn IFNULL((ChildPreBillAdjustments.PrebillCompoundAdjAmt), 0.0)}) AS CompoundPrebillAdjedAmt,
             
        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'A')
	            THEN prebillajs.AdjustmentAmount
	            ELSE 0 END) AS AtomicPrebillAdjAmt,
        	    
        (au.amount + (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
	            THEN prebillajs.AdjustmentAmount
	            ELSE 0 END) ) AS AtomicPrebillAdjedAmt,
	            
        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'P')
	            THEN prebillajs.AdjustmentAmount
	            ELSE 0 END) AS PendingPrebillAdjAmt,
	            
	      -- COMPOUND PREBILL ADJUSTMENTS TO TAXES:
	      
	      CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
            THEN prebillajs.aj_tax_federal
            ELSE 0 END
            +
            {fn IFNULL((ChildPreBillAdjustments.PrebillCompoundFedTaxAdjAmt), 0.0)} AS CompoundPrebillFedTaxAdjAmt,
            
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
            THEN prebillajs.aj_tax_state
            ELSE 0 END
            +
            {fn IFNULL((ChildPreBillAdjustments.PrebillCompoundStateTaxAdjAmt), 0.0)} AS CompoundPrebillStateTaxAdjAmt,
            
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
            THEN prebillajs.aj_tax_county
            ELSE 0 END
            +
            {fn IFNULL((ChildPreBillAdjustments.PrebillCompoundCntyTaxAdjAmt), 0.0)} AS CompoundPrebillCntyTaxAdjAmt,
            
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
            THEN prebillajs.aj_tax_local
            ELSE 0 END
            +
            {fn IFNULL((ChildPreBillAdjustments.PrebillCompoundLocalTaxAdjAmt), 0.0)} AS CompoundPrebillLocalTaxAdjAmt,
            
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
            THEN prebillajs.aj_tax_other
            ELSE 0 END
            +
            {fn IFNULL((ChildPreBillAdjustments.PrebillCompoundOtherTaxAdjAmt), 0.0)} AS CompoundPrebillOtherTaxAdjAmt,
            
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
            THEN (prebillajs.aj_tax_federal + prebillajs.aj_tax_state + prebillajs.aj_tax_county + prebillajs.aj_tax_local + prebillajs.aj_tax_other)
            ELSE 0 END
            +
            {fn IFNULL((ChildPreBillAdjustments.PrebillCompoundTotalTaxAdjAmt), 0.0)} AS CompoundPrebillTotalTaxAdjAmt,
            
				-- ATOMIC PREBILL ADJUSTMENTS TO TAXES:
	      
	      (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
            THEN prebillajs.aj_tax_federal
            ELSE 0 END) AS AtomicPrebillFedTaxAdjAmt,
            
        (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
            THEN prebillajs.aj_tax_state
            ELSE 0 END) AS AtomicPrebillStateTaxAdjAmt,
        
        (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
            THEN prebillajs.aj_tax_county
            ELSE 0 END) AS AtomicPrebillCntyTaxAdjAmt,
        
        (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
            THEN prebillajs.aj_tax_local
            ELSE 0 END) AS AtomicPrebillLocalTaxAdjAmt,
            
        (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
            THEN prebillajs.aj_tax_other
            ELSE 0 END) AS AtomicPrebillOtherTaxAdjAmt,
            
        (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
            THEN (prebillajs.aj_tax_federal + prebillajs.aj_tax_state + prebillajs.aj_tax_county + prebillajs.aj_tax_local + prebillajs.aj_tax_other)
            ELSE 0 END) AS AtomicPrebillTotalTaxAdjAmt,
        
        -- POSTBILL ADJUSTMENTS:

        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
            THEN postbillajs.AdjustmentAmount
            ELSE 0 END + {fn IFNULL((ChildPostBillAdjustments.PostbillCompoundAdjAmt), 0.0)} AS CompoundPostbillAdjAmt,


        -- when calculating postbill adjusted amounts, always consider prebill adjusted amounts
        (au.amount + CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
            THEN postbillajs.AdjustmentAmount
            ELSE 0 END  + {fn IFNULL((ChildPostBillAdjustments.PostbillCompoundAdjAmt), 0.0)}
        +
        --bring in prebill adjustments
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
            THEN prebillajs.AdjustmentAmount
            ELSE 0 END
            +
            {fn IFNULL((ChildPreBillAdjustments.PrebillCompoundAdjAmt), 0.0)}
        )
            AS CompoundPostbillAdjedAmt,
             
        (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status = 'A')
	            THEN postbillajs.AdjustmentAmount
	            ELSE 0 END) AS AtomicPostbillAdjAmt,

        -- when calculating postbill adjusted amounts, always consider prebill adjusted amounts
        (au.amount + (CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
	            THEN postbillajs.AdjustmentAmount
	            ELSE 0 END)
        --bring in prebill adjustments
        +
        (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
	            THEN prebillajs.AdjustmentAmount
	            ELSE 0 END)
        	    
	            ) AS AtomicPostbillAdjedAmt,
	       
       (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status = 'P')
	            THEN postbillajs.AdjustmentAmount
	            ELSE 0 END) AS PendingPostbillAdjAmt,
	            
	      -- COMPOUND POSTBILL ADJUSTMENTS TO TAXES:
	      
	      CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
            THEN postbillajs.aj_tax_federal
            ELSE 0 END
            +
            {fn IFNULL((ChildPostBillAdjustments.PostbillCompoundFedTaxAdjAmt), 0.0)} AS CompoundPostbillFedTaxAdjAmt,
            
        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
            THEN postbillajs.aj_tax_state
            ELSE 0 END
            +
            {fn IFNULL((ChildPostBillAdjustments.PostbillCompoundStateTaxAdjAmt), 0.0)} AS CompoundPostbillStateTaxAdjAmt,
            
        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
            THEN postbillajs.aj_tax_county
            ELSE 0 END
            +
            {fn IFNULL((ChildPostBillAdjustments.PostbillCompoundCntyTaxAdjAmt), 0.0)} AS CompoundPostbillCntyTaxAdjAmt,
            
        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
            THEN postbillajs.aj_tax_local
            ELSE 0 END
            +
            {fn IFNULL((ChildPostBillAdjustments.PostbillCompoundLocalTaxAdjAmt), 0.0)} AS CompoundPostbillLocalTaxAdjAmt,
            
        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
            THEN postbillajs.aj_tax_other
            ELSE 0 END
            +
            {fn IFNULL((ChildPostBillAdjustments.PostbillCompoundOtherTaxAdjAmt), 0.0)} AS CompoundPostbillOtherTaxAdjAmt,
            
        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
            THEN (postbillajs.aj_tax_federal + postbillajs.aj_tax_state +
									postbillajs.aj_tax_county + postbillajs.aj_tax_local + postbillajs.aj_tax_other)
            ELSE 0 END
            +
            {fn IFNULL((ChildPostBillAdjustments.PostbillCompoundTotalTaxAdjAmt), 0.0)} AS CompoundPostbillTotalTaxAdjAmt,
            
				-- ATOMIC POST ADJUSTMENTS TO TAXES:
	      
	      (CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
            THEN postbillajs.aj_tax_federal
            ELSE 0 END) AS AtomicPostbillFedTaxAdjAmt,
            
        (CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
            THEN postbillajs.aj_tax_state
            ELSE 0 END) AS AtomicPostbillStateTaxAdjAmt,
        
        (CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
            THEN postbillajs.aj_tax_county
            ELSE 0 END) AS AtomicPostbillCntyTaxAdjAmt,
        
        (CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
            THEN postbillajs.aj_tax_local
            ELSE 0 END) AS AtomicPostbillLocalTaxAdjAmt,
            
        (CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
            THEN postbillajs.aj_tax_other
            ELSE 0 END) AS AtomicPostbillOtherTaxAdjAmt,
            
        (CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
            THEN (postbillajs.aj_tax_federal + postbillajs.aj_tax_state + postbillajs.aj_tax_county +
									postbillajs.aj_tax_local + postbillajs.aj_tax_other)
            ELSE 0 END) AS AtomicPostbillTotalTaxAdjAmt,
        


        -- 2. Return Adjustment Transaction IDs for both prebill and postbill adjustments (or -1 if none): 

        (CASE WHEN prebillajs.id_adj_trx IS NULL THEN -1 ELSE prebillajs.id_adj_trx END) AS PrebillAdjustmentID,
        (CASE WHEN postbillajs.id_adj_trx IS NULL THEN -1 ELSE postbillajs.id_adj_trx END) AS PostbillAdjustmentID,

        -- 3. Return Adjustment Template IDs for both prebill and postbill adjustments (or -1 if none): 

        (CASE WHEN prebillajs.id_aj_template IS NULL THEN -1 ELSE prebillajs.id_aj_template END) AS PrebillAdjustmentTemplateID,
        (CASE WHEN postbillajs.id_aj_template IS NULL THEN -1 ELSE postbillajs.id_aj_template END) AS PostbillAdjustmentTemplateID,

        -- 4. Return Adjustment Instance IDs for both prebill and postbill adjustments (or -1 if none): 

        (CASE WHEN prebillajs.id_aj_instance IS NULL THEN -1 ELSE prebillajs.id_aj_instance END) AS PrebillAdjustmentInstanceID,
        (CASE WHEN postbillajs.id_aj_instance IS NULL THEN -1 ELSE postbillajs.id_aj_instance END) AS PostbillAdjustmentInstanceID,

        -- 5. Return Adjustment ReasonCode IDs for both prebill and postbill adjustments (or -1 if none): 

        (CASE WHEN prebillajs.id_reason_code IS NULL THEN -1 ELSE prebillajs.id_reason_code END) AS PrebillAdjustmentReasonCodeID,
        (CASE WHEN postbillajs.id_reason_code IS NULL THEN -1 ELSE postbillajs.id_reason_code END) AS PostbillAdjustmentReasonCodeID,


        -- 6. Return Adjustment Descriptions and default descriptions for both prebill and postbill adjustments (or empty string if none): 

        (CASE WHEN prebillajs.tx_desc IS NULL THEN '' ELSE prebillajs.tx_desc END) AS PrebillAdjustmentDescription,
        (CASE WHEN postbillajs.tx_desc IS NULL THEN '' ELSE postbillajs.tx_desc END) AS PostbillAdjustmentDescription,
        (CASE WHEN prebillajs.tx_default_desc IS NULL THEN '' ELSE prebillajs.tx_default_desc END) AS PrebillAdjDefaultDesc,
        (CASE WHEN postbillajs.tx_default_desc IS NULL THEN '' ELSE postbillajs.tx_default_desc END) AS PostbillAdjDefaultDesc,
        
        -- 7. Return Adjustment Status as following: If transaction interval is either open or soft closed, return prebill adjustment status or 'NA' if none;
        --    If transaction interval is hard closed, return post bill adjustment status or 'NA' if none
        (CASE WHEN (taui.tx_status in ('O', 'C') AND  prebillajs.id_adj_trx IS NOT NULL) THEN prebillajs.c_status
         ELSE
        (CASE WHEN (taui.tx_status = 'H' AND postbillajs.id_adj_trx IS NOT NULL) THEN postbillajs.c_status ELSE 'NA' END)
        END) AS AdjustmentStatus,


        -- 8. Return Adjustment Template and Instance Display Names for both prebill and postbill adjustments (or empty string if none): 
        --    if needed,  we can return name and descriptions from t_base_props

        -- CASE WHEN (prebillajtemplatedesc.tx_desc IS NULL) THEN '' ELSE prebillajtemplatedesc.tx_desc END  AS PrebillAdjustmentTemplateDisplayName,
        -- CASE WHEN (postbillajtemplatedesc.tx_desc IS NULL) THEN '' ELSE postbillajtemplatedesc.tx_desc END  AS PostbillAdjustmentTemplateDisplayName,

        -- CASE WHEN (prebillajinstancedesc.tx_desc IS NULL) THEN '' ELSE prebillajinstancedesc.tx_desc END  AS PrebillAdjustmentInstanceDisplayName,
        -- CASE WHEN (postbillajinstancedesc.tx_desc IS NULL) THEN '' ELSE postbillajinstancedesc.tx_desc END  AS PostbillAdjustmentInstanceDisplayName,

        -- 9. Return Reason Code Name, Description, Display Name for both prebill and post bill adjustments (or empty string if none)

        -- CASE WHEN (prebillrcdesc.tx_desc IS NULL) THEN '' ELSE prebillrcdesc.tx_desc END  AS PrebillAdjReasonCodeDispName,
        -- CASE WHEN (postbillrcdesc.tx_desc IS NULL) THEN '' ELSE postbillrcdesc.tx_desc END  AS PostbillAdjReasonCodeDispName,



        -- 10. Return different flags indicating status of a transaction in regard to adjustments


        -- Transactions are not considered to be adjusted if status is not 'A'
        -- CR 11785 - Now we are checking for Pending also	

        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status in ('A','P'))
			OR (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status in ('A','P'))
            THEN 'Y' ELSE 'N' END) AS IsAdjusted,
   	    	    
        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status  in ('A','P'))
            THEN 'Y' ELSE 'N' END) AS IsPrebillAdjusted,

        (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status  in ('A','P'))
            THEN 'Y' ELSE 'N' END) AS IsPostbillAdjusted,

        (CASE WHEN (taui.tx_status = 'O')
		        THEN 'Y'
		        ELSE 'N' END) AS IsPreBill,

        --can not adjust transactions:
        --1. in soft closed interval
        --2. If transaction is Prebill and it was already prebill adjusted
        --3. If transaction is Post bill and it was already postbill adjusted
        (CASE WHEN
          (taui.tx_status in ('C')) OR
          (taui.tx_status = 'O' AND prebillajs.id_adj_trx IS NOT NULL) OR
          (taui.tx_status = 'H' AND postbillajs.id_adj_trx IS NOT NULL)
	        then 'N'  else 'Y' end)	AS CanAdjust,

        -- Can not Rebill transactions:
        -- 1. If they are child transactions
        -- 2. in soft closed interval
        -- 3. If transaction is Prebill and it (or it's children) have already been adjusted (need to delete adjustments first)
        -- 4. If transaction is Postbill and it (or it's children) have already been adjusted (need to delete adjustments first)
        --    Above case will take care of possibility of someone trying to do PostBill rebill over and over again.
          (CASE WHEN
          (au.id_parent_sess IS NOT NULL)
	        OR
          (taui.tx_status =('C'))
          OR
          (taui.tx_status =	'O' AND (prebillajs.id_adj_trx IS NOT NULL
          OR (ChildPreBillAdjustments.NumChildrenPrebillAdjusted IS NOT NULL AND ChildPreBillAdjustments.NumChildrenPrebillAdjusted > 0)) )
          OR
          (taui.tx_status = 'H' AND (postbillajs.id_adj_trx IS NOT NULL
          OR (ChildPostBillAdjustments.NumChildrenPostbillAdjusted IS NOT NULL AND ChildPostBillAdjustments.NumChildrenPostbillAdjusted > 0)))
          then 'N' else 'Y' end)	AS CanRebill,
        	
        -- Return 'N' if
        -- 1. Transaction hasn't been prebill adjusted yet
        -- 2. Transaction has been prebill adjusted but transaction interval is already closed
        -- Otherwise return 'Y'
        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL) THEN
        (CASE WHEN taui.tx_status in ('C', 'H') then 'N'  else 'Y' end)
        ELSE 'N' END)
        AS CanManagePrebillAdjustment,
        
        -- Return 'N' if
        -- 1. If adjustment is postbill rebill
        -- 2. Transaction hasn't been postbill adjusted
        -- 3. Transaction has been postbill adjusted but payer's interval is already closed
        -- Otherwise return 'Y'
        
        (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL)
        THEN
				-- CR 11775: we want to allow adjustment management
				-- if adjustment is pending but interval is hard closed
       (CASE WHEN (ajaui.tx_status in ('C') OR
					(ajaui.tx_status  = 'H' AND postbillajs.c_status = 'A') OR
        postbillajtype.n_adjustmenttype = 4) then 'N'  else 'Y' end)
        ELSE 'N' END)
        AS CanManagePostbillAdjustment,
        
        -- This calculates the logical AND of the above two flags.
        -- CR 9547 fix: Start with postbillajs. If transaction was both
        -- pre and post bill adjusted, we should be able to manage it
        -- CR 9548 fix: should not be able to manage REBILL adjustment
          
        (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL) THEN
         -- CR 11775: we want to allow adjustment management
				-- if adjustment is pending but interval is hard closed
        (CASE WHEN (ajaui.tx_status in ('C') OR
					(ajaui.tx_status  = 'H' AND postbillajs.c_status = 'A') OR
        postbillajtype.n_adjustmenttype = 4) then 'N'  else 'Y' end)
        ELSE
        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL) THEN
        (CASE WHEN taui.tx_status in ('C', 'H') then 'N'  else 'Y' end)
        ELSE 'N' END)
        END)

        AS CanManageAdjustments,
        
        
        (CASE WHEN (taui.tx_status = 'C' ) THEN 'Y' ELSE 'N' END) As IsIntervalSoftClosed,
        
        -- return the number of adjusted children
        -- or 0 for child transactions of a compound
        CASE WHEN ChildPreBillAdjustments.NumApprovedChildPrebillAdjed IS NULL
        THEN 0
          ELSE ChildPreBillAdjustments.NumApprovedChildPrebillAdjed
        END
        AS NumPrebillAdjustedChildren,
        
        CASE WHEN ChildPostBillAdjustments.NumApprovedChildPostbillAdjed IS NULL
        THEN 0
          ELSE ChildPostBillAdjustments.NumApprovedChildPostbillAdjed
        END
        AS NumPostbillAdjustedChildren


        from

        t_acc_usage au
        left outer join t_adjustment_transaction prebillajs on prebillajs.id_sess=au.id_sess AND prebillajs.c_status IN ('A', 'P') AND prebillajs.n_adjustmenttype=0
        left outer join t_adjustment_transaction postbillajs on postbillajs.id_sess=au.id_sess AND postbillajs.c_status IN ('A', 'P') AND postbillajs.n_adjustmenttype=1
        left outer join
        (
        select id_parent_sess,
        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')
	          THEN childprebillajs.AdjustmentAmount
	          ELSE 0 END) PrebillCompoundAdjAmt,
	      
	      --adjustments to taxes
	      SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')
	          THEN childprebillajs.AJ_TAX_FEDERAL
	          ELSE 0 END) PrebillCompoundFedTaxAdjAmt,
	      
	      SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')
	          THEN childprebillajs.AJ_TAX_STATE
	          ELSE 0 END) PrebillCompoundStateTaxAdjAmt,
	      
	      SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')
	          THEN childprebillajs.AJ_TAX_COUNTY
	          ELSE 0 END) PrebillCompoundCntyTaxAdjAmt,
	        
	      SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')
	          THEN childprebillajs.AJ_TAX_LOCAL
	          ELSE 0 END) PrebillCompoundLocalTaxAdjAmt,
        
	      SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')
	          THEN childprebillajs.AJ_TAX_OTHER
	          ELSE 0 END) PrebillCompoundOtherTaxAdjAmt,
        
	      SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')
	          THEN (childprebillajs.AJ_TAX_FEDERAL + childprebillajs.AJ_TAX_STATE + childprebillajs.AJ_TAX_COUNTY
	          + childprebillajs.AJ_TAX_LOCAL + childprebillajs.AJ_TAX_OTHER)
	          ELSE 0 END) PrebillCompoundTotalTaxAdjAmt,
        
        -- Approved or Pending adjusted kids
        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NULL) THEN 0 ELSE 1 END) NumChildrenPrebillAdjusted,
        -- Approved adjusted kids (I didn't want to change the above flag because it's used for CanRebill flag calculation)
        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status ='A') THEN 1 ELSE 0 END) NumApprovedChildPrebillAdjed
        from
			t_adjustment_transaction childprebillajs
		where
			childprebillajs.c_status IN ('A', 'P') AND childprebillajs.n_adjustmenttype=0
		group by id_parent_sess
        ) ChildPreBillAdjustments on ChildPreBillAdjustments.id_parent_sess=au.id_sess
        left outer join
        (
        select id_parent_sess,
        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')
	        THEN childpostbillajs.AdjustmentAmount
	        ELSE 0 END) PostbillCompoundAdjAmt,
	      
	      --adjustments to taxes
        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')
	        THEN childpostbillajs.AJ_TAX_FEDERAL
	        ELSE 0 END) PostbillCompoundFedTaxAdjAmt,
	      
        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')
	        THEN childpostbillajs.AJ_TAX_STATE
	        ELSE 0 END) PostbillCompoundStateTaxAdjAmt,
	      
        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')
	        THEN childpostbillajs.AJ_TAX_COUNTY
	        ELSE 0 END) PostbillCompoundCntyTaxAdjAmt,
	        
        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')
	        THEN childpostbillajs.AJ_TAX_LOCAL
	        ELSE 0 END) PostbillCompoundLocalTaxAdjAmt,
	        
        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')
	        THEN childpostbillajs.AJ_TAX_OTHER
	        ELSE 0 END) PostbillCompoundOtherTaxAdjAmt,
	      
        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')
	        THEN (childpostbillajs.AJ_TAX_FEDERAL + childpostbillajs.AJ_TAX_STATE + childpostbillajs.AJ_TAX_COUNTY
	          + childpostbillajs.AJ_TAX_LOCAL + childpostbillajs.AJ_TAX_OTHER)
	        ELSE 0 END) PostbillCompoundTotalTaxAdjAmt,

        -- Approved or Pending adjusted kids
        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NULL) THEN 0 ELSE 1 END) NumChildrenPostbillAdjusted,
        -- Approved adjusted kids (I didn't want to change the above flag because it's used for CanRebill flag calculation)
        SUM(CASE WHEN  (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status ='A')  THEN 1 ELSE 0 END)AS NumApprovedChildPostbillAdjed
        from
        t_adjustment_transaction childpostbillajs
        where
			childpostbillajs.c_status IN ('A', 'P') AND childpostbillajs.n_adjustmenttype=1
        group by id_parent_sess
        ) ChildPostBillAdjustments on ChildPostBillAdjustments.id_parent_sess=au.id_sess
        INNER JOIN t_acc_usage_interval taui on au.id_usage_interval = taui.id_usage_interval AND au.id_acc = taui.id_acc
        LEFT OUTER JOIN t_acc_usage_interval ajaui on postbillajs.id_usage_interval = ajaui.id_usage_interval AND postbillajs.id_acc_payer = ajaui.id_acc
        
        --need to bring in adjustment type in order to set ManageAdjustments flag to false in case
        -- of REBILL adjustment type
        LEFT OUTER JOIN t_adjustment_type prebillajtype on prebillajtype.id_prop = prebillajs.id_aj_type
        LEFT OUTER JOIN t_adjustment_type postbillajtype on postbillajtype.id_prop = postbillajs.id_aj_type
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[MTSP_GENERATE_ST_NRCS_QUOTING]'
GO
ALTER PROCEDURE [dbo].[MTSP_GENERATE_ST_NRCS_QUOTING]

@dt_start datetime,
@dt_end datetime,
@v_id_accounts VARCHAR(4000),
@v_id_poid VARCHAR(4000),
@v_id_interval int,
@v_id_batch varchar(256),
@v_n_batch_size int,
@v_run_date datetime,
@v_is_group_sub int,
@p_count int OUTPUT

AS BEGIN

DECLARE @id_nonrec int,
		@n_batches  int,
		@total_nrcs int,
		@id_message bigint,
		@id_ss int,
		@tx_batch binary(16);
		
IF OBJECT_ID('tempdb..#TMP_NRC_ACCOUNTS_FOR_RUN') IS NOT NULL
DROP TABLE #TMP_NRC_ACCOUNTS_FOR_RUN

IF OBJECT_ID('tempdb..#TMP_RC_POID_FOR_RUN') IS NOT NULL
DROP TABLE #TMP_RC_POID_FOR_RUN

IF OBJECT_ID('tempdb..#TMP_NRC') IS NOT NULL
DROP TABLE #TMP_NRC

CREATE TABLE #TMP_NRC
  (
  id_source_sess uniqueidentifier,
  c_NRCEventType int,
  c_NRCIntervalStart datetime,
  c_NRCIntervalEnd datetime,
  c_NRCIntervalSubscriptionStart datetime,
  c_NRCIntervalSubscriptionEnd datetime,
  c__AccountID int,
  c__PriceableItemInstanceID int,
  c__PriceableItemTemplateID int,
  c__ProductOfferingID int,
  c__SubscriptionID int,
  c__IntervalID int,
  c__Resubmit int,
  c__TransactionCookie int,
  c__CollectionID binary (16)
  )


SELECT * INTO #TMP_NRC_ACCOUNTS_FOR_RUN FROM(SELECT value as id_acc FROM CSVToInt(@v_id_accounts)) A;
SELECT * INTO #TMP_RC_POID_FOR_RUN FROM(SELECT value as id_po FROM CSVToInt(@v_id_poid)) A;

SELECT @tx_batch = cast(N'' as xml).value('xs:hexBinary(sql:variable("@v_id_batch"))', 'binary(16)');

IF @v_is_group_sub > 0
BEGIN

	INSERT INTO #TMP_NRC
	(
		id_source_sess,
		c_NRCEventType,
		c_NRCIntervalStart,
		c_NRCIntervalEnd,
		c_NRCIntervalSubscriptionStart,
		c_NRCIntervalSubscriptionEnd,
		c__AccountID,
		c__PriceableItemInstanceID,
		c__PriceableItemTemplateID,
		c__ProductOfferingID,
		c__SubscriptionID,
		c__IntervalID,
		c__Resubmit,
		c__TransactionCookie,
		c__CollectionID
	)
	
	SELECT
			newid() AS id_source_sess,
			nrc.n_event_type AS	c_NRCEventType,
			@dt_start AS c_NRCIntervalStart,
			@dt_end AS 	c_NRCIntervalEnd,
			mem.vt_start AS	c_NRCIntervalSubscriptionStart,
			mem.vt_end AS	c_NRCIntervalSubscriptionEnd,
			mem.id_acc AS	c__AccountID,
			plm.id_pi_instance AS	c__PriceableItemInstanceID,
			plm.id_pi_template AS	c__PriceableItemTemplateID,
			sub.id_po AS c__ProductOfferingID,
			sub.id_sub AS	c__SubscriptionID,
			@v_id_interval AS c__IntervalID,
			'0' AS c__Resubmit,
			NULL AS c__TransactionCookie,
			@tx_batch AS c__CollectionID
	FROM	t_sub sub
			inner join t_gsubmember mem on mem.id_group = sub.id_group
			inner join #TMP_NRC_ACCOUNTS_FOR_RUN acc on acc.id_acc = mem.id_acc
			inner join #TMP_RC_POID_FOR_RUN po on po.id_po = sub.id_po
			inner join t_po on sub.id_po = t_po.id_po
			inner join t_pl_map plm on sub.id_po = plm.id_po and plm.id_paramtable IS NULL
			inner join t_base_props bp on bp.id_prop = plm.id_pi_instance and bp.n_kind = 30
			inner join t_nonrecur nrc on nrc.id_prop = bp.id_prop and nrc.n_event_type = 1
	WHERE	sub.vt_start >= @dt_start and sub.vt_start < @dt_end
	;

END
ELSE
BEGIN

	INSERT INTO #TMP_NRC
	(
		id_source_sess,
		c_NRCEventType,
		c_NRCIntervalStart,
		c_NRCIntervalEnd,
		c_NRCIntervalSubscriptionStart,
		c_NRCIntervalSubscriptionEnd,
		c__AccountID,
		c__PriceableItemInstanceID,
		c__PriceableItemTemplateID,
		c__ProductOfferingID,
		c__SubscriptionID,
		c__IntervalID,
		c__Resubmit,
		c__TransactionCookie,
		c__CollectionID
	)
	SELECT
			newid() AS id_source_sess,
			nrc.n_event_type AS	c_NRCEventType,
			@dt_start AS c_NRCIntervalStart,
			@dt_end AS 	c_NRCIntervalEnd,
			sub.vt_start AS	c_NRCIntervalSubscriptionStart,
			sub.vt_end AS	c_NRCIntervalSubscriptionEnd,
			sub.id_acc AS	c__AccountID,
			plm.id_pi_instance AS	c__PriceableItemInstanceID,
			plm.id_pi_template AS	c__PriceableItemTemplateID,
			sub.id_po AS c__ProductOfferingID,
			sub.id_sub AS	c__SubscriptionID,
			@v_id_interval AS c__IntervalID,
			'0' AS c__Resubmit,
			NULL AS c__TransactionCookie,
			@tx_batch AS c__CollectionID
	FROM	t_sub sub
			inner join #TMP_NRC_ACCOUNTS_FOR_RUN acc on acc.id_acc = sub.id_acc
			inner join #TMP_RC_POID_FOR_RUN po on po.id_po = sub.id_po
			inner join t_po on sub.id_po = t_po.id_po
			inner join t_pl_map plm on sub.id_po = plm.id_po and plm.id_paramtable IS NULL
			inner join t_base_props bp on bp.id_prop = plm.id_pi_instance and bp.n_kind = 30
			inner join t_nonrecur nrc on nrc.id_prop = bp.id_prop and nrc.n_event_type = 1
	WHERE	sub.vt_start >= @dt_start and sub.vt_start < @dt_end
	;

END

set @total_nrcs = (select count(*) from #tmp_nrc)

set @id_nonrec = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
	'metratech.com/nonrecurringcharge');

SET @n_batches = (@total_nrcs / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT 	INTO t_message
(
	id_message,
	id_route,
	dt_crt,
	dt_metered,
	dt_assigned,
	id_listener,
	id_pipeline,
	dt_completed,
	id_feedback,
	tx_TransactionID,
	tx_sc_username,
	tx_sc_password,
	tx_sc_namespace,
	tx_sc_serialized,
	tx_ip_address
)
SELECT
	id_message,
	NULL,
	@v_run_date,
	@v_run_date,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	'127.0.0.1'
FROM
	(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY id_source_sess) % @n_batches) AS id_message
	FROM #tmp_nrc
	) a
GROUP BY a.id_message;
    
INSERT INTO t_session
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY id_source_sess) % @n_batches) AS id_ss,
    id_source_sess
FROM #tmp_nrc
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, @id_nonrec, b_root, COUNT(1) as session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY id_source_sess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY id_source_sess) % @n_batches) AS id_ss,
    1 AS b_root
FROM #tmp_nrc) a
GROUP BY a.id_message, a.id_ss, a.b_root;
 
INSERT INTO t_svc_NonRecurringCharge
(
	id_source_sess,
    id_parent_source_sess,
    id_external,
    c_NRCEventType,
	c_NRCIntervalStart,
	c_NRCIntervalEnd,
	c_NRCIntervalSubscriptionStart,
	c_NRCIntervalSubscriptionEnd,
	c__AccountID,
	c__PriceableItemInstanceID,
	c__PriceableItemTemplateID,
	c__ProductOfferingID,
	c__SubscriptionID,
    c__IntervalID,
    c__Resubmit,
    c__TransactionCookie,
    c__CollectionID
)
SELECT
    id_source_sess,
    NULL AS id_parent_source_sess,
    NULL AS id_external,
	c_NRCEventType,
	c_NRCIntervalStart,
	c_NRCIntervalEnd,
	c_NRCIntervalSubscriptionStart,
	c_NRCIntervalSubscriptionEnd,
	c__AccountID,
	c__PriceableItemInstanceID,
	c__PriceableItemTemplateID,
	c__ProductOfferingID,
	c__SubscriptionID,
    c__IntervalID,
    c__Resubmit,
    c__TransactionCookie,
    c__CollectionID
FROM #tmp_nrc

drop table #tmp_nrc
SET @p_count = @total_nrcs
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[REMOVEGSUBS_QUOTING]'
GO
CREATE PROCEDURE [dbo].[REMOVEGSUBS_QUOTING](
  @p_id_sub int,
  @p_systemdate datetime,
  @p_status int OUTPUT)

  as
  begin
    
    declare @groupID int
    declare @maxdate datetime
    declare @nmembers int
    declare @icbID int

    set @p_status = 0

    select @groupID = id_group,@maxdate = dbo.mtmaxdate()
    from t_sub where id_sub = @p_id_sub

    select distinct @icbID = id_pricelist from t_pl_map where id_sub=@p_id_sub
	    
    delete from t_gsub_recur_map where id_group = @groupID
    delete from t_recur_value where id_sub = @p_id_sub

    -- In the t_acc_template_subs, either id_po or id_group have to be null.
    -- If a subscription is added to a template, then id_po points to the subscription
    -- If a group subscription is added to a template, then id_group points to the group subscription.
    delete from t_acc_template_subs where id_group = @groupID and id_po is null

    -- Eventually we would need to make sure that the rules for each icb rate schedule are removed from the proper parameter tables
    delete from t_pl_map where id_sub = @p_id_sub

    update t_recur_value set tt_end = @p_systemdate
      where id_sub = @p_id_sub and tt_end = @maxdate
    update t_sub_history set tt_end = @p_systemdate
      where tt_end = @maxdate and id_sub = @p_id_sub

    delete from t_sub where id_sub = @p_id_sub
    
    delete from t_char_values where id_entity = @p_id_sub
    
      if (@icbID is not NULL)
      begin
        exec sp_DeletePricelist @icbID, @p_status output
        if @p_status <> 0 return
      end
  
    update t_group_sub set tx_name = CAST('[DELETED ' + CAST(GetDate() as nvarchar) + ']' + tx_name as nvarchar(255)) where id_group = @groupID

  end
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[MTSP_GENERATE_ST_RCS_QUOTING]'
GO
ALTER PROCEDURE [dbo].[MTSP_GENERATE_ST_RCS_QUOTING]
	@v_id_interval  int
   ,@v_id_billgroup int
   ,@v_id_run       int
   ,@v_id_accounts VARCHAR(4000)
   ,@v_id_poid VARCHAR(4000)
   ,@v_id_batch     varchar(256)
   ,@v_n_batch_size int
   ,@v_run_date   datetime
   ,@p_count      int OUTPUT
AS
BEGIN
	/* SET NOCOUNT ON added to prevent extra result sets from
	   interfering with SELECT statements. */
	SET NOCOUNT ON;
  DECLARE @total_rcs  int,
          @total_flat int,
          @total_udrc int,
          @n_batches  int,
          @id_flat    int,
          @id_udrc    int,
          @id_message bigint,
          @id_ss      int,
          @tx_batch   binary(16);
--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Retrieving RC candidates');

/* Create the list of accounts to generate for */
IF OBJECT_ID('tempdb..#TMP_RC_ACCOUNTS_FOR_RUN') IS NOT NULL
DROP TABLE #TMP_RC_ACCOUNTS_FOR_RUN

IF OBJECT_ID('tempdb..#TMP_RC_POID_FOR_RUN') IS NOT NULL
DROP TABLE #TMP_RC_POID_FOR_RUN

SELECT * INTO #TMP_RC_ACCOUNTS_FOR_RUN FROM(SELECT value as id_acc FROM CSVToInt(@v_id_accounts)) A;
SELECT * INTO #TMP_RC_POID_FOR_RUN FROM(SELECT value as id_po FROM CSVToInt(@v_id_poid)) A;


SELECT
*
INTO
#TMP_RC
FROM(
SELECT
newid() AS idSourceSess,
      'Arrears' AS c_RCActionType
      ,pci.dt_start      AS c_RCIntervalStart
      ,pci.dt_end      AS c_RCIntervalEnd
      ,ui.dt_start      AS c_BillingIntervalStart
      ,ui.dt_end          AS c_BillingIntervalEnd
      ,dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)          AS c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart          AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
      ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
      ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
      ,case when rcr.b_prorate_on_deactivate ='Y' then '1' else '0' end       AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
      ,rw.c__accountid AS c__AccountID
      ,rw.c__payingaccount      AS c__PayingAccount
      ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
      ,rw.c__productofferingid      AS c__ProductOfferingID
      ,pci.dt_end      AS c_BilledRateDate
      ,rw.c__subscriptionid      AS c__SubscriptionID
	  ,rw.c_payerstart
	  ,rw.c_payerend
	  ,case when rw.c_unitvaluestart < '1970-01-01 00:00:00' THEN '1970-01-01 00:00:00' ELSE rw.c_unitvaluestart END AS c_unitvaluestart
	  ,rw.c_unitvalueend
	  ,rw.c_unitvalue
	  ,rcr.n_rating_type AS c_RatingType
      FROM t_usage_interval ui
      /*INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
      INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup*/
	  LEFT JOIN #TMP_RC_ACCOUNTS_FOR_RUN bgm ON 1=1
      INNER LOOP JOIN t_recur_window rw WITH(INDEX(rc_window_time_idx)) ON bgm.id_acc = rw.c__payingaccount
                                   AND rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* interval overlaps with payer */
                                   AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* interval overlaps with cycle */
                                   AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* interval overlaps with membership */
                                   AND rw.c_subscriptionstart   < ui.dt_end AND rw.c_subscriptionend   > ui.dt_start /* interval overlaps with subscription */
                                   AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* interval overlaps with UDRC */
      INNER JOIN #TMP_RC_POID_FOR_RUN po on po.id_po = rw.c__ProductOfferingID
	  INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
      INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle WHEN rcr.tx_cycle_mode LIKE 'BCR%' THEN ui.id_usage_cycle WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) ELSE NULL END
      /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
      INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_end BETWEEN ui.dt_start        AND ui.dt_end                             /* rc end falls in this interval */
                                   AND pci.dt_end BETWEEN rw.c_payerstart    AND rw.c_payerend                         /* rc end goes to this payer */
                                   AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
                                   AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
      INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
	  
      where 1=1
      and ui.id_interval = @v_id_interval
      /*and bg.id_billgroup = @v_id_billgroup*/
      and rcr.b_advance <> 'Y'
UNION ALL
SELECT
newid() AS idSourceSess,
      'Advance' AS c_RCActionType
      ,pci.dt_start      AS c_RCIntervalStart
      ,pci.dt_end      AS c_RCIntervalEnd
      ,ui.dt_start      AS c_BillingIntervalStart
      ,ui.dt_end          AS c_BillingIntervalEnd
      ,CASE WHEN rcr.tx_cycle_mode <> 'Fixed' AND nui.dt_start <> c_cycleEffectiveDate
       THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(c_cycleEffectiveDate), pci.dt_start)
       ELSE pci.dt_start END as c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart          AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
      ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
      ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
      ,case when rcr.b_prorate_on_deactivate ='Y' then '1' else '0' end       AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
      ,rw.c__accountid AS c__AccountID
      ,rw.c__payingaccount      AS c__PayingAccount
      ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
      ,rw.c__productofferingid      AS c__ProductOfferingID
      ,pci.dt_start      AS c_BilledRateDate
      ,rw.c__subscriptionid      AS c__SubscriptionID
	  ,rw.c_payerstart
	  ,rw.c_payerend
	  ,case when rw.c_unitvaluestart < '1970-01-01 00:00:00' THEN '1970-01-01 00:00:00' ELSE rw.c_unitvaluestart END AS c_unitvaluestart
	  ,rw.c_unitvalueend
	  ,rw.c_unitvalue
	  ,rcr.n_rating_type AS c_RatingType
     FROM t_usage_interval ui
      INNER LOOP JOIN t_usage_interval nui ON ui.id_usage_cycle = nui.id_usage_cycle AND dbo.AddSecond(ui.dt_end) = nui.dt_start
      /*INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
      INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup*/
	  LEFT JOIN #TMP_RC_ACCOUNTS_FOR_RUN bgm ON 1=1
      INNER LOOP JOIN t_recur_window rw WITH(INDEX(rc_window_time_idx)) ON bgm.id_acc = rw.c__payingaccount
                                   AND rw.c_payerstart          < nui.dt_end AND rw.c_payerend          > nui.dt_start /* next interval overlaps with payer */
                                   AND rw.c_cycleeffectivestart < nui.dt_end AND rw.c_cycleeffectiveend > nui.dt_start /* next interval overlaps with cycle */
                                   AND rw.c_membershipstart     < nui.dt_end AND rw.c_membershipend     > nui.dt_start /* next interval overlaps with membership */
                                   AND rw.c_subscriptionstart   < nui.dt_end AND rw.c_subscriptionend   > nui.dt_start /* next interval overlaps with subscription */
                                   AND rw.c_unitvaluestart      < nui.dt_end AND rw.c_unitvalueend      > nui.dt_start /* next interval overlaps with UDRC */
      INNER JOIN #TMP_RC_POID_FOR_RUN po on po.id_po = rw.c__ProductOfferingID
	  INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
      INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle WHEN rcr.tx_cycle_mode LIKE 'BCR%' THEN ui.id_usage_cycle WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) ELSE NULL END
      INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_start BETWEEN nui.dt_start     AND nui.dt_end                            /* rc start falls in this interval */
                                   AND pci.dt_start BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
                                   AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
                                   AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
      INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      where 1=1
      and ui.id_interval = @v_id_interval
      /*and bg.id_billgroup = @v_id_billgroup*/
      and rcr.b_advance = 'Y'
)A      ;

SELECT @total_rcs  = COUNT(1) FROM #tmp_rc;

--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'RC Candidate Count: ' + CAST(@total_rcs AS VARCHAR));

if @total_rcs > 0
BEGIN

SELECT @total_flat = COUNT(1) FROM #tmp_rc where c_unitvalue is null;
SELECT @total_udrc = COUNT(1) FROM #tmp_rc where c_unitvalue is not null;

--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Flat RC Candidate Count: ' + CAST(@total_flat AS VARCHAR));
--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'UDRC RC Candidate Count: ' + CAST(@total_udrc AS VARCHAR));

--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Session Set Count: ' + CAST(@v_n_batch_size AS VARCHAR));
--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch: ' + @v_id_batch);

SELECT @tx_batch = cast(N'' as xml).value('xs:hexBinary(sql:variable("@v_id_batch"))', 'binary(16)');
--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch ID: ' + CAST(@tx_batch AS varchar));

if @total_flat > 0
begin

    
set @id_flat = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
	'metratech.com/flatrecurringcharge');
    
SET @n_batches = (@total_flat / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT INTO t_session
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    idSourceSess AS id_source_sess
FROM #tmp_rc where c_unitvalue is null;
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, id_svc, b_root, COUNT(1) as session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    @id_flat AS id_svc,
    1 AS b_root
FROM #tmp_rc
 where c_unitvalue is null) a
GROUP BY a.id_message, a.id_ss, a.id_svc, a.b_root;
 
INSERT INTO t_svc_FlatRecurringCharge
(id_source_sess
    ,id_parent_source_sess
    ,id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
    ,c_ProrateInstantly
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,c__IntervalID
    ,c__Resubmit
    ,c__TransactionCookie
    ,c__CollectionID)
SELECT
    idSourceSess AS id_source_sess
    ,NULL AS id_parent_source_sess
    ,NULL AS id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
    ,c_ProrateInstantly
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,@v_id_interval AS c__IntervalID
    ,'0' AS c__Resubmit
    ,NULL AS c__TransactionCookie
    ,@tx_batch AS c__CollectionID
FROM #tmp_rc
 where c_unitvalue is null;
          INSERT
          INTO t_message
            (
              id_message,
              id_route,
              dt_crt,
              dt_metered,
              dt_assigned,
              id_listener,
              id_pipeline,
              dt_completed,
              id_feedback,
              tx_TransactionID,
              tx_sc_username,
              tx_sc_password,
              tx_sc_namespace,
              tx_sc_serialized,
              tx_ip_address
            )
            SELECT
              id_message,
              NULL,
              @v_run_date,
              @v_run_date,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              '127.0.0.1'
            FROM
              (SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message
              FROM #tmp_rc
              WHERE c_unitvalue IS NULL
              ) a
            GROUP BY a.id_message;

/*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting Flat RCs');*/

END;
if @total_udrc > 0
begin

set @id_udrc = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
	'metratech.com/udrecurringcharge');
    
SET @n_batches = (@total_udrc / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT INTO t_session
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    idSourceSess AS id_source_sess
FROM #tmp_rc where c_unitvalue is not null;
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, id_svc, b_root, COUNT(1) as session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    @id_udrc AS id_svc,
    1 AS b_root
FROM #tmp_rc
 where c_unitvalue is not null) a
GROUP BY a.id_message, a.id_ss, a.id_svc, a.b_root;
 
INSERT INTO t_svc_UDRecurringCharge
(id_source_sess, id_parent_source_sess, id_external, c_RCActionType, c_RCIntervalStart,c_RCIntervalEnd,c_BillingIntervalStart,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
/*    ,c_ProrateInstantly */
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,c__IntervalID
    ,c__Resubmit
    ,c__TransactionCookie
    ,c__CollectionID
	,c_unitvaluestart
	,c_unitvalueend
	,c_unitvalue
	,c_ratingtype)
SELECT
    idSourceSess AS id_source_sess
    ,NULL AS id_parent_source_sess
    ,NULL AS id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
/*    ,c_ProrateInstantly */
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,@v_id_interval AS c__IntervalID
    ,'0' AS c__Resubmit
    ,NULL AS c__TransactionCookie
    ,@tx_batch AS c__CollectionID
	,c_unitvaluestart
	,c_unitvalueend
	,c_unitvalue
	,c_ratingtype
FROM #tmp_rc
 where c_unitvalue is not null;

          INSERT
          INTO t_message
            (
              id_message,
              id_route,
              dt_crt,
              dt_metered,
              dt_assigned,
              id_listener,
              id_pipeline,
              dt_completed,
              id_feedback,
              tx_TransactionID,
              tx_sc_username,
              tx_sc_password,
              tx_sc_namespace,
              tx_sc_serialized,
              tx_ip_address
            )
            SELECT
              id_message,
              NULL,
              @v_run_date,
              @v_run_date,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              '127.0.0.1'
            FROM
              (SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message
              FROM #tmp_rc
              WHERE c_unitvalue IS NOT NULL
              ) a
            GROUP BY a.id_message;

			/*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting UDRC RCs');*/

END;
 
 END;
 
 SET @p_count = @total_rcs;

/*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Info', 'Finished submitting RCs, count: ' + CAST(@total_rcs AS VARCHAR));*/

END;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[mtsp_generate_stateful_rcs]'
GO
ALTER PROCEDURE [dbo].[mtsp_generate_stateful_rcs]
                                            @v_id_interval  int
                                           ,@v_id_billgroup int
                                           ,@v_id_run       int
                                           ,@v_id_batch     varchar(256)
                                           ,@v_n_batch_size int
                                                               ,@v_run_date   datetime
                                           ,@p_count      int OUTPUT
AS
BEGIN
      /* SET NOCOUNT ON added to prevent extra result sets from
         interfering with SELECT statements. */
      SET NOCOUNT ON;
	  SET XACT_ABORT ON;
  DECLARE @total_rcs  int,
          @total_flat int,
          @total_udrc int,
          @n_batches  int,
          @id_flat    int,
          @id_udrc    int,
          @id_message bigint,
          @id_ss      int,
          @tx_batch   binary(16);
INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Retrieving RC candidates');
SELECT
*
INTO
#TMP_RC
FROM(
SELECT
newid() AS idSourceSess,
      'Arrears' AS c_RCActionType
      ,pci.dt_start      AS c_RCIntervalStart
      ,pci.dt_end      AS c_RCIntervalEnd
      ,ui.dt_start      AS c_BillingIntervalStart
      ,ui.dt_end          AS c_BillingIntervalEnd
      ,dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)          AS c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart          AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
      ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
      ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
      ,case when rcr.b_prorate_on_deactivate ='Y' then '1' else '0' end       AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
      ,rw.c__accountid AS c__AccountID
      ,rw.c__payingaccount      AS c__PayingAccount
      ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
      ,rw.c__productofferingid      AS c__ProductOfferingID
      ,pci.dt_end      AS c_BilledRateDate
      ,rw.c__subscriptionid      AS c__SubscriptionID
	  ,rw.c_payerstart
	  ,rw.c_payerend
	  ,case when rw.c_unitvaluestart < '1970-01-01 00:00:00' THEN '1970-01-01 00:00:00' ELSE rw.c_unitvaluestart END AS c_unitvaluestart
	  ,rw.c_unitvalueend
	  ,rw.c_unitvalue
	  ,rcr.n_rating_type AS c_RatingType
      FROM t_usage_interval ui
      INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
      INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup
      INNER LOOP JOIN t_recur_window rw WITH(INDEX(rc_window_time_idx)) ON bgm.id_acc = rw.c__payingaccount
                                   AND rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* interval overlaps with payer */
                                   AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* interval overlaps with cycle */
                                   AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* interval overlaps with membership */
                                   AND rw.c_subscriptionstart   < ui.dt_end AND rw.c_subscriptionend   > ui.dt_start /* interval overlaps with subscription */
                                   AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* interval overlaps with UDRC */
      INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
      INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) ELSE NULL END
      /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
      INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_end BETWEEN ui.dt_start        AND ui.dt_end                             /* rc end falls in this interval */
                                   AND pci.dt_end BETWEEN rw.c_payerstart    AND rw.c_payerend                         /* rc end goes to this payer */
                                   AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
                                   AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
      INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      where 1=1
      and ui.id_interval = @v_id_interval
      and bg.id_billgroup = @v_id_billgroup
      and rcr.b_advance <> 'Y'
 /* Exclude any accounts which have been billed through the charge range.
	     This is because they will have been billed through to the end of last period (advanced charged)
		 OR they will have ended their subscription in which case all of the charging has been done.
		 ONLY subscriptions which are scheduled to end this period which have not been ended by subscription change will be caught 
		 in these queries
		 */
	  and rw.c_BilledThroughDate < dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)
UNION ALL
SELECT
newid() AS idSourceSess,
      'Advance' AS c_RCActionType
      ,pci.dt_start		AS c_RCIntervalStart		/* Start date of Next RC Interval - the one we'll pay for In Advance in current interval */
      ,pci.dt_end		AS c_RCIntervalEnd			/* End date of Next RC Interval - the one we'll pay for In Advance in current interval */
      ,ui.dt_start		AS c_BillingIntervalStart	/* Start date of Current Billing Interval */
      ,ui.dt_end		AS c_BillingIntervalEnd		/* End date of Current Billing Interval */
      ,CASE WHEN rcr.tx_cycle_mode <> 'Fixed' AND nui.dt_start <> c_cycleEffectiveDate
       THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(c_cycleEffectiveDate), pci.dt_start)
       ELSE pci.dt_start END as c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart          AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
      ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
      ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
      ,case when rcr.b_prorate_on_deactivate ='Y' then '1' else '0' end       AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
      ,rw.c__accountid AS c__AccountID
      ,rw.c__payingaccount      AS c__PayingAccount
      ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
      ,rw.c__productofferingid      AS c__ProductOfferingID
      ,pci.dt_start      AS c_BilledRateDate
      ,rw.c__subscriptionid      AS c__SubscriptionID
	  ,rw.c_payerstart
	  ,rw.c_payerend
	  ,case when rw.c_unitvaluestart < '1970-01-01 00:00:00' THEN '1970-01-01 00:00:00' ELSE rw.c_unitvaluestart END AS c_unitvaluestart
	  ,rw.c_unitvalueend
	  ,rw.c_unitvalue
	  ,rcr.n_rating_type AS c_RatingType
      FROM t_usage_interval ui
      INNER LOOP JOIN t_usage_interval nui ON ui.id_usage_cycle = nui.id_usage_cycle AND dbo.AddSecond(ui.dt_end) = nui.dt_start
      INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
      INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup
      INNER LOOP JOIN t_recur_window rw WITH(INDEX(rc_window_time_idx)) ON bgm.id_acc = rw.c__payingaccount
                                   AND rw.c_payerstart          < nui.dt_end AND rw.c_payerend          > nui.dt_start /* next interval overlaps with payer */
                                   AND rw.c_cycleeffectivestart < nui.dt_end AND rw.c_cycleeffectiveend > nui.dt_start /* next interval overlaps with cycle */
                                   AND rw.c_membershipstart     < nui.dt_end AND rw.c_membershipend     > nui.dt_start /* next interval overlaps with membership */
                                   AND rw.c_subscriptionstart   < nui.dt_end AND rw.c_subscriptionend   > nui.dt_start /* next interval overlaps with subscription */
                                   AND rw.c_unitvaluestart      < nui.dt_end AND rw.c_unitvalueend      > nui.dt_start /* next interval overlaps with UDRC */
      INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
      INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) ELSE NULL END
      INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_start BETWEEN nui.dt_start     AND nui.dt_end                            /* rc start falls in Next interval */
                                   AND pci.dt_start BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
                                   AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
                                   AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
      INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      where 1=1
      and ui.id_interval = @v_id_interval
      and bg.id_billgroup = @v_id_billgroup
      and rcr.b_advance = 'Y'
 /* Exclude any accounts which have been billed through the charge range.
	     This is because they will have been billed through to the end of last period (advanced charged)
		 OR they will have ended their subscription in which case all of the charging has been done.
		 ONLY subscriptions which are scheduled to end this period which have not been ended by subscription change will be caught 
		 in these queries
		 */
	  and rw.c_BilledThroughDate < (CASE WHEN rcr.tx_cycle_mode <> 'Fixed' AND nui.dt_start <> c_cycleEffectiveDate
                                    THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(c_cycleEffectiveDate), pci.dt_start)
                                    ELSE pci.dt_start END)
)A      ;

SELECT @total_rcs  = COUNT(1) FROM #tmp_rc;

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'RC Candidate Count: ' + CAST(@total_rcs AS VARCHAR));

if @total_rcs > 0
BEGIN

SELECT @total_flat = COUNT(1) FROM #tmp_rc where c_unitvalue is null;
SELECT @total_udrc = COUNT(1) FROM #tmp_rc where c_unitvalue is not null;

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Flat RC Candidate Count: ' + CAST(@total_flat AS VARCHAR));
INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'UDRC RC Candidate Count: ' + CAST(@total_udrc AS VARCHAR));

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Session Set Count: ' + CAST(@v_n_batch_size AS VARCHAR));
INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch: ' + @v_id_batch);

SELECT @tx_batch = cast(N'' as xml).value('xs:hexBinary(sql:variable("@v_id_batch"))', 'binary(16)');
INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch ID: ' + CAST(@tx_batch AS varchar));

IF (@tx_batch IS NOT NULL)
BEGIN
UPDATE t_batch SET n_metered = @total_rcs, n_expected = @total_rcs WHERE tx_batch = @tx_batch;
END;

if @total_flat > 0
begin

    
set @id_flat = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
      'metratech.com/flatrecurringcharge');
    
SET @n_batches = (@total_flat / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT INTO t_session
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    idSourceSess AS id_source_sess
FROM #tmp_rc where c_unitvalue is null;
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, id_svc, b_root, COUNT(1) as session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    @id_flat AS id_svc,
    1 AS b_root
FROM #tmp_rc
where c_unitvalue is null) a
GROUP BY a.id_message, a.id_ss, a.id_svc, a.b_root;

INSERT INTO t_svc_FlatRecurringCharge
(id_source_sess
    ,id_parent_source_sess
    ,id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
    ,c_ProrateInstantly
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,c__IntervalID
    ,c__Resubmit
    ,c__TransactionCookie
    ,c__CollectionID)
SELECT
    idSourceSess AS id_source_sess
    ,NULL AS id_parent_source_sess
    ,NULL AS id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
    ,c_ProrateInstantly
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,@v_id_interval AS c__IntervalID
    ,'0' AS c__Resubmit
    ,NULL AS c__TransactionCookie
    ,@tx_batch AS c__CollectionID
FROM #tmp_rc
where c_unitvalue is null;
          INSERT
          INTO t_message
            (
              id_message,
              id_route,
              dt_crt,
              dt_metered,
              dt_assigned,
              id_listener,
              id_pipeline,
              dt_completed,
              id_feedback,
              tx_TransactionID,
              tx_sc_username,
              tx_sc_password,
              tx_sc_namespace,
              tx_sc_serialized,
              tx_ip_address
            )
            SELECT
              id_message,
              NULL,
              @v_run_date,
              @v_run_date,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              '127.0.0.1'
            FROM
              (SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message
              FROM #tmp_rc
              WHERE c_unitvalue IS NULL
              ) a
            GROUP BY a.id_message;

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting Flat RCs');

END;
if @total_udrc > 0
begin

set @id_udrc = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
      'metratech.com/udrecurringcharge');
    
SET @n_batches = (@total_udrc / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT INTO t_session
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    idSourceSess AS id_source_sess
FROM #tmp_rc where c_unitvalue is not null;
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, id_svc, b_root, COUNT(1) as session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    @id_udrc AS id_svc,
    1 AS b_root
FROM #tmp_rc
where c_unitvalue is not null) a
GROUP BY a.id_message, a.id_ss, a.id_svc, a.b_root;

INSERT INTO t_svc_UDRecurringCharge
(id_source_sess, id_parent_source_sess, id_external, c_RCActionType, c_RCIntervalStart,c_RCIntervalEnd,c_BillingIntervalStart,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
/*    ,c_ProrateInstantly */
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,c__IntervalID
    ,c__Resubmit
    ,c__TransactionCookie
    ,c__CollectionID
      ,c_unitvaluestart
      ,c_unitvalueend
      ,c_unitvalue
      ,c_ratingtype)
SELECT
    idSourceSess AS id_source_sess
    ,NULL AS id_parent_source_sess
    ,NULL AS id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
/*    ,c_ProrateInstantly */
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,@v_id_interval AS c__IntervalID
    ,'0' AS c__Resubmit
    ,NULL AS c__TransactionCookie
    ,@tx_batch AS c__CollectionID
      ,c_unitvaluestart
      ,c_unitvalueend
      ,c_unitvalue
      ,c_ratingtype
FROM #tmp_rc
where c_unitvalue is not null;

          INSERT
          INTO t_message
            (
              id_message,
              id_route,
              dt_crt,
              dt_metered,
              dt_assigned,
              id_listener,
              id_pipeline,
              dt_completed,
              id_feedback,
              tx_TransactionID,
              tx_sc_username,
              tx_sc_password,
              tx_sc_namespace,
              tx_sc_serialized,
              tx_ip_address
            )
            SELECT
              id_message,
              NULL,
              @v_run_date,
              @v_run_date,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              '127.0.0.1'
            FROM
              (SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message
              FROM #tmp_rc
              WHERE c_unitvalue IS NOT NULL
              ) a
            GROUP BY a.id_message;

                  INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting UDRC RCs');

    /** UPDATE THE BILLED THROUGH DATE TO THE END OF THE ADVANCED CHARGE 
			 ** (IN CASE THE END THE SUB BEFORE THE END OF THE MONTH)
			 ** THIS WILL MAKE SURE THE CREDIT IS CORRECT AND MAKE SURE THERE ARE NOT CHARGES 
			 ** REGENERATED FOR ALL THE MONTHS WHERE RC ADAPTER RAN (But forgot to mark)
			 ** Only for advanced charges.
		     **/
            UPDATE trw
			SET trw.c_BilledThroughDate = trc.c_RCIntervalSubscriptionEnd
			FROM t_recur_window trw
			INNER JOIN #tmp_rc trc ON trc.c_RCActionType = 'Advance' AND trw.c__AccountID = trc.c__AccountID AND trw.c__SubscriptionID = trc.c__SubscriptionID
END;

 END;

 SET @p_count = @total_rcs;

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Info', 'Finished submitting RCs, count: ' + CAST(@total_rcs AS VARCHAR));

END;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[archive_queue_partition_get_status]'
GO
ALTER PROCEDURE [dbo].[archive_queue_partition_get_status](
    @current_time              DATETIME,
    @next_allow_run_time       DATETIME OUT,
    @current_id_partition      INT OUT,
    @new_current_id_partition  INT OUT,
    @old_id_partition          INT OUT,
    @no_need_to_run            BIT OUT
)
AS
	SET NOCOUNT ON
	
	DECLARE @message NVARCHAR(4000)
	SET @no_need_to_run = 0
	
	IF NOT EXISTS(SELECT * FROM t_archive_queue_partition)
	    RAISERROR ('t_archive_queue_partition must contain at least one record.
Try to execute "USM CREATE" command in cmd.
First record inserts to this table on creation of Partition Infrastructure for metering tables', 16, 1)
	
	SELECT @current_id_partition = MAX(current_id_partition)
	FROM   t_archive_queue_partition
	
	SELECT @next_allow_run_time = next_allow_run
	FROM   t_archive_queue_partition
	WHERE  current_id_partition = @current_id_partition
	
	IF @next_allow_run_time IS NOT NULL
	BEGIN
	    /* Period of full partition cycle should pass since last execution of [archive_queue_partition] */
	    IF (@current_time < @next_allow_run_time)
	    BEGIN
	        SET @no_need_to_run = 1
	        SET @message = 'No need to run archive functionality. '
	            + 'Time of cycle period not elapsed yet since the last run. '
	            + 'Try execute the procedure after "'
	            + CONVERT(VARCHAR, @next_allow_run_time) + '" date.'
	        RAISERROR (@message, 0, 1)
	    END
	    
		SET @new_current_id_partition = @current_id_partition + 1
		SET @old_id_partition = @current_id_partition - 1
	END
	ELSE
	BEGIN
	    SET @message = 'Warning: previouse execution of [archive_queue_partition] failed.
The oldest partition was not archived, but new data already written to new partition with ID: "'
+ CAST(@current_id_partition AS NVARCHAR(20)) + '".
Retrying archivation of the oldest partition...'
	    RAISERROR (@message, 0, 1)
	    
	    SET @new_current_id_partition = @current_id_partition
	    SET @current_id_partition = @new_current_id_partition - 1
	    SET @old_id_partition = @new_current_id_partition - 2
	END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[prtn_GetMeterPartitionFileGroupName]'
GO
ALTER FUNCTION [dbo].[prtn_GetMeterPartitionFileGroupName] ()
/* Short prtn_GetMeterPartFileGroupName function name uses in Oracle */
RETURNS NVARCHAR(100)
AS
BEGIN
	RETURN DB_NAME() + '_MeterFileGroup'
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[prtn_get_next_allow_run_date]'
GO
CREATE PROCEDURE [dbo].[prtn_get_next_allow_run_date]
	@current_datetime DATETIME = NULL,
	@next_allow_run_date DATETIME OUT
AS
	SET NOCOUNT ON
	
	IF @current_datetime IS NULL
	    SET @current_datetime = GETDATE()
	
	DECLARE @days_to_add INT
	SELECT @days_to_add = tuc.n_proration_length
	FROM   t_usage_server tus
	       INNER JOIN t_usage_cycle_type tuc
	            ON  tuc.tx_desc = tus.partition_type
	
	SET @next_allow_run_date = DATEADD(DAY, @days_to_add, @current_datetime)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[archive_queue_partition]'
GO
ALTER PROCEDURE [dbo].[archive_queue_partition](
    @update_stats    CHAR(1) = 'N',
    @sampling_ratio  VARCHAR(3) = '30',
    @current_time DATETIME = NULL,
    @result          NVARCHAR(4000) OUTPUT
)
AS
	/* This SP is called from from basic SP - [archive_queue] if DB is partitioned */

	/*
	How to run this stored procedure:	
	DECLARE @result NVARCHAR(2000)
	EXEC archive_queue_partition @result = @result OUTPUT
	PRINT @result
	
	Or if we want to update statistics and change current date/time also:	
	DECLARE @result			NVARCHAR(2000),
	        @current_time	DATETIME
	SET @current_time = GETDATE()
	EXEC archive_queue_partition 'Y',
	     30,
	     @current_time = @current_time,
	     @result = @result OUTPUT
	PRINT @result	
	*/
	
	SET NOCOUNT ON
	
	DECLARE @next_allow_run_time       DATETIME,
	        @current_id_partition      INT,
	        @new_current_id_partition  INT,
	        @old_id_partition          INT,
	        @no_need_to_run            BIT,
	        @meter_partition_function_name   NVARCHAR(50),
	        @meter_partition_schema_name     NVARCHAR(50),
	        @meter_partition_filegroup_name  NVARCHAR(50),
	        @meter_partition_field_name      NVARCHAR(50),
	        @sqlCommand                      NVARCHAR(MAX)
	
	IF @current_time IS NULL
	    SET @current_time = GETDATE()
	
	SET @meter_partition_filegroup_name = dbo.prtn_GetMeterPartitionFileGroupName()
	SET @meter_partition_function_name = dbo.prtn_GetMeterPartitionFunctionName()
	SET @meter_partition_schema_name = dbo.prtn_GetMeterPartitionSchemaName()
	SET @meter_partition_field_name = 'id_partition'
	
	BEGIN TRY
		IF dbo.IsSystemPartitioned() = 0
			RAISERROR('DB is not partitioned. [archive_queue_partition] SP can be executed only on paritioned DB.', 16, 1)

		EXEC archive_queue_partition_get_status @current_time = @current_time,
		     @next_allow_run_time = @next_allow_run_time OUT,
		     @current_id_partition = @current_id_partition OUT,
		     @new_current_id_partition = @new_current_id_partition OUT,
		     @old_id_partition = @old_id_partition OUT,
		     @no_need_to_run = @no_need_to_run OUT
		
		IF @no_need_to_run = 1
		    RETURN
		
		IF @next_allow_run_time IS NULL
			RAISERROR ('Partition Schema and Default "id_partition" had already been updated. Skipping this step...', 0, 1)
		ELSE
		    EXEC archive_queue_partition_apply_next_partition
		         @new_current_id_partition = @new_current_id_partition,
		         @current_time = @current_time,
		         @meter_partition_function_name = @meter_partition_function_name,
		         @meter_partition_schema_name = @meter_partition_schema_name,
		         @meter_partition_filegroup_name = @meter_partition_filegroup_name,
		         @meter_partition_field_name = @meter_partition_field_name
		
		/* If it is the 1-st time of running [archive_queue_partition] there are only 2 partitions.
		* It is early to archive data.
		* When 3-rd partition is created the oldest one is archiving.
		* So, meter tables always have 2 partition.*/
		IF (
		       (
		           SELECT COUNT(current_id_partition)
		           FROM   t_archive_queue_partition
		       ) > 2
		   )
		BEGIN
			DECLARE @temp_table_postfix_oldest  NVARCHAR(50),
					@temp_table_postfix_preserved  NVARCHAR(50)
					
			SET @temp_table_postfix_oldest = '_switch_out_oldest_partition'
			SET	@temp_table_postfix_preserved = '_switch_out_preserved_partition'
			
		    /* Append temp table ##id_sess_to_keep with IDs of sessions from the 'oldest' partition that should not be archived */
		    EXEC archive_queue_partition_get_id_sess_to_keep @old_id_partition = @old_id_partition
		    
		    /* Move data from old to current partition for all meter tables if id_sess in ##id_sess_to_keep */
		    /* Switch out data from meter tables with @old_id_partition to temp_meter_tables */
		    EXEC archive_queue_partition_switch_out_partition_all
				@number_of_partition = @old_id_partition,
				@partition_filegroup_name = @meter_partition_filegroup_name,
				@temp_table_postfix_oldest = @temp_table_postfix_oldest,
				@temp_table_postfix_preserved = @temp_table_postfix_preserved
		    
		    IF OBJECT_ID('tempdb..##id_sess_to_keep') IS NOT NULL
		        DROP TABLE ##id_sess_to_keep
		    
		    /* Drop temp_meter_tables with switched out data of 'oldest' and 'preserved' partitions */
		    EXEC archive_queue_partition_drop_temp_tables
				@temp_table_postfix = @temp_table_postfix_oldest
		    
		    EXEC archive_queue_partition_drop_temp_tables
				@temp_table_postfix = @temp_table_postfix_preserved
		    		    
		    /* Remove obsolete boundary value that divides 2 empty partitions.
		    * (Ensure no data movement ) */
		    DECLARE @obsoleteRange INT
		    SET @obsoleteRange = @old_id_partition - 2 /* range value before 'preserved' partition range value */
		    IF EXISTS(
		           SELECT *
		           FROM   sys.partition_functions pf
		                  JOIN sys.partition_range_values prv
		                       ON  prv.function_id = pf.function_id
		           WHERE  pf.name = @meter_partition_function_name
		                  AND prv.value = @obsoleteRange
		       )
		    BEGIN
		        SET @sqlCommand = 'ALTER PARTITION FUNCTION ' + @meter_partition_function_name
		            + '() MERGE RANGE (' + CAST(@obsoleteRange AS NVARCHAR(20)) + ')'
		        EXEC (@sqlCommand)
		    END
		END
		
		/* Update next_allow_run value in [t_archive_queue_partition] table.
		* This is an indicator of successful archivation*/
		EXEC prtn_get_next_allow_run_date @current_datetime = @current_time,
			 @next_allow_run_date = @next_allow_run_time OUT
		
		UPDATE t_archive_queue_partition
		SET next_allow_run = @next_allow_run_time
		WHERE current_id_partition = @new_current_id_partition
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		    ROLLBACK TRANSACTION
		    
		DECLARE @ErrorSeverity  INT,
		        @ErrorState     INT
		
		SELECT @result = ERROR_MESSAGE(),
		       @ErrorSeverity = ERROR_SEVERITY(),
		       @ErrorState = ERROR_STATE()
		
		RAISERROR (@result, @ErrorSeverity, @ErrorState)
		
		RETURN
	END CATCH
		
	DECLARE @tab1                   NVARCHAR(1000),
	        @sql1                   NVARCHAR(4000),
	        @NU_varStatPercentChar  VARCHAR(255)
	
	IF (@update_stats = 'Y')
	BEGIN
	    DECLARE c1 CURSOR FAST_FORWARD
	    FOR
	        SELECT nm_table_name
	        FROM   t_service_def_log
	    
	    OPEN c1
	    FETCH NEXT FROM c1 INTO @tab1
	    WHILE (@@fetch_status = 0)
	    BEGIN
	        IF @sampling_ratio < 5
	            SET @NU_varStatPercentChar = ' WITH SAMPLE 5 PERCENT '
	        ELSE
	        IF @sampling_ratio >= 100
	            SET @NU_varStatPercentChar = ' WITH FULLSCAN '
	        ELSE
	            SET @NU_varStatPercentChar = ' WITH SAMPLE '
	                + CAST(@sampling_ratio AS VARCHAR(20)) + ' PERCENT '
	        
	        SET @sql1 = 'UPDATE STATISTICS ' + @tab1 + @NU_varStatPercentChar
	        EXECUTE (@sql1)
	        IF (@@error <> 0)
	        BEGIN
	            SET @result =
	                '7000022-archive_queue_partition operation failed-->Error in update stats'
	            
	            CLOSE c1
	            DEALLOCATE c1
				RAISERROR (@result, 16, 1)
	        END
	        
	        FETCH NEXT FROM c1 INTO @tab1
	    END
	    CLOSE c1
	    DEALLOCATE c1
	    SET @sql1 = 'UPDATE STATISTICS t_session ' + @NU_varStatPercentChar
	    EXECUTE (@sql1)
	    SET @sql1 = 'UPDATE STATISTICS t_session_set ' + @NU_varStatPercentChar
	    EXECUTE (@sql1)
	    SET @sql1 = 'UPDATE STATISTICS t_session_state ' + @NU_varStatPercentChar
	    EXECUTE (@sql1)
	    SET @sql1 = 'UPDATE STATISTICS t_message' + @NU_varStatPercentChar
	    EXECUTE (@sql1)
	END
	
	SET @result = '0-archive_queue_partition operation successful'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[PrepareTaxDetailPartitions]'
GO
ALTER proc [dbo].[PrepareTaxDetailPartitions]
                    @intervalStatusToConsider varchar(20),
                    @partitionFunctionCommand varchar(MAX) output,
                    @partitionSchemeCommand varchar(MAX) output
                as
                begin
                    -- Stored procedure return value
                    declare @ret int
                    set @ret = 0

                    -- Get minimum interval start date and and maximum interval end date for all
                    -- of the active intervals (interval status is B or O)
                    declare @minIntervalStartDate datetime
                    declare @maxIntervalEndDate datetime
                    select @minIntervalStartDate=min(dt_start), @maxIntervalEndDate=max(dt_end)
                        from t_usage_interval ui
                        where ui.tx_interval_status like @intervalStatusToConsider

                    -- Now we need to create partitions with the specified cycle (e.g. monthly, yearly)
                    -- that will encompass the minIntervalStartDate and maxIntervalEndDate

                    -- Get the partition cycle from t_usage_server.  The cycle was specified
                    -- during installation.
                    -- e.g. daily, weekly, bi-monthly, monthly, quarterly, yearly
                    declare @partitionCycle int
                    select @partitionCycle = partition_cycle from t_usage_server

                    -- The first partition doesn't really have a start date.  It only has an
                    -- end date.  Assume 19700101 is the beginning of time.
                    declare @partitionStartDate datetime
                    set @partitionStartDate = '19700101'

                    -- Assume t_pc_interval contains a range with the appropriate cycle
                    -- that we can use for the first partition.
                    declare @partitionEndDate datetime
                    SELECT @partitionEndDate=max(dt_start) FROM t_pc_interval
                        WHERE id_cycle=@partitionCycle AND dt_start <= @minIntervalStartDate

                    set @partitionFunctionCommand = 'CREATE PARTITION FUNCTION pfTaxDetails(int) AS RANGE LEFT FOR VALUES ('

                    set @partitionSchemeCommand = 'CREATE PARTITION SCHEME psTaxDetails as partition pfTaxDetails to ('
                    
                    declare @isFirstTimeInLoop int
                    set @isFirstTimeInLoop = 1;

                    while (1 = 1)
                    begin
                        -- Reformat the partitionEndDate to match the format of an interval_id
                        -- which has the days-since-1970101 in the upper 16 bits.
                        declare @endDateInIntervalFormat int
                        set @endDateInIntervalFormat = DATEDIFF(DAY, '19700101', @partitionEndDate) * 65536

                        if (@isFirstTimeInLoop = 1)
                        begin
                            set @partitionFunctionCommand = @partitionFunctionCommand + convert(varchar, @endDateInIntervalFormat)
                            set @partitionSchemeCommand = @partitionSchemeCommand + '[PRIMARY], '
                            set @isFirstTimeInLoop = 0
                        end
                        else
                        begin
                            -- Determine a suffix to be used on the fileGroup and the file
                            -- associated with a partition
                            declare @partitionNameSuffix varchar(500)
                            exec GeneratePartitionNameSuffix @partitionStartDate, @partitionEndDate, @partitionNameSuffix out
                            if (@@ERROR <> 0)
                            begin
                                raiserror('GeneratePartitionNameSuffix failed', 16, 1);
                                return 1
                            end

                            -- Create and execute an add filegroup command e.g.
                            -- "alter database add filegroup fgIntervalId_1013252096_1015283712"
                            declare @fileGroupName varchar(500)
                            exec CreateAndExecuteAddFileGroupCommand 'fg', @partitionNameSuffix, @fileGroupName output
                            if (@@ERROR <> 0)
                            begin
                                return 1
                            end

                            -- Create and execute an add file command e.g.
                            -- ALTER DATABASE NetMeter ADD FILE
                            -- ( 
                            -- NAME = 'File201205.ndf',
                            -- FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\testFile201205.ndf',
                            -- SIZE = 5MB,
                            -- MAXSIZE = 100MB,
                            -- FILEGROWTH = 5MB
                            -- )
                            -- TO FILEGROUP Fg201205
                            exec CreateAndExecuteAddFileCommand 'file', @partitionNameSuffix, @fileGroupName
                            if (@@ERROR <> 0)
                            begin
                                return 1
                            end

                            -- Append to the existing partitition function command
                            set @partitionFunctionCommand = @partitionFunctionCommand + ', ' + convert(varchar, @endDateInIntervalFormat)

                            -- Append to the existing partitition scheme command
                            set @partitionSchemeCommand = @partitionSchemeCommand + @fileGroupName + ', '
                        end
                            
                        -- Determine the end date of the next partition
                        declare @newPartitionEndDate datetime
                        SELECT @newPartitionEndDate=min(dt_start) FROM t_pc_interval
                            WHERE id_cycle=@partitionCycle AND dt_start > @partitionEndDate
                            
                        -- Update the partition dates and see if we should stop looping
                        set @partitionStartDate = @partitionEndDate
                        set @partitionEndDate = @newPartitionEndDate
                        
                        if (@partitionStartDate >= @maxIntervalEndDate)
                        begin
                            break
                        end
                    end

                    set @partitionFunctionCommand = @partitionFunctionCommand + ')'

                    set @partitionSchemeCommand = @partitionSchemeCommand + '[PRIMARY])'

                    return 0
                end
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[CreatePartitionedTaxDetailsFromScratch]'
GO
ALTER proc [dbo].[CreatePartitionedTaxDetailsFromScratch]
                as
                begin
                    -- Stored procedure return value
                    declare @ret int
                    set @ret = 0

                    -- Only consider open and soft-closed intervals
                    declare @intervalStatus varchar(20)
                    set @intervalstatus = '[BO]'

                    -- Create variables to hold the commands that we will generate.
                    -- The commands will look like this when they are run:
                    --
                    -- CREATE PARTITION FUNCTION [testPf](id_usage_interval) AS RANGE RIGHT FOR VALUES (1013252096, 1015283712)
                    -- 
                    -- CREATE PARTITION SCHEME [testPs] AS PARTITION [testPf] TO ( [fgIntervalIdLessThan1013252096], 
                    -- [fgIntervalId1013252096_1015283712], [PRIMARY])
                    --
                    declare @partitionFunctionCommand varchar(MAX)
                    declare @partitionSchemeCommand varchar(MAX)

                    exec PrepareTaxDetailPartitions @intervalStatus, @partitionFunctionCommand output, @partitionSchemeCommand output
                    if (@@ERROR <> 0)
                    begin
                        raiserror('Failed [PrepareTaxDetailPartitions]', 16, 1, @partitionFunctionCommand);
                        return 1
                    end

                    -- The partitionFunctionCommand is now complete, so execute it
                    exec(@partitionFunctionCommand);
                    if (@@ERROR <> 0)
                    begin
                        raiserror('Failed [%s]', 16, 1, @partitionFunctionCommand);
                        return 1
                    end

                    -- The partitionSchemeCommand is now complete, so execute it
                    exec(@partitionSchemeCommand);
                    if (@@ERROR <> 0)
                    begin
                        raiserror('Failed [%s]', 16, 1, @partitionSchemeCommand);
                        return 1
                    end

                    -- Now create the partitioned t_tax_details table
                    declare @taxDetailRowDefinitions varchar(1000)
                    exec GetTaxDetailRowDefinitions @taxDetailRowDefinitions out
                    if (@@ERROR <> 0)
                    begin
                        raiserror('Failed GetTaxDetailRowDefinitions', 16, 1);
                        return 1
                    end

                    declare @createTableCommand varchar(1000)
                    set @createTableCommand = 'CREATE TABLE [t_tax_details](' +
                        @taxDetailRowDefinitions +
                        ') ON psTaxDetails(id_usage_interval)';
                    exec(@createTableCommand);
                    if (@@ERROR <> 0)
                    begin
                        raiserror('Failed [%s]', 16, 1, @createTableCommand);
                        return 1
                    end

                    CREATE UNIQUE CLUSTERED INDEX TaxDetailIndex ON t_tax_details
                    (
                        id_usage_interval ASC,
                        id_acc ASC,
                        id_tax_detail ASC
                    )
                    ON psTaxDetails(id_usage_interval)

                    -- successfully created a partitioned t_tax_details table
                    return 0
                end
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[PartitionExistingTaxDetailsTable]'
GO
ALTER proc [dbo].[PartitionExistingTaxDetailsTable]
                as
                begin
                    -- Stored procedure return value
                    declare @ret int
                    set @ret = 0

                    -- Only consider open and soft-closed intervals
                    declare @intervalStatus varchar(20)
                    set @intervalstatus = '[BO]'

                    -- Create variables to hold the createPartitionCommand/createSchemeCommand
                    declare @partitionFunctionCommand varchar(MAX)
                    declare @partitionSchemeCommand varchar(MAX)

                    exec PrepareTaxDetailPartitions @intervalStatus, @partitionFunctionCommand output, @partitionSchemeCommand output
                    if (@@ERROR <> 0)
                    begin
                        raiserror('Failed [PrepareTaxDetailPartitions]', 16, 1, @partitionFunctionCommand);
                        return 1
                    end

                    -- The partitionFunctionCommand is now complete, so execute it
                    exec(@partitionFunctionCommand);
                    if (@@ERROR <> 0)
                    begin
                        raiserror('Failed [%s]', 16, 1, @partitionFunctionCommand);
                        return 1
                    end

                    -- The partitionSchemeCommand is now complete, so execute it
                    exec(@partitionSchemeCommand);
                    if (@@ERROR <> 0)
                    begin
                        raiserror('Failed [%s]', 16, 1, @partitionSchemeCommand);
                        return 1
                    end

                    -- We already have the files, filegroups, partitionFunction, partitionScheme,
                    -- and an existing unpartitioned t_tax_details table.  So, re-create the TaxDetailIndex
                    -- so that the table will be partitioned.
                    CREATE UNIQUE CLUSTERED INDEX TaxDetailIndex ON t_tax_details
                    (
                        id_usage_interval ASC,
                        id_acc ASC,
                        id_tax_detail ASC
                    )
                    WITH (DROP_EXISTING = ON)
                    ON psTaxDetails(id_usage_interval)

                    -- successfully created a partitioned t_tax_details table
                    return 0
                end
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[prtn_add_file_group]'
GO
CREATE PROCEDURE [dbo].[prtn_add_file_group]
				@partition_name NVARCHAR(100)
				AS
				BEGIN TRY
					DECLARE @sql_cmd VARCHAR(max),
							@sql_file_size VARCHAR(50) = '',
							@data_size INT,
							@path VARCHAR(150)

					IF @partition_name IS NULL OR @partition_name = ''
						RAISERROR('Partition name wasn''t set',16,1)

					IF NOT EXISTS (SELECT * FROM sys.filegroups f
								   WHERE f.name = @partition_name)
					BEGIN
						SELECT  @data_size = partition_data_size
						FROM t_usage_server
						
						IF @data_size IS NOT NULL
						BEGIN
							SET @sql_file_size = 'SIZE = ' + CAST(@data_size as nvarchar(10)) + 'MB'
						END
						
						EXEC GetNextStoragePath	@path = @path OUTPUT
						 
						SET @path = RTRIM(@path)
						
						SET @sql_cmd = 'ALTER DATABASE ' + DB_NAME() + ' ADD FILEGROUP ' + @partition_name + ';' +
										'ALTER DATABASE ' + DB_NAME() + ' ADD FILE (NAME = ' + @partition_name + ', ' +
										'FILENAME = ''' + @path + '\' + @partition_name + '.ndf'', ' +
										@sql_file_size + ') TO FILEGROUP ' + @partition_name
											
						EXEC (@sql_cmd)
					END
				END TRY
				BEGIN CATCH
					IF EXISTS (SELECT * FROM sys.filegroups f
					   WHERE f.name = @partition_name)
					BEGIN
						SET @sql_cmd = 'ALTER DATABASE ' + DB_NAME() + ' REMOVE FILEGROUP ' + @partition_name
						EXEC (@sql_cmd)
					END
					DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT
					SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
					IF (ERROR_NUMBER() = 5009)
						SET @ErrorMessage = 'Folder ' + @path + ' does not exist. Please create it manually'
						
					RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
				END CATCH
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[prtn_alter_partition_schema]'
GO
CREATE PROCEDURE [dbo].[prtn_alter_partition_schema]
				@interval_id_end INT,
				@interval_dt_end DATETIME,
				@partition_name NVARCHAR(100) OUTPUT
				AS
				BEGIN TRY
				IF @interval_id_end IS NULL
				RAISERROR ('End interval ID of partition wasn''t specified', 16, 1)
				IF @interval_dt_end IS NULL OR @interval_dt_end = ''
				RAISERROR ('End date of partition wasn''t specified', 16, 1)

				DECLARE @partition_schema_name    NVARCHAR(50),
				@partition_function_name  NVARCHAR(50),
				@partition_function_id    INT,
				@sqlCommand               NVARCHAR(MAX)

				SET @partition_name = DB_NAME() + '_' + CONVERT(VARCHAR, @interval_dt_end, 102)
				SET @partition_name = REPLACE(@partition_name, '.', '')
				SET @partition_schema_name = dbo.prtn_GetUsagePartitionSchemaName()
				SET @partition_function_name = dbo.Prtn_GetUsagePartitionFunctionName()
				SELECT @partition_function_id = function_id FROM sys.partition_functions WHERE name = @partition_function_name

				IF NOT EXISTS (SELECT * FROM sys.partition_range_values rv
				WHERE  rv.function_id = @partition_function_id
				AND rv.value = @interval_dt_end)
				BEGIN
				EXEC prtn_add_file_group @partition_name

				SET @sqlCommand = 'ALTER PARTITION SCHEME ' + @partition_schema_name
							+ ' NEXT USED ' + @partition_name
				EXEC (@sqlCommand)

				SET @sqlCommand = 'ALTER PARTITION FUNCTION ' + @partition_function_name +
				'() SPLIT RANGE (' + CAST(@interval_id_end AS NVARCHAR(20)) + ')'
				EXEC (@sqlCommand)
				END
				END TRY
				BEGIN CATCH
				DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT
				SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
				RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
				END CATCH
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[prtn_create_meter_partitions]'
GO
CREATE PROCEDURE [dbo].[prtn_create_meter_partitions]
				AS
				DECLARE @meter_partition_function_name NVARCHAR(50),
						@meter_partition_schema_name NVARCHAR(50),
						@meter_partition_filegroup_name NVARCHAR(50),
						@meter_partition_id INT,
						@sqlCommand NVARCHAR(MAX)
											
				BEGIN TRY

					IF dbo.IsSystemPartitioned()=0
						RAISERROR('System not enabled for partitioning.', 16, 1)

					SET @meter_partition_id = 1
					SET @meter_partition_filegroup_name = dbo.prtn_GetMeterPartitionFileGroupName()
					SET @meter_partition_function_name = dbo.prtn_GetMeterPartitionFunctionName()
					SET @meter_partition_schema_name = dbo.prtn_GetMeterPartitionSchemaName()

					IF NOT EXISTS(SELECT * FROM sys.partition_schemes ps WHERE ps.name = @meter_partition_schema_name)
					BEGIN
						------------------------------------------------------------------------------
						----------create file group for meter partition ----------------------------
						------------------------------------------------------------------------------ 
								EXEC prtn_add_file_group @meter_partition_filegroup_name

					    ------------------------------------------------------------------------------
						----------create meter partition function-------------------------------------------
						------------------------------------------------------------------------------ 
						SET @sqlCommand = 'CREATE PARTITION FUNCTION ' + @meter_partition_function_name
						+ ' (int) AS RANGE LEFT FOR VALUES (' + CAST(@meter_partition_id AS NVARCHAR(20)) + ')'
						EXEC (@sqlCommand)

						------------------------------------------------------------------------------
						----------create meter partition scheme-------------------------------------------
						------------------------------------------------------------------------------ 
						SET @sqlCommand = 'CREATE PARTITION SCHEME ' + @meter_partition_schema_name
						+ ' AS PARTITION ' + @meter_partition_function_name
						+ ' TO (' + @meter_partition_filegroup_name + ',' + @meter_partition_filegroup_name + ')'
						EXEC (@sqlCommand)
				
						DECLARE @count_t_archive_queue_partition  INT
						
						SELECT @count_t_archive_queue_partition = COUNT(taqp.current_id_partition)
						FROM   t_archive_queue_partition taqp
						
						IF (@count_t_archive_queue_partition = 0)
							RAISERROR ('t_archive_queue_partition table must have at least one initial record', 16, 1)
						
					END
				END TRY
				BEGIN CATCH
					DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT
					SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
					RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
				END CATCH
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[prtn_create_partition_schema]'
GO
CREATE PROCEDURE [dbo].[prtn_create_partition_schema]
					@interval_id_end INT,
                	@dt_end DATETIME,
                	@partition_name NVARCHAR(100) OUTPUT
				AS
				BEGIN TRY
					IF @interval_id_end IS NULL
						RAISERROR ('End interval ID of first partition wasn''t specified', 16, 1)
					IF @dt_end IS NULL OR @dt_end = ''
						RAISERROR ('End date of first partition wasn''t specified', 16, 1)
					
					DECLARE @default_partition_name  NVARCHAR(100),
							@partition_function_name  NVARCHAR(50),
							@partition_schema_name    NVARCHAR(50),
							@sqlCommand             NVARCHAR(MAX)
					
            	    SET @partition_name = DB_NAME() + '_' + CONVERT(VARCHAR, @dt_end, 102)
            	    SET @partition_name = REPLACE(@partition_name, '.', '')
            	    SET @default_partition_name = dbo.prtn_GetDefaultPartitionName()
					SET @partition_function_name = dbo.Prtn_GetUsagePartitionFunctionName()
					SET @partition_schema_name = dbo.prtn_GetUsagePartitionSchemaName()
					
            	    EXEC prtn_add_file_group @partition_name
            	    EXEC prtn_add_file_group @default_partition_name
            	    
					SET @sqlCommand = 'CREATE PARTITION FUNCTION ' + @partition_function_name
						+ ' (int) AS RANGE LEFT FOR VALUES (' + CAST(@interval_id_end AS NVARCHAR(20)) + ')'
					EXEC (@sqlCommand)
					
					SET @sqlCommand = 'CREATE PARTITION SCHEME ' + @partition_schema_name
						+ ' AS PARTITION ' + @partition_function_name
						+ ' TO  (' + @partition_name + ',' + @default_partition_name + ')'
					EXEC (@sqlCommand)
				END TRY
				BEGIN CATCH
					DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT
					SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
					RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
				END CATCH
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[prtn_create_tax_partitions]'
GO
create proc [dbo].[prtn_create_tax_partitions]
                as
                begin
                    -- Stored procedure return value
                    declare @ret int
                    set @ret = 0

                    -- Set environment for this session
                    set nocount on

                    -- Abort if system isn't enabled for partitioning
                    if dbo.IsSystemPartitioned() = 0
                    begin
                        if OBJECT_ID('t_tax_details') IS NULL
                        begin
                            -- Partitioning disabled, and t_tax_details table doesn't exist, so create it
                            print 'CreateUnpartitionedTaxDetailsTable'
                            exec CreateUnpartitionedTaxDetailsTable
                            if (@@ERROR <> 0)
                            begin
                                raiserror('CreateUnpartitionedTaxDetailsTable failed', 16, 1);
                                set @ret = 1
                            end
                        end
                        else
                        begin
                            print 'unpartitioned t_tax_details already exists, nothing to do'
                        end
                    end
                    else if OBJECT_ID('t_tax_details') IS NULL
                    begin
                        -- Create partitioned t_tax_details from scratch
                        -- that will handle the existing open intervals
                        print 'CreatePartitionedTaxDetailsFromScratch'
                        exec CreatePartitionedTaxDetailsFromScratch
                        if (@@ERROR <> 0)
                        begin
                            raiserror('CreatePartitionedTaxDetailsFromScratch failed', 16, 1);
                            set @ret = 1
                        end
                    end
                    else
                    begin
                        -- Create a cursor capable of looping on the 
                        -- existing partitions of the t_tax_details table.
                        declare partitionInfoCursor CURSOR FOR SELECT c_partition_number FROM v_partition_info vpi WHERE vpi.c_object_name='t_tax_details'
                        open partitionInfoCursor

                        if CURSOR_STATUS('global', 'partitionInfoCursor') = 0
                        begin
                            -- t_tax_details exists, but does not have any partitions
                            print 'PartitionExistingTaxDetailsTable'
                            exec PartitionExistingTaxDetailsTable
                            if (@@ERROR <> 0)
                            begin
                                raiserror('PartitionExistingTaxDetailsTable failed', 16, 1);
                                set @ret = 1
                            end
                        end
                        else
                        begin
                            -- t_tax_details exists and is already partitioned
                            -- Add new partitions if necessary
                            print 'AddPartitionsToTaxDetailsTable'
                            exec AddPartitionsToTaxDetailsTable
                            if (@@ERROR <> 0)
                            begin
                                raiserror('AddPartitionsToTaxDetailsTable failed', 16, 1);
                                set @ret = 1
                            end
                        end
                        close partitionInfoCursor
                        deallocate partitionInfoCursor
                    end

                    return @ret
                end
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[prtn_create_usage_partitions]'
GO
CREATE PROCEDURE [dbo].[prtn_create_usage_partitions]
				AS
				BEGIN TRY
				IF dbo.IsSystemPartitioned() = 0
					RAISERROR('System not enabled for partitioning.', 16, 1)

				/* Vars for iterating through the new partition list
				*/
				DECLARE @cur CURSOR
				DECLARE @dt_start DATETIME
				DECLARE @dt_end DATETIME
				DECLARE @id_interval_start INT
				DECLARE @id_interval_end INT
				DECLARE @parts TABLE (
							partition_name NVARCHAR(100),
							dt_start DATETIME,
							dt_end DATETIME,
							interval_start INT,
							interval_end INT
						)
									
				EXEC GeneratePartitionSequence @cur OUT

				/* Get first row of partition info*/
				FETCH @cur INTO	@dt_start, @dt_end, @id_interval_start, @id_interval_end

				/* pause pipeline to reduce contention */
				IF (@@FETCH_STATUS = 0) EXEC PausePipelineProcessing 1

				/* Iterate through partition sequence */
				WHILE (@@fetch_status = 0)
				BEGIN
					DECLARE @partition_name NVARCHAR(100)
					
					IF NOT EXISTS (SELECT * FROM sys.partition_schemes WHERE name = dbo.prtn_GetUsagePartitionSchemaName())
					BEGIN
						EXEC prtn_create_partition_schema @id_interval_end, @dt_end, @partition_name OUT
						
						-- insert information about default partition						
						INSERT INTO t_partition
						(partition_name, b_default, dt_start, dt_end, id_interval_start, id_interval_end, b_active)
						VALUES
						(dbo.prtn_GetDefaultPartitionName(), 'Y', DATEADD(DAY, 1, @dt_end), dbo.MTMaxdate(), @id_interval_end + 1, 2147483647, 'N')
						
						INSERT INTO @parts
						VALUES
						(dbo.prtn_GetDefaultPartitionName(), DATEADD(DAY, 1, @dt_end), dbo.MTMaxdate(), @id_interval_end + 1, 2147483647)
					END
					ELSE
					BEGIN
						EXEC prtn_alter_partition_schema @id_interval_end, @dt_end, @partition_name OUT
						
						-- update start of default partition
						UPDATE t_partition
						SET
							dt_start = DATEADD(DAY, 1, @dt_end),
							id_interval_start = @id_interval_end + 1
						WHERE  b_default = 'Y'
					END
					
					-- insert information about created partition			
					INSERT INTO t_partition
						(partition_name, b_default, dt_start, dt_end, id_interval_start, id_interval_end, b_active)
						VALUES
						(@partition_name, 'N', @dt_start, @dt_end, @id_interval_start, @id_interval_end, 'Y')
						
					INSERT INTO @parts
						VALUES
						(@partition_name, @dt_start, @dt_end, @id_interval_start, @id_interval_end)
					
					/* Get next patition info */
					FETCH @cur INTO @dt_start, @dt_end, @id_interval_start, @id_interval_end
				END

				/* Deallocate the cursor */
				CLOSE @cur
				DEALLOCATE @cur

				/* unpause pipeline */
				EXEC PausePipelineProcessing 0

				/* Correct default partition start if it was just created */
				UPDATE @parts
				SET
					dt_start = DATEADD(DAY, 1, @dt_end),
					interval_start = @id_interval_end + 1
				WHERE dt_end = dbo.MTMaxdate()
				
				/* Returning partition info*/
				SELECT * FROM @parts ORDER BY dt_start
				
				END TRY
				BEGIN CATCH
					DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT
					SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
					EXEC PausePipelineProcessing 0
					RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
				END CATCH
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[prtn_deploy_table]'
GO
CREATE PROCEDURE [dbo].[prtn_deploy_table]
	@partition_table_name	VARCHAR(32),
	@pk_columns				VARCHAR(200),
	@partition_schema		VARCHAR(100),
	@partition_column		VARCHAR(32),
	@apply_uk_tables		BIT = 0
AS
BEGIN
	DECLARE @found_partition_schema  VARCHAR(100),
	        @error_message           VARCHAR(300),
	        @sql_command             VARCHAR(MAX)

	BEGIN TRY

		IF dbo.IsSystemPartitioned() = 0
			RAISERROR('Partitioning not enabled', 16, 1)
		
		IF @partition_table_name IS NULL
		   OR @partition_table_name = ''
			RAISERROR ('Table name wasn''t specified', 16, 1)
		
		IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @partition_table_name)
		BEGIN
			SET @error_message = 'Table "' + @partition_table_name + '" does not exist'
			RAISERROR (@error_message, 16, 1)
		END
			
		IF NOT EXISTS(SELECT * FROM sys.partition_schemes ps WHERE ps.name = @partition_schema)
		BEGIN
			SET @error_message = '"' + @partition_schema +
				'" schema was not created. Partitioning cannot be applied for table "' + @partition_table_name + '".'
			RAISERROR (@error_message, 16, 1)
		END
		
		IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @partition_table_name AND COLUMN_NAME = @partition_column)
		BEGIN
			SET @error_message = 'Table "' + @partition_table_name
			+ '" does not contain a partition column "'+ @partition_column + '". This field is required for partitioning.'
			RAISERROR (@error_message, 16, 1)
		END
		
		IF OBJECT_ID('RecreateIndexes') IS NULL
		BEGIN
			SET @error_message = 'Stored procedure "RecreateIndexes" does not exist in database'
			RAISERROR (@error_message, 16, 1)
		END
		
		SELECT DISTINCT @found_partition_schema = ps.name
		FROM   sys.partitions p
			   JOIN sys.objects o
					ON  o.object_id = p.object_id
			   JOIN sys.indexes i
					ON  p.object_id = i.object_id
					AND p.index_id = i.index_id
			   JOIN sys.data_spaces ds
					ON  i.data_space_id = ds.data_space_id
			   JOIN sys.partition_schemes ps
					ON  ds.data_space_id = ps.data_space_id
			   JOIN sys.partition_functions pf
					ON  ps.function_id = pf.function_id
		WHERE  o.name = @partition_table_name
		
		BEGIN TRANSACTION
		
		IF @found_partition_schema IS NULL
		BEGIN
			DECLARE @pk_name NVARCHAR(50)
			SELECT @pk_name = CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'PRIMARY KEY' AND TABLE_NAME = @partition_table_name
			
			IF @pk_name IS NOT NULL
			BEGIN
				SET @sql_command = 'ALTER TABLE ' + @partition_table_name + ' DROP CONSTRAINT ' + @pk_name
				EXEC(@sql_command)
			END
			
			SET @sql_command = 'ALTER TABLE ' + @partition_table_name + ' ADD CONSTRAINT pk_' + @partition_table_name
							 + ' PRIMARY KEY CLUSTERED( '+ @pk_columns +' )
								WITH (
									 PAD_INDEX = OFF,
									 STATISTICS_NORECOMPUTE = OFF,
									 IGNORE_DUP_KEY = OFF,
									 ALLOW_ROW_LOCKS = ON,
									 ALLOW_PAGE_LOCKS = ON
								 ) ON ' + @partition_schema + '('+ @partition_column +')'
			EXEC(@sql_command)
			
			/* For now only Usage tables supports Non-Clustered Unique Constraints.
			't_uk_*' table is created for each Non-Clustered Unique constraint. */
			IF @apply_uk_tables = 1
			BEGIN
				/*
				* Cannot use DropUniqueConstraints for t_acc_usage, cause of missmach in constraint names.
				* Stored in t_unique_cons name:	"uk_acc_usage_tx_uid"
				* Real name: "C_t_acc_usage"
				*/
				IF @partition_table_name = 't_acc_usage'
					ALTER TABLE t_acc_usage DROP CONSTRAINT C_t_acc_usage
				ELSE
					EXEC DropUniqueConstraints @partition_table_name
			END
			
			EXEC RecreateIndexes @partition_table_name
			
		END
		ELSE
		BEGIN
			IF @found_partition_schema <> @partition_schema
			BEGIN
				SET @error_message = 'Table "' + @partition_table_name
					+ '" already under "' + @found_partition_schema
					+ '". Could not apply for "' + @partition_schema + '"'
				RAISERROR (@error_message, 16, 1)
			END
		END
		
		/* Now - for Usage tables only */
		IF @apply_uk_tables = 1
		BEGIN
			DECLARE @ret INT
			EXEC @ret = CreateUniqueKeyTables @partition_table_name
			IF (@ret <> 0)
				RAISERROR('Cannot create unique keys for table [%s]',16,1,@partition_table_name)
		END
		
		COMMIT
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT
		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
		ROLLBACK
	END CATCH
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[prtn_deploy_all_meter_tables]'
GO
CREATE PROCEDURE [dbo].[prtn_deploy_all_meter_tables]
	AS
	BEGIN
		DECLARE @svc_table_name VARCHAR(50),
				@meter_partition_schema VARCHAR(100)

		BEGIN TRY
			SET @meter_partition_schema = dbo.prtn_GetMeterPartitionSchemaName()

			IF dbo.IsSystemPartitioned()=0
				RAISERROR('System not enabled for partitioning.', 16, 1)

			DECLARE svctablecur CURSOR FOR
								SELECT nm_table_name
								FROM t_service_def_log

			--------------------------------------------------------------------------
			------------------Deploy service definition tables -----------------------
			--------------------------------------------------------------------------
			OPEN svctablecur
			FETCH NEXT FROM svctablecur INTO @svc_table_name
			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				EXEC prtn_deploy_table
						@svc_table_name,
						N'id_source_sess ASC, id_partition ASC',
						@meter_partition_schema,
						N'id_partition'
			
			FETCH NEXT FROM svctablecur INTO @svc_table_name
			END

			-------------------------------------------------------------------------
			-----------------Deploy message and session tables-----------------------
			-------------------------------------------------------------------------
			EXEC prtn_deploy_table
						N't_message',
						N'id_message ASC, id_partition ASC',
						@meter_partition_schema,
						N'id_partition'

			EXEC prtn_deploy_table
						N't_session',
						N'id_ss ASC, id_source_sess ASC, id_partition ASC',
						@meter_partition_schema,
						N'id_partition'

			EXEC prtn_deploy_table
						N't_session_set',
						N'id_ss ASC, id_partition ASC',
						@meter_partition_schema,
						N'id_partition'

			EXEC prtn_deploy_table
						N't_session_state',
						N'id_sess ASC, dt_end ASC, tx_state ASC, id_partition ASC',
						@meter_partition_schema,
						N'id_partition'
		END TRY
		BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT
		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
		END CATCH
	END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[prtn_deploy_usage_table]'
GO
CREATE PROCEDURE [dbo].[prtn_deploy_usage_table]
	@table_name VARCHAR(200)
AS
BEGIN
	DECLARE @usage_partition_scheme  VARCHAR(100),
	        @error_message           VARCHAR(300)

	BEGIN TRY
		SET @usage_partition_scheme = dbo.prtn_GetUsagePartitionSchemaName()

		IF NOT EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @table_name AND COLUMN_NAME = 'id_sess' )
		BEGIN
		    SET @error_message = 'Table "' + @table_name  + '" suggests to have column "id_sess" as a part of PK. This field is required for partitioning.'
		    RAISERROR (@error_message, 16, 1)
		END

		EXEC prtn_deploy_table
		     @partition_table_name = @table_name,
		     @pk_columns = N'id_sess, id_usage_interval',
		     @partition_schema = @usage_partition_scheme,
		     @partition_column = 'id_usage_interval',
		     @apply_uk_tables = 1
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT
		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
		ROLLBACK
	END CATCH
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[prtn_deploy_all_usage_tables]'
GO
CREATE PROCEDURE [dbo].[prtn_deploy_all_usage_tables]
AS
	SET NOCOUNT ON
	
	DECLARE @err               INT,	-- last error
	        @rc                INT,	-- row count
	        @tab               VARCHAR(300),
	        @partition_schema  VARCHAR(100)

	SET @partition_schema = dbo.prtn_GetUsagePartitionSchemaName()
	
	-- Abort if system isn't enabled for partitioning
	IF dbo.IsSystemPartitioned() = 0
	BEGIN
	    RAISERROR('System not enabled for partitioning.', 0, 1)
	    RETURN 1
	END


	PRINT '------ DEPLOYING PRODUCT VIEW TABLES ----------'

	DECLARE tabcur CURSOR
	FOR
	    SELECT nm_table_name
	    FROM   t_prod_view
	    ORDER BY
	           nm_table_name
	
	OPEN tabcur
	FETCH tabcur INTO @tab

	WHILE (@@fetch_status >= 0)
	BEGIN
	    PRINT CHAR(13) + 'Deploying ' + @tab

	    EXEC prtn_deploy_usage_table @tab
	    
	    FETCH tabcur INTO @tab
	END
	DEALLOCATE tabcur
	
	
	PRINT '------ DEPLOYING AMP TABLES ----------'
	
	PRINT 'DEPLOYING AGG_CHARGE_AUDIT_TRAIL TABLE'
	IF OBJECT_ID('agg_charge_audit_trail') IS NOT NULL
	    EXEC prtn_deploy_table
	         @partition_table_name = N'agg_charge_audit_trail',
	         @pk_columns = N'id_payee ASC, id_usage_interval ASC, id_sess ASC',
	         @partition_schema = @partition_schema,
	         @partition_column = N'id_usage_interval'
	
	PRINT 'DEPLOYING AGG_USAGE_AUDIT_TRAIL TABLE'
	IF OBJECT_ID('agg_usage_audit_trail') IS NOT NULL
	    EXEC prtn_deploy_table
	         @partition_table_name = N'agg_usage_audit_trail',
	         @pk_columns = N'id_payee ASC, id_usage_interval ASC, id_sess ASC, is_realtime ASC',
	         @partition_schema = @partition_schema,
	         @partition_column = N'id_usage_interval'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[prtn_deploy_serv_def_table]'
GO
CREATE PROCEDURE [dbo].[prtn_deploy_serv_def_table]
		@svc_table_name 		VARCHAR(32)
AS
DECLARE @meter_partition_schema	NVARCHAR(50),
		@error_message			NVARCHAR(4000)

BEGIN TRY
	IF dbo.IsSystemPartitioned() = 0
		RETURN

	SET @meter_partition_schema = dbo.prtn_GetMeterPartitionSchemaName()

	IF NOT EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @svc_table_name AND COLUMN_NAME = 'id_source_sess' )
	BEGIN
		SET @error_message = 'Table "' + @svc_table_name  + '" suggests to have column "id_source_sess" as a part of PK. This field is required for partitioning.'
		RAISERROR (@error_message, 16, 1)
	END

	IF EXISTS(SELECT * FROM sys.partition_schemes ps WHERE ps.name = @meter_partition_schema)
	BEGIN
	IF OBJECT_ID(@svc_table_name) IS NOT NULL
		EXEC prtn_deploy_table
				@svc_table_name,
				N'id_source_sess ASC, id_partition ASC',
				@meter_partition_schema,
				N'id_partition'
	END
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT
	SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
	ROLLBACK
END CATCH
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[prtn_insert_meter_partition_info]'
GO
ALTER PROCEDURE [dbo].[prtn_insert_meter_partition_info]
	@id_partition INT,
	@current_datetime DATETIME = NULL
AS
	SET NOCOUNT ON

	DECLARE @next_allow_run DATETIME
	
	IF @current_datetime IS NULL
	    SET @current_datetime = GETDATE()

	EXEC prtn_get_next_allow_run_date @current_datetime = @current_datetime,
	     @next_allow_run_date = @next_allow_run OUT

	INSERT INTO t_archive_queue_partition
	VALUES
	  (
	    @id_partition,
	    @current_datetime,
	    @next_allow_run
	  )
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[mvm_resubmit_runs]'
GO
ALTER TABLE [dbo].[mvm_resubmit_runs] ADD
[msg_count] [int] NULL,
[ss_count] [int] NULL,
[s_count] [int] NULL
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
ALTER TABLE [dbo].[mvm_resubmit_runs] ALTER COLUMN [resubmit_date] [datetime] NULL
ALTER TABLE [dbo].[mvm_resubmit_runs] ALTER COLUMN [dt_started] [datetime] NULL
ALTER TABLE [dbo].[mvm_resubmit_runs] ALTER COLUMN [dt_completed] [datetime] NULL
ALTER TABLE [dbo].[mvm_resubmit_runs] ALTER COLUMN [dt_assigned] [datetime] NULL
ALTER TABLE [dbo].[mvm_resubmit_runs] ALTER COLUMN [range_start_date] [datetime] NULL
ALTER TABLE [dbo].[mvm_resubmit_runs] ALTER COLUMN [range_end_date] [datetime] NULL
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[GetReconcileParameters]'
GO
CREATE PROCEDURE [dbo].[GetReconcileParameters]
    @do_recovery INT OUTPUT,
    @dt_min      DATETIME OUTPUT,
    @dt_max      DATETIME OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    /******************************************
     ** SET DEFAULTS
     ******************************************/
    SET @do_recovery = 1

    SELECT TOP 1 @dt_min = range_end_date
    FROM mvm_resubmit_runs
    WHERE dt_completed > dbo.MTMinDate()
    ORDER BY dt_completed DESC

	IF(@@ROWCOUNT = 0 OR @dt_min IS NULL)
	BEGIN
        SET @dt_min = dbo.MTMinDate()
    END
	
    /******************************************
     ** IF there is usage then we get the current 
     ** value, otherwise we fall back to the set 
     ** default above 
     ******************************************/
    SELECT @dt_max = MAX(dt_completed) FROM t_message where dt_completed BETWEEN @dt_min and dbo.metratime(1,'RAMP')
	IF(@dt_max IS NULL)
	BEGIN
        SET @do_recovery = 0;
        SET @dt_min = dbo.MTMinDate()
        SET @dt_max = dbo.MTMinDate()
        RETURN;
    END

    IF @dt_max = @dt_min
    BEGIN
        SET @do_recovery = 0;
    END
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[InsertResubmitAudit]'
GO
CREATE PROCEDURE [dbo].[InsertResubmitAudit]
    @dt_reconcile   DATETIME OUTPUT,
    @dt_range_start DATETIME,
    @dt_range_end   DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    SET @dt_reconcile = GETUTCDATE()
    INSERT INTO mvm_resubmit_runs (resubmit_date, dt_started, range_start_date, range_end_date)
                VALUES(@dt_reconcile, @dt_reconcile, @dt_range_start, @dt_range_end);
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[mvm_is_partitioned]'
GO
ALTER
PROCEDURE [dbo].[mvm_is_partitioned](
    @p_table  VARCHAR(4000),           -- table to bulk update
    @p_is_partitioned integer OUTPUT -- table we created
  )
AS
begin
	declare @errmsg VARCHAR(4000)

	--determine if table is partioned
	set @p_is_partitioned=-1
	if (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME=@p_table))
	begin
		set @p_is_partitioned=0
	end
	else
		begin try
       -- N_DEFAULT is not present in the non partitioned database or in the native partitioned database (MetraNet 7.x and later)
       -- Adding a check so that not partitioned returns when N_DEFAULT is not found. This will work on all versions of MetraNet
       -- as the reason for the check is to see if SQL Server partitioned Views are used.
		   if (EXISTS (SELECT 1 from SYS.DATABASES where NAME = 'N_DEFAULT'))
		   BEGIN
			   if (EXISTS (SELECT 1 FROM n_default.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME=@p_table))
			   begin
				   set @p_is_partitioned=1
			   end
       end
		end try
		begin catch
		end catch;

	if @p_is_partitioned=-1
	begin
 		select @errmsg = 'Error, table ['+@p_table+'] does not appear in either n_default.INFORMATION_SCHEMA.TABLES or INFORMATION_SCHEMA.TABLES'
		RAISERROR (@errmsg, 16, 1)
	end
end
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[mvm_create_blk_del_table2]'
GO
ALTER
PROCEDURE [dbo].[mvm_create_blk_del_table2](
    @p_table  VARCHAR(4000),           -- table to bulk delete
    @p_prefix VARCHAR(4000),           -- prefix on blk_del_table name
    @p_mvm_run_id INTEGER,           --  identifier of mvm run
    @p_node_id VARCHAR(4000),           --  identifier of mvm node_id
    @p_blk_del_table VARCHAR(4000) OUTPUT -- table we created
  )
AS
begin
	declare @sql table(s varchar(1000), id int identity)
	declare @guid uniqueidentifier
	declare @is_partitioned integer

	--determine if table is partioned
	exec mvm_is_partitioned @p_table=@p_table, @p_is_partitioned=@is_partitioned OUTPUT
	--print 'is_partitioned='+CONVERT(varchar(5), @is_partitioned)


	-- name of tmp bulk delete table
	select @p_blk_del_table=substring(@p_prefix + replace( newid(),'-',''),0,30)
	while (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME=@p_blk_del_table))
	begin
		select @p_blk_del_table=substring(@p_prefix+replace( newid(),'-',''),0,30)
	end

	-- create statement
	insert into  @sql(s) values ('create table [' + @p_blk_del_table + '] (')

  -- create all primary key columns as non-null allowable
	if(@is_partitioned=0)
	begin
		insert into @sql(s)
		SELECT 	'  ['+c.column_name+'] '+c.data_type + coalesce('('+cast(c.character_maximum_length as varchar)+')','') + ','
		FROM information_schema.table_constraints a
		INNER JOIN information_schema.key_column_usage b ON a.constraint_name = b.CONSTRAINT_NAME
    		INNER JOIN information_schema.columns c on a.TABLE_NAME = c.TABLE_NAME and b.COLUMN_NAME = c.COLUMN_NAME
		WHERE a.constraint_type = 'PRIMARY KEY'
		AND a.table_name = @p_table
		order by b.ordinal_position
	end
	else
	begin
		insert into @sql(s)
		SELECT 	'  ['+c.column_name+'] '+c.data_type + coalesce('('+cast(c.character_maximum_length as varchar)+')','') + ','
		FROM n_default.information_schema.table_constraints a
		INNER JOIN n_default.information_schema.key_column_usage b ON a.constraint_name = b.CONSTRAINT_NAME
    		INNER JOIN n_default.information_schema.columns c on a.TABLE_NAME = c.TABLE_NAME and b.COLUMN_NAME = c.COLUMN_NAME
		WHERE a.constraint_type = 'PRIMARY KEY'
		AND a.table_name = @p_table
		order by b.ordinal_position
	end
		

	-- add primary key
	insert into @sql(s) values( ' CONSTRAINT pk_' + @p_blk_del_table + ' PRIMARY KEY (' )

	-- add primary key columns 
	if(@is_partitioned=0)
	begin
		insert into @sql(s)
		SELECT ' '+ b.column_name + ','
		FROM information_schema.table_constraints a
		INNER JOIN information_schema.key_column_usage b ON a.constraint_name = b.CONSTRAINT_NAME
		WHERE a.constraint_type = 'PRIMARY KEY'
		AND a.table_name = @p_table
		order by ordinal_position
	end
	else
	begin
		insert into @sql(s)
		SELECT ' '+ b.column_name + ','
		FROM n_default.information_schema.table_constraints a
		INNER JOIN n_default.information_schema.key_column_usage b ON a.constraint_name = b.CONSTRAINT_NAME
		WHERE a.constraint_type = 'PRIMARY KEY'
		AND a.table_name = @p_table
		order by ordinal_position
	end

	-- remove trailing comma
	update @sql set s=left(s,len(s)-1) where id=(select max(id) from @sql) --@@identity
	
	-- PK closing bracket
	insert into @sql(s) values( ')' )

	-- create closing bracket
	insert into @sql(s) values( ')' )

		-- result!
	declare @stmt varchar(8000)
	SELECT @stmt = coalesce(@stmt + CHAR(13)+ CHAR(10), '') + s
	FROM @sql
	order by id

	--print @stmt
	EXECUTE( 'begin '+@stmt+' end')

	insert into amp_staging_tables (mvm_run_id, node_id, staging_table_name, create_dt) values(@p_mvm_run_id, @p_node_id, @p_blk_del_table, getdate())
end
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[mvm_create_blk_ins_table2]'
GO
ALTER
PROCEDURE [dbo].[mvm_create_blk_ins_table2](
    @p_table  VARCHAR(4000),           -- table to bulk update
    @p_prefix VARCHAR(4000),           -- prefix on blk_upd_table name
    @p_mvm_run_id INTEGER,           --  identifier of mvm run
    @p_node_id VARCHAR(4000),           --  identifier of mvm node_id
    @p_blk_upd_table VARCHAR(4000) OUTPUT -- table we created
  )
AS
begin
	declare @sql table(s varchar(1000), id int identity)
	declare @guid uniqueidentifier
	declare @is_partitioned integer

	--determine if table is partioned
	exec mvm_is_partitioned @p_table=@p_table, @p_is_partitioned=@is_partitioned OUTPUT
	--print 'is_partitioned='+CONVERT(varchar(5), @is_partitioned)

	-- name of tmp bulk update table
	select @p_blk_upd_table=substring(@p_prefix + replace( newid(),'-',''),0,30)
	while (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME=@p_blk_upd_table))
	begin
		select @p_blk_upd_table=substring(@p_prefix+replace( newid(),'-',''),0,30)
	end

	-- create statement
	insert into  @sql(s) values ('create table [' + @p_blk_upd_table + '] (')

	-- add columns all null allowable
if(@is_partitioned=0)
begin
	insert into @sql(s)
	select
	'  ['+column_name+'] '+data_type + case data_type when 'numeric' then '('+cast(numeric_precision as varchar)+',' + cast(numeric_scale as varchar) +')' else coalesce('('+cast(character_maximum_length as varchar)+')','') end + ' NULL,'
	from information_schema.columns where table_name = @p_table
	order by ordinal_position
end
else
begin
	insert into @sql(s)
	select
	'  ['+column_name+'] '+data_type + case data_type when 'numeric' then '('+cast(numeric_precision as varchar)+',' + cast(numeric_scale as varchar) +')' else coalesce('('+cast(character_maximum_length as varchar)+')','') end + ' NULL,'
	from n_default.information_schema.columns where table_name = @p_table
	order by ordinal_position
end

	-- remove trailing comma
	update @sql set s=left(s,len(s)-1) where id=(select max(id) from @sql) --@@identity
	
	-- create closing bracket
	insert into @sql(s) values( ')' )

		-- result!
	declare @stmt varchar(8000)
	SELECT @stmt = coalesce(@stmt + CHAR(13)+ CHAR(10), '') + s
	FROM @sql
	order by id

	--select @stmt
	EXECUTE( 'begin '+@stmt+' end')

	insert into amp_staging_tables (mvm_run_id, node_id, staging_table_name, create_dt) values(@p_mvm_run_id, @p_node_id, @p_blk_upd_table, getdate())
end
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[mvm_create_uk_table]'
GO
create
PROCEDURE [dbo].[mvm_create_uk_table](
    @p_table  VARCHAR(4000),           -- table to bulk update
    @p_prefix VARCHAR(4000),           -- prefix on blk_upd_table name
    @p_mvm_run_id INTEGER,           --  identifier of mvm run
    @p_node_id VARCHAR(4000),           --  identifier of mvm node_id
    @p_tmp_table VARCHAR(4000) OUTPUT -- table we created
  )
AS
begin
	declare @sql table(s varchar(1000), id int identity)
	declare @guid uniqueidentifier
	declare @is_partitioned integer

	--determine if table is partioned
	exec mvm_is_partitioned @p_table=@p_table, @p_is_partitioned=@is_partitioned OUTPUT
	--print 'is_partitioned='+CONVERT(varchar(5), @is_partitioned)

	-- name of tmp bulk update table
	select @p_tmp_table=substring(@p_prefix + replace( newid(),'-',''),0,30)
	while (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME=@p_tmp_table))
	begin
		select @p_tmp_table=substring(@p_prefix+replace( newid(),'-',''),0,30)
	end

	-- create statement
	insert into  @sql(s) values ('create table [' + @p_tmp_table + '] (')

	-- add columns all null allowable
if(@is_partitioned=0)
begin
	insert into @sql(s)
	select
	'  ['+column_name+'] '+data_type + case data_type when 'numeric' then '('+cast(numeric_precision as varchar)+',' + cast(numeric_scale as varchar) +')' else coalesce('('+cast(character_maximum_length as varchar)+')','') end + ' NULL,'
	from information_schema.columns where table_name = 't_acc_usage' and column_name = 'tx_uid'
	order by ordinal_position
	insert into @sql(s)
	select
	'  ['+column_name+'] '+data_type + case data_type when 'numeric' then '('+cast(numeric_precision as varchar)+',' + cast(numeric_scale as varchar) +')' else coalesce('('+cast(character_maximum_length as varchar)+')','') end + ' NULL,'
	from information_schema.columns where table_name = @p_table and column_name not in ('id_usage_interval', 'id_sess', 'tx_uid')
	order by ordinal_position
end
else
begin
	insert into @sql(s)
	select
	'  ['+column_name+'] '+data_type + case data_type when 'numeric' then '('+cast(numeric_precision as varchar)+',' + cast(numeric_scale as varchar) +')' else coalesce('('+cast(character_maximum_length as varchar)+')','') end + ' NULL,'
	from n_default.information_schema.columns where table_name = 't_acc_usage' and column_name = 'tx_uid'
	order by ordinal_position
	insert into @sql(s)
	select
	'  ['+column_name+'] '+data_type + case data_type when 'numeric' then '('+cast(numeric_precision as varchar)+',' + cast(numeric_scale as varchar) +')' else coalesce('('+cast(character_maximum_length as varchar)+')','') end + ' NULL,'
	from n_default.information_schema.columns where table_name = @p_table and column_name not in ('id_usage_interval', 'id_sess', 'tx_uid')
	order by ordinal_position
end

	-- remove trailing comma
	update @sql set s=left(s,len(s)-1) where id=(select max(id) from @sql) --@@identity
	
	-- create closing bracket
	insert into @sql(s) values( ')' )

		-- result!
	declare @stmt varchar(8000)
	SELECT @stmt = coalesce(@stmt + CHAR(13)+ CHAR(10), '') + s
	FROM @sql
	order by id

	--select @stmt
	EXECUTE( 'begin '+@stmt+' end')

	insert into amp_staging_tables (mvm_run_id, node_id, staging_table_name, create_dt) values(@p_mvm_run_id, @p_node_id, @p_tmp_table, getdate())
end
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Create [dbo].[ReconcileUsageForward]'
GO
CREATE PROCEDURE [dbo].[ReconcileUsageForward]
    @WindowBegin DATETIME,
    @WindowEnd DATETIME,
	@SafeDate DATETIME
AS
BEGIN
SET XACT_ABORT ON;
    SET NOCOUNT ON;
    
    IF @WindowBegin IS NULL OR @WindowEnd IS NULL
    BEGIN
        --PRINT 'WINDOW DATES ARE NULL'
        select -1 msg_count,  -1 ss_count,  -1 s_count
        RETURN;
    END

    IF @WindowBegin = '' OR @WindowEnd = ''
    BEGIN
        --PRINT 'WINDOW DATES ARE EMPTY'
        select -2 msg_count,  -2 ss_count,  -2 s_count
        RETURN;
    END
        
    IF @WindowBegin = @WindowEnd OR @WindowBegin > @WindowEnd
    BEGIN
        SELECT 0 msg_count,  0 ss_count,  0 s_count
        RETURN;
    END

    DECLARE @dt_reconcile DATETIME;
    SET @dt_reconcile = dbo.metratime(1,'RAMP') ;
    
    /***************************************************************
     ** FIRST ORDER OF BUSINESS (SUSPENDED PIPELINE TRANSACTIONS)
     ** CLEAR THEM SINCE WE WILL RESUBMIT THEM HERE...
     ***************************************************************/
    DECLARE @suspended_txn_time INT
    SELECT @suspended_txn_time = 1

    SELECT @suspended_txn_time = CAST(param_value AS INT) FROM mvm_global_params p WITH(NOLOCK) WHERE p.param_name = 'suspended_txn_time'

	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE t_message with(ROWLOCK,READPAST)
		SET dt_completed = @WindowEnd
		WHERE 1=1
		AND dt_completed IS NULL
		AND dt_assigned < DATEADD(hour, -@suspended_txn_time, @dt_reconcile )
		and id_pipeline in (select id_pipeline from t_pipeline with(nolock) where b_online='1' and b_paused = '0')
		COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
    END CATCH;

    /***************************************************************
     ** END (SUSPENDED PIPELINE TRANSACTIONS)
     ***************************************************************/

	DECLARE @idMessage       INT
    DECLARE @id_run          INT
    DECLARE @msg_count       INT,
            @ss_count        INT,
            @s_count         INT

    DECLARE @new_partition   INT
    DECLARE @id_svc          INT
    DECLARE @tbl_name        SYSNAME
    DECLARE @statement       NVARCHAR(MAX)

    CREATE TABLE #ServiceMap
	(
        id_svc int not null,
        table_name varchar(255) not null,
		PRIMARY KEY (id_svc)
    );

    CREATE TABLE #SessionSetMap
	(
        id_ss int not null,
        new_id_ss int,
        sess_cnt int,
		PRIMARY KEY (id_ss)
    );

    CREATE TABLE #MessageIdTable
	(
        id_message int not null,
        new_id_message int,
		PRIMARY KEY (id_message)
    );

    CREATE TABLE #tmpReconcileMessageTable
    (
        id_message       INT,
        dt_completed     DATETIME,
        dt_assigned      DATETIME,
        b_root           CHAR(1),
        id_ss            INT,
        id_svc           INT,
        id_partition     INT,
        id_source_sess   BINARY(16),
        dt_metered       DATETIME,
        tx_ip_address    VARCHAR(15),
		PRIMARY KEY (id_message,id_ss,id_source_sess)
    );

    CREATE TABLE #tmpReconcileMessageTable2
    (
        id_message       INT,
        dt_completed     DATETIME,
        dt_assigned      DATETIME,
        b_root           CHAR(1),
        id_ss            INT,
        id_svc           INT,
        id_partition     INT,
        id_source_sess   BINARY(16),
        dt_metered       DATETIME,
        tx_ip_address    VARCHAR(15),
		b_resubmit       CHAR(1) NULL,
		PRIMARY KEY (id_message,id_ss,id_source_sess)
    );

    /**********************************************************************
    ** If Partitioning is not enabled, the value is always one... which is 
    ** what we want.
    ** If partitioning is enabled, we need to update to 
    ** the partition and ensure the svc data is moved to the new partition
    ** so we don't loose the read usage...
    ** AND
    ** Identify Service definition mapping to table
    **********************************************************************/
    SELECT @new_partition = current_id_partition FROM t_archive_queue_partition
    INSERT INTO #ServiceMap (id_svc, table_name)
    SELECT b.id_enum_data id_svc, a.nm_table_name table_name
    FROM t_service_def_log a
    INNER JOIN t_enum_data b on a.nm_service_def = b.nm_enum_data

    /**********************************************************************
    ** Identify messages and the sessions which we must Reconcile
    **********************************************************************/
	IF(dbo.IsSystemPartitioned() = 1)
	BEGIN
		INSERT INTO #tmpReconcileMessageTable
		(
			id_message,
			dt_completed,
			dt_assigned,
			b_root,
			id_ss,
			id_svc,
			id_partition,
			id_source_sess,
			dt_metered,
			tx_ip_address
		)
		SELECT MAX(a.id_message) id_message, MAX(IsNull(a.dt_completed, dbo.mtmaxdate())) dt_completed, MAX(IsNull(a.dt_assigned,dbo.mtmaxdate())) dt_assigned, b.b_root, MAX(b.id_ss), b.id_svc, MAX(c.id_partition), c.id_source_sess, MAX(a.dt_metered), MAX(a.tx_ip_address)
		FROM t_message a WITH(NOLOCK)
			inner join t_session_set b WITH(NOLOCK) on a.id_message = b.id_message
			inner join t_session c WITH(NOLOCK) on b.id_ss = c.id_ss
			left outer join t_uk_acc_usage_tx_uid d WITH(NOLOCK) on c.id_source_sess = d.tx_uid
			left outer join t_session_state e WITH(NOLOCK) on c.id_source_sess = e.id_sess AND e.dt_end = dbo.mtmaxdate() AND e.tx_state IN ('F', 'D')
		where 1=1
		and d.tx_uid IS NULL
		and e.id_sess IS NULL
		and IsNull(a.dt_completed, dbo.MTMaxDate()) >= @WindowBegin
		group by b.b_root, b.id_svc, c.id_source_sess
		order by id_message
	END
	ELSE
	BEGIN
		INSERT INTO #tmpReconcileMessageTable
		(
			id_message,
			dt_completed,
			dt_assigned,
			b_root,
			id_ss,
			id_svc,
			id_partition,
			id_source_sess,
			dt_metered,
			tx_ip_address
		)
		SELECT MAX(a.id_message) id_message, MAX(IsNull(a.dt_completed, dbo.mtmaxdate())) dt_completed, MAX(IsNull(a.dt_assigned,dbo.mtmaxdate())) dt_assigned, b.b_root, MAX(b.id_ss), b.id_svc, MAX(c.id_partition), c.id_source_sess, MAX(a.dt_metered), MAX(a.tx_ip_address)
		FROM t_message a WITH(NOLOCK)
			inner join t_session_set b WITH(NOLOCK) on a.id_message = b.id_message
			inner join t_session c WITH(NOLOCK) on b.id_ss = c.id_ss
			left outer join t_acc_usage d WITH(NOLOCK) on c.id_source_sess = d.tx_uid
			left outer join t_session_state e WITH(NOLOCK) on c.id_source_sess = e.id_sess AND e.dt_end = dbo.mtmaxdate() AND e.tx_state IN ('F', 'D')
		where 1=1
		and d.tx_uid IS NULL
		and e.id_sess IS NULL
		and IsNull(a.dt_completed, dbo.MTMaxDate()) >= @WindowBegin
		group by b.b_root, b.id_svc, c.id_source_sess
		order by id_message

	END

    /**********************************************************************
    ** Delete the non-maximum messages
    **********************************************************************/
	INSERT INTO #tmpReconcileMessageTable2
	(
		id_message,
		dt_completed,
		dt_assigned,
		b_root,
		id_ss,
		id_svc,
		id_partition,
		id_source_sess,
		dt_metered,
		tx_ip_address,
		b_resubmit
	)
    SELECT
    id_message, dt_completed, dt_assigned, b_root, id_ss, id_svc, id_partition, id_source_sess, dt_metered, tx_ip_address, 1
    FROM
    #tmpReconcileMessageTable
	WHERE
	 dt_completed BETWEEN @WindowBegin and @WindowEnd

    SET @s_count = @@RowCount

    /**********************************************************************
    ** Capture the count we expect
    **********************************************************************/

/*	IF (@SafeDate IS NOT NULL)
	BEGIN
		UPDATE #tmpReconcileMessageTable2 set b_resubmit = null where dt_completed < @SafeDate;
	END;
	*/
    IF @s_count = 0
    BEGIN
        BEGIN TRANSACTION
        BEGIN TRY
            INSERT INTO mvm_resubmit_runs (resubmit_date,
                                           dt_started,
                                           dt_completed,
                                           dt_assigned,
                                           range_start_date,
                                           range_end_date,
                                           msg_count,
                                           ss_count,s_count)
            VALUES(@dt_reconcile,@dt_reconcile,@dt_reconcile,@dt_reconcile, @WindowBegin, @WindowEnd, 0, 0, 0);
            COMMIT TRANSACTION;
            select 0 msg_count,  0 ss_count,  0 s_count
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            select -4 msg_count,  -4 ss_count,  -4 s_count
        END CATCH;
        RETURN;
    END
	 
    DECLARE @start_tm DATETIME
    SET @start_tm = dbo.metratime(1,'RAMP')

    /**********************************************************************
    ** Capture the count of new messages
    **********************************************************************/
    INSERT INTO #MessageIdTable    (id_message)
    SELECT DISTINCT id_message FROM #tmpReconcileMessageTable2 group by id_message
    SET @msg_count = @@RowCount

    /**********************************************************************
    ** Isolate the service types to allow us to minimize the number of 
    ** messages that are necessary to create.
    **********************************************************************/
    INSERT INTO #SessionSetMap (id_ss)
    SELECT distinct id_ss FROM #tmpReconcileMessageTable2 group by id_ss
    SET @ss_count = @@ROWCOUNT

    /**********************************************************************
    ** Grab the new ID blocks
    **********************************************************************/
    EXEC GetIdBlock @msg_count, 'id_dbqueuesch', @idMessage OUTPUT;
    EXEC GetIdBlock @ss_count, 'id_dbqueuess', @id_run OUTPUT;
    
    /**********************************************************************
    ** Assign new SS values
    **********************************************************************/
    ;WITH UpdateData  AS
    (
        SELECT id_message, -1 + ROW_NUMBER() OVER (ORDER BY id_message DESC) AS row_num FROM #MessageIdTable
    )
    UPDATE #MessageIdTable SET new_id_message = row_num + @idMessage
    FROM #MessageIdTable m
    INNER JOIN UpdateData ON m.id_message = UpdateData.id_message;

    /**********************************************************************
    ** Assign new SS values
    **********************************************************************/
    ;WITH UpdateData  AS
    (
        SELECT id_ss, -1 + ROW_NUMBER() OVER (ORDER BY id_ss DESC) AS row_num FROM #SessionSetMap
    )
    UPDATE #SessionSetMap SET new_id_ss = row_num + @id_run
    FROM #SessionSetMap ssm
    INNER JOIN UpdateData ON ssm.id_ss = UpdateData.id_ss;

    /**********************************************************************
    ** To avoid using a cursor, we need to do a bit of work to capture the 
    ** count of sessions per session set...
    ** Update Session Count per session from our resubmit table
    **********************************************************************/
    ;WITH UpdateData  AS
    (
        SELECT id_ss, COUNT(id_source_sess) sess_cnt FROM #tmpReconcileMessageTable2 group by id_ss
    )
    UPDATE #SessionSetMap SET sess_cnt = UpdateData.sess_cnt
    FROM #SessionSetMap ssm
    INNER JOIN UpdateData ON ssm.id_ss = UpdateData.id_ss

    /******************
    SELECT * FROM #MessageIdTable
    SELECT * FROM #SessionSetMap
    ******************/

    /**********************************************************************
    ** I DETEST CURSORS, BUT NOW SURE HOW TO DO THIS WELL SINCE I 
    ** NEED TO UPDATE THE TABLE WHICH NAME IS IN A TABLE...
    **********************************************************************/
    DECLARE svc_tbl_cursor CURSOR FOR
    SELECT distinct id_svc
    FROM #tmpReconcileMessageTable2
    GROUP BY id_svc;

    OPEN svc_tbl_cursor

    FETCH NEXT FROM svc_tbl_cursor INTO @id_svc

    BEGIN TRANSACTION
    
        WHILE @@FETCH_STATUS = 0
        BEGIN
            /**************************************************** 
            ** GET THE SERVICE TABLE NAME AND 
            ** UPDATE THE PARTITION FOR THE ENTRIES 
            ** (entries with the correct id_source_sess)
            ****************************************************/
            SELECT @tbl_name = sm.table_name FROM #ServiceMap sm WHERE sm.id_svc = @id_svc

            SET @statement = N'UPDATE ' + @tbl_name + ' SET c__resubmit = 1 FROM ' + @tbl_name + ' tb ' +
                                N'INNER JOIN #tmpReconcileMessageTable2 lst ON lst.id_source_sess = tb.id_source_sess';

            exec sp_executesql  @statement

            FETCH NEXT FROM svc_tbl_cursor INTO @id_svc;
        END
        CLOSE svc_tbl_cursor;
        DEALLOCATE svc_tbl_cursor;

/******
        select * from #tmpReconcileMessageTable2
*******/

        /**********************************************************************
            ** Move the partition for the svc table
            **********************************************************************/
        INSERT INTO t_session (id_ss, id_source_sess, id_partition)
            SELECT
                    ssm.new_id_ss      AS id_ss,
                    rmt.id_source_sess AS id_source_sess,
                    rmt.id_partition   AS id_partition
            FROM #tmpReconcileMessageTable2 rmt
            JOIN #SessionSetMap ssm ON ssm.id_ss = rmt.id_ss
                     
        INSERT INTO t_session_set (id_message, id_ss, id_svc, b_root, session_count, id_partition)
            SELECT distinct
                    mit.new_id_message AS id_message,
                    ssm.new_id_ss      AS id_ss,
                    rmt.id_svc         AS id_svc,
                    rmt.b_root         AS b_root,
                    ssm.sess_cnt       AS session_count,
                    rmt.id_partition   AS id_partition
            FROM #tmpReconcileMessageTable2 rmt
            JOIN #SessionSetMap ssm on ssm.id_ss = rmt.id_ss
            JOIN #MessageIdTable mit on mit.id_message = rmt.id_message
     
         DECLARE @mtr_tm DATETIME
         SET @mtr_tm = dbo.metratime(1,'RAMP')

		;with my_msgs as
		(
		  SELECT DISTINCT id_message, tx_ip_address, id_partition, dt_metered
            FROM #tmpReconcileMessageTable2 rmt
		)
        INSERT INTO t_message (id_message, id_route, dt_crt, dt_metered, dt_assigned, id_listener, id_pipeline, dt_completed, id_feedback, tx_TransactionID, tx_sc_username, tx_sc_password, tx_sc_namespace, tx_sc_serialized, tx_ip_address, id_partition)
            SELECT
            mit.new_id_message    AS id_message,
            NULL                  AS id_route,
            @mtr_tm               AS dt_crt,
            rmt.dt_metered        AS dt_metered,
            NULL                  AS dt_assigned,
            NULL                  AS id_listener,
            NULL                  AS id_pipeline,
            NULL                  AS dt_completed,
            NULL                  AS id_feedback,
            orig.tx_TransactionID AS tx_TransactionID,
            orig.tx_sc_username   AS tx_sc_username,
            orig.tx_sc_password   AS tx_sc_password,
            orig.tx_sc_namespace  AS tx_sc_namespace,
            orig.tx_sc_serialized AS tx_sc_serialized,
            rmt.tx_ip_address     AS tx_ip_address,
            rmt.id_partition      AS id_partition
            FROM my_msgs rmt
            JOIN #MessageIdTable mit on mit.id_message = rmt.id_message
			INNER JOIN t_message orig with(nolock) on orig.id_message = mit.id_message
                                
            DECLARE @dt_complete DATETIME;
            SET @dt_complete = dbo.metratime(1,'RAMP') ;
            INSERT INTO mvm_resubmit_runs (resubmit_date,
                                           dt_started,
                                           dt_completed,
                                           dt_assigned,
                                           range_start_date,
                                           range_end_date,
                                           msg_count,
                                           ss_count,s_count)
            VALUES(@dt_reconcile,@start_tm,@dt_complete,@mtr_tm, @WindowBegin, @WindowEnd, @msg_count, @ss_count, @s_count);

            select @msg_count msg_count,  @ss_count ss_count,  @s_count s_count
            COMMIT TRANSACTION;
    
    DROP TABLE #tmpReconcileMessageTable
    DROP TABLE #tmpReconcileMessageTable2
    DROP TABLE #ServiceMap
    DROP TABLE #SessionSetMap
    DROP TABLE #MessageIdTable
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[UpdateBatchStatus]'
GO
ALTER procedure [dbo].[UpdateBatchStatus]
	@tx_batch VARBINARY(16),
	@tx_batch_encoded varchar(24),
	@n_completed int,
	@sysdate datetime
as
declare @initialStatus char(1)
declare @finalStatus char(1)

BEGIN TRANSACTION
if not exists (select * from t_batch with(updlock) where tx_batch = @tx_batch)
begin
  insert into t_batch (tx_namespace, tx_name, tx_batch, tx_batch_encoded, tx_status, n_completed, n_failed, dt_first, dt_crt)
    values ('pipeline', @tx_batch_encoded, @tx_batch, @tx_batch_encoded, 'A', 0, 0, @sysdate, @sysdate)
end

select @initialStatus = tx_status from t_batch with(updlock) where tx_batch = @tx_batch

update t_batch
  set t_batch.n_completed = t_batch.n_completed + @n_completed,
    -- ESR-4575 MetraControl- failed batches have completed status. Corrected batches have failed status
    -- Added a condition to mark batches with failed transections as Failed
    t_batch.tx_status =
       case when (t_batch.tx_status = 'A' and (t_batch.n_failed > 0))
            then 'F'
            when ((t_batch.n_completed + t_batch.n_failed + ISNULL(t_batch.n_dismissed, 0) + @n_completed) = t_batch.n_expected
                   or
                  (((t_batch.n_completed + t_batch.n_failed + + ISNULL(t_batch.n_dismissed, 0) + @n_completed) = t_batch.n_metered)                      and t_batch.n_expected = 0))
            then 'C'
				    when ((t_batch.n_completed + t_batch.n_failed + ISNULL(t_batch.n_dismissed, 0) + @n_completed) < t_batch.n_expected
                   or
                 (((t_batch.n_completed + t_batch.n_failed + ISNULL(t_batch.n_dismissed, 0) + @n_completed) < t_batch.n_metered)
                    and t_batch.n_expected = 0))
            then 'A'
            when ((t_batch.n_completed + t_batch.n_failed + ISNULL(t_batch.n_dismissed, 0) + @n_completed) > t_batch.n_expected)
                   and t_batch.n_expected > 0
            then 'F'
            else t_batch.tx_status end,
     t_batch.dt_last = @sysdate,
     t_batch.dt_first =
       case when t_batch.n_completed = 0 then @sysdate else t_batch.dt_first end
  where tx_batch = @tx_batch

 IF ( @@ERROR != 0 )

     BEGIN
        ROLLBACK TRANSACTION
     END
         
COMMIT TRANSACTION

  
select @finalStatus = tx_status from t_batch where tx_batch = @tx_batch
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[UpdateResubmitAudit]'
GO
CREATE PROCEDURE [dbo].[UpdateResubmitAudit]
    @dt_reconcile   DATETIME,
    @dt_range_start DATETIME,
    @dt_range_end   DATETIME,
    @msg_count      INT,
    @ss_count       INT,
    @s_count        INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE mvm_resubmit_runs
    SET dt_completed = GETUTCDATE(), dt_assigned  = GETUTCDATE()
    ,msg_count    = @msg_count
    ,ss_count     = @ss_count
    ,s_count      = @s_count
    WHERE  1=1
    AND resubmit_date    = @dt_reconcile
--    AND range_start_date = @dt_range_start
--    AND range_end_date   = @dt_range_end
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[apply_subscriptions_to_acc]'
GO
ALTER PROCEDURE [dbo].[apply_subscriptions_to_acc] (
    @id_acc                     int,
    @id_acc_template            int,
    @next_cycle_after_startdate char, /* Y or N */
    @next_cycle_after_enddate   char, /* Y or N */
    @user_id                    int,
    @id_audit                   int,
    @id_event_success           int,
    @systemdate                 datetime,
    @id_template_session        int,
    @retrycount                 int,
    @detailtypesubs             int,
    @detailresultfailure        int
)
AS
    SET NOCOUNT ON
    DECLARE @v_vt_start        datetime
    DECLARE @v_vt_end          datetime
    DECLARE @v_acc_start       datetime
    DECLARE @v_sub_end         datetime
    DECLARE @curr_id_sub       int
    DECLARE @my_id_audit       int
    DECLARE @my_user_id        int
	DECLARE @id_acc_type       int

    SELECT @my_user_id = ISNULL(@user_id, 1), @my_id_audit = @id_audit
	SELECT @id_acc_type = id_type FROM t_account WHERE id_acc = @id_acc

    IF @my_id_audit IS NULL
    BEGIN
        EXEC getcurrentid 'id_audit', @my_id_audit OUT

        INSERT INTO t_audit
                    (id_audit, id_event, id_userid, id_entitytype, id_entity, dt_crt
                    )
            VALUES (@my_id_audit, @id_event_success, @user_id, 1, @id_acc, getutcdate ()
                    )
    END

    SELECT @v_acc_start = vt_start
    FROM   t_account_state
    WHERE  id_acc = @id_acc
    
    DECLARE @id_po            int
    DECLARE @id_group         int
    DECLARE @vt_start         datetime
    DECLARE @vt_end           datetime
    DECLARE @conflicts        int
    DECLARE @my_sub_start     datetime
    DECLARE @my_sub_end       datetime
    
    DECLARE subs CURSOR LOCAL FOR
		SELECT  id_po,
				id_group,
				dbo.GreatestDate(t1.v_sub_start, @v_acc_start) AS vt_start,
				t1.v_sub_end,
				dbo.GreatestDate(t1.v_sub_start, @v_acc_start) AS v_sub_start,
				t1.v_sub_end
			FROM (
				SELECT
					id_po,
					id_group,
					CASE
						WHEN @next_cycle_after_startdate = 'Y'
						THEN
							(
								SELECT dbo.GreatestDate(DATEADD(s, 1, tpc.dt_end), tvs.po_start)
									FROM   t_pc_interval tpc
									INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
									WHERE  tauc.id_acc = @id_acc
									AND tvs.sub_start BETWEEN tpc.dt_start AND tpc.dt_end
							)
						ELSE tvs.sub_start
					END AS v_sub_start,
					CASE
						WHEN @next_cycle_after_enddate = 'Y'
						THEN
							(
								SELECT dbo.LeastDate(dbo.LeastDate(DATEADD(s, 1, tpc.dt_end), dbo.MTMaxDate()), tvs.po_end)
									FROM   t_pc_interval tpc
									INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
									WHERE  tauc.id_acc = @id_acc
									AND tvs.sub_end BETWEEN tpc.dt_start AND tpc.dt_end
							)
						ELSE tvs.sub_end
					END AS v_sub_end
					FROM #t_acc_template_valid_subs tvs
			) t1
--            WHERE tvs.id_acc_template_session = apply_subscriptions_to_acc.id_template_session


    --  SELECT ts.id_po,
    --         ts.id_group,
    --         dbo.GreatestDate(dbo.LeastDate(MIN(s.vt_start), MIN(gm.vt_start)), @v_acc_start) AS vt_start,
    --         dbo.GreatestDate(MAX(s.vt_end), MAX(gm.vt_end)) AS vt_end,
    --         SUM(CASE WHEN s.id_sub IS NULL THEN 0 ELSE 1 END) + SUM(CASE WHEN gm.id_group IS NULL THEN 0 ELSE 1 END) conflicts,
    --         vs.v_sub_start AS my_sub_start,
    --         vs.v_sub_end AS my_sub_end
    --  FROM   t_acc_template_subs ts
    --         JOIN (
    --                SELECT id_po,
    --                       id_group,
    --                        CASE
    --                           WHEN @next_cycle_after_startdate = 'Y'
    --                           THEN
    --                               (
    --                                 SELECT dbo.GreatestDate(DATEADD(s, 1, tpc.dt_end), tvs.po_start)
    --                                 FROM   t_pc_interval tpc
    --                                        INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
    --                                 WHERE  tauc.id_acc = @id_acc
    --                                    AND tvs.sub_start BETWEEN tpc.dt_start AND tpc.dt_end
    --                               )
    --                           ELSE tvs.sub_start
    --                       END AS v_sub_start,
    --                       CASE
    --                           WHEN @next_cycle_after_enddate = 'Y'
    --                           THEN
    --                               (
    --                                 SELECT dbo.LeastDate(dbo.LeastDate(DATEADD(s, 1, tpc.dt_end), dbo.MTMaxDate()), tvs.po_end)
    --                                 FROM   t_pc_interval tpc
    --                                        INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
    --                                 WHERE  tauc.id_acc = @id_acc
    --                                    AND tvs.sub_end BETWEEN tpc.dt_start AND tpc.dt_end
    --                               )
    --                           ELSE tvs.sub_end
    --                       END AS v_sub_end

    --                FROM   #t_acc_template_valid_subs tvs
    --         ) vs ON vs.id_po = ts.id_po OR vs.id_group = ts.id_group
    --         LEFT JOIN t_sub gs ON gs.id_group = ts.id_group
    --         LEFT JOIN t_sub s
    --          ON     s.id_acc = @id_acc
    --             AND s.vt_start <= vs.v_sub_end
    --             AND s.vt_end >= vs.v_sub_start
    --             AND EXISTS (SELECT 1
    --                         FROM   t_pl_map mpo
    --                                JOIN t_pl_map ms ON mpo.id_pi_template = ms.id_pi_template
    --                         WHERE  mpo.id_po = ISNULL(ts.id_po, gs.id_po) AND ms.id_po = s.id_po)
    --         LEFT JOIN t_gsubmember gm
    --          ON     gm.id_acc = @id_acc
    --             AND gm.vt_start <= vs.v_sub_end
    --             AND gm.vt_end >= vs.v_sub_start
    --             AND EXISTS (SELECT 1
    --                         FROM   t_sub ags
    --                                JOIN t_pl_map ms ON ms.id_po = ags.id_po
    --                                JOIN t_pl_map mpo ON mpo.id_pi_template = ms.id_pi_template
    --                         WHERE  ags.id_group = gm.id_group AND mpo.id_po = ISNULL(ts.id_po, gs.id_po))
    --  WHERE  ts.id_acc_template = @id_acc_template
	   --  /* Check if the PO is available for the account's type */
	   --  AND (  (ts.id_po IS NOT NULL AND
		  --        (  EXISTS
		  --           (
				--        SELECT 1
				--	    FROM   t_po_account_type_map atm
				--	    WHERE  atm.id_po = ts.id_po AND atm.id_account_type = @id_acc_type
				--     )
				--  OR NOT EXISTS
				--     (
				--	     SELECT 1 FROM t_po_account_type_map atm WHERE atm.id_po = ts.id_po
				--	 )
				-- )
				--)
		  --   OR (ts.id_group IS NOT NULL AND
			 --     (  EXISTS
			 --        (
				--        SELECT 1
				--	    FROM   t_po_account_type_map atm
				--	           JOIN t_sub tgs ON tgs.id_po = atm.id_po
				--	    WHERE  tgs.id_group = ts.id_group AND atm.id_account_type = @id_acc_type
				--     )
				-- OR NOT EXISTS
				--     (
				--		SELECT 1
				--	    FROM   t_po_account_type_map atm
				--	           JOIN t_sub tgs ON tgs.id_po = atm.id_po
				--	    WHERE  tgs.id_group = ts.id_group
				--	 )
				--  )
				--)
		  --   )
    --  GROUP BY ts.id_po, ts.id_group, vs.v_sub_start, vs.v_sub_end
	DECLARE @v_prev_end DATETIME
	DECLARE @c_vt_start DATETIME
	DECLARE @c_vt_end DATETIME
    
    OPEN subs
    FETCH NEXT FROM subs INTO @id_po, @id_group, @vt_start, @vt_end, @my_sub_start, @my_sub_end

    /* Create new subscriptions */
    WHILE @@FETCH_STATUS = 0
    BEGIN
		SET @v_prev_end = DATEADD(d, -1, @my_sub_start)
		IF @id_group IS NULL
		BEGIN
			DECLARE csubs CURSOR FOR
				SELECT s.vt_start, s.vt_end
					FROM (
						SELECT ts.vt_start
								,ts.vt_end
							FROM t_sub ts
							WHERE ts.vt_end >= @my_sub_start
								AND ts.vt_start <= @my_sub_end
								AND ts.id_acc = @id_acc
								AND ts.id_po = @id_po
						UNION ALL
						SELECT ts1.vt_start
								,ts1.vt_end
							FROM #tmp_sub ts1
							WHERE ts1.vt_end >= @my_sub_start
								AND ts1.vt_start <= @my_sub_end
								AND ts1.id_acc = @id_acc
								AND ts1.id_po = @id_po
					) s
					ORDER BY s.vt_start
		END ELSE BEGIN
			DECLARE csubs CURSOR FOR
				SELECT s.vt_start, s.vt_end
					FROM (
						SELECT ts.vt_start
								,ts.vt_end
							FROM t_gsubmember ts
							WHERE ts.vt_end >= @my_sub_start
								AND ts.vt_start <= @my_sub_end
								AND ts.id_acc = @id_acc
								AND ts.id_group = @id_group
						UNION ALL
						SELECT ts1.vt_start
								,ts1.vt_end
							FROM #tmp_gsubmember ts1
							WHERE ts1.vt_end >= @my_sub_start
								AND ts1.vt_start <= @my_sub_end
								AND ts1.id_acc = @id_acc
								AND ts1.id_group = @id_group
					) s
					ORDER BY s.vt_start
		END

		OPEN csubs
		FETCH NEXT FROM csubs INTO @c_vt_start, @c_vt_end

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @c_vt_start > @v_prev_end
			BEGIN
				SET @v_vt_start = DATEADD(d, 1, @v_prev_end)
				SET @v_vt_end = DATEADD(d, -1, @c_vt_start)
			END
			IF @v_vt_start <= @v_vt_end
			BEGIN
				EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
			END
			SET @v_prev_end = @c_vt_end

			FETCH NEXT FROM csubs INTO @c_vt_start, @c_vt_end
		END
		CLOSE csubs
		DEALLOCATE csubs
		IF @v_prev_end < @my_sub_end
		BEGIN
			SET @v_vt_start = DATEADD(d,1,@v_prev_end)
			SET @v_vt_end = @my_sub_end
				EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
		END

        --/* 1.  There is no conflicting subscription */
        --IF @conflicts = 0
        --BEGIN
        --    SELECT @v_vt_start = @my_sub_start, @v_vt_end = @my_sub_end
            
        --    EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
        --END
        --/* 2.  There is a conflicting subscription for the same or greatest interval */
        --ELSE IF @my_sub_start >= @vt_start AND @my_sub_end <= @vt_end
        --BEGIN
        --    INSERT INTO t_acc_template_session_detail
        --        (
        --            id_session,
        --            n_detail_type,
        --            n_result,
        --            dt_detail,
        --            nm_text,
        --            n_retry_count
        --        )
        --    VALUES
        --        (
        --            @id_template_session,
        --            @detailtypesubs,
        --            @detailresultfailure,
        --            getdate(),
        --            N'Subscription for account ' + CAST(@id_acc AS nvarchar(10)) + N' not created due to ' + CAST(@conflicts AS nvarchar(10)) + N'conflict' + CASE WHEN @conflicts > 1 THEN 's' ELSE '' END,
        --            @retrycount
        --        )
        --END
        --/* 3.  There is a conflicting subscription for an early period */
        --ELSE IF @my_sub_start >= @vt_start AND @my_sub_end > @vt_end
        --BEGIN
        --    SELECT @v_vt_start = DATEADD(d, 1, @vt_end), @v_vt_end = @my_sub_end
            
        --    EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
        --END
        --/* 4.  There is a conflicting subscription for a late period */
        --ELSE IF @my_sub_start < @vt_start AND @my_sub_end <= @vt_end
        --BEGIN
        --    SELECT @v_vt_start = @my_sub_start, @v_vt_end = DATEADD(d, -1, @vt_start)
            
        --    EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
        --END
        --/* 5.  There is a conflicting subscription for the period inside the indicated one */
        --ELSE
        --BEGIN
        --    SELECT @v_vt_start = DATEADD(d, 1, @vt_end), @v_vt_end = @my_sub_end
            
        --    EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate

        --    SELECT @v_vt_start = @my_sub_start, @v_vt_end = DATEADD(d, -1, @vt_start)
            
        --    EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
        --END

        FETCH NEXT FROM subs INTO @id_po, @id_group, @vt_start, @vt_end, @my_sub_start, @my_sub_end
    END

    CLOSE subs
    DEALLOCATE subs
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[amp_sorted_decisions]'
GO
ALTER view dbo.amp_sorted_decisions
        as
        SELECT
        a.c_Name as c_decisionName,
        a.c_Description as c_decisionDescription,
        a.c_TableName as c_parameterTable,
        ISNULL(tbp.nm_display_name, ISNULL(tbp.nm_name, a.c_TableName)) AS c_paramTableDisplayName,
        a.c_DecisionType_Id as c_decisionUniqueId,
        b1.c_DefaultValue as c_isActive,
        b2.c_DefaultValue as c_accountQualGroup,
        ISNULL(b3.c_ColumnName, b3.c_DefaultValue) as c_pvToAmountChainMapping,
        b4.c_DefaultValue as c_usageQualGroup,
        CAST ( b5.c_DefaultValue AS bigint) as c_priorityValue
        FROM t_amp_decisiontype a
        INNER JOIN t_rulesetdefinition tr ON tr.nm_instance_tablename = a.c_TableName
        INNER JOIN t_base_props tbp ON tbp.id_prop = tr.id_paramtable
        JOIN t_amp_decisionattrib b1 ON
        a.c_DecisionType_id=b1.c_DecisionType_Id and b1.c_AttributeName='Is Active'
        JOIN t_amp_decisionattrib b2 ON
        a.c_DecisionType_id=b2.c_DecisionType_Id and b2.c_AttributeName='Account Qualification Group'
        JOIN t_amp_decisionattrib b3 ON
        a.c_DecisionType_id=b3.c_DecisionType_Id and b3.c_AttributeName='Product View To Amount Chain Mapping'
        JOIN t_amp_decisionattrib b4 ON
        a.c_DecisionType_id=b4.c_DecisionType_Id and b4.c_AttributeName='Usage Qualification Group'
        JOIN t_amp_decisionattrib b5 ON
        a.c_DecisionType_id=b5.c_DecisionType_Id and b5.c_AttributeName='Tier Priority'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[mvm_scheduled_tasks]'
GO
ALTER TABLE [dbo].[mvm_scheduled_tasks] ADD
[is_scheduled] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mvm_error_msg] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [pk_mvm_scheduled_tasks] on [dbo].[mvm_scheduled_tasks]'
GO
ALTER TABLE [dbo].[mvm_scheduled_tasks] ADD CONSTRAINT [pk_mvm_scheduled_tasks] PRIMARY KEY CLUSTERED  ([mvm_task_guid])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [mvm_scheduled_tasks_ndx1] on [dbo].[mvm_scheduled_tasks]'
GO
CREATE NONCLUSTERED INDEX [mvm_scheduled_tasks_ndx1] ON [dbo].[mvm_scheduled_tasks] ([mvm_scheduled_dt], [is_scheduled], [mvm_logical_cluster])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [mvm_scheduled_tasks_ndx2] on [dbo].[mvm_scheduled_tasks]'
GO
CREATE NONCLUSTERED INDEX [mvm_scheduled_tasks_ndx2] ON [dbo].[mvm_scheduled_tasks] ([mvm_poll_guid])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[t_tax_run]'
GO
ALTER TABLE [dbo].[t_tax_run] ADD
[is_audited] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__t_tax_run__is_au__442B18F2] DEFAULT ('Y')
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [idx_tax_run1] on [dbo].[t_tax_run]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_tax_run1] ON [dbo].[t_tax_run] ([id_vendor], [id_usage_interval], [id_billgroup], [dt_start], [dt_end], [is_audited])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[NotificationEndpoint]'
GO
CREATE TABLE [dbo].[NotificationEndpoint]
(
[EntityId] [uniqueidentifier] NOT NULL,
[ExternalId] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreationDate] [datetime] NOT NULL,
[ModifiedDate] [datetime] NOT NULL,
[Active] [bit] NOT NULL,
[EndpointConfiguration] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AuthenticationConfiguration] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_NotificationEndpoint] on [dbo].[NotificationEndpoint]'
GO
ALTER TABLE [dbo].[NotificationEndpoint] ADD CONSTRAINT [PK_NotificationEndpoint] PRIMARY KEY CLUSTERED  ([EntityId])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[NotificationConfiguration]'
GO
CREATE TABLE [dbo].[NotificationConfiguration]
(
[EntityId] [uniqueidentifier] NOT NULL,
[ExternalId] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreationDate] [datetime] NOT NULL,
[ModifiedDate] [datetime] NOT NULL,
[EventType] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Criteria] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NotificationEndpointEntityId] [uniqueidentifier] NOT NULL,
[MessageTemplate] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_NotificationConfiguration] on [dbo].[NotificationConfiguration]'
GO
ALTER TABLE [dbo].[NotificationConfiguration] ADD CONSTRAINT [PK_NotificationConfiguration] PRIMARY KEY CLUSTERED  ([EntityId])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[CheckEBCRCycleTypeCompatible]'
GO
CREATE FUNCTION [dbo].[CheckEBCRCycleTypeCompatible]
  (@EBCRCycleType INT, @OtherCycleType INT)
RETURNS INT
BEGIN
  -- checks weekly based cycle types
  IF (((@EBCRCycleType = 4) OR (@EBCRCycleType = 5)) AND
      ((@OtherCycleType = 4) OR (@OtherCycleType = 5)))
    RETURN 1   -- success

  -- checks monthly based cycle types
  IF ((@EBCRCycleType in (1,7,8,9)) AND
      (@OtherCycleType  in (1,7,8,9)))
    RETURN 1   -- success

  RETURN 0     -- failure
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[agg_decision_audit_trail]'
GO
ALTER TABLE [dbo].[agg_decision_audit_trail] ALTER COLUMN [start_date] [datetime] NULL
ALTER TABLE [dbo].[agg_decision_audit_trail] ALTER COLUMN [end_date] [datetime] NOT NULL
ALTER TABLE [dbo].[agg_decision_audit_trail] ALTER COLUMN [finalization_date] [datetime] NULL
ALTER TABLE [dbo].[agg_decision_audit_trail] ALTER COLUMN [expiration_date] [datetime] NULL
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [agg_dec_audit_trail_pk] on [dbo].[agg_decision_audit_trail]'
GO
ALTER TABLE [dbo].[agg_decision_audit_trail] ADD CONSTRAINT [agg_dec_audit_trail_pk] PRIMARY KEY CLUSTERED  ([decision_unique_id], [id_usage_interval], [end_date])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [agg_dec_audit_ndx] on [dbo].[agg_decision_audit_trail]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [agg_dec_audit_ndx] ON [dbo].[agg_decision_audit_trail] ([id_acc], [id_usage_interval], [decision_unique_id], [end_date])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[agg_bundle_old_pos]'
GO
CREATE TABLE [dbo].[agg_bundle_old_pos]
(
[id_po] [int] NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [agg_bundle_old_pos_ndx] on [dbo].[agg_bundle_old_pos]'
GO
CREATE NONCLUSTERED INDEX [agg_bundle_old_pos_ndx] ON [dbo].[agg_bundle_old_pos] ([id_po])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[agg_bundle_new_pos]'
GO
CREATE TABLE [dbo].[agg_bundle_new_pos]
(
[id_po] [int] NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [agg_bundle_new_pos_ndx] on [dbo].[agg_bundle_new_pos]'
GO
CREATE NONCLUSTERED INDEX [agg_bundle_new_pos_ndx] ON [dbo].[agg_bundle_new_pos] ([id_po])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[Metadata]'
GO
CREATE TABLE [dbo].[Metadata]
(
[timecreate] [datetime] NOT NULL,
[content] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_Metadata] on [dbo].[Metadata]'
GO
ALTER TABLE [dbo].[Metadata] ADD CONSTRAINT [PK_Metadata] PRIMARY KEY CLUSTERED  ([timecreate] DESC)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[QuoteIndividualPrice]'
GO
CREATE TABLE [dbo].[QuoteIndividualPrice]
(
[Id] [uniqueidentifier] NOT NULL,
[QuoteId] [int] NOT NULL,
[CurrentChargeType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProductOfferingId] [int] NOT NULL,
[PriceableItemId] [int] NULL,
[ChargesRates] [xml] NOT NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK__QuoteInd__3214EC07AB382B63] on [dbo].[QuoteIndividualPrice]'
GO
ALTER TABLE [dbo].[QuoteIndividualPrice] ADD PRIMARY KEY CLUSTERED  ([Id])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[mvm_cluster_history]'
GO
CREATE TABLE [dbo].[mvm_cluster_history]
(
[physical_cluster] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dt_started] [date] NOT NULL,
[dt_stopped] [date] NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[mvm_cluster_run_history]'
GO
CREATE TABLE [dbo].[mvm_cluster_run_history]
(
[physical_cluster] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dt_started] [datetime] NOT NULL,
[dt_stopped] [datetime] NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [mvm_cluster_run_history_pk] on [dbo].[mvm_cluster_run_history]'
GO
ALTER TABLE [dbo].[mvm_cluster_run_history] ADD CONSTRAINT [mvm_cluster_run_history_pk] PRIMARY KEY CLUSTERED  ([physical_cluster], [dt_started])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Rebuilding [dbo].[agg_decision_rollover]'
GO
CREATE TABLE [dbo].[tmp_rg_xx_agg_decision_rollover]
(
[id_acc] [int] NOT NULL,
[id_usage_interval] [int] NOT NULL,
[interval_start] [int] NULL,
[interval_end] [int] NULL,
[decision_unique_id] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[start_date] [datetime] NULL,
[end_date] [datetime] NOT NULL,
[rollover_end_date] [datetime] NULL,
[rollover_interval_end] [int] NULL,
[rolled_over_units] [numeric] (18, 6) NULL,
[expired_units] [numeric] (18, 6) NULL,
[rollover_date] [datetime] NULL,
[rollover_action] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Copy data from agg_decision_rollover to tmp_rg_xx_agg_decision_rollover table'
GO
INSERT INTO [dbo].[tmp_rg_xx_agg_decision_rollover]([id_acc], [id_usage_interval], [interval_start], [interval_end], [decision_unique_id], [start_date], [end_date], [rollover_end_date], [rollover_interval_end], [rolled_over_units], [expired_units], [rollover_date], [rollover_action]) SELECT [id_acc], [id_usage_interval], [interval_start], [interval_end], [decision_unique_id], [start_date], [end_date], [rollover_end_date], [rollover_interval_end], [rolled_over_units], [expired_units], [rollover_date], 'rollover' FROM [dbo].[agg_decision_rollover]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Drop old agg_decision_rollover table'
GO
DROP TABLE [dbo].[agg_decision_rollover]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Rename temp table tmp_rg_xx_agg_decision_rollover to agg_decision_rollover table'
GO
EXEC sp_rename N'[dbo].[tmp_rg_xx_agg_decision_rollover]', N'agg_decision_rollover'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [agg_dec_rollover_pk] on [dbo].[agg_decision_rollover]'
GO
ALTER TABLE [dbo].[agg_decision_rollover] ADD CONSTRAINT [agg_dec_rollover_pk] PRIMARY KEY CLUSTERED  ([id_acc], [id_usage_interval], [end_date], [decision_unique_id], [rollover_action])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Rebuilding [dbo].[mvm_change_tracking_status]'
GO
CREATE TABLE [dbo].[tmp_rg_xx_mvm_change_tracking_status]
(
[logical_cluster_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[table_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_transaction_id] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_transaction_date] [datetime] NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
INSERT INTO [dbo].[tmp_rg_xx_mvm_change_tracking_status]([logical_cluster_name], [table_name], [last_transaction_id], [last_transaction_date]) SELECT [logical_cluster_name], '_NONE_', [last_transaction_id], [last_transaction_date] FROM [dbo].[mvm_change_tracking_status]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
DROP TABLE [dbo].[mvm_change_tracking_status]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_rename N'[dbo].[tmp_rg_xx_mvm_change_tracking_status]', N'mvm_change_tracking_status'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [mvm_change_tracking_status_pk] on [dbo].[mvm_change_tracking_status]'
GO
ALTER TABLE [dbo].[mvm_change_tracking_status] ADD CONSTRAINT [mvm_change_tracking_status_pk] PRIMARY KEY CLUSTERED  ([logical_cluster_name], [table_name])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[CreateReportingDB]'
GO
ALTER procedure [dbo].[CreateReportingDB] (
                    @strDBName nvarchar(100),
                    @strNetmeterDBName nvarchar(100),
                    @strDataLogFilePath nvarchar(255),
                    @dbSize integer,
					@return_code integer output
                   )
as
  set @return_code = 0
  declare @strDataFileName    nvarchar(255);
  declare @strLogFileName     nvarchar(255);
  declare @strDBCreateQuery   nvarchar(2000);
  declare @strAddDbToBackupQuery nvarchar(2000);
  declare @strProcess         nvarchar(100)
  declare @nSQLRetCode        INT

  declare @bDebug tinyint
  set @bDebug = 1

  declare @strsize nvarchar(5);
  set @strsize = CAST(@dbSize AS nvarchar(5))
  set  @strDataFileName = @strDataLogFilePath + '\' + @strDBName + '_Data';
  set  @strLogFileName =  @strDataLogFilePath + '\' + @strDBName + '_Log';


  set @strDBCreateQuery = 'if not exists(select * from sys.databases where name = N''' + @strDBName + ''')
    CREATE DATABASE [' + @strDBName + ']  ON
                           (
                                    NAME = N''' + @strDBName + '_Data' + ''',
                                FILENAME = N''' + @strDataFileName + '.MDF' + ''' ,
                                    SIZE = ' + @strsize + ',
                              FILEGROWTH = 20%
                            )
                            LOG ON
                            (
                                    NAME = N''' + @strDBName + '_Log' + ''',
                                FILENAME = N''' + @strLogFileName + '.LDF' + ''' ,
                                    SIZE = ' + @strsize + ',
                              FILEGROWTH = 10%
                            )'
  set @strAddDbToBackupQuery = 'insert into ' + @strNetmeterDBName + '..t_ReportingDBLog(NameOfReportingDB, doBackup)
							    Values(''' + @strDBName + ''', ''Y'')';

  if ( @bDebug = 1 )
      print 'About to execute create DB Query : ' + @strDBCreateQuery;

  exec sp_executesql @strDBCreateQuery
  select @nSQLRetCode = @@ERROR
  if ( @nSQLRetCode <> 0 )
  begin
    set @strProcess = object_name(@@procid)
    print 'An error occured while creating the database. Procedure (' + @strProcess + ')';
    set @return_code = -1
    return -1
  end
  -- set the simple log option for database.
  SET @strDBCreateQuery = 'Alter Database ' + @strDBName + ' SET RECOVERY SIMPLE';
  exec sp_executesql @strDBCreateQuery
  select @nSQLRetCode = @@ERROR
  if ( @nSQLRetCode <> 0 )
  begin
    set @strProcess = object_name(@@procid)
    print 'An error occured while setting the recovery option to Bulk-Logged to the created database. Procedure (' + @strProcess + ')';
    set @return_code = -1
    return -1
  end

  if ( @bDebug = 1 )
      print 'About to execute add DB to backup table Query : ' + @strAddDBToBackupQuery;

  exec sp_executesql @strAddDBToBackupQuery
  BEGIN TRY
    exec sp_executesql @strAddDBToBackupQuery
  END TRY
  BEGIN CATCH
   	  declare
   	       @ErrorMessage varchar(2048),
   	       @ErrorSeverity INT
   	  select
   	       @ErrorMessage = ERROR_MESSAGE(),
   	       @ErrorSeverity = ERROR_SEVERITY()
   	  if (patindex('%pk_t_ReportingDBLog%', @ErrorMessage) > 0)
   	    BEGIN
   	         PRINT @ErrorMessage
   	      set @return_code = 0
   	      SET @nSQLRetCode = 0
   	    end
   	  ELSE
        begin
          SET @nSQLRetCode = ERROR_NUMBER()
   	      raiserror(@ErrorMessage, @ErrorSeverity, 1)
 	    end
  END CATCH
  -- select @nSQLRetCode = @@ERROR
  if ( @nSQLRetCode <> 0 )
  begin
    set @strProcess = object_name(@@procid)
    print 'An error occured while adding database to t_ReportingDBLog table. Procedure (' + @strProcess + ')';
    set @return_code = -1
    return -1
  end

  return 0
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [dbo].[NotificationConfiguration]'
GO
ALTER TABLE [dbo].[NotificationConfiguration] ADD CONSTRAINT [FK_NotificationConfiguration_NotificationEndpoint_NotificationEndpointEntityId] FOREIGN KEY ([NotificationEndpointEntityId]) REFERENCES [dbo].[NotificationEndpoint] ([EntityId])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering trigger [dbo].[trig_update_recur_window_on_t_gsub_recur_map] on [dbo].[t_gsub_recur_map]'
GO
ALTER trigger dbo.trig_update_recur_window_on_t_gsub_recur_map
ON dbo.t_gsub_recur_map
for insert, UPDATE, delete
as
begin
declare @temp datetime;

delete from t_recur_window where exists (
    select 1 from deleted gsrm
      join t_sub sub on gsrm.id_group = sub.id_group
	  join t_pl_map plm on sub.id_po = plm.id_po
		  and t_recur_window.c__PriceableItemInstanceID = plm.id_pi_instance and t_recur_window.c__PriceableItemTemplateID = plm.id_pi_template
         and t_recur_window.c__SubscriptionID = sub.id_sub
         and t_recur_window.c__AccountID = gsrm.id_acc
		  and t_recur_window.c__PriceableItemInstanceID = gsrm.id_prop);

  MERGE into t_recur_window USING (
    select distinct sub.id_sub, gsrm.id_acc, gsrm.vt_start, gsrm.vt_end
      FROM
       INSERTED gsrm inner join t_recur_window trw on
         trw.c__AccountID = gsrm.id_acc
         inner join t_sub sub on sub.id_group = gsrm.id_group
            and trw.c__SubscriptionID = sub.id_sub) AS source
     ON (t_recur_window.c__SubscriptionID = source.id_sub
       and t_recur_window.c__AccountID = source.id_acc)
   WHEN matched AND t_recur_window.c__AccountID = source.id_acc THEN
	UPDATE SET c_MembershipStart = source.vt_start,
	           c_MembershipEnd = source.vt_end;
			   
	select @temp = tt_start from inserted
	           
 SELECT
       sub.vt_start AS c_CycleEffectiveDate
      ,sub.vt_start AS c_CycleEffectiveStart
      ,sub.vt_end AS c_CycleEffectiveEnd
      ,sub.vt_start          AS c_SubscriptionStart
      ,sub.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , @temp as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , grm.vt_start AS c_MembershipStart
      , grm.vt_end AS c_MembershipEnd
	  , dbo.AllowInitialArrersCharge(rcr.b_advance, sub.id_acc, sub.vt_end, sub.dt_crt) AS c__IsAllowGenChargeByTrigger
	  into #recur_window_holder
FROM inserted grm
      /* TODO: GRM dates or sub dates or both for filtering */
      INNER JOIN t_sub sub ON grm.id_group = sub.id_group
      INNER JOIN t_payment_redirection pay ON pay.id_payee = grm.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL and plm.id_sub is null and plm.id_pi_instance = grm.id_prop
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub
        AND rv.tt_end = dbo.MTMaxDate()
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
      WHERE
		not EXISTS
	        (SELECT 1 FROM T_RECUR_WINDOW where c__AccountID = grm.id_acc
	          	AND c__SubscriptionID = sub.id_sub
				AND c__priceableiteminstanceid = grm.id_prop
				AND c__priceableitemtemplateid = plm.id_pi_template
			)
	      AND grm.tt_end = dbo.mtmaxdate()
	      AND rcr.b_charge_per_participant = 'N'
	      AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL);
      
    
	/* adds charges to METER tables */
	EXEC MeterInitialFromRecurWindow @currentDate = @temp;
    EXEC MeterCreditFromRecurWindow @currentDate = @temp;
	 
	INSERT INTO t_recur_window
	SELECT c_CycleEffectiveDate,
	c_CycleEffectiveStart,
	c_CycleEffectiveEnd,
	c_SubscriptionStart,
	c_SubscriptionEnd,
	c_Advance,
	c__AccountID,
	c__PayingAccount,
	c__PriceableItemInstanceID,
	c__PriceableItemTemplateID,
	c__ProductOfferingID,
	c_PayerStart,
	c_PayerEnd,
	c__SubscriptionID,
	c_UnitValueStart,
	c_UnitValueEnd,
	c_UnitValue,
	c_BilledThroughDate,
	c_LastIdRun,
	c_MembershipStart,
	c_MembershipEnd
	FROM #recur_window_holder;
	
/* step 2) update the cycle effective windows */
UPDATE t_recur_window
 SET c_CycleEffectiveEnd =
 (
  SELECT MIN(IsNull(c_CycleEffectiveDate,c_SubscriptionEnd)) FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId AND t_recur_window.c_PayerStart = w2.c_PayerStart
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd
    AND t_recur_window.c_membershipstart = w2.c_membershipstart
    AND t_recur_window.c_membershipend = w2.c_membershipend
    AND t_recur_window.c__accountid = w2.c__accountid
    AND t_recur_window.c__payingaccount = w2.c__payingaccount
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate
 )
 WHERE 1=1
 AND EXISTS
(SELECT 1 FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId
    AND t_recur_window.c_PayerStart = w2.c_PayerStart
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd
    AND t_recur_window.c_membershipstart = w2.c_membershipstart
    AND t_recur_window.c_membershipend = w2.c_membershipend
    AND t_recur_window.c__accountid = w2.c__accountid
    AND t_recur_window.c__payingaccount = w2.c__payingaccount
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate)
;
END;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering trigger [dbo].[trig_update_t_recur_window_with_t_payment_redirection] on [dbo].[t_payment_redirection]'
GO
ALTER trigger [dbo].[trig_update_t_recur_window_with_t_payment_redirection]
ON [dbo].[t_payment_redirection]
/* We don't want to trigger on delete, because the insert comes right after a delete, and we can get the info that was deleted
  from payment_redir_history*/
for insert
as
begin
--Grab everything that was changed
--Get the old vt_start and vt_end for payees that have changed
select distinct redirold.id_payer, redirold.id_payee, redirold.vt_start, redirold.vt_end
  into #tmp_redir from inserted
  inner loop join t_payment_redir_history redirnew on redirnew.id_payee = inserted.id_payee
       and redirnew.tt_end = dbo.MTMaxDate()
  inner loop join t_payment_redir_history redirold on redirnew.id_payee = redirold.id_payee
       and redirold.tt_end  = dbo.subtractSecond(redirnew.tt_start);
    
--Get the old windows for payees that have changed
select *  into #tmp_oldrw from t_recur_window trw JOIN #tmp_redir ON trw.c__AccountID = #tmp_redir.id_payee
  AND trw.c_PayerStart = #tmp_redir.vt_start AND trw.c_PayerEnd = #tmp_redir.vt_end;
 
DECLARE @currentDate DATETIME
SET @currentDate = dbo.metratime(1,'RC');
 
SELECT orw.c_CycleEffectiveDate
       ,orw.c_CycleEffectiveStart
       ,orw.c_CycleEffectiveEnd
       ,orw.c_SubscriptionStart
       ,orw.c_SubscriptionEnd
       ,orw.c_Advance
       ,orw.c__AccountID
       ,INSERTED.id_payer AS c__PayingAccount
       ,orw.c__PriceableItemInstanceID
       ,orw.c__PriceableItemTemplateID
       ,orw.c__ProductOfferingID
       ,inserted.vt_start as c_PayerStart
       ,INSERTED.vt_end AS c_PayerEnd
       ,orw.c__SubscriptionID
       ,orw.c_UnitValueStart
       ,orw.c_UnitValueEnd
       ,orw.c_UnitValue
       ,orw.c_BilledThroughDate
       ,orw.c_LastIdRun
       ,orw.c_MembershipStart
       ,orw.c_MembershipEnd
	   , dbo.AllowInitialArrersCharge(orw.c_Advance, orw.c__AccountID, orw.c_SubscriptionEnd, @currentDate) AS c__IsAllowGenChargeByTrigger

        INTO #tmp_newrw FROM #tmp_oldrw orw JOIN INSERTED ON orw.c__AccountId = INSERTED.id_payee;

exec MeterPayerChangesFromRecurWindow @currentDate;

delete FROM t_recur_window WHERE EXISTS (SELECT 1 FROM
 #tmp_oldrw orw where
   t_recur_window.c__PayingAccount = orw.c__PayingAccount
       and t_recur_window.c__ProductOfferingID = orw.c__ProductOfferingID
       and t_recur_window.c_PayerStart = orw.c_PayerStart
       and t_recur_window.c_PayerEnd = orw.c_PayerEnd
       and t_recur_window.c__SubscriptionID = orw.c__SubscriptionID
);
  
INSERT INTO t_recur_window
	SELECT DISTINCT c_CycleEffectiveDate,
	c_CycleEffectiveStart,
	c_CycleEffectiveEnd,
	c_SubscriptionStart,
	c_SubscriptionEnd,
	c_Advance,
	c__AccountID,
	c__PayingAccount,
	c__PriceableItemInstanceID,
	c__PriceableItemTemplateID,
	c__ProductOfferingID,
	c_PayerStart,
	c_PayerEnd,
	c__SubscriptionID,
	c_UnitValueStart,
	c_UnitValueEnd,
	c_UnitValue,
	c_BilledThroughDate,
	c_LastIdRun,
	c_MembershipStart,
	c_MembershipEnd
	FROM #tmp_newrw;


UPDATE t_recur_window
SET c_CycleEffectiveEnd =
 (
  SELECT MIN(IsNull(c_CycleEffectiveDate,c_SubscriptionEnd)) FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId AND t_recur_window.c_PayerStart = w2.c_PayerStart
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd
    AND t_recur_window.c_membershipstart = w2.c_membershipstart
    AND t_recur_window.c_membershipend = w2.c_membershipend
    AND t_recur_window.c__accountid = w2.c__accountid
    AND t_recur_window.c__payingaccount = w2.c__payingaccount
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate
)
WHERE 1=1
AND c__PayingAccount in (select c__PayingAccount from #tmp_newrw)
AND EXISTS
(SELECT 1 FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId
    AND t_recur_window.c_PayerStart = w2.c_PayerStart
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd
    AND t_recur_window.c_membershipstart = w2.c_membershipstart
    AND t_recur_window.c_membershipend = w2.c_membershipend
    AND t_recur_window.c__accountid = w2.c__accountid
    AND t_recur_window.c__payingaccount = w2.c__payingaccount
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate)
;
end
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering trigger [dbo].[trig_update_recur_window_on_t_gsubmember] on [dbo].[t_gsubmember]'
GO
ALTER trigger [dbo].[trig_update_recur_window_on_t_gsubmember]
ON [dbo].[t_gsubmember]
for insert, UPDATE, delete
as
begin
declare @startDate datetime;
delete from t_recur_window where exists (
  select 1 from deleted gsm
         join t_sub sub on gsm.id_group = sub.id_group and
         t_recur_window.c__SubscriptionID = sub.id_sub and t_recur_window.c__AccountID = gsm.id_acc
	    join t_pl_map plm on sub.id_po = plm.id_po
		  and t_recur_window.c__PriceableItemInstanceID = plm.id_pi_instance and t_recur_window.c__PriceableItemTemplateID = plm.id_pi_template
INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
AND rcr.b_charge_per_participant = 'Y');
         
         
MERGE into t_recur_window USING (
	select distinct sub.id_sub, gsubmember.id_acc, gsubmember.vt_start, gsubmember.vt_end, plm.id_pi_template, plm.id_pi_instance
	FROM
       INSERTED gsubmember inner join t_recur_window trw on
         trw.c__AccountID = gsubmember.id_acc
         inner join t_sub sub on sub.id_group = gsubmember.id_group
            and trw.c__SubscriptionID = sub.id_sub
         inner join t_pl_map plm on sub.id_po = plm.id_po
            and plm.id_sub = null and plm.id_paramtable = null
			) AS source
     ON (t_recur_window.c__SubscriptionID = source.id_sub
     and t_recur_window.c__AccountID = source.id_acc)
WHEN matched AND t_recur_window.c__SubscriptionID = source.id_sub
    AND t_recur_window.c__AccountID = source.id_acc
    and t_recur_window.c__PriceableItemInstanceID = source.id_pi_instance
    AND t_recur_window.c__PriceableItemTemplateID = source.id_pi_template	THEN
	UPDATE SET c_MembershipStart = source.vt_start,
	           c_MembershipEnd = source.vt_end;
	
	
	SET @startDate = dbo.metratime(1,'RC');
			   
	SELECT
       gsm.vt_start AS c_CycleEffectiveDate
      ,gsm.vt_start AS c_CycleEffectiveStart
      ,gsm.vt_end AS c_CycleEffectiveEnd
      ,gsm.vt_start          AS c_SubscriptionStart
      ,gsm.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , @startDate as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , dbo.mtmindate() AS c_MembershipStart
      , dbo.mtmaxdate() AS c_MembershipEnd
	  , dbo.AllowInitialArrersCharge(rcr.b_advance, sub.id_acc, sub.vt_end, @startDate) AS c__IsAllowGenChargeByTrigger
	INTO #recur_window_holder
    FROM INSERTED gsm
      INNER JOIN t_sub sub ON sub.id_group = gsm.id_group
      INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start AND pay.vt_start < gsm.vt_end AND pay.vt_end > gsm.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate() AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start AND rv.vt_start < gsm.vt_end AND rv.vt_end > gsm.vt_start
      WHERE
		not EXISTS
        (SELECT 1 FROM T_RECUR_WINDOW where c__AccountID = gsm.id_acc
          AND c__SubscriptionID = sub.id_sub
		  and c__PriceableItemInstanceID = plm.id_pi_instance
		  and c__PriceableItemTemplateID = plm.id_pi_template)
      AND rcr.b_charge_per_participant = 'Y'
      AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL);
	
	/* adds charges to METER tables */
    EXEC MeterInitialFromRecurWindow @currentDate = @startDate;
    EXEC MeterCreditFromRecurWindow @currentDate = @startDate;
	  
	INSERT INTO t_recur_window
	SELECT c_CycleEffectiveDate,
	c_CycleEffectiveStart,
	c_CycleEffectiveEnd,
	c_SubscriptionStart,
	c_SubscriptionEnd,
	c_Advance,
	c__AccountID,
	c__PayingAccount,
	c__PriceableItemInstanceID,
	c__PriceableItemTemplateID,
	c__ProductOfferingID,
	c_PayerStart,
	c_PayerEnd,
	c__SubscriptionID,
	c_UnitValueStart,
	c_UnitValueEnd,
	c_UnitValue,
	c_BilledThroughDate,
	c_LastIdRun,
	c_MembershipStart,
	c_MembershipEnd
	FROM #recur_window_holder;
	
/* step 2) update the cycle effective windows */

/* sql */
UPDATE t_recur_window
 SET c_CycleEffectiveEnd =
 (
  SELECT MIN(IsNull(c_CycleEffectiveDate,c_SubscriptionEnd)) FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId AND t_recur_window.c_PayerStart = w2.c_PayerStart
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd
    AND t_recur_window.c_membershipstart = w2.c_membershipstart
    AND t_recur_window.c_membershipend = w2.c_membershipend
    AND t_recur_window.c__accountid = w2.c__accountid
    AND t_recur_window.c__payingaccount = w2.c__payingaccount
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate
 )
 WHERE EXISTS
(SELECT 1 FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId
    AND t_recur_window.c_PayerStart = w2.c_PayerStart
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd
    AND t_recur_window.c_membershipstart = w2.c_membershipstart
    AND t_recur_window.c_membershipend = w2.c_membershipend
    AND t_recur_window.c__accountid = w2.c__accountid
    AND t_recur_window.c__payingaccount = w2.c__payingaccount
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate)
;
END;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering trigger [dbo].[trig_update_t_recur_window_with_recur_value] on [dbo].[t_recur_value]'
GO
ALTER trigger [dbo].[trig_update_t_recur_window_with_recur_value]
 ON [dbo].[t_recur_value] for INSERT, UPDATE, delete
 as
BEGIN
declare @startDate datetime;
select @startDate = tt_start from inserted
  --Get the values which are new (the problem is that we delete and
  --     re-insert EVERY unit value for this subscription, even the
  --     ones that haven't changed.
  select * into #tmp_new_units
  FROM inserted rdnew
  WHERE NOT EXISTS
   (SELECT * FROM inserted rdold where
     rdnew.n_value = rdold.n_value
     AND rdnew.vt_start = rdold.vt_start
     AND rdnew.vt_end = rdold.vt_end
	  and rdnew.id_prop = rdold.id_prop
     and rdnew.id_sub = rdold.id_sub
     AND rdold.tt_end < dbo.MTMaxDate()) /* FIXME: this should join to new tt_start + 1 second */
     
  SELECT
       sub.vt_start AS c_CycleEffectiveDate
      ,sub.vt_start AS c_CycleEffectiveStart
      ,sub.vt_end AS c_CycleEffectiveEnd
      ,sub.vt_start          AS c_SubscriptionStart
      ,sub.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , dbo.mtmindate() as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , dbo.mtmindate() AS c_MembershipStart
      , dbo.mtmaxdate() AS c_MembershipEnd
	  , dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payee, sub.vt_end, @startDate) AS c__IsAllowGenChargeByTrigger
      INTO #recur_window_holder
      FROM t_sub sub
      INNER JOIN t_payment_redirection pay ON pay.id_payee = sub.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN #tmp_new_units rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate()
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
      WHERE 1=1
      AND sub.id_group IS NULL
      AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)

UNION ALL
SELECT
       gsm.vt_start AS c_CycleEffectiveDate
      ,gsm.vt_start AS c_CycleEffectiveStart
      ,gsm.vt_end AS c_CycleEffectiveEnd
      ,gsm.vt_start          AS c_SubscriptionStart
      ,gsm.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , dbo.mtmindate() as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , dbo.mtmindate() AS c_MembershipStart
      , dbo.mtmaxdate() AS c_MembershipEnd
	  , dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payee, gsm.vt_end, @startDate) AS c__IsAllowGenChargeByTrigger
      FROM t_gsubmember gsm
      INNER JOIN t_sub sub ON sub.id_group = gsm.id_group
      INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc
        AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
        AND pay.vt_start < gsm.vt_end AND pay.vt_end > gsm.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN #tmp_new_units rv ON rv.id_prop = rcr.id_prop
        AND sub.id_sub = rv.id_sub
        AND rv.tt_end = dbo.MTMaxDate()
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
        AND rv.vt_start < gsm.vt_end AND rv.vt_end > gsm.vt_start
      WHERE
      	rcr.b_charge_per_participant = 'Y'
      	AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)
UNION ALL
SELECT
       sub.vt_start AS c_CycleEffectiveDate
      ,sub.vt_start AS c_CycleEffectiveStart
      ,sub.vt_end AS c_CycleEffectiveEnd
      ,sub.vt_start          AS c_SubscriptionStart
      ,sub.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , dbo.mtmindate() as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , grm.vt_start AS c_MembershipStart
      , grm.vt_end AS c_MembershipEnd
	  , dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payee, sub.vt_end, @startDate) AS c__IsAllowGenChargeByTrigger
      FROM t_gsub_recur_map grm
      /* TODO: GRM dates or sub dates or both for filtering */
      INNER JOIN t_sub sub ON grm.id_group = sub.id_group
      INNER JOIN t_payment_redirection pay ON pay.id_payee = grm.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN #tmp_new_units rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub
      AND rv.tt_end = dbo.MTMaxDate()
      AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
      AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
      WHERE
      	grm.tt_end = dbo.mtmaxdate()
      	AND rcr.b_charge_per_participant = 'N'
      	AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)
;
--Get the old vt_start and vt_end for recur values that have changed
select distinct trw.c__SubscriptionID AS id_sub,
    trw.c_UnitValue as n_value,
   IsNull(trw.c_UnitValueStart, dbo.mtmindate()) AS vt_start,
    IsNull(trw.c_UnitValueEnd, dbo.mtmaxdate()) AS vt_end,
    trv.tt_end
  into  #tmp_old_units
  FROM
     t_recur_window trw
     JOIN #recur_window_holder rwh ON
  trw.c__SubscriptionID = rwh.c__SubscriptionID
  and trw.c__PriceableItemTemplateId = rwh.c__PriceableItemTemplateId
  and trw.c__PriceableItemInstanceId = rwh.c__PriceableItemInstanceId
  AND trw.c_UnitValue = rwh.c_UnitValue
  --A possibly clumsy attempt at an XOR.  We want one of the start or end dates
  --  to match the old start/end, but not the other one.
  AND (trw.c_UnitValueStart = rwh.c_UnitValueStart
  or trw.c_UnitValueEnd = rwh.c_UnitValueEnd)
  AND (trw.c_UnitValueStart != rwh.c_UnitValueStart
  or trw.c_UnitValueEnd != rwh.c_UnitValueEnd)
  JOIN t_recur_value trv
    ON rwh.c__SubscriptionID = trv.id_sub
    and trv.id_prop = rwh.c__PriceableItemInstanceId
    AND trw.c_UnitValueStart = trv.vt_start
    and trw.c_UnitValueEnd = trv.vt_end
    AND trv.tt_end < dbo.MTMaxDate() ; /* FIXME: this should join to new tt_start + 1 second */
    
--The recur_window_holder has too many entries, because of the way we drop all entries for a sub
--  then re-insert them.  So, drop all the entries that already exist in t_recur_window
DELETE FROM #recur_window_holder WHERE EXISTS
(SELECT 1 FROM t_recur_window trw  JOIN t_recur_value trv
    ON trw.c__SubscriptionID = trv.id_sub
    AND trw.c__PriceableItemInstanceId = trv.id_prop
    AND trw.c_UnitValueStart = trv.vt_start
    AND trw.c_UnitValueEnd = trv.vt_end
    AND trv.tt_end = dbo.MTMaxDate()
WHERE
   trw.c__SubscriptionID = #recur_window_holder.c__SubscriptionID
   AND trw.c_UnitValue = #recur_window_holder.c_UnitValue
   AND trw.c_UnitValueStart = #recur_window_holder.c_UnitValueStart
   AND trw.c_UnitValueEnd = #recur_window_holder.c_UnitValueEnd
   and trw.c__PriceableItemInstanceID = #recur_window_holder.c__PriceableItemInstanceID
   and trw.c__PriceableItemTemplateID = #recur_window_holder.c__PriceableItemTemplateID
)
      
      EXEC MeterInitialFromRecurWindow @currentDate = @startDate;
	  EXEC MeterUdrcFromRecurWindow @currentDate = @startDate;

--Delete old values from t_recur_window
delete from t_recur_window WHERE EXISTS
  (SELECT 1 FROM t_recur_value oldunits join t_pl_map plm on oldunits.id_sub = plm.id_sub
  and oldunits.id_prop = plm.id_pi_instance
     where
  t_recur_window.c__SubscriptionID = oldunits.id_sub
  AND t_recur_window.c_UnitValueStart = oldunits.vt_start
  AND t_recur_window.c_UnitValueEnd = oldunits.vt_end
  and plm.id_pi_instance = t_recur_window.c__PriceableItemInstanceID
  and plm.id_pi_template = t_recur_window.c__PriceableItemTemplateID
  );
                  
	INSERT INTO t_recur_window
	SELECT DISTINCT c_CycleEffectiveDate,
	c_CycleEffectiveStart,
	c_CycleEffectiveEnd,
	c_SubscriptionStart,
	c_SubscriptionEnd,
	c_Advance,
	c__AccountID,
	c__PayingAccount,
	c__PriceableItemInstanceID,
	c__PriceableItemTemplateID,
	c__ProductOfferingID,
	c_PayerStart,
	c_PayerEnd,
	c__SubscriptionID,
	c_UnitValueStart,
	c_UnitValueEnd,
	c_UnitValue,
	c_BilledThroughDate,
	c_LastIdRun,
	c_MembershipStart,
	c_MembershipEnd
	FROM #recur_window_holder;


UPDATE t_recur_window
SET c_CycleEffectiveEnd =
 (
  SELECT MIN(IsNull(c_CycleEffectiveDate,c_SubscriptionEnd)) FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId AND t_recur_window.c_PayerStart = w2.c_PayerStart
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd
    AND t_recur_window.c_membershipstart = w2.c_membershipstart
    AND t_recur_window.c_membershipend = w2.c_membershipend
    AND t_recur_window.c__accountid = w2.c__accountid
    AND t_recur_window.c__payingaccount = w2.c__payingaccount
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate
)
WHERE EXISTS
(SELECT 1 FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId
    AND t_recur_window.c_PayerStart = w2.c_PayerStart
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd
    AND t_recur_window.c_membershipstart = w2.c_membershipstart
    AND t_recur_window.c_membershipend = w2.c_membershipend
    AND t_recur_window.c__accountid = w2.c__accountid
    AND t_recur_window.c__payingaccount = w2.c__payingaccount
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate)
    ;
end;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering extended properties'
GO
EXEC sp_updateextendedproperty N'MS_Description', 'Tells the calculate tax adapters which algorithm to use when calculating the tax amount for tax inclusive amounts. If set to True, then the standard implied tax algorithm is tax=amount - amount/(1.0+rate). If set to False, the alternate implied tax algorithm is tax=amount*rate.', 'SCHEMA', N'dbo', 'TABLE', N't_av_Internal', 'COLUMN', N'c_UseStdImpliedTaxAlg'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_updateextendedproperty N'MS_Description', 'Required column. The partition value that specifies on which partition 1,2,???X the current data is saved. Column for meter partitioning. It uses to simplify archive functionality.', 'SCHEMA', N'dbo', 'TABLE', N't_svc_FlatRecurringCharge', 'COLUMN', N'id_partition'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_updateextendedproperty N'MS_Description', 'Required column. The partition value that specifies on which partition 1,2,???X the current data is saved. Column for meter partitioning. It uses to simplify archive functionality.', 'SCHEMA', N'dbo', 'TABLE', N't_svc_NonRecurringCharge', 'COLUMN', N'id_partition'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_updateextendedproperty N'MS_Description', 'Required column. The partition value that specifies on which partition 1,2,???X the current data is saved. Column for meter partitioning. It uses to simplify archive functionality.', 'SCHEMA', N'dbo', 'TABLE', N't_svc_UDRecurringCharge', 'COLUMN', N'id_partition'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
PRINT N'Altering trigger [dbo].[trig_update_recur_window_on_t_sub] on [dbo].[t_sub]'
GO
ALTER trigger [dbo].[trig_update_recur_window_on_t_sub]
ON [dbo].[t_sub]
for INSERT, UPDATE, delete
as
BEGIN
declare @temp datetime
  delete from t_recur_window where exists (
    select 1 from deleted sub where
      t_recur_window.c__AccountID = sub.id_acc
      and t_recur_window.c__SubscriptionID = sub.id_sub
      AND t_recur_window.c_SubscriptionStart = sub.vt_start
      AND t_recur_window.c_SubscriptionEnd = sub.vt_end);

  MERGE into t_recur_window USING (
    select distinct sub.id_sub, sub.id_acc, sub.vt_start, sub.vt_end, plm.id_pi_template, plm.id_pi_instance
    FROM INSERTED sub inner join t_recur_window trw on trw.c__AccountID = sub.id_acc
       AND trw.c__SubscriptionID = sub.id_sub
       inner join t_pl_map plm on sub.id_po = plm.id_po
            and plm.id_sub = sub.id_sub and plm.id_paramtable = null	) AS source
        ON (t_recur_window.c__SubscriptionID = source.id_sub
             and t_recur_window.c__AccountID = source.id_acc)
    WHEN matched AND t_recur_window.c__SubscriptionID = source.id_sub and t_recur_window.c__AccountID = source.id_acc
      THEN UPDATE SET c_SubscriptionStart = source.vt_start, c_SubscriptionEnd = source.vt_end;
    
  SELECT sub.vt_start AS c_CycleEffectiveDate
        ,sub.vt_start AS c_CycleEffectiveStart
        ,sub.vt_end   AS c_CycleEffectiveEnd
        ,sub.vt_start AS c_SubscriptionStart
        ,sub.vt_end   AS c_SubscriptionEnd
        ,rcr.b_advance  AS c_Advance
        ,pay.id_payee AS c__AccountID
        ,pay.id_payer AS c__PayingAccount
        ,plm.id_pi_instance AS c__PriceableItemInstanceID
        ,plm.id_pi_template AS c__PriceableItemTemplateID
        ,plm.id_po    AS c__ProductOfferingID
        ,pay.vt_start AS c_PayerStart
        ,pay.vt_end   AS c_PayerEnd
        ,sub.id_sub   AS c__SubscriptionID
        ,IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
        ,IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
        ,rv.n_value   AS c_UnitValue
        ,dbo.mtmindate() as c_BilledThroughDate
        ,-1 AS c_LastIdRun
        ,dbo.mtmindate() AS c_MembershipStart
        ,dbo.mtmaxdate() AS c_MembershipEnd
		, dbo.AllowInitialArrersCharge(rcr.b_advance, sub.id_acc, sub.vt_end, sub.dt_crt) AS c__IsAllowGenChargeByTrigger
      --We'll use #recur_window_holder in the stored proc that operates only on the latest data
        INTO #recur_window_holder
        FROM inserted sub
          INNER JOIN t_payment_redirection pay ON pay.id_payee = sub.id_acc
         --   AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
          INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
          INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
          INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
          LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub
            AND rv.tt_end = dbo.MTMaxDate()
            AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
            AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
         WHERE 1=1
        --Make sure not to insert a row that already takes care of this account/sub id
           AND not EXISTS
           (SELECT 1 FROM T_RECUR_WINDOW where c__AccountID = sub.id_acc
              AND c__SubscriptionID = sub.id_sub)
              AND sub.id_group IS NULL
              AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)

   select @temp = max(tsh.tt_start) from t_sub_history tsh
   join inserted sub
   on tsh.id_acc = sub.id_acc and tsh.id_sub = sub.id_sub;
   
   /* adds charges to METER tables */
   EXEC MeterInitialFromRecurWindow @currentDate = @temp;
   EXEC MeterCreditFromRecurWindow @currentDate = @temp;
  
   INSERT INTO t_recur_window
	SELECT c_CycleEffectiveDate,
	c_CycleEffectiveStart,
	c_CycleEffectiveEnd,
	c_SubscriptionStart,
	c_SubscriptionEnd,
	c_Advance,
	c__AccountID,
	c__PayingAccount,
	c__PriceableItemInstanceID,
	c__PriceableItemTemplateID,
	c__ProductOfferingID,
	c_PayerStart,
	c_PayerEnd,
	c__SubscriptionID,
	c_UnitValueStart,
	c_UnitValueEnd,
	c_UnitValue,
	c_BilledThroughDate,
	c_LastIdRun,
	c_MembershipStart,
	c_MembershipEnd
	FROM #recur_window_holder;

 END;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
IF EXISTS (SELECT * FROM #tmpErrors) ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT>0 BEGIN
PRINT 'The database update succeeded'
COMMIT TRANSACTION
END
ELSE PRINT 'The database update failed'
GO
DROP TABLE #tmpErrors
GO