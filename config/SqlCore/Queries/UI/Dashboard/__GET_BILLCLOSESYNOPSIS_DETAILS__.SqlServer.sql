DECLARE @id_interval int
DECLARE @interval_type int
DECLARE @openFTs int
DECLARE @UnderInvFTs int
DECLARE @FixedFTs int
DECLARE @UnguidedFTs int

set @id_interval = %%ID_USAGE_INTERVAL%% --set interval here
set @interval_type = (
select Type = 
      CASE DAY(dt_end)
         WHEN '5' THEN 7
         WHEN '12' THEN 14
         WHEN '19' THEN 21
         WHEN '26' THEN 28
         ELSE 30
      END
from t_usage_interval ui
where ui.id_interval = @id_interval)


(select 'Open' as [Status], COUNT(*) as [Count] from t_failed_transaction ft
join t_acc_usage_cycle cycle on cycle.id_acc = ft.id_PossiblePayeeID
where ft.State = 'N'
and cycle.id_usage_cycle = @interval_type
and ft.dt_FailureTime > DATEADD(day, -30, getutcdate()))
Union (
select 'Under Investigation' as [Status], COUNT(*) as [Count] from t_failed_transaction ft
join t_acc_usage_cycle cycle on cycle.id_acc = ft.id_PossiblePayeeID
where ft.State = 'I'
and cycle.id_usage_cycle = @interval_type
and ft.dt_FailureTime > DATEADD(day, -30, getutcdate())
)
Union (
select 'Fixed' as [Status], COUNT(*) as [Count]   from t_failed_transaction ft
join t_acc_usage_cycle cycle on cycle.id_acc = ft.id_PossiblePayeeID
where ft.State = 'R'
and cycle.id_usage_cycle = @interval_type
and ft.dt_FailureTime > DATEADD(day, -30, getutcdate())
)
 Union (
select 'Unguided' as [Status], COUNT(*) as [Count]  from t_failed_transaction ft
where ft.State = 'N' and ft.id_PossiblePayerID < 2
and ft.dt_FailureTime > DATEADD(day, -30, getutcdate())
)
