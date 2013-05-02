
			begin
    if not table_exists('ttt_duplicates') then
      exec_ddl('CREATE TABLE  TTT_DUPLICATES (TX_ID VARCHAR2(169) NOT NULL, ID_SESS DECIMAL(20,0), KEY_CONSTRAINT  VARCHAR2(4000 BYTE), DBCONFLICT  INTEGER)');
      exec_ddl('CREATE OR REPLACE FORCE VIEW tmp_duplicates AS SELECT id_sess, key_constraint, dbconflict FROM ttt_duplicates WHERE tx_id = mt_ttt.get_tx_id ()');
      exec_ddl('CREATE OR REPLACE TRIGGER TRG_DUPLICATES BEFORE INSERT ON TTT_DUPLICATES FOR EACH ROW BEGIN:NEW.tx_id := mt_ttt.get_tx_id(); END;');
    end if;
  end;		
      