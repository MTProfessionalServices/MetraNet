/* replace SYSDATE with input date */
select to_char(MAX(dt_failuretime),'dd/mm/yyyy hh24:mi:ss') as "Date",
		EXTRACT(DAY FROM dt_failuretime) as "Day", 
		nvl(COUNT(*), 0) as "Total", 
		0 as "Open", 
		0 as "Fixed" 
from t_failed_transaction ft
where  ft.dt_FailureTime > (SYSDATE - 30)
and ft.dt_FailureTime < (SYSDATE + 1)
group by 	EXTRACT(DAY FROM dt_failuretime)
order by MAX(dt_failuretime), EXTRACT(DAY FROM dt_failuretime)