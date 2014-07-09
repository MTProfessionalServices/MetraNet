CREATE or replace VIEW vw_audit_log AS
        select /*+ INDEX_DESC(audit1 PK_T_AUDIT) */     audit1.dt_crt as Time, 
       	accmap.nm_login || case accmap.nm_login when null then null else '/' end || accmap.nm_space as username,
        	audit1.id_userid userid,
        	audit1.id_Event eventid,
        	d.tx_desc EventName,
          (CASE audit1.id_entitytype
        	 WHEN 1 THEN (select nm_login from t_account_mapper a,t_namespace n where id_acc=audit1.id_entity 
						and a.nm_space=n.nm_space and n.tx_typ_space !='metered' and n.tx_typ_space != 'system_ar'  and rownum < 2)
        	 WHEN 2 THEN (select nm_name from t_base_props where id_prop=audit1.id_entity)
        	 WHEN 3 THEN (select tx_name from t_group_sub where id_group=audit1.id_entity)
         	 WHEN 5 THEN (select tx_FailureCompoundId_encoded from t_failed_transaction where 
						id_failed_transaction=audit1.id_entity)
         	 WHEN 6 THEN (select tx_namespace || '\' || tx_name || '\' || tx_sequence from 
						t_batch where id_batch=audit1.id_entity)            
        	 WHEN 9 THEN (select nm_login from t_account_mapper a,t_namespace n where id_acc=audit1.id_entity 
                        and a.nm_space=n.nm_space and n.tx_typ_space !='metered' and n.tx_typ_space != 'system_ar')
			ELSE NULL
        	END) EntityName,
        	audit1.id_entity EntityId,
        	audit1.id_entitytype  EntityType,
        	auditdetail.tx_details Details,
        	audit1.tx_logged_in_as LoggedInAs,
			audit1.tx_application_name ApplicationName,
        	audit1.*
        from
				t_audit audit1
          inner join t_audit_events auditevent on audit1.id_event = auditevent.id_event
          inner join t_description d on auditevent.id_desc = d.id_desc and d.id_lang_code = 840
          left outer join t_account_mapper accmap on audit1.id_userid = accmap.id_acc 
          left outer join t_audit_details auditdetail on audit1.id_audit = auditdetail.id_audit
          -- CORE-5043 add filtering account aliases 
          WHERE accmap.nm_space NOT IN (select nm_space from t_namespace where lower(tx_typ_space) in ('metered', 'system_ar'))
 		