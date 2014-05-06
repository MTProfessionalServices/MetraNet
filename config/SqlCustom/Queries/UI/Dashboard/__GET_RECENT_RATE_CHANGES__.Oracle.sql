select * FROM
(select /* RATE_CHANGE_EVENTS */
nm_login || dt_crt || id_sched as unique_id,
am.nm_login as nm_login,
a.dt_crt as dt_crt,
a.id_entity as id_sched,
ad.tx_details as tx_details,
d.tx_desc as tx_desc,
rs.id_pt as id_pt,
rd.nm_instance_tablename as nm_pt
from t_audit a
inner join t_audit_events ae on a.id_event = ae.id_event
inner join t_audit_details ad on a.id_audit = ad.id_audit
inner join t_rsched rs on rs.id_sched = a.id_entity
inner join t_rulesetdefinition rd on rd.id_paramtable = rs.id_pt
left outer join t_account_mapper am on am.id_acc = a.id_userid and am.nm_space = 'system_user'
left outer join t_description d on d.id_desc = ae.id_desc and d.id_lang_code = 840
where 1=1
and a.id_event in (1400,1401,1402,1403)
and a.dt_crt > getutcdate()-30
order by dt_crt desc)
WHERE ROWNUM <= 100
