
              if object_id( '%%TEMPDEBUG%%tmp_subscribe_individual_batch' ) is not null
                DROP TABLE %%DEBUG%%tmp_subscribe_individual_batch

              CREATE TABLE %%DEBUG%%tmp_subscribe_individual_batch
              ( /* Input */
                id_acc int NOT NULL,
                id_sub int NOT NULL,
                id_po int NOT NULL,
                dt_start datetime NOT NULL, 
                dt_end datetime NULL,
                next_cycle_after_startdate varchar(1) NOT NULL, /* 'Y' or 'N' */
                next_cycle_after_enddate varchar(1) NOT NULL, /* 'Y' or 'N' */
                sub_guid varbinary(16) NULL,

                /* Audit Info */
                id_audit int NOT NULL,
                id_event int NOT NULL,
                id_userid int NOT NULL,
                id_entitytype int NOT NULL,

                /* Temporary Variables */
                dt_adj_start datetime NULL,
                dt_adj_end datetime NULL,
                count int NULL,
                tauc_id_cycle_type int NULL,
                po_id_cycle_type int NULL,
                nm_display_name nvarchar(255) NULL,

                /* Output */
                status int NULL,
                date_modified varchar(1) NULL, /* 'Y' or 'N' */
              )

              CREATE UNIQUE INDEX idx_id_sub ON %%DEBUG%%tmp_subscribe_individual_batch(id_sub)
        