
                    CREATE OR REPLACE TRIGGER TRG_TMP_SESSION_SET
                    BEFORE INSERT ON TTT_TMP_SESSION_SET
                    FOR EACH ROW
                    BEGIN
                       :NEW.tx_id := mt_ttt.get_tx_id();
                    END;            
                            