
--
-- inputs: vt_start, vt_end
--

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Read all shared group subscription memberships to discounts.
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
INNER JOIN t_group_sub gs ON s.id_group=gs.id_group
INNER JOIN t_gsubmember gsm ON gsm.id_group=gs.id_group
WHERE {fn mod(s.id_sub, %%NUMPARTITIONS%%)} = %%PARTITION%% 
AND gs.b_supportgroupops='Y'"];


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
-- Read the product catalog for info about non-bcr discounts (all types, templates, instances).
----------------------------------------------------------------------------
plm:select[baseQuery="SELECT id_pi_instance as plm_id_pi_instance, id_pi_template as plm_id_pi_template, id_po as plm_id_po, id_usage_cycle as plm_id_usage_cycle FROM t_pl_map INNER JOIN t_discount ON id_prop=id_pi_instance WHERE id_paramtable IS NULL AND t_discount.id_usage_cycle IS NOT NULL"];

/* Lookup discount info (broadcast the discount info) */
lookupDiscountCycle:inner_hash_join[probeKey="sub_id_po", tableKey="plm_id_po"];

-- Get Discount info from subscription pi instance 
plm->lookupDiscountCycle("table");
s -> sub -> lookupDiscountCycle("probe(0)");

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- The following considers all discount intervals that may be billed in
-- our considered date range.
----------------------------------------------------------------------------
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Read all candidate discount intervals (those ending in our processed date range).
----------------------------------------------------------------------------
pci:select[baseQuery="
SELECT pci.id_interval as pci_id_usage_interval, pci.id_cycle as pci_id_usage_cycle, pci.dt_start as pci_vt_start, pci.dt_end as pci_vt_end 
FROM t_pc_interval pci
WHERE pci.dt_end BETWEEN %%VT_START%% AND %%VT_END%%"]; 

/*bIntervals:broadcast[];*/
lookupDiscountIntervals:inner_hash_join[
	probeKey="plm_id_usage_cycle", 
	tableKey="pci_id_usage_cycle", 
	residual="CREATE FUNCTION r (@sub_vt_start DATETIME @sub_vt_end DATETIME 
                                     @pci_vt_start DATETIME @pci_vt_end DATETIME) RETURNS BOOLEAN
	          AS
                  RETURN @pci_vt_start <= @sub_vt_end AND @sub_vt_start <= @pci_vt_end"
];

-- Lookup discount intervals to be billed in this bill cycle 
lookupDiscountCycle->lookupDiscountIntervals("probe(0)");
pci-> lookupDiscountIntervals("table");

adjDiscInterval:expr[program="
CREATE PROCEDURE p 
@sub_vt_start DATETIME @sub_vt_end DATETIME 
@pci_vt_start DATETIME @pci_vt_end DATETIME
@sub_pci_vt_start DATETIME OUTPUT @sub_pci_vt_end DATETIME OUTPUT
AS
SET @sub_pci_vt_start = CASE WHEN @sub_vt_start < @pci_vt_start THEN @pci_vt_start ELSE @sub_vt_start END
SET @sub_pci_vt_end = CASE WHEN @sub_vt_end < @pci_vt_end THEN @sub_vt_end ELSE @pci_vt_end END"];

lookupDiscountIntervals -> adjDiscInterval;

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
@plm_id_pi_template INTEGER
@plm_id_po INTEGER
@Probe_pci_id_usage_interval INTEGER
@pci_vt_start DATETIME
@pci_vt_end DATETIME
@sub_vt_start DATETIME
@sub_vt_end DATETIME
@sub_pci_vt_start DATETIME
@sub_pci_vt_end DATETIME
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
    SET @c__PriceableItemTemplateID = @plm_id_pi_template
    SET @c__ProductOfferingID = @plm_id_po
    SET @c_DiscountIntervalStart = @pci_vt_start
    SET @c_DiscountIntervalEnd = @pci_vt_end
    SET @c_SubscriptionStart = @sub_vt_start
    SET @c_SubscriptionEnd = @sub_vt_end
    SET @c_DiscountIntervalSubStart = @sub_pci_vt_start
    SET @c_DiscountIntervalSubEnd = @sub_pci_vt_end
    SET @c_GroupDiscountPass = 1
    SET @c_GroupSubscriptionID = @gs_id_group
    SET @c_GroupDiscountIntervalID = @Probe_pci_id_usage_interval
    SET @c_GroupDiscountIsShared = 1
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

adjDiscInterval -> insert_copy;
insert_copy(0) -> discount_insert_summarize -> r -> discount_insert;
insert_copy(1) -> contributorProj -> contributor_insert;
			