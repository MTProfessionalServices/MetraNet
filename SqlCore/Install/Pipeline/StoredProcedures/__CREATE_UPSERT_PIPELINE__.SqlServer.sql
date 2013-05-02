
CREATE PROCEDURE UpsertPipeline @tx_machine nvarchar(128), @id_pipeline int OUTPUT
AS
BEGIN
      update t_pipeline 
			set 
			  b_online = '1',
			  b_processing = '0' -- explicitly resets processing flag in case the pipeline 
			                     -- came down hard or had a shared memory leak (CR13044)
			where
			tx_machine = @tx_machine

			if (@@ROWCOUNT = 0)
			insert into t_pipeline(tx_machine, b_online, b_paused, b_processing) values (@tx_machine, '1', '0', '0')

			select @id_pipeline=id_pipeline from t_pipeline where tx_machine=@tx_machine
END
			