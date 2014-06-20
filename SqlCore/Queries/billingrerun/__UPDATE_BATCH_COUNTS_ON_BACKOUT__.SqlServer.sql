
update t_batch
  set t_batch.n_completed = t_batch.n_completed - ISNULL(count_summ.backout_count, 0),
      /*t_batch.n_failed = t_batch.n_failed - ISNULL(count_summ.error_count, 0),*/
	  t_batch.n_failed = ((select count(*) from t_failed_transaction ft where ft.tx_Batch_Encoded=t_batch.tx_Batch_Encoded and ft.State in ('I','N','C')) - ISNULL(count_summ.error_count,0)),
      /* CORE-1426 - keep track of dismissed records */
      /*t_batch.n_dismissed = ISNULL(t_batch.n_dismissed, 0) + ISNULL(count_summ.error_count, 0),*/
      t_batch.n_dismissed = (select COUNT(*) from t_failed_transaction ft where ft.tx_Batch_Encoded=t_batch.tx_Batch_Encoded and ft.State='P'),
     
      t_batch.tx_status = case when (t_batch.n_completed - ISNULL(count_summ.backout_count, 0)) = 0 then 'B'
                               when (t_batch.n_completed + t_batch.n_failed + t_batch.n_dismissed) < t_batch.n_expected then 'A'
                               else t_batch.tx_status end,
      t_batch.dt_first = case when (t_batch.n_completed - ISNULL(count_summ.backout_count, 0)) = 0 then null
                            else t_batch.dt_first end,
      t_batch.dt_last = case when (t_batch.n_completed - ISNULL(count_summ.backout_count, 0)) = 0 then null
                            else t_batch.dt_last end
  from
    t_batch
    -- count of completed sessions we're backing out
    inner join
   (
    select ISNULL(summ.tx_batch, errorsumm.tx_batch) as tx_batch, summ.backout_count, errorsumm.error_count
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
   on count_summ.tx_batch = t_batch.tx_batch
