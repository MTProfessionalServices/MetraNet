DECLARE
   CURSOR tx_batch_cur
   IS
   select tx_batch from %%TABLE_NAME%% rr group by tx_batch;
BEGIN
   FOR tx_batch_value 
   IN tx_batch_cur
   LOOP

  update t_batch
         set (n_completed)
     = (select t_batch.n_completed - nvl(count_summ.backout_count, 0) as n_completed
  from
    -- count of completed sessions we're backing out
   (
    select nvl(summ.tx_batch, errorsumm.tx_batch) as tx_batch, summ.backout_count, errorsumm.error_count
    from
    (select au.tx_batch, count(*) as backout_count from %%TABLE_NAME%% rr left outer join
      t_acc_usage au on au.id_sess = rr.id_sess and au.id_usage_interval = rr.id_interval
      where rr.id_sess is not null and au.tx_batch is not null and rr.tx_state = 'A'
      group by au.tx_batch) summ
      full outer join
    -- count of errors we're backing out
    (select ft.tx_batch, count(*) as error_count from %%TABLE_NAME%% rr inner join
      t_failed_transaction ft on ft.tx_FailureCompoundID = rr.id_source_sess
      where rr.tx_state = 'E'
      and ft.State <> 'R'
      group by ft.tx_batch) errorsumm
     on errorsumm.tx_batch = summ.tx_batch
   ) count_summ 
   where t_batch.tx_batch = count_summ.tx_batch  
   ) 
    WHERE t_batch.tx_batch = tx_batch_value.tx_batch;
   
   END LOOP;
END;
