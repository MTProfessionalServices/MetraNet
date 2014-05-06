
(
select  N'Open' as Name , count(*) as NumCount from t_failed_transaction ft
where  ft.dt_FailureTime > DATEADD(day, -30, GETUTCDATE())
and ft.dt_FailureTime < DATEADD(day, 1, GETUTCDATE())
and state in ('N'))
Union
(select N'Under Investigation' as Name, count(*) as NumCount from t_failed_transaction ft
where  ft.dt_FailureTime > DATEADD(day, -30, GETUTCDATE())
and ft.dt_FailureTime < DATEADD(day, 1, GETUTCDATE())
and state in ('I'))
--union
--(
--select  N'Fixed' as Name , count(*) as NumCount from t_failed_transaction ft
--where  ft.dt_FailureTime > DATEADD(day, -30,GetDate())
--and ft.dt_FailureTime < DATEADD(day, 1, GetDate())
--and State = 'R')


