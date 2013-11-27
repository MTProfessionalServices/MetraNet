
				  CREATE TABLE TTT_TMP_AGGREGATE
        (
          TX_ID                  VARCHAR2(169 BYTE)     NOT NULL,
          ID_SESS                NUMBER(10)             NOT NULL,
          ID_PARENT_SOURCE_SESS  RAW(16),
          SESSIONS_IN_COMPOUND   NUMBER(10),
          CONSTRAINT PK_ttt_tmp_aggregate PRIMARY KEY(tx_id, id_sess)
        ) 
            