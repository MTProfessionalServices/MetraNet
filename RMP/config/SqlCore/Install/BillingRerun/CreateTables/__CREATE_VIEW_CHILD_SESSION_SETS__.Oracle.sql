
				        CREATE VIEW TMP_CHILD_SESSION_SETS
                AS
                SELECT
                ID_SESS,
                ID_PARENT_SESS,
                ID_SVC,
                CNT
                FROM TTT_TMP_CHILD_SESSION_SETS
                WHERE tx_id = mt_ttt.get_tx_id()
            