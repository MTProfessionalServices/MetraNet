
				    CREATE VIEW TMP_SVC_RELATIONS
              AS
              SELECT id_svc,
              parent_id_svc
              FROM TTT_TMP_SVC_RELATIONS
              WHERE tx_id = mt_ttt.get_tx_id()
            