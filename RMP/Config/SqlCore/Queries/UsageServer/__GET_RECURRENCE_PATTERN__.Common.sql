
select 
  sch.id_event, sch.interval_type, sch.interval, sch.start_date, sch.execution_times, 
  sch.days_of_week, sch.days_of_month, sch.is_paused, sch.override_date 
from 
  t_recevent_scheduled sch 
  inner join t_recevent on t_recevent.id_event = sch.id_event 
where 
  t_recevent.dt_deactivated is null
  and t_recevent.id_event = ?
        