

		   SELECT id_approval, c_SubmittedDate, c_SubmitterId, mapsubmitter.nm_login SubmitterDisplayName, 
			   c_ChangeType, d.tx_desc as ChangeTypeDisplayName, c_ApproverId, mapapprover.nm_login ApproverDisplayName, c_ChangeLastModifiedDate, c_ItemDisplayName,
			   c_Comment, c_CurrentState, de.tx_desc as CurrentStateDisplayName, c_UniqueItemId, c_ChangeDetails FROM  t_approvals a
			 INNER JOIN t_account_mapper mapsubmitter on a.c_SubmitterId = mapsubmitter.id_acc and mapsubmitter.nm_space = 'system_user' 
			 LEFT JOIN t_enum_data e on ('Approvals/ChangeType/' + a.c_ChangeType) LIKE e.nm_enum_data
			 LEFT JOIN t_enum_data em on ('Approvals/ChangeState/' + a.c_CurrentState) LIKE em.nm_enum_data
			 LEFT JOIN t_account_mapper mapapprover on a.c_ApproverId = mapapprover.id_acc and mapapprover.nm_space = 'system_user'
       LEFT JOIN (select id_desc,tx_desc from t_description inner join t_language on tx_lang_code = '%%id_languagecode%%' and t_description.id_lang_code = t_language.id_lang_code) d 
           on e.id_enum_data = d.id_desc
       LEFT JOIN (select id_desc,tx_desc from t_description inner join t_language on tx_lang_code = '%%id_languagecode%%' and t_description.id_lang_code = t_language.id_lang_code) de 
           on em.id_enum_data = de.id_desc		
			