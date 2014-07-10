BEGIN TRY
	insert into t_batch (tx_namespace, tx_name, tx_batch, tx_batch_encoded, tx_status, n_completed, n_failed, n_expected, n_metered, dt_first, dt_crt)
	select 'pipeline', tx_batch_encoded, tx_batch, tx_batch_encoded, 'A', 0, 0, 0, 0, %%%SYSTEMDATE%%%, %%%SYSTEMDATE%%%
	from  %%TABLENAME%% 
	where tx_batch not in (select tx_batch from t_batch)
END TRY
BEGIN CATCH
    -- Ignore the error
END CATCH; 

update t_batch with(rowlock,readpast)
set t_batch.n_failed = t_batch.n_failed + summ.n_completed, 
    t_batch.dt_first = case when t_batch.dt_first is null then %%%SYSTEMDATE%%% else t_batch.dt_first end, 
    t_batch.dt_last =  %%%SYSTEMDATE%%%, 
    t_batch.tx_status = 
		case when t_batch.tx_status = 'A' and (((t_batch.n_completed + summ.n_completed + t_batch.n_failed) = t_batch.n_expected) or ((t_batch.n_completed + summ.n_completed + t_batch.n_failed) = t_batch.n_metered)) then 'C' 
      when (t_batch.tx_status = 'A' and ((t_batch.n_completed + summ.n_completed + t_batch.n_failed) > t_batch.n_expected and t_batch.n_expected > 0) or ((t_batch.n_completed + summ.n_completed + t_batch.n_failed) > t_batch.n_metered and t_batch.n_metered > 0)) then 'F'
      else t_batch.tx_status 
    end 
from %%TABLENAME%% summ
where t_batch.tx_batch = summ.tx_batch 
