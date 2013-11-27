
                  CREATE OR REPLACE TRIGGER TRG_TTT_TMP_MESSAGE
                  BEFORE INSERT ON TTT_TMP_MESSAGE
                  FOR EACH ROW
                  BEGIN
                     :NEW.tx_id := mt_ttt.get_tx_id();
                  END;            
                                