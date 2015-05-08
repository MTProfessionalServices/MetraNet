IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[t_be_cor_cre_creditnoteitem]') AND type in (N'U')) 
    OR NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[t_be_cor_cre_creditnotepdf]') AND type in (N'U'))
BEGIN
  UPDATE t_credit_note_current_id
  SET id_current = id_current - 1
  WHERE nm_current = 'credit_note';  
END;



