
update t_recevent_scheduled
set
  interval_type = ?,
  interval = ?, 
  start_date = ?, 
  execution_times = ?, 
  days_of_week = ?, 
  days_of_month = ?, 
  is_paused = ?, 
  override_date = ?, 
  update_date = ?
where 
  id_event = ?
			