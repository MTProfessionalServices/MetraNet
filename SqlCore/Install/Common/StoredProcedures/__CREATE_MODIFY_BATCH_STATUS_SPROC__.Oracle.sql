
        CREATE or replace PROCedure ModifyBatchStatus(
        p_tx_batch RAW,
        p_dt_change date,
        p_tx_new_status char,
        p_id_batch out int,
        p_tx_current_status out char ,
        p_status out int )
        AS
            v_count number :=0;
        BEGIN
            for i in (
            SELECT
               id_batch ,
               tx_status
            FROM
              t_batch
            WHERE
              tx_batch = p_tx_batch )
            loop
                v_count             := v_count + 1 ;
                p_id_batch          := i.id_batch  ;
                p_tx_current_status := i.tx_status ;
            end loop;
            /* Batch does not exist	 */
            IF (v_count = 0) then
              /* MTBATCH_BATCH_DOES_NOT_EXIST ((DWORD)0xE4020007L) */
              p_status := -469630969;
              RETURN;
            END IF;

            /* State transition business rules  */
            IF (
                ((p_tx_new_status = 'F') AND
                 ((p_tx_current_status = 'D') OR (p_tx_current_status = 'B')))
                    OR
                    ((p_tx_new_status = 'D') AND
                     ((p_tx_current_status = 'A') OR (p_tx_current_status = 'C') OR
                      (p_tx_current_status = 'F')))
                    OR
                    ((p_tx_new_status = 'C') AND
                     ((p_tx_current_status = 'D') OR (p_tx_current_status = 'B')))
                    OR
                    ((p_tx_new_status = 'A') AND
                     ((p_tx_current_status = 'D') OR (p_tx_current_status = 'C') OR
                      (p_tx_current_status = 'F')))
                    OR
                    ((p_tx_new_status = 'B') AND
                     ((p_tx_current_status = 'A') OR (p_tx_current_status = 'D') OR
                      (p_tx_current_status = 'C')))
                    )
            then
                /* MTBATCH_STATE_CHANGE_NOT_PERMITTED ((DWORD)0xE4020007L) */
                p_status := -469630968;
                RETURN;
            END if;

            UPDATE
            t_batch
            SET
            tx_status = p_tx_new_status
            WHERE
            tx_batch = p_tx_batch;

                p_status := 1 ;
            RETURN;
        END;
			