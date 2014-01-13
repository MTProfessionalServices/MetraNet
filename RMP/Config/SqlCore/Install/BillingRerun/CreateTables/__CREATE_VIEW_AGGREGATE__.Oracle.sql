
				    CREATE OR REPLACE VIEW TMP_AGGREGATE
                AS
            SELECT 
                ID_SESS, 
                ID_PARENT_SOURCE_SESS, 
                SESSIONS_IN_COMPOUND
            FROM ttt_tmp_aggregate
            WHERE tx_id = mt_ttt.get_tx_id()
            