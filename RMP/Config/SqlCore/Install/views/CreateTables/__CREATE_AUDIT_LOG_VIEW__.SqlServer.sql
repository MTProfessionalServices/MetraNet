
      CREATE VIEW vw_audit_log AS
        select 	audit.dt_crt as "Time",
        	accmap.nm_login +
					case accmap.nm_login when null then null else '/' end + accmap.nm_space as "UserName",
        	audit.id_userid as "UserId",
        	audit.id_Event as "EventId",
        	d.tx_desc as "EventName",
        	EntityName =
                CASE audit.id_entitytype
					WHEN 1 THEN (select nm_login from t_account_mapper a,t_namespace n where id_acc=audit.id_entity and a.nm_space=n.nm_space and n.tx_typ_space !='metered' and n.tx_typ_space != 'system_ar')
					WHEN 2 THEN (select nm_name from t_base_props where id_prop=audit.id_entity)
					WHEN 3 THEN (select tx_name from t_group_sub where id_group=audit.id_entity)
					WHEN 4 THEN (CASE WHEN (select count(*) from t_role where id_role=audit.id_entity) > 0 THEN (select tx_name from t_role where id_role=audit.id_entity)
                             ELSE (select tx_details from t_audit_details where id_audit=audit.id_audit)
                         END
                       )
					WHEN 5 THEN (select tx_FailureCompoundId_encoded from t_failed_transaction where id_failed_transaction=audit.id_entity)
					WHEN 6 THEN (select tx_namespace + '\' + tx_name + '\' + tx_sequence from t_batch where id_batch=audit.id_entity)                      
					WHEN 9 THEN (select nm_login from t_account_mapper a,t_namespace n where id_acc=audit.id_entity and a.nm_space=n.nm_space and n.tx_typ_space !='metered' and n.tx_typ_space != 'system_ar')
					WHEN 10 THEN (select c_ChangeType + ' Item [' + c_ItemDisplayName + '] Item Id [' + c_UniqueItemId + ']' from t_approvals where id_approval=audit.id_entity)
				ELSE NULL
				END,
        	audit.id_entity as "EntityId",
        	audit.id_entitytype as "EntityType",
        	auditdetail.tx_details as "Details",
			audit.tx_logged_in_as as "LoggedInAs",
			audit.tx_application_name as "ApplicationName",
        	audit.*
        from
        	t_audit audit
          inner join t_audit_events auditevent on audit.id_event = auditevent.id_event
          inner join t_description d on auditevent.id_desc = d.id_desc and d.id_lang_code = 840
          left outer join t_account_mapper accmap on audit.id_userid = accmap.id_acc 
          left outer join t_audit_details auditdetail on audit.id_audit = auditdetail.id_audit
          -- CORE-5043 add filtering account aliases 
          WHERE accmap.nm_space NOT IN (select nm_space from t_namespace where lower(tx_typ_space) in ('metered', 'system_ar'))
 		