
              if object_id( 'tempdb..#tmp_acc_ownership_batch' ) is not null
                DROP TABLE #tmp_acc_ownership_batch

              CREATE TABLE #tmp_acc_ownership_batch
              ( -- Input
                id_owner int NOT NULL,
                id_owned int NOT NULL,
                id_relation_type int NOT NULL,
                n_percent int NOT NULL,
                vt_start datetime NULL, 
                vt_end datetime NULL,
                tt_start datetime NOT NULL, 
                
                -- Audit Info
                id_audit int NOT NULL,
                id_event int NOT NULL,
                id_userid int NOT NULL,
                id_entitytype int NOT NULL,

                -- Output
                status int NULL
              )

              CREATE UNIQUE INDEX idx_id_acc_ownership ON #tmp_acc_ownership_batch(id_owner, id_owned)

        