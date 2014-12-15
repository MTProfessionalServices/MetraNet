DECLARE @id_interval int
DECLARE @interval_type int
DECLARE @openFTs int
DECLARE @UnderInvFTs int
DECLARE @FixedFTs int
DECLARE @UnguidedFTs int
DECLARE @interval_start datetime
DECLARE @interval_end datetime

set @id_interval = %%ID_USAGE_INTERVAL%% --set interval here
set @interval_type = (select id_usage_cycle
from t_usage_interval ui
where ui.id_interval = @id_interval)
set @interval_start = (select dt_start
from t_usage_interval ui
where ui.id_interval = @id_interval)
set @interval_end = (select dt_end
from t_usage_interval ui
where ui.id_interval = @id_interval)


(
select 'Open' as [Status], 
COUNT(*) + (
-- Add in the under investigation transactions with unknown payer id
SELECT
COUNT(*) 
FROM t_failed_transaction ft
JOIN t_usage_interval ui ON ui.id_interval = @id_interval
WHERE ft.State = 'N' AND ft.id_PossiblePayerID = -1
AND (ft.dt_FailureTime >= ui.dt_start AND ft.dt_FailureTime <= ui.dt_end)
) as [Count] 
from t_failed_transaction ft
join t_acc_usage_cycle cycle on cycle.id_acc = ft.id_PossiblePayeeID
join t_usage_interval ui ON cycle.id_usage_cycle = ui.id_usage_cycle and ui.id_interval = @id_interval
where ft.State = 'N'
AND cycle.id_usage_cycle is not null
and (ft.dt_FailureTime >= @interval_start and ft.dt_FailureTime <= @interval_end))
Union (
select 'Under Investigation' as [Status], 
COUNT(*) + (
-- Add in the under investigation transactions with unknown payer id
SELECT
COUNT(*) 
FROM t_failed_transaction ft
JOIN t_usage_interval ui ON ui.id_interval = @id_interval
WHERE ft.State = 'I' AND ft.id_PossiblePayerID = -1
AND (ft.dt_FailureTime >= ui.dt_start AND ft.dt_FailureTime <= ui.dt_end)
) as [Count] 
from t_failed_transaction ft
join t_acc_usage_cycle cycle on cycle.id_acc = ft.id_PossiblePayeeID
join t_usage_interval ui ON cycle.id_usage_cycle = ui.id_usage_cycle and ui.id_interval = @id_interval
where ft.State = 'I'
AND cycle.id_usage_cycle is not null
and (ft.dt_FailureTime >= @interval_start and ft.dt_FailureTime <= @interval_end))
Union (
select 'Fixed' as [Status], 
COUNT(*) + (
-- Add in the under investigation transactions with unknown payer id
SELECT
COUNT(*) 
FROM t_failed_transaction ft
JOIN t_usage_interval ui ON ui.id_interval = @id_interval
WHERE ft.State = 'R' AND ft.id_PossiblePayerID = -1
AND (ft.dt_FailureTime >= ui.dt_start AND ft.dt_FailureTime <= ui.dt_end)
) as [Count] 
from t_failed_transaction ft
join t_acc_usage_cycle cycle on cycle.id_acc = ft.id_PossiblePayeeID
join t_usage_interval ui ON cycle.id_usage_cycle = ui.id_usage_cycle and ui.id_interval = @id_interval
where ft.State = 'R'
AND cycle.id_usage_cycle is not null
and (ft.dt_FailureTime >= @interval_start and ft.dt_FailureTime <= @interval_end))
Union (
select 'Unguided' as [Status], COUNT(*) as [Count]  from t_failed_transaction ft
where ft.State = 'N' and ft.id_PossiblePayerID < 2
and (ft.dt_FailureTime >= @interval_start and ft.dt_FailureTime <= @interval_end))