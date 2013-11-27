
select
/*  __CHECK_RECUR_VALUE_HISTORY_SPAN__ */
         rv.id_prop, rv.id_sub, min(rv.vt_start) as min_history_date,
         max(rv.vt_end) as max_history_date
from     t_recur_value rv
where    tt_end = dbo.mtmaxdate()
group by rv.id_prop, rv.id_sub
having   min(rv.vt_start) > dbo.mtmindate()
         or max(rv.vt_end) < dbo.mtmaxdate()
		