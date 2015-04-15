CREATE PROCEDURE CreateCreditNoteSequenceString 
	@AccountID int,
	@CurrentTime DATETIME,
	@CreditNoteID int, 
  @CreditNoteString NVARCHAR(255) OUTPUT,
	@Status INT OUTPUT 
AS

BEGIN TRAN
  
DECLARE 
	@id_current INT, 
	@id_next INT,
	@CreditNotePrefix NVARCHAR(15),
	@count_credit_note_string INT

/* Init with empty string */ 
SET @CreditNoteString = '' 

UPDATE t_credit_note_current_id 
SET @id_next = id_current = id_current + 1
WHERE nm_current = 'credit_note'

IF ( ( @@ERROR != 0 ) 
OR ( @@ROWCOUNT != 1 ) ) 
BEGIN 
  SELECT @status = -1
	RAISERROR(N'T_CREDIT_NOTE_CURRENT_ID Update failed for [%s]', 16, 1, 'credit_note') 
  RETURN -1
END 
ELSE 
BEGIN 
	SET @id_current = @id_next - 1 

  SELECT @CreditNotePrefix = (SELECT template.c_CreditNotePrefix FROM
  t_be_cor_cre_creditnote cr
  INNER JOIN t_be_cor_cre_creditnotetmpl template ON template.c_CreditNoteTmpl_Id = cr.c_CreditNoteTmpl_Id
  WHERE cr.c_CreditNoteID = @CreditNoteID)
  
	SET @CreditNoteString = CONCAT(@CreditNotePrefix,  REPLICATE('0',10-LEN(convert(varchar,@id_current))) + convert(varchar,@id_current))

	/*Verify this is a unique CreditNoteString*/
	select @count_credit_note_string = count(*) from t_be_cor_cre_creditnote
	where t_be_cor_cre_creditnote.c_CreditNoteString = @CreditNoteString

	IF @count_credit_note_string > 0
	BEGIN
    ROLLBACK
    SELECT @status = -1
    RAISERROR(N'Failed to generate a unique credit note string for credit note with CreditNoteID [%d]', 16, 1, @CreditNoteID) 
    RETURN -1
	END
  ELSE
  BEGIN
    /*Update the Credit Note BME with the credit note string*/
    UPDATE t_be_cor_cre_creditnote SET c_CreditNoteString = @CreditNoteString WHERE c_CreditNoteID = @CreditNoteID
  
    IF ( ( @@ERROR != 0 ) 
    OR ( @@ROWCOUNT != 1 ) ) 
    BEGIN
      SELECT @status = -1
      RAISERROR(N't_be_cor_cre_creditnote Update failed for [%d]', 16, 1, @CreditNoteID) 
      RETURN -1
    END
  END
SELECT @status = 1
COMMIT
END 
