
				        CREATE VIEW TMP_MESSAGE
AS
   SELECT ID_MESSAGE
     FROM TTT_TMP_MESSAGE
    WHERE tx_id = mt_ttt.get_tx_id()
            