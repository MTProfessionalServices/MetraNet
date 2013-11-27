
			CREATE PROC UpdateMeteredCount
			  @tx_batch VARBINARY(16),
				@n_metered int,
				@dt_change datetime,
				@status int output
			AS
			BEGIN
			  declare @id_batch int
				declare @batch_status char(1)
				SELECT
				  @id_batch = id_batch,
					@batch_status = tx_status
				FROM
				  t_batch
				WHERE
				  tx_batch = @tx_batch

				UPDATE
				  t_batch
				SET
				  n_metered = @n_metered
				WHERE
				  tx_batch = @tx_batch

		    SELECT @status = 1
				RETURN
			END
			