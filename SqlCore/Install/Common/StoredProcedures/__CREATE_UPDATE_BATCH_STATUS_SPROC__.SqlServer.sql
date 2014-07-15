
create procedure UpdateBatchStatus
	@tx_batch VARBINARY(16),
	@tx_batch_encoded varchar(24),
	@n_completed int,
	@sysdate datetime
as
declare @initialStatus char(1)
declare @finalStatus char(1)

BEGIN TRANSACTION
if not exists (select * from t_batch with(updlock) where tx_batch = @tx_batch)
begin
  insert into t_batch (tx_namespace, tx_name, tx_batch, tx_batch_encoded, tx_status, n_completed, n_failed, dt_first, dt_crt)
    values ('pipeline', @tx_batch_encoded, @tx_batch, @tx_batch_encoded, 'A', 0, 0, @sysdate, @sysdate)
end

select @initialStatus = tx_status from t_batch with(updlock) where tx_batch = @tx_batch

update t_batch
  set t_batch.n_completed = t_batch.n_completed + @n_completed,
    -- ESR-4575 MetraControl- failed batches have completed status. Corrected batches have failed status
    -- Added a condition to mark batches with failed transections as Failed
    t_batch.tx_status =
       case when ((t_batch.n_completed + t_batch.n_failed + ISNULL(t_batch.n_dismissed, 0) + @n_completed) = t_batch.n_expected
                   or 
                  (((t_batch.n_completed + t_batch.n_failed + + ISNULL(t_batch.n_dismissed, 0) + @n_completed) = t_batch.n_metered)                      and t_batch.n_expected = 0)) 
            then 'C'
				    when ((t_batch.n_completed + t_batch.n_failed + ISNULL(t_batch.n_dismissed, 0) + @n_completed) < t_batch.n_expected
                   or 
                 (((t_batch.n_completed + t_batch.n_failed + ISNULL(t_batch.n_dismissed, 0) + @n_completed) < t_batch.n_metered) 
                    and t_batch.n_expected = 0)) 
            then 'A'
            when ((t_batch.n_completed + t_batch.n_failed + ISNULL(t_batch.n_dismissed, 0) + @n_completed) > t_batch.n_expected) 
                   and t_batch.n_expected > 0 
            then 'F'
            else t_batch.tx_status end,
     t_batch.dt_last = @sysdate,
     t_batch.dt_first =
       case when t_batch.n_completed = 0 then @sysdate else t_batch.dt_first end
  where tx_batch = @tx_batch

 IF ( @@ERROR != 0 ) 

     BEGIN 
        ROLLBACK TRANSACTION 
     END   
         
COMMIT TRANSACTION

  
select @finalStatus = tx_status from t_batch where tx_batch = @tx_batch
			