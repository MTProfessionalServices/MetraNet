
				      CREATE TABLE TTT_TMP_AGGREGATE_LARGE
              (
                TX_ID   VARCHAR2(169) NOT NULL,
                id_sess number(10) not null,
                id_parent_source_sess raw(16),
                sessions_in_compound number(10),
                CONSTRAINT PK_ttt_tmp_agg_large PRIMARY KEY(tx_id, id_sess)
              )
			