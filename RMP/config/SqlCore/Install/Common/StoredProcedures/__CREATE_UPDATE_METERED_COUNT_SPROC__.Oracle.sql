
            CREATE or replace PROCedure UpdateMeteredCount(
                p_tx_batch RAW,
                p_n_metered int,
                p_dt_change date,
                p_status out int)
            AS
                v_id_batch int;
                v_batch_status char(1);
            BEGIN
                for i in
                (SELECT id_batch,tx_status
                FROM t_batch
                WHERE tx_batch = p_tx_batch)
                loop
                    v_id_batch     := i.id_batch;
                    v_batch_status := i.tx_status;
                end loop;


                UPDATE
                  t_batch
                SET
                  n_metered = p_n_metered
                WHERE
                  tx_batch = p_tx_batch;

                p_status := 1 ;
                RETURN;
            END;
			