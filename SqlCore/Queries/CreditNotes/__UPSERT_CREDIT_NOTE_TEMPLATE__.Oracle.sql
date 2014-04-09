MERGE INTO t_be_cor_cre_creditnotetmpl tmpl USING dual on (c_TemplateName = TemplateName)
WHEN NOT MATCHED THEN
		INSERT(c_CreditNoteTmpl_Id
           ,c__version
           ,c_internal_key
           ,c_CreationDate
           ,c_UpdateDate
           ,c_UID
           ,c_LanguageCode
           ,c_TemplateName
           ,c_CreditNotePrefix
           ,c_CreditNoteTemplateID)
     VALUES
           (SYS_GUID()  
           ,1
           ,SYS_GUID()
           ,sysdate
           ,sysdate
           ,null
           ,LanguageCode
           ,TemplateName
           ,CreditNotePrefix
           ,CreditNoteTemplateID);
WHEN MATCHED THEN 
			UPDATE SET c_LanguageCode=@LanguageCode,
     						c_CreditNotePrefix = @CreditNotePrefix,          
     						c_CreditNoteTemplateID = @CreditNoteTemplateID;