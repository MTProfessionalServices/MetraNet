
            CREATE OR REPLACE PROCEDURE Insertmeteredbatch (
                p_tx_batch RAW,
                p_tx_batch_encoded VARCHAR2,
                p_tx_source VARCHAR2,
                p_tx_sequence VARCHAR2,
                p_tx_name NVARCHAR2,
                p_tx_namespace NVARCHAR2,
                p_tx_status CHAR,
                p_dt_crt_source DATE,
                p_dt_crt DATE,
                p_n_completed INT,
                p_n_failed INT,
                p_n_expected INT,
                p_n_metered INT,
                p_id_batch OUT INT )
            AS
                v_count NUMBER:=0;
            BEGIN
                p_id_batch := -1;
                FOR i IN (SELECT 1 dummy
                FROM
                    T_BATCH
                WHERE
                    tx_name = p_tx_name AND
                    tx_namespace = p_tx_namespace AND
                    tx_sequence = p_tx_sequence AND
                    tx_status != 'D')
                LOOP
                    v_count := v_count+1;
                    EXIT;
                END LOOP;
                IF v_count = 0 THEN

                    INSERT INTO T_BATCH (
                        ID_BATCH,
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
                    VALUES (
                        seq_T_BATCH.NEXTVAL,
                        p_tx_batch,
                        p_tx_batch_encoded,
                    p_tx_source,
                    p_tx_sequence,
                        p_tx_name,
                        p_tx_namespace,
                        UPPER(p_tx_status),
                        p_dt_crt_source,
                        p_dt_crt,
                        p_n_completed,
                        p_n_failed,
                        p_n_expected,
                        p_n_metered );
                    SELECT seq_T_BATCH.CURRVAL INTO p_id_batch FROM dual;
                ELSE
                    /* MTBATCH_BATCH_ALREADY_EXISTS ((DWORD)0xE4020001L) */
                    p_id_batch := -469630975;
                END IF;
            END;
			