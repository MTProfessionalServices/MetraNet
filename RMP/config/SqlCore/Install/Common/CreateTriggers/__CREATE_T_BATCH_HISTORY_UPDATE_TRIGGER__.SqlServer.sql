
			CREATE TRIGGER t_batch_history_update_trigger
			ON t_batch
			AFTER INSERT, UPDATE 
			AS
			DECLARE @completed_old INT, @completed_new INT;
			DECLARE @failed_old INT, @failed_new INT;
			DECLARE @dismissed_old INT, @dismissed_new INT; 
			DECLARE @status_old CHAR, @status_new CHAR;

			SELECT	@completed_old	= old.n_completed,
					@failed_old		= old.n_failed,
					@dismissed_old	= old.n_dismissed,
					@status_old		= old.tx_status
			 FROM DELETED old 

			SELECT	@completed_new	= new.n_completed,
					@failed_new		= new.n_failed,
					@dismissed_new	= new.n_dismissed,
					@status_new		= new.tx_status	
			 FROM INSERTED new 

			IF NOT EXISTS (SELECT tx_batch 
								FROM t_batch_history tbh 
								WHERE tbh.tx_batch = (SELECT TOP(1) tx_batch FROM INSERTED)
							) 
							OR ISNULL(@dismissed_old,-1) <> ISNULL(@dismissed_new, -1)
							OR ISNULL(@completed_old,-1) <> ISNULL(@completed_new, -1) AND ISNULL(@failed_old,-1) <> ISNULL(@failed_new,-1) 
							OR ISNULL(@status_old,'') <> ISNULL(@status_new,'')
				BEGIN
					INSERT INTO t_batch_history
						(tx_batch, tx_batch_encoded, tx_status, dt_first, dt_last, n_completed, n_failed, n_dismissed, n_expected, n_metered)
					SELECT tx_batch, tx_batch_encoded, tx_status, dt_first, dt_last, n_completed, n_failed, n_dismissed, n_expected, n_metered 

					FROM INSERTED
				END
			ELSE
				BEGIN
					UPDATE bh
					SET			
						bh.tx_batch				= i.tx_batch,
						bh.tx_batch_encoded		= i.tx_batch_encoded,
						bh.tx_status			= i.tx_status,
						bh.dt_first				= i.dt_first,
						bh.dt_last				= i.dt_last,
						bh.n_completed			= i.n_completed,
						bh.n_failed				= i.n_failed,
						bh.n_dismissed			= i.n_dismissed,
						bh.n_expected			= i.n_expected,
						bh.n_metered			= i.n_metered			
					FROM INSERTED i, t_batch_history bh
					WHERE bh.tx_batch = i.tx_batch 
						AND bh.id_batch_history = (SELECT MAX(tbh.id_batch_history) FROM t_batch_history tbh)	
				END
      