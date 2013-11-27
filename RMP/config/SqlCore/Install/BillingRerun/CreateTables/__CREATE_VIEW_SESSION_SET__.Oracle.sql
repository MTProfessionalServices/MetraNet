
				        CREATE VIEW TMP_SESSION_SET
                AS
                   SELECT 
                    ID_MESSAGE,
                    ID_SS,
                    ID_SVC,
                    B_ROOT,
                    SESSION_COUNT   
                     FROM TTT_TMP_SESSION_SET
                    WHERE tx_id = mt_ttt.get_tx_id()
            