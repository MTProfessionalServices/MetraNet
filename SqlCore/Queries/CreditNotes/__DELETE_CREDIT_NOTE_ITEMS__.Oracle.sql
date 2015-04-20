DECLARE
table1_exists NUMBER;
table2_exists NUMBER;
BEGIN
SELECT count(*) into table1_exists FROM user_tables WHERE table_name=UPPER('t_be_cor_cre_creditnoteitem');
SELECT count(*) into table2_exists FROM user_tables WHERE table_name=UPPER('t_be_cor_cre_creditnote');
IF(table1_exists > 0) AND (table2_exists > 0) THEN          
  EXECUTE IMMEDIATE  'delete from t_be_cor_cre_creditnoteitem
  where c_creditnote_id = (select c_creditnote_id from t_be_cor_cre_creditnote where c_creditnoteid =' || :credit_note_id || ')';
  END IF;
END;