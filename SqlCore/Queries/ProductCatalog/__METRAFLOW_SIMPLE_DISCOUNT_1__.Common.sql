
--
-- inputs: id_interval, id_run, id_billgroup
--

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Read all subscriptions and memberships to discounts.
----------------------------------------------------------------------------
----------------------------------------------------------------------------

s:select[baseQuery="
SELECT 
s.id_sub as s_id_sub, 
s.id_acc as s_id_acc, 
s.id_po as s_id_po, 
s.vt_start as s_vt_start, 
s.vt_end as s_vt_end, 
gs.id_group as gs_id_group, 
gs.b_supportgroupops as gs_b_supportgroupops,
gs.b_proportional as gs_b_proportional, 
gs.id_usage_cycle as gs_id_usage_cycle, 
gsm.id_acc as gsm_id_acc, 
gsm.vt_start as gsm_vt_start, 
gsm.vt_end as gsm_vt_end 
FROM t_sub s
LEFT OUTER JOIN t_group_sub gs ON s.id_group=gs.id_group
LEFT OUTER JOIN t_gsubmember gsm ON gsm.id_group=gs.id_group
WHERE {fn mod(s.id_sub, %%NUMPARTITIONS%%)} = %%PARTITION%%"];


sub:expr[program="
CREATE PROCEDURE sub @sub_id_aggregation INTEGER OUTPUT @sub_id_sub INTEGER OUTPUT @sub_id_acc INTEGER OUTPUT @sub_id_po INTEGER OUTPUT @sub_id_usage_cycle INTEGER OUTPUT @sub_vt_start DATETIME OUTPUT @sub_vt_end DATETIME OUTPUT
@s_id_sub INTEGER @s_id_acc INTEGER @s_id_po INTEGER @s_vt_start DATETIME @s_vt_end DATETIME 
@gs_id_group INTEGER @gs_b_supportgroupops VARCHAR @gs_id_usage_cycle INTEGER @gsm_id_acc INTEGER @gsm_vt_start DATETIME @gsm_vt_end DATETIME 
AS
SET @sub_id_aggregation = CASE WHEN @gs_id_group IS NULL OR @gs_b_supportgroupops = 'Y' THEN @s_id_sub ELSE @gsm_id_acc END
SET @sub_id_sub = @s_id_sub
SET @sub_id_acc = CASE WHEN @gs_id_group IS NULL THEN @s_id_acc ELSE @gsm_id_acc END
SET @sub_id_po = @s_id_po
SET @sub_id_usage_cycle = @gs_id_usage_cycle
SET @sub_vt_start = CASE WHEN @gs_id_group IS NULL THEN @s_vt_start ELSE @gsm_vt_start END
SET @sub_vt_end = CASE WHEN @gs_id_group IS NULL THEN @s_vt_end ELSE @gsm_vt_end END
"];

----------------------------------------------------------------------------
-- Read the product catalog for info about discounts (all types, templates, instances).
----------------------------------------------------------------------------
plm:select[baseQuery="SELECT id_pi_instance as plm_id_pi_instance, id_pi_template as plm_id_pi_template, id_po as plm_id_po, id_usage_cycle as plm_id_usage_cycle FROM t_pl_map INNER JOIN t_discount ON id_prop=id_pi_instance WHERE id_paramtable IS NULL"];

/* Lookup discount info (broadcast the discount info) */
lookupDiscountCycle:inner_hash_join[probeKey="sub_id_po", tableKey="plm_id_po"];

-- Get Discount info from subscription pi instance 
plm->lookupDiscountCycle("table");
s -> sub -> lookupDiscountCycle("probe(0)");

-- Filter out non-BCR shared group discounts.  These are processed by scheduled adapter.
eliminateNonBCRShared:filter[program="
CREATE FUNCTION f (@gs_b_supportgroupops VARCHAR @plm_id_usage_cycle INTEGER) RETURNS BOOLEAN
AS
RETURN @gs_b_supportgroupops IS NULL OR @gs_b_supportgroupops = 'N' OR @plm_id_usage_cycle IS NULL"];
lookupDiscountCycle -> eliminateNonBCRShared;

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Attach payers to each subscription
----------------------------------------------------------------------------
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Read the entire payment redirection table
----------------------------------------------------------------------------
pay:select[baseQuery="
SELECT id_payer as pay_id_payer, id_payee as pay_id_payee, vt_start as pay_vt_start, vt_end as pay_vt_end, tt_start as pay_tt_start, tt_end as pay_tt_end 
FROM t_payment_redir_history pay 
WHERE {fn mod(id_payer, %%NUMPARTITIONS%%)} = %%PARTITION%%"];


----------------------------------------------------------------------------
-- Join to get usage intervals overlapping the subscription (those which may have billed).
----------------------------------------------------------------------------
partOnPayee:hashpart[key="pay_id_payee"];
collOnPayee:coll[];

partOnContrib:hashpart[key="sub_id_acc"];
collOnContrib:coll[];

lookupSubscribers:inner_hash_join[
	tableKey="sub_id_acc", 
	probeKey="pay_id_payee",
	residual="CREATE FUNCTION r (@sub_vt_start DATETIME @sub_vt_end DATETIME 
                                     @pay_vt_start DATETIME @pay_vt_end DATETIME) RETURNS BOOLEAN
	          AS
                  RETURN @sub_vt_start <= @pay_vt_end AND @pay_vt_start <= @sub_vt_end"
];

-- Join from payers to subscribers to discount whose effective date intersects bill interval 
pay -> partOnPayee -> collOnPayee -> lookupSubscribers("probe(0)");
eliminateNonBCRShared -> partOnContrib -> collOnContrib -> lookupSubscribers("table");

----------------------------------------------------------------------------
-- Read usage intervals for all accounts that may have generated a discount we consider.
-- Such intervals must intersect the date range we process.
----------------------------------------------------------------------------
aui:select[baseQuery="
SELECT id_usage_interval as aui_id_usage_interval, id_usage_cycle as aui_id_usage_cycle, dt_effective as aui_vt_effective, id_acc as aui_id_acc, dt_start as aui_vt_start, dt_end aui_vt_end 
FROM t_acc_usage_interval aui 
INNER JOIN t_usage_interval ui ON aui.id_usage_interval = ui.id_interval 
WHERE {fn mod(aui.id_acc, %%NUMPARTITIONS%%)} = %%PARTITION%%
AND aui.tx_status <> 'H'
AND EXISTS (
	SELECT 1 FROM
	t_usage_interval ui2
	WHERE
	ui2.id_interval=%%ID_USAGE_INTERVAL%%
	AND
	ui.dt_start <= ui2.dt_end AND ui.dt_end >= ui2.dt_start)"];

lookupUsageIntervalDates:inner_hash_join[
tableKey="aui_id_acc", 
probeKey="pay_id_payer",
residual="
CREATE FUNCTION r (@sub_vt_start DATETIME @sub_vt_end DATETIME
@aui_vt_start DATETIME @aui_vt_end DATETIME) RETURNS BOOLEAN
AS
RETURN @sub_vt_start <= @aui_vt_end AND @aui_vt_start <= @sub_vt_end"];

cycleSubDateBillDateCalculation:expr[program="
CREATE PROCEDURE cycleSubDateBillDateCalculation 
	@plm_id_usage_cycle INTEGER @sub_id_usage_cycle INTEGER @aui_id_usage_cycle INTEGER @id_usage_cycle INTEGER OUTPUT
	@aui_vt_start DATETIME @aui_vt_effective DATETIME @bill_vt_start DATETIME OUTPUT
        @aui_vt_end DATETIME @bill_vt_end DATETIME OUTPUT
AS
   SET @id_usage_cycle = 
   CASE WHEN @plm_id_usage_cycle IS NULL THEN   /* is the discount billing cycle relative */
      CASE WHEN @sub_id_usage_cycle IS NULL THEN /* and it is not a group subscription */
         @aui_id_usage_cycle   /* use the payers billing cycle */
      ELSE
         @sub_id_usage_cycle         /* use the group subs cycle */
      END
   ELSE  /* the discount is not billing cycle relative, so use the discount cycle */
      @plm_id_usage_cycle 
   END 
   SET @bill_vt_start = 
   CASE WHEN dateadd('s', 1.0, @aui_vt_effective) > @aui_vt_start THEN @aui_vt_effective ELSE @aui_vt_start END 
   SET @bill_vt_end = @aui_vt_end
"];


lookupSubscribers->lookupUsageIntervalDates("probe(0)");
aui->lookupUsageIntervalDates("table");
lookupUsageIntervalDates -> cycleSubDateBillDateCalculation;

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- The following considers all discount intervals that may be billed in
-- our considered date range/interval but looks at all payers/intervals
-- that are potential billed intervals.
----------------------------------------------------------------------------
----------------------------------------------------------------------------

---------------------------------------------------------------
---------------------------------------------------------------
-- For each payer/subscriber pair, select discount intervals that
-- the payer may have paid for.
---------------------------------------------------------------
---------------------------------------------------------------
----------------------------------------------------------------------------
-- Read all candidate discount intervals (those ending in our processed date range).
----------------------------------------------------------------------------
pci:select[baseQuery="
SELECT pci.id_interval as pci_id_usage_interval, pci.id_cycle as pci_id_usage_cycle, pci.dt_start as pci_vt_start, pci.dt_end as pci_vt_end 
FROM t_pc_interval pci
INNER JOIN t_usage_interval ui ON pci.dt_start <= ui.dt_end AND ui.dt_start <= pci.dt_end
WHERE ui.id_interval=%%ID_USAGE_INTERVAL%%"]; 
-- Can optimize the all BCR case as follows:
/*
pci:select[baseQuery="SELECT id_interval as pci_id_usage_interval, id_cycle as pci_id_usage_cycle, dt_start as pci_vt_start, dt_end as pci_vt_end FROM t_pc_interval WHERE id_interval=%%ID_USAGE_INTERVAL%%"];
*/ 
-- When executing shared group discounts (scheduled) we don't have an interval.
/*
pci:select[baseQuery="
SELECT pci.id_interval as pci_id_usage_interval, pci.id_cycle as pci_id_usage_cycle, pci.dt_start as pci_vt_start, pci.dt_end as pci_vt_end 
FROM t_pc_interval pci
WHERE pci.dt_end BETWEEN ? AND ?"]; 
*/
/*bIntervals:broadcast[];*/
lookupDiscountIntervals:inner_hash_join[
	probeKey="id_usage_cycle", 
	tableKey="pci_id_usage_cycle", 
	residual="CREATE FUNCTION r (@sub_vt_start DATETIME @sub_vt_end DATETIME 
                                     @pay_vt_start DATETIME @pay_vt_end DATETIME 
                                     @pci_vt_start DATETIME @pci_vt_end DATETIME 
                                     @bill_vt_start DATETIME @bill_vt_end DATETIME) RETURNS BOOLEAN
	          AS
                  DECLARE @subscription_adjusted_interval_end DATETIME
                  SET @subscription_adjusted_interval_end = CASE WHEN @sub_vt_end < @pci_vt_end THEN @sub_vt_end ELSE @pci_vt_end END
                  RETURN @pci_vt_start <= @sub_vt_end AND @sub_vt_start <= @pci_vt_end AND
                         @subscription_adjusted_interval_end >= @bill_vt_start AND @subscription_adjusted_interval_end <= @bill_vt_end AND
                         @subscription_adjusted_interval_end >= @pay_vt_start AND @subscription_adjusted_interval_end <= @pay_vt_end"
];

-- All BCR optimization
/*
lookupDiscountIntervals:inner_hash_join[
	probeKey="aui_id_usage_interval", 
	tableKey="pci_id_usage_interval" 
];
*/


-- Lookup discount intervals to be billed in this bill cycle 
cycleSubDateBillDateCalculation->lookupDiscountIntervals("probe(0)");
pci-> lookupDiscountIntervals("table");

---------------------------------------------------------------
---------------------------------------------------------------
-- Join payers to the discount adapter invocations that they have been part of.
---------------------------------------------------------------
---------------------------------------------------------------

-- This gets all (payer, billgroup) pairs for which the adapter was run
-- and the associated interval overlaps the current one.
-- TODO: We are currently requiring that the other (payer,billgroup) had a discount adapter run; perhaps
-- we shouldn't?
bgm:select[baseQuery="
SELECT bgm.id_billgroup as bgm_id_billgroup, bgm.id_acc as bgm_id_acc 
FROM t_billgroup_member bgm
WHERE 
EXISTS (
	SELECT 1
	FROM 
	t_recevent_run rer 
	INNER JOIN t_recevent_inst rei ON rer.id_instance=rei.id_instance 
	INNER JOIN t_usage_interval ui ON ui.id_interval=rei.id_arg_interval
	WHERE 
        bgm.id_billgroup=rei.id_arg_billgroup
        AND EXISTS (
                SELECT 1
                FROM t_recevent_run rer2
                INNER JOIN t_recevent_inst rei2 ON rer2.id_instance=rei2.id_instance
                WHERE
                rer2.id_run=%%ID_RUN%%
                AND
                rei2.id_event=rei.id_event)
        AND EXISTS (
		SELECT 1 
		FROM t_usage_interval ui2
		WHERE
		ui2.id_interval=%%ID_USAGE_INTERVAL%% AND ui.dt_start <= ui2.dt_end AND ui.dt_end >= ui2.dt_start))
AND {fn mod(bgm.id_acc, %%NUMPARTITIONS%%)} = %%PARTITION%%"];

bgLookup:inner_hash_join[probeKey="pay_id_payer", tableKey="bgm_id_acc"];
lookupDiscountIntervals -> bgLookup("probe(0)");
bgm -> bgLookup("table");

---------------------------------------------------------------
---------------------------------------------------------------
-- We look at all previous invocations of the discount adapter.
-- We select the timestamp of the last run.
-- Note that we only have to consider adapter invocations that have interval
-- overlap with the current one since the discount end date will have to
-- live in both.
-- Inputs: None
-- Outputs: lastRuns
---------------------------------------------------------------
---------------------------------------------------------------
runs:select[baseQuery="
SELECT rer.id_instance as run_id_instance, rei.id_arg_interval as run_id_usage_interval, rei.id_arg_billgroup as run_id_billgroup, rer.dt_start as run_vt_start 
FROM t_recevent_run rer 
INNER JOIN t_recevent_inst rei ON rer.id_instance=rei.id_instance 
INNER JOIN t_usage_interval ui ON ui.id_interval=rei.id_arg_interval
WHERE 
EXISTS (
         SELECT 1
         FROM t_recevent_run rer2
         INNER JOIN t_recevent_inst rei2 ON rer2.id_instance=rei2.id_instance
         WHERE
         rer2.id_run=%%ID_RUN%%
         AND
         rei2.id_event=rei.id_event)
AND EXISTS (
	SELECT 1 
	FROM t_usage_interval ui2
	WHERE
	ui2.id_interval=%%ID_USAGE_INTERVAL%% AND ui.dt_start <= ui2.dt_end AND ui.dt_end >= ui2.dt_start)", mode="sequential"];

lastRuns:hash_group_by[key="run_id_instance", key="run_id_usage_interval", key="run_id_billgroup",
initialize="
CREATE PROCEDURE i @max_run_vt_start DATETIME
AS
SET @max_run_vt_start = CAST('1970-01-01' AS DATETIME)",
update="
CREATE PROCEDURE u @max_run_vt_start DATETIME @run_vt_start DATETIME
AS
IF @run_vt_start > @max_run_vt_start
  SET @max_run_vt_start = @run_vt_start", mode="sequential"];

lastRunsPart:hashpart[key="run_id_billgroup", mode="sequential"];

---------------------------------------------------------------
-- Assign the discount adapter run date to each charge/candidate payer.
---------------------------------------------------------------
adapterInvokeLookup:inner_hash_join[
probeKey="bgm_id_billgroup", 
tableKey="run_id_billgroup",
residual="
CREATE FUNCTION r (@max_run_vt_start DATETIME @pay_tt_start DATETIME @pay_tt_end DATETIME) RETURNS BOOLEAN
AS
RETURN @max_run_vt_start >= @pay_tt_start AND @max_run_vt_start <= @pay_tt_end"];

runs -> lastRuns -> lastRunsPart -> adapterInvokeLookup("table");
bgLookup -> adapterInvokeLookup("probe(0)");

---------------------------------------------------------------
---------------------------------------------------------------
-- For each paid for charge, pick the "first" one based on adapter run time.
---------------------------------------------------------------
---------------------------------------------------------------
/*
grpSelect:hash_group_filter[key="sub_id_aggregation", key="pci_id_usage_interval", 
	initialize="
CREATE PROCEDURE i @min_tt_adapter_start DATETIME 
AS
SET @min_tt_adapter_start = CAST('2038-01-01' AS DATETIME)",
update="
CREATE PROCEDURE u @min_tt_adapter_start DATETIME @tt_adapter_start DATETIME
IF @min_tt_adapter_start > @tt_adapter_start 
BEGIN
  SET @min_tt_adapter_start = @tt_adapter_start
  RETURN TRUE
END
ELSE
  RETURN FALSE"];
*/

-- HACK: group selection not implemented yet.
grpSelect:copy[];
---------------------------------------------------------------
---------------------------------------------------------------
-- Now filter out based on bill group and interval for charges
-- with no previous payer.
---------------------------------------------------------------
---------------------------------------------------------------
chargeFilter:filter[program="
CREATE FUNCTION f (@bgm_id_billgroup INTEGER) RETURNS BOOLEAN
AS
RETURN @bgm_id_billgroup = %%ID_BILLGROUP%%"];

adjDiscInterval:expr[program="
CREATE PROCEDURE p 
@sub_vt_start DATETIME @sub_vt_end DATETIME 
@pci_vt_start DATETIME @pci_vt_end DATETIME
@sub_pci_vt_start DATETIME OUTPUT @sub_pci_vt_end DATETIME OUTPUT
AS
SET @sub_pci_vt_start = CASE WHEN @sub_vt_start < @pci_vt_start THEN @pci_vt_start ELSE @sub_vt_start END
SET @sub_pci_vt_end = CASE WHEN @sub_vt_end < @pci_vt_end THEN @sub_vt_end ELSE @pci_vt_end END"];

-- From the contributors to the discount, we create a discount
-- descriptor record (one per discount/interval pair).  For
-- the individual and group per-participant cases this record
-- is essentially what we have already calculated since there is
-- a 1-1 correspondence between contributor and discounts.  For the 
-- group shared case we assign the member with the 
-- maximum membership end date and the minimum id_acc.
-- TODO: We can branch off the shared group case for performance.
discount_insert_summarize:hash_group_by[key="sub_id_aggregation", key="sub_id_sub", key="plm_id_pi_instance", key="pci_id_usage_interval",
initialize="
CREATE PROCEDURE i 
@c__AccountID INTEGER OUTPUT
@c__PayingAccount INTEGER OUTPUT
@c_BillingIntervalStart DATETIME OUTPUT
@c_BillingIntervalEnd DATETIME OUTPUT
@c__PriceableItemTemplateID INTEGER OUTPUT
@c__ProductOfferingID INTEGER OUTPUT
@c_DiscountIntervalStart DATETIME OUTPUT
@c_DiscountIntervalEnd DATETIME OUTPUT
@c_SubscriptionStart DATETIME OUTPUT
@c_SubscriptionEnd DATETIME OUTPUT
@c_DiscountIntervalSubStart DATETIME OUTPUT
@c_DiscountIntervalSubEnd DATETIME OUTPUT
@c_GroupDiscountPass INTEGER OUTPUT
@c_GroupSubscriptionID INTEGER OUTPUT
@c_GroupSubscriptionName NVARCHAR OUTPUT
@c_GroupDiscountAmount DECIMAL OUTPUT
@c_GroupDiscountPercent DECIMAL OUTPUT
@c_GroupDiscountIsShared INTEGER OUTPUT
@c_GroupDiscountIntervalID INTEGER OUTPUT
@c__IntervalID INTEGER OUTPUT
AS
SET @c__AccountID = 2147483647
SET @c_SubscriptionEnd = CAST('1970-01-01' AS DATETIME)
",
update="
CREATE PROCEDURE u @sub_id_acc INTEGER
@pay_id_payer INTEGER
@bill_vt_start DATETIME
@bill_vt_end DATETIME
@plm_id_pi_template INTEGER
@plm_id_po INTEGER
@Probe_pci_id_usage_interval INTEGER
@pci_vt_start DATETIME
@pci_vt_end DATETIME
@sub_vt_start DATETIME
@sub_vt_end DATETIME
@sub_pci_vt_start DATETIME
@sub_pci_vt_end DATETIME
@aui_id_usage_interval INTEGER
@gs_b_supportgroupops VARCHAR
@gs_id_group INTEGER
@c__AccountID INTEGER OUTPUT
@c__PayingAccount INTEGER OUTPUT
@c_BillingIntervalStart DATETIME OUTPUT
@c_BillingIntervalEnd DATETIME OUTPUT
@c__PriceableItemTemplateID INTEGER OUTPUT
@c__ProductOfferingID INTEGER OUTPUT
@c_DiscountIntervalStart DATETIME OUTPUT
@c_DiscountIntervalEnd DATETIME OUTPUT
@c_SubscriptionStart DATETIME OUTPUT
@c_SubscriptionEnd DATETIME OUTPUT
@c_DiscountIntervalSubStart DATETIME OUTPUT
@c_DiscountIntervalSubEnd DATETIME OUTPUT
@c_GroupDiscountPass INTEGER OUTPUT
@c_GroupSubscriptionID INTEGER OUTPUT
@c_GroupSubscriptionName NVARCHAR OUTPUT
@c_GroupDiscountAmount DECIMAL OUTPUT
@c_GroupDiscountPercent DECIMAL OUTPUT
@c_GroupDiscountIsShared INTEGER OUTPUT
@c_GroupDiscountIntervalID INTEGER OUTPUT
@c__IntervalID INTEGER OUTPUT
AS
IF @sub_vt_end >= @c_SubscriptionEnd
  IF @sub_id_acc < @c__AccountID
  BEGIN
    SET @c__AccountID = @sub_id_acc
    SET @c__PayingAccount = @pay_id_payer
    SET @c_BillingIntervalStart = @bill_vt_start
    SET @c_BillingIntervalEnd = @bill_vt_end
    SET @c__PriceableItemTemplateID = @plm_id_pi_template
    SET @c__ProductOfferingID = @plm_id_po
    SET @c_DiscountIntervalStart = @pci_vt_start
    SET @c_DiscountIntervalEnd = @pci_vt_end
    SET @c_SubscriptionStart = @sub_vt_start
    SET @c_SubscriptionEnd = @sub_vt_end
    SET @c_DiscountIntervalSubStart = @sub_pci_vt_start
    SET @c_DiscountIntervalSubEnd = @sub_pci_vt_end
    SET @c_GroupSubscriptionName = NULL
    SET @c_GroupDiscountAmount = NULL
    SET @c_GroupDiscountPercent = NULL
    IF @gs_b_supportgroupops = 'Y'
    BEGIN
      SET @c_GroupDiscountPass = 1
      SET @c_GroupSubscriptionID = @gs_id_group
      SET @c_GroupDiscountIntervalID = @Probe_pci_id_usage_interval
      SET @c_GroupDiscountIsShared = 1
    END
    ELSE
    BEGIN
      SET @c_GroupSubscriptionID = NULL
      SET @c_GroupDiscountPass = NULL
      SET @c_GroupDiscountIntervalID = NULL
      SET @c_GroupDiscountIsShared = 0
    END
    SET @c__IntervalID = @aui_id_usage_interval
  END
"];

r:rename[
from="sub_id_aggregation", to="c_AggregationID",
from="sub_id_sub", to="c__SubscriptionID",
from="pci_id_usage_interval", to="c_DiscountIntervalID",
from="plm_id_pi_instance", to="c__PriceableItemInstanceID"];

contributorProj:proj[
column="pci_id_usage_interval",
column="pci_id_usage_cycle",
column="pci_vt_start",
column="pci_vt_end",
column="plm_id_pi_instance",
column="plm_id_pi_template",
column="plm_id_po",
column="plm_id_usage_cycle",
column="gs_id_group",
column="gs_b_supportgroupops",
column="gs_b_proportional",
column="gs_id_usage_cycle",
column="sub_id_aggregation",
column="sub_id_sub",
column="sub_id_acc",
column="sub_id_po",
column="sub_id_usage_cycle",
column="sub_vt_start",
column="sub_vt_end",
column="sub_pci_vt_start",
column="sub_pci_vt_end"];

insert_copy:copy[];
contributor_insert:insert[table="tmp_all_disc_contrib", createTable=TRUE, schema="NetMeter"];
discount_insert:insert[table="tmp_all_disc_desc", createTable=TRUE, schema="NetMeter"];

adapterInvokeLookup -> grpSelect -> chargeFilter -> adjDiscInterval -> insert_copy;
insert_copy(0) -> discount_insert_summarize -> r -> discount_insert;
insert_copy(1) -> contributorProj -> contributor_insert;
			