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

(select 'Open' as [Status], COUNT(*) as [Count] from t_failed_transaction ft
inner join t_acc_usage_cycle cycle on cycle.id_acc = ft.id_PossiblePayeeID
where ft.State = 'N' and cycle.id_usage_cycle = @interval_type
and (ft.dt_FailureTime >= @interval_start and ft.dt_FailureTime <= @interval_end))
Union (
select 'Under Investigation' as [Status], COUNT(*) as [Count] from t_failed_transaction ft
left outer join t_acc_usage_cycle cycle on cycle.id_acc = ft.id_PossiblePayeeID
where ft.State = 'I' and (cycle.id_usage_cycle = @interval_type or ft.id_PossiblePayerID = -1)
and (ft.dt_FailureTime >= @interval_start and ft.dt_FailureTime <= @interval_end))
Union (
select 'Fixed' as [Status], COUNT(*) as [Count]   from t_failed_transaction ft
left outer join t_acc_usage_cycle cycle on cycle.id_acc = ft.id_PossiblePayeeID
where ft.State = 'R' and (cycle.id_usage_cycle = @interval_type or ft.id_PossiblePayerID = -1)
and (ft.dt_FailureTime >= @interval_start and ft.dt_FailureTime <= @interval_end))
Union (
select 'Unguided' as [Status], COUNT(*) as [Count]  from t_failed_transaction ft
where ft.State = 'N' and ft.id_PossiblePayerID < 2
and (ft.dt_FailureTime >= @interval_start and ft.dt_FailureTime <= @interval_end))