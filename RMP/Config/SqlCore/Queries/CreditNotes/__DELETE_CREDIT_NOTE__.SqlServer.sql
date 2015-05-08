
  IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[t_be_cor_cre_creditnote]') AND type in (N'U'))
  BEGIN
    delete from t_be_cor_cre_creditnote where c_creditnoteid = @credit_note_id;
  END;
