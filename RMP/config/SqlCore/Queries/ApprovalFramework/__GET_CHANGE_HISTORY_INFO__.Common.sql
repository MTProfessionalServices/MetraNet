
			select audit1.id_audit UniqueId, audit1.id_userid UserId, map.hierarchyname UserDisplayName, audit1.dt_crt CreateDate, ae.id_event as EventId, d.tx_desc as EventDisplayName, auditdetails.tx_details Details
			from t_audit audit1
        inner join t_audit_events ae on audit1.id_event = ae.id_event
        LEFT JOIN (select t_description.* from t_description inner join t_language on tx_lang_code = '%%id_languagecode%%' and t_description.id_lang_code = t_language.id_lang_code) d  
          on ae.id_desc = d.id_desc
        left join t_audit_details auditdetails on audit1.id_audit = auditdetails.id_audit
        left join vw_mps_or_system_hierarchyname map on audit1.id_UserId = map.id_acc
      where audit1.id_entitytype=10 and audit1.id_entity = %%id_approval%%
			