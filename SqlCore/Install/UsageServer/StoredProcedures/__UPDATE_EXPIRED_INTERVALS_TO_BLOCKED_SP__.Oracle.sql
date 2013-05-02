
create or replace procedure updexpiredintervalstoblocked(
  p_dt_now date,   
  n_count out int) 
as
  expintervals id_table;

begin

  /* initialize n_count */ 
  n_count := 0;
  expintervals := dbo.getexpiredintervals(p_dt_now, 1);
  
  update t_usage_interval ui
  set tx_interval_status = 'B'
  where exists
    (select 1
     from table(expintervals) ei
     where ei.id = ui.id_interval
     and ui.tx_interval_status = 'O');
     
  n_count := sql%rowcount;
  
end updexpiredintervalstoblocked;
      