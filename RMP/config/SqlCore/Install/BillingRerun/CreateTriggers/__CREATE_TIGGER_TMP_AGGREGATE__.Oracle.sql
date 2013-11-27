
                    CREATE OR REPLACE TRIGGER TRG_TTT_TMP_AGGREGATE
                    BEFORE INSERT ON TTT_TMP_AGGREGATE
                    FOR EACH ROW
                    BEGIN
                       :NEW.tx_id := mt_ttt.get_tx_id();
                    END;             
                