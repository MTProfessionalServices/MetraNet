UPDATE t_be_cor_cre_creditnotetmpl
 SET c_LanguageCode=@LanguageCode,
     c_CreditNotePrefix = @CreditNotePrefix,          
     c_CreditNoteTemplateID = @CreditNoteTemplateID,
	 c__version = c__version+1
WHERE c_TemplateName=@TemplateName

IF @@ROWCOUNT = 0  
INSERT INTO t_be_cor_cre_creditnotetmpl
           (c_CreditNoteTmpl_Id
           ,c__version
           ,c_internal_key
           ,c_CreationDate
           ,c_UpdateDate
           ,c_UID
           ,c_LanguageCode
           ,c_CreditNotePrefix
           ,c_TemplateName
           ,c_CreditNoteTemplateID)
     VALUES(
            NEWID()
           ,1
           ,NEWID()
           ,getdate()
           ,getdate()
           ,1
           ,@LanguageCode
           ,@CreditNotePrefix
           ,@TemplateName
           ,@CreditNoteTemplateID);