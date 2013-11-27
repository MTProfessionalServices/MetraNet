
create or replace procedure hardcloseexpiredintervals_npa(
  p_dt_now date,   
  n_count out int) 
as
 expintervals id_table;
begin

  /* Initialize n_count */
  n_count := 0;

  expintervals := dbo.GetExpiredIntervals (p_dt_now, 1);

  UPDATE t_usage_interval ui 
    SET tx_interval_status = 'H'
  where exists (
    select 1 
    from table(expintervals) ei /* expired, non-materialized intervals */
    WHERE ei.id = ui.id_interval
      and not exists (
          SELECT 1     /* no paying accounts */
          FROM vw_paying_accounts pa
          WHERE pa.IntervalID = ui.id_interval) 
      AND ui.tx_interval_status <> 'H'
    );
 
  n_count := sql%rowcount;

end hardcloseexpiredintervals_npa;
   