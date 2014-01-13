
                    CREATE OR REPLACE TRIGGER TRG_TMP_CHILD_SESSION_SETS
                    BEFORE INSERT ON TTT_TMP_CHILD_SESSION_SETS
                    FOR EACH ROW
                    BEGIN
                       :NEW.tx_id := mt_ttt.get_tx_id();
                    END;             
                        