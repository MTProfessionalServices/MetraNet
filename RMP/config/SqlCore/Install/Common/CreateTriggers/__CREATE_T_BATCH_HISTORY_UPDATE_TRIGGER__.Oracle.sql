
				CREATE OR REPLACE TRIGGER t_batch_history_update_trigger     
				AFTER INSERT OR UPDATE ON T_BATCH 
				FOR EACH ROW
				  
				  DECLARE
					 batchCount NUMBER;
				   
				  BEGIN   

					SELECT COUNT(*) INTO batchCount FROM t_batch_history tbh WHERE tbh.tx_batch =:NEW.tx_batch;

					IF batchCount = 0
						OR NVL(:OLD.n_dismissed,-1) <> NVL(:NEW.n_dismissed,-1)
						OR NVL(:OLD.n_completed,-1) <> NVL(:NEW.n_completed,-1) AND NVL(:OLD.n_failed,-1) <> NVL(:NEW.n_failed,-1)
						OR :OLD.tx_status <> :NEW.tx_status THEN
						BEGIN
							  INSERT INTO t_batch_history  (id_batch_history, tx_batch, tx_batch_encoded, tx_status, dt_first, dt_last, n_completed, n_failed, n_dismissed, n_expected, n_metered)
							  VALUES (seq_t_batch_history.nextval, :NEW.tx_batch, :NEW.tx_batch_encoded,:NEW.tx_status,:NEW.dt_first,:NEW.dt_last,:NEW.n_completed,:NEW.n_failed,:NEW.n_dismissed, :NEW.n_expected, :NEW.n_metered);
						END;
						ELSE
						   BEGIN
								UPDATE  t_batch_history bh
								  SET
								  bh.tx_batch    = :NEW.tx_batch,
								  bh.tx_batch_encoded  = :NEW.tx_batch_encoded,
								  bh.tx_status   = :NEW.tx_status,
								  bh.dt_first    = :NEW.dt_first,
								  bh.dt_last    = :NEW.dt_last,
								  bh.n_completed   = :NEW.n_completed,
								  bh.n_failed    = :NEW.n_failed,
								  bh.n_dismissed   = :NEW.n_dismissed,
								  bh.n_expected   = :NEW.n_expected,
								  bh.n_metered   = :NEW.n_metered         
								 WHERE bh.tx_batch = :NEW.tx_batch
									AND bh.id_batch_history = (SELECT MAX(tbh.id_batch_history) FROM t_batch_history tbh);
						   END;
					END IF;
				  END;
			