SELECT top 100
  NEWID() AS unique_id,
  am.nm_login AS nm_login,
  a.dt_crt AS dt_crt,
  a.id_entity AS id_sched,
  ad.tx_details AS tx_details,
  d.tx_desc AS tx_desc,
  rs.id_pt AS id_pt,
  rd.nm_instance_tablename AS nm_pt
FROM t_audit a WITH (nolock)
INNER JOIN t_audit_events ae WITH (nolock) 
  ON a.id_event = ae.id_event
INNER JOIN t_audit_details ad WITH (nolock)
  ON a.id_audit = ad.id_audit
LEFT OUTER JOIN t_rsched rs WITH (nolock)
  ON rs.id_sched = a.id_entity
/*Only show recent changes for rates associated with product offerings that have not been deleted*/
INNER JOIN t_pl_map map WITH (nolock)
  ON map.id_paramtable = rs.id_pt and map.id_pi_template = rs.id_pi_template and map.id_pricelist = rs.id_pricelist
LEFT OUTER JOIN t_rulesetdefinition rd WITH (nolock)
  ON rd.id_paramtable = rs.id_pt
LEFT OUTER JOIN t_account_mapper am WITH (nolock)
  ON am.id_acc = a.id_userid 
  AND am.nm_space = 'system_user'
LEFT OUTER JOIN t_description d WITH (nolock) 
  ON d.id_desc = ae.id_desc 
  AND d.id_lang_code = 840
WHERE 1=1
  AND a.id_event IN (1400,1401,1402,1403)
  AND a.dt_crt > DATEADD(day,-30,%%CURRENT_DATETIME%%)
  AND nm_login = '%%USERNAME%%'
  AND map.id_sub is null
ORDER BY dt_crt DESC
