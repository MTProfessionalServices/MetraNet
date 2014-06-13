
			CREATE proc InsertMeteredBatch (
				@tx_batch varbinary(16),
				@tx_batch_encoded varchar(255),
  			@tx_source varchar(255),
  			@tx_sequence varchar(255),
				@tx_name nvarchar(255),
				@tx_namespace nvarchar(255),
				@tx_status char(1),
				@dt_crt_source datetime,
				@dt_crt datetime,
				@n_completed int,
				@n_failed int,
				@n_expected int,
				@n_metered int,
				@id_batch INT OUTPUT )
			AS
			BEGIN
			  select @id_batch = -1
				IF NOT EXISTS (SELECT
				                 *
											 FROM
											   t_batch
					             WHERE
											   tx_name = @tx_name AND
												 tx_namespace = @tx_namespace AND
												 tx_sequence = @tx_sequence AND
												 tx_status != 'D')
				BEGIN
				  INSERT INTO t_batch (
						tx_batch,
						tx_batch_encoded,
  					tx_source,
  					tx_sequence,
						tx_name,
						tx_namespace,
						tx_status,
						dt_crt_source,
						dt_crt,
						n_completed,
						n_failed,
						n_expected,
						n_metered )
					values (
						@tx_batch,
						@tx_batch_encoded,
  					@tx_source,
  					@tx_sequence,
						@tx_name,
						@tx_namespace,
						UPPER(@tx_status),
						@dt_crt_source,
						@dt_crt,
						@n_completed,
						@n_failed,
						@n_expected,
						@n_metered )

					select @id_batch = max(id_batch) from t_batch 
				END
				ELSE
				BEGIN
				  -- MTBATCH_BATCH_ALREADY_EXISTS ((DWORD)0xE4020001L)
				  SELECT @id_batch = -469630975
				END
			END
			