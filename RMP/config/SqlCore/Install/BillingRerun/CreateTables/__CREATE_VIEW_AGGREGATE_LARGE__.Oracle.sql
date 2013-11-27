
				    CREATE VIEW TMP_AGGREGATE_LARGE
              AS
                 SELECT 
                  ID_SESS,
                  ID_PARENT_SOURCE_SESS,
                  SESSIONS_IN_COMPOUND   
                   FROM TTT_TMP_AGGREGATE_LARGE
                  WHERE tx_id = mt_ttt.get_tx_id()
            