
				        CREATE VIEW TMP_SESSION
                AS
                   SELECT 
                    ID_SS,
                    ID_SOURCE_SESS   
                     FROM TTT_TMP_SESSION
                    WHERE tx_id = mt_ttt.get_tx_id()
            