BEGIN TRY
	insert into t_batch (tx_batch, tx_batch_encoded, tx_status, n_completed, n_failed, dt_first, dt_crt)
	select tx_batch, tx_batch_encoded, 'A', 0, 0, %%%SYSTEMDATE%%%, %%%SYSTEMDATE%%%  
	from  %%TABLENAME%% 
	where tx_batch not in (select tx_batch from t_batch)
END TRY
BEGIN CATCH
    -- Ignore the error
END CATCH; 

update t_batch  with(rowlock,readpast)
set t_batch.n_completed = t_batch.n_completed + summ.n_completed, 
    t_batch.dt_first = case when t_batch.dt_first is null then %%%SYSTEMDATE%%% else t_batch.dt_first end, 
    t_batch.tx_status = case when t_batch.tx_status = 'A' and (t_batch.n_completed + summ.n_completed) >= t_batch.n_expected then 'C' else t_batch.tx_status end, 
    t_batch.dt_last =  %%%SYSTEMDATE%%%
from %%TABLENAME%% summ
where t_batch.tx_batch = summ.tx_batch

