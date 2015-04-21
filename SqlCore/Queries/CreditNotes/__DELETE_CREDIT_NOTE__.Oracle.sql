DECLARE
table_exists NUMBER;
BEGIN
SELECT count(*) into table_exists FROM user_tables WHERE table_name=UPPER('t_be_cor_cre_creditnote');
IF(table_exists > 0) THEN
  EXECUTE IMMEDIATE 'delete from t_be_cor_cre_creditnote where c_creditnoteid =' || :credit_note_id;  
  END IF;
END;