
                CREATE GLOBAL TEMPORARY TABLE tmp_acc_ownership_batch
                (
                id_owner number(10) NOT NULL,
                id_owned number(10) NOT NULL,
                id_relation_type number(10) NOT NULL,
                n_percent number(10) NOT NULL,
                vt_start date NULL, 
                vt_end date NULL,
                tt_start TIMESTAMP NOT NULL, 
                
                /* Audit Info */
                id_audit number(10) NOT NULL,
                id_event number(10) NOT NULL,
                id_userid number(10) NOT NULL,
                id_entitytype number(10) NOT NULL,
                
                 -- Output
                status number(10) NULL
                ) ON COMMIT DELETE ROWS;
                CREATE UNIQUE INDEX idx_id_acc_ownership ON tmp_acc_ownership_batch(id_owner, id_owned);

