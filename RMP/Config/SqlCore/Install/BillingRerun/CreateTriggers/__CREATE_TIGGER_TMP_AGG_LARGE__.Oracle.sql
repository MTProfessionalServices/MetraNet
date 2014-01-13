
                  CREATE OR REPLACE TRIGGER TRG_TMP_AGGREGATE_LARGE
                  BEFORE INSERT ON TTT_TMP_AGGREGATE_LARGE
                  FOR EACH ROW
                  BEGIN
                     :NEW.tx_id := mt_ttt.get_tx_id();
                  END;             
                    