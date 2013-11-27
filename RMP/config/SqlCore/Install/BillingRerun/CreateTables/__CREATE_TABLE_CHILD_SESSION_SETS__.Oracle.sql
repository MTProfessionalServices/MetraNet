
				CREATE TABLE TTT_TMP_CHILD_SESSION_SETS
        (
          TX_ID   VARCHAR2(169) NOT NULL,
          id_sess number(10) not null,
          id_parent_sess number(10) not null,
          id_svc number(10) not null,
          cnt number(10),
          CONSTRAINT PK_ttt_tmp_child_session_sets PRIMARY KEY(tx_id, id_parent_sess, id_svc)
        )
            