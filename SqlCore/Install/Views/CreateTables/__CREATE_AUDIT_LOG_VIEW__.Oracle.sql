CREATE OR REPLACE FORCE VIEW VW_AUDIT_LOG
AS
SELECT
       audit1.dt_crt AS Time,
       accmap1.nm_login
       || CASE accmap1.nm_login WHEN NULL THEN NULL ELSE '/' END
       || accmap1.nm_space
          AS username,
       audit1.id_userid userid,
       audit1.id_Event eventid,
       d.tx_desc EventName,
       (CASE audit1.id_entitytype
           WHEN 1
           THEN accmap2.nm_login
           WHEN 2
           THEN bp2.nm_name
           WHEN 3
           THEN gs2.tx_name
           WHEN 5
           THEN ft2.tx_FailureCompoundId_encoded
           WHEN 6
           THEN b2.tx_namespace || '\' || b2.tx_name || '\' || b2.tx_sequence
           WHEN 9
           THEN accmap2.nm_login
           ELSE NULL
        END) EntityName,
       audit1.id_entity EntityId,
       audit1.id_entitytype EntityType,
       auditdetail.tx_details Details,
       audit1.tx_logged_in_as LoggedInAs,
       audit1.tx_application_name ApplicationName,
       audit1."ID_AUDIT",
       audit1."ID_EVENT",
       audit1."ID_USERID",
       audit1."ID_ENTITYTYPE",
       audit1."ID_ENTITY",
       audit1."TX_LOGGED_IN_AS",
       audit1."TX_APPLICATION_NAME",
       audit1."DT_CRT"
  FROM t_audit audit1
       INNER JOIN t_audit_events auditevent
          ON audit1.id_event = auditevent.id_event
       INNER JOIN t_description d
          ON auditevent.id_desc = d.id_desc AND d.id_lang_code = 840
       INNER JOIN t_account_mapper accmap1 ON audit1.id_userid = accmap1.id_acc
       -- CORE-5043 add filtering account aliases
       INNER JOIN t_namespace ns1 
         ON accmap1.nm_space  = ns1.nm_space
        AND lower(ns1.tx_typ_space) != 'metered'
        AND lower(ns1.tx_typ_space) != 'system_ar'
       LEFT OUTER JOIN t_audit_details auditdetail
         ON audit1.id_audit = auditdetail.id_audit
       /* Handle different entity types below */
       LEFT OUTER JOIN t_account_mapper accmap2
         ON audit1.id_entitytype IN (1, 9)
        AND audit1.id_entity = accmap2.id_acc
        AND accmap2.nm_space NOT IN (select nm_space from t_namespace where lower(tx_typ_space) in ('metered', 'system_ar'))
       LEFT OUTER JOIN t_base_props bp2
         ON audit1.id_entitytype = 2
        AND audit1.id_entity = bp2.id_prop
       LEFT OUTER JOIN t_group_sub gs2
         ON audit1.id_entitytype = 3
        AND audit1.id_entity = gs2.id_group
       LEFT OUTER JOIN t_failed_transaction ft2
         ON audit1.id_entitytype = 5
        AND audit1.id_entity = ft2.id_failed_transaction
       LEFT OUTER JOIN t_batch b2
         ON audit1.id_entitytype = 6
        AND audit1.id_entity = b2.id_batch