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
DECLARE @Varience FLOAT
DECLARE @ETAoffset INT
DECLARE @EarliestETA DATETIME

set @Varience = (SELECT CAST(RAND() * 10 AS INT) + round(RAND(), 2) AS [RandomNumber]
)
set @ETAoffset = (SELECT CAST(RAND() * 10 AS INT))
set @EarliestETA = DATEADD(HOUR, 20 + @ETAoffset, GETDATE())


SET @EOP_Interval = %%ID_USAGE_INTERVAL%% --change to your interval variable
SET @EOP_End_Date = (
SELECT dt_end AS dt_end from t_usage_interval
where id_interval = @EOP_Interval
)
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
,@Varience as Variance, @EarliestETA as [earliest_eta];


