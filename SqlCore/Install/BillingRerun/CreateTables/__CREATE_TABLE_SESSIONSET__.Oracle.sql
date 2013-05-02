
				      CREATE TABLE TTT_TMP_SESSION_SET
              (
                TX_ID   VARCHAR2(169) NOT NULL,
                id_message number(10) NOT NULL,
                id_ss number(10) NOT NULL,
                id_svc number(10) NOT NULL,
                b_root CHAR(1) NOT NULL,
                session_count number(10) NOT NULL,
                CONSTRAINT pk_ttt_tmp_session_set PRIMARY KEY(tx_id, id_ss) 
              )
            