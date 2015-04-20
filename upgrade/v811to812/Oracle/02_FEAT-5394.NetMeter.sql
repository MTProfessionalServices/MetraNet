-- upgrade script for esr-5394

WHENEVER SQLERROR EXIT SQL.SQLCODE
DECLARE
nCount NUMBER;
v_sql LONG;
BEGIN
SELECT count(*) into nCount FROM USER_TAB_COLUMNS WHERE table_name=UPPER('t_be_cor_cre_creditnote') and column_name=UPPER('c_CreditNoteString');
IF(nCount <= 0) THEN
  v_sql := 'ALTER TABLE t_be_cor_cre_creditnote
               ADD c_CreditNoteString nvarchar2(255)';
  EXECUTE IMMEDIATE v_sql;  
END IF;
END;
/
DECLARE
table_exists NUMBER;
v_sql LONG;
BEGIN
SELECT count(*) into table_exists FROM user_tables where table_name=Upper('t_credit_note_current_id');
IF(table_exists <= 0) THEN
 v_sql := 'CREATE TABLE t_credit_note_current_id
          (
          nm_current nvarchar2(20) NOT NULL,
          id_current number(10) NOT NULL,
          CONSTRAINT PK_t_credit_note_current_id PRIMARY KEY (nm_current)
          )';
  execute immediate v_sql;
END IF;
END;
/
DECLARE
nCount NUMBER;
BEGIN
SELECT count(*) into nCount FROM t_credit_note_current_id;
IF(nCount <= 0) THEN
  insert into t_credit_note_current_id (nm_current, id_current) values ('credit_note', 1);
END IF;
END;
/
create or replace PROCEDURE CREATECREDITNOTESEQUENCESTRING
  (
	p_accountid INT,
	p_currenttime TIMESTAMP,
  p_creditnoteid INT,
  p_creditnotestring OUT NVARCHAR2,
	p_status OUT INT
  )
AS
  v_id_next     t_current_id.id_current%TYPE;
  v_id_current  t_current_id.id_current%TYPE;
  v_credit_note_prefix NVARCHAR2(15);
  v_count_credit_note_string INT;
BEGIN
              
  /* Init with empty string */ 
  p_creditnotestring := '';

  UPDATE t_credit_note_current_id 
  SET id_current = id_current + 1
  WHERE nm_current = 'credit_note'
  RETURNING id_current
  INTO v_id_next;

  if sql%rowcount != 1 then
    rollback;
    p_status := -1;
    raise_application_error (-20001,'T_CREDIT_NOTE_CURRENT_ID Update failed for [credit_note]');
    return;
  end if;
  
  v_id_current := v_id_next - 1;
  
  SELECT template.c_CreditNotePrefix INTO v_credit_note_prefix
  FROM t_be_cor_cre_creditnote cr
  INNER JOIN t_be_cor_cre_creditnotetmpl template ON template.c_CreditNoteTmpl_Id = cr.c_CreditNoteTmpl_Id
  WHERE cr.c_CreditNoteID = p_creditnoteid;
  
  p_creditnotestring := CONCAT(v_credit_note_prefix, LPAD( TO_CHAR(v_id_current), 10, '0' ));

	/*Verify this is a unique CreditNoteString*/
	select count(*) into v_count_credit_note_string from t_be_cor_cre_creditnote
	where t_be_cor_cre_creditnote.c_CreditNoteString = p_creditnotestring;

  IF v_count_credit_note_string > 0
  THEN
    rollback;
    p_status := -1;
    raise_application_error (-20001,'Failed to generate a unique credit note string for credit note with CreditNoteID [' || TO_CHAR(p_creditnoteid) || ']');
    return;
  END IF;
  
  /*Update the Credit Note BME with the credit note string*/
  UPDATE t_be_cor_cre_creditnote SET c_CreditNoteString = p_creditnotestring WHERE c_CreditNoteID = p_creditnoteid;
  
  if sql%rowcount != 1 then
    rollback;
    p_status := -1;
    raise_application_error (-20001,'t_be_cor_cre_creditnote Update failed for [' || TO_CHAR(p_creditnoteid) || ']');
    return;
  end if;
 
  p_status := 1; 
  commit;

END;
/

