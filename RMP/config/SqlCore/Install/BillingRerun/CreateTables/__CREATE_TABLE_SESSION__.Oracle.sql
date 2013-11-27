
				CREATE TABLE TTT_TMP_SESSION
        (
          TX_ID   VARCHAR2(169) NOT NULL,
          id_ss number(10) NOT NULL,
          id_source_sess raw(16) NOT NULL,  
          CONSTRAINT pk_ttt_tmp_session PRIMARY KEY (tx_id, id_ss, id_source_sess)
        )	
            