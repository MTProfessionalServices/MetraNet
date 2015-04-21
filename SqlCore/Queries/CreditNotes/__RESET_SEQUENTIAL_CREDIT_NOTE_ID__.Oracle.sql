DECLARE
table1_exists NUMBER;
table2_exists NUMBER;
BEGIN
SELECT count(*) into table1_exists FROM user_tables WHERE table_name=UPPER('t_be_cor_cre_creditnoteitem');
SELECT count(*) into table2_exists FROM user_tables WHERE table_name=UPPER('t_be_cor_cre_creditnotepdf');
IF(table1_exists <= 0) OR (table2_exists <= 0) THEN          
  UPDATE t_credit_note_current_id
  SET id_current = id_current - 1
  WHERE nm_current = 'credit_note';
  COMMIT;
  END IF;
END;