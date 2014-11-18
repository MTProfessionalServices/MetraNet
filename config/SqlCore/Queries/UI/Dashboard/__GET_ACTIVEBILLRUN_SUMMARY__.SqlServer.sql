DECLARE @EOP_Interval INT
DECLARE @EOP_End_Date DATETIME --Eop END date
DECLARE @EOPadapterCount INT
DECLARE @lastEOPinstanceRun DATETIME --time of run
DECLARE @EOP_ReadyToRun INT
DECLARE @EOPnotYetRun INT
DECLARE @EOPfailedCount INT
DECLARE @EOPsucceededCount INT
DECLARE @lastEOPAdapterName VARCHAR(50)
DECLARE @lastEOPAdapterDuration INT
DECLARE @lastEOPAdapterStatus VARCHAR(25)
DECLARE @start_time DATETIME
DECLARE @Variance FLOAT
DECLARE @ETAoffset INT
DECLARE @ETAoffsetHours FLOAT
DECLARE @EarliestETA DATETIME
DECLARE @EOP_Interval_run_time FLOAT
DECLARE @Past_three_month_average FLOAT

SET @EOP_Interval = %%ID_USAGE_INTERVAL%% --change to your interval variable
SET @EOP_End_Date = (
SELECT dt_end AS dt_end from t_usage_interval
where id_interval = @EOP_Interval
)

--get sum of all run times for successful adapters that have run so far for current EOP Interval (in seconds)
SET @EOP_Interval_run_time = (SELECT sum(datediff(second, rer.dt_start, rer.dt_end))
  FROM [dbo].[t_recevent_inst] rei
  join t_recevent re on re.id_event = rei.id_event
  left join t_recevent_run rer on rer.id_instance = rei.id_instance
Where id_arg_interval = @EOP_Interval
and rer.tx_type = 'Execute'
and tx_detail not like 'Manually changed status%'
and rei.tx_status = 'Succeeded') + 0.0

-- get the three month average total run time (in seconds) for all EOP adapters in past hard closed intervals that match the bill cycle of the current EOP Interval
SET @Past_three_month_average = (SELECT case when count(distinct rei.id_arg_interval) != 0 then sum(datediff(second, rer.dt_start, rer.dt_end) + 0.0) / count(distinct rei.id_arg_interval) else 0 end
  FROM [dbo].[t_recevent_inst] rei
  join t_recevent re on re.id_event = rei.id_event
  left join t_recevent_run rer on rer.id_instance = rei.id_instance
WHERE id_arg_interval in (
select ui.id_interval
from t_usage_interval ui
where ui.tx_interval_status = 'H'
and ui.dt_end > dateadd(month, -3, getdate())
and ui.id_usage_cycle = (select id_usage_cycle from t_usage_interval where id_interval = @EOP_Interval))
and rer.tx_type = 'Execute'
and tx_detail not like 'Manually changed status%'
and tx_name in (
-- These are the adapters that have successfully run so far for the current EOP interval
SELECT tx_name
  FROM [dbo].[t_recevent_inst] rei
  join t_recevent re on re.id_event = rei.id_event
  left join t_recevent_run rer on rer.id_instance = rei.id_instance
Where id_arg_interval = @EOP_Interval
and rer.tx_type = 'Execute'
and tx_detail not like 'Manually changed status%'
and rei.tx_status = 'Succeeded'
)) + 0.0

-- compute Variance based on @EOP_Interval_run_time compared to @Past_three_month_average
set @Variance = case when @Past_three_month_average != 0.0 then ROUND(((@EOP_Interval_run_time - @Past_three_month_average) * 100.0/ @Past_three_month_average),2) else 0.0 end;

-- get the three month average total run time (in seconds) of all adapters that have not yet successfully run for the current EOP adapter
SET @ETAoffset = (SELECT case when count(distinct rei.id_arg_interval) != 0 then sum(datediff(second, rer.dt_start, rer.dt_end)) / count(distinct rei.id_arg_interval) else 0 end
  FROM [dbo].[t_recevent_inst] rei
  join t_recevent re on re.id_event = rei.id_event
  left join t_recevent_run rer on rer.id_instance = rei.id_instance
WHERE id_arg_interval in (
select ui.id_interval
from t_usage_interval ui
where ui.tx_interval_status = 'H'
and ui.dt_end > dateadd(month, -3, getdate())
and ui.id_usage_cycle = (select id_usage_cycle from t_usage_interval where id_interval = @EOP_Interval))
and rer.tx_type = 'Execute'
and tx_detail not like 'Manually changed status%'
and tx_name not in (
-- These are the adapters that have successfully run so far for the current EOP interval
SELECT tx_name
  FROM [dbo].[t_recevent_inst] rei
  join t_recevent re on re.id_event = rei.id_event
  left join t_recevent_run rer on rer.id_instance = rei.id_instance
Where id_arg_interval = @EOP_Interval
and rer.tx_type = 'Execute'
and tx_detail not like 'Manually changed status%'
and rei.tx_status = 'Succeeded'
))

-- Convert the ETAoffset from seconds to hours
set @ETAoffsetHours = ROUND(((@ETAoffset + 0.0) / 3600.0), 3)

-- Compute the @EarliestETA
set @EarliestETA = DATEADD(SECOND, @ETAoffset, GETUTCDATE())


