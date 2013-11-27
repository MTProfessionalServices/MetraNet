
			CREATE PROC ModifyBatchStatus
			  @tx_batch VARBINARY(16),
				@dt_change datetime,
				@tx_new_status char(1),
				@id_batch int output,
				@tx_current_status char(1) output,
				@status int output
			AS
			BEGIN
				SELECT
				  @id_batch = id_batch,
				  @tx_current_status = tx_status
				FROM
				  t_batch
				WHERE
				  tx_batch = @tx_batch
				-- Batch does not exist
				IF (@@rowcount = 0)
				BEGIN
				  -- MTBATCH_BATCH_DOES_NOT_EXIST ((DWORD)0xE4020007L)
				  SELECT @status = -469630969
					RETURN
				END

				-- State transition business rules
				IF (
				    ((@tx_new_status = 'F') AND
				     ((@tx_current_status = 'D') OR (@tx_current_status = 'B')))
						OR
						((@tx_new_status = 'D') AND
						 ((@tx_current_status = 'A') OR (@tx_current_status = 'C') OR
						  (@tx_current_status = 'F')))
						OR
						((@tx_new_status = 'C') AND
						 ((@tx_current_status = 'D') OR (@tx_current_status = 'B')))
						OR
						((@tx_new_status = 'A') AND
						 ((@tx_current_status = 'D') OR (@tx_current_status = 'C') OR
						  (@tx_current_status = 'F')))
						OR
						((@tx_new_status = 'B') AND
						 ((@tx_current_status = 'A') OR (@tx_current_status = 'D') OR
						  (@tx_current_status = 'C')))
						)
				BEGIN
				 	-- MTBATCH_STATE_CHANGE_NOT_PERMITTED ((DWORD)0xE4020007L)
				 	SELECT @status = -469630968
					RETURN
				END

				UPDATE
			  	t_batch
				SET
			  	tx_status = @tx_new_status
				WHERE
			  	tx_batch = @tx_batch

	    	SELECT @status = 1
				RETURN
			END
			