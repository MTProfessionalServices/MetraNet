
                CREATE OR REPLACE TRIGGER TRG_TMP_SVC_RELATIONS
                BEFORE INSERT ON TTT_TMP_SVC_RELATIONS
                FOR EACH ROW
                BEGIN
                   :NEW.tx_id := mt_ttt.get_tx_id();
                END;              
            