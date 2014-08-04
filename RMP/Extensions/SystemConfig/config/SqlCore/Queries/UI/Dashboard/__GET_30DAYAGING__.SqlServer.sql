DECLARE @as_of_date DATETIME
set @as_of_date = GETDATE()--replace GETDATE() with input date
select CONVERT(VARCHAR(10), MAX(dt_failuretime), 7) AS [Date], day(dt_failuretime) as [Day], isnull(COUNT(*), 0) as Total, 0 as [Open], 0 as [Fixed] from t_failed_transaction ft
where  ft.dt_FailureTime > DATEADD(day, -30, @as_of_date)
and ft.dt_FailureTime < DATEADD(day, 1, @as_of_date)
group by day(dt_failuretime)
order by MAX(dt_failuretime), day(dt_failuretime);