--get count of all EOP Adapters
SET @EOPadapterCount  = (
select count(*) as EOP_adaptet_Count
FROM t_recevent_inst rei
join t_recevent re on re.id_event = rei.id_event
where rei.id_arg_interval = @EOP_Interval
and re.tx_type = 'EndofPeriod' 
)

--First Adapter Run
SET @start_time  = (
SELECT top 1  DATEADD(hh, -5, rer.dt_start) as EOP_Start_Time
FROM t_recevent_run rer with (nolock)
join t_recevent_inst rei with (nolock) on   rei.id_instance = rer.id_instance
join t_recevent re with (nolock) on re.id_event = rei.id_event
where re.tx_type = 'EndofPeriod' and rei.id_arg_interval = @EOP_Interval
and rer.tx_type = 'Execute'
order by rer.dt_start asc)


--time of last EOP adapter / checkpoint run  - adjusted
SET @lastEOPinstanceRun  = (
SELECT top 1  DATEADD(hh, -5, rer.dt_start) as time_of_last_EOP_run
FROM t_recevent_run rer with (nolock)
join t_recevent_inst rei with (nolock) on   rei.id_instance = rer.id_instance
join t_recevent re with (nolock) on re.id_event = rei.id_event
where re.tx_type = 'EndofPeriod' and rei.id_arg_interval = @EOP_Interval
and rer.tx_type = 'Execute'
order by rer.dt_start desc)

--get count of scheduled adatpters in Ready-to-Run state
SET @EOP_ReadyToRun  = (
select count(*) as EOP_NYR_Count
FROM t_recevent_inst rei
join t_recevent re on re.id_event = rei.id_event
where rei.id_arg_interval = @EOP_Interval
and re.tx_type = 'EndofPeriod' and rei.tx_status = 'ReadytoRun'
)

--get count of EOP adatpters in not yet run state
SET @EOPnotYetRun  = (
select count(*) as EOP_NYR_Count
FROM t_recevent_inst rei
join t_recevent re on re.id_event = rei.id_event
where rei.id_arg_interval = @EOP_Interval
and re.tx_type = 'EndofPeriod' and rei.tx_status = 'NotYetRun'
)

SET @EOPfailedCount  = (
SELECT count(*) as eop_failed_count
FROM t_recevent_inst rei with (nolock)
join t_recevent re with (nolock) on re.id_event = rei.id_event
where re.tx_type = 'EndofPeriod' and rei.tx_status = 'Failed'
and rei.id_arg_interval = @EOP_Interval
)

SET @EOPsucceededCount  = (
SELECT count(*) as eop_failed_count
FROM t_recevent_inst rei with (nolock)
join t_recevent re with (nolock) on re.id_event = rei.id_event
where re.tx_type = 'EndofPeriod' and rei.tx_status = 'Succeeded'
and rei.id_arg_interval = @EOP_Interval
)

SET @lastEOPAdapterName   = (
SELECT  top 1 re.tx_display_name 
FROM t_recevent_run rer with (nolock)
join t_recevent_inst rei with (nolock) on   rei.id_instance = rer.id_instance
join t_recevent re with (nolock) on re.id_event = rei.id_event
where re.tx_type = 'EndofPeriod' and rer.tx_type = 'Execute'
and rei.id_arg_interval = @EOP_Interval
order by rer.dt_start desc
)
--Get last EOP adapter duration
SET @lastEOPAdapterDuration   = (
SELECT  top 1  datediff(minute, dt_start, isnull(dt_end, dateadd(hh,+4,getdate()))) as [Duration] 
FROM t_recevent_run rer with (nolock)
join t_recevent_inst rei with (nolock) on   rei.id_instance = rer.id_instance
join t_recevent re with (nolock) on re.id_event = rei.id_event
where re.tx_type = 'EndofPeriod' and rer.tx_type = 'Execute'
and rei.id_arg_interval = @EOP_Interval
order by rer.dt_start desc
)

--Get last EOP adapter status
SET  @lastEOPAdapterStatus   = (
SELECT  top 1 rer.tx_status 
FROM t_recevent_run rer with (nolock)
join t_recevent_inst rei with (nolock) on   rei.id_instance = rer.id_instance
join t_recevent re with (nolock) on re.id_event = rei.id_event
where re.tx_type = 'EndofPeriod' and rer.tx_type = 'Execute'
and rei.id_arg_interval = @EOP_Interval
order by rer.dt_start desc
)

select
@EOP_Interval as id_interval
,@EOP_End_Date as end_date
,@EOPadapterCount as eop_adapter_count
,@start_time as EOP_Start_Time
,@lastEOPinstanceRun as last_adapter_run_time
,@EOP_ReadyToRun as eop_RtR_adapter_count
,@EOPnotYetRun as eop_NYR_adapter_count
,@EOPfailedCount as eop_failed_adapter_count
,@EOPsucceededCount as eop_succeeded_adapter_count
,@lastEOPAdapterName as last_eop_adapter_name
,@lastEOPAdapterDuration as last_eop_adapter_duration
,@lastEOPAdapterStatus as last_eop_adapter_status
,@Variance as Variance
,@EarliestETA as earliest_eta
,@ETAoffsetHours as eta_offset;


