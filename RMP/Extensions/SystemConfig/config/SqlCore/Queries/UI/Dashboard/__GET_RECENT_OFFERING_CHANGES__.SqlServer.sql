select /* PO_CHANGE_EVENTS */
top 100
NEWID() as unique_id,
am.nm_login as nm_login,
a.dt_crt as dt_crt,
ad.tx_details as tx_details,
bp.id_prop as id_po,
bp.nm_display_name as nm_po,
d.tx_desc as tx_desc
from t_audit a with(nolock)
inner join t_audit_events ae with(nolock) on a.id_event = ae.id_event
left outer join t_audit_details ad with(nolock) on a.id_audit = ad.id_audit
inner join t_base_props bp with(nolock) on bp.id_prop = a.id_entity
left outer join t_account_mapper am with(nolock) on am.id_acc = a.id_userid and am.nm_space = 'system_user'
left outer join t_description d with(nolock) on d.id_desc = ae.id_desc and d.id_lang_code = 840
where 1=1
and a.id_event in (1100,1101,1102,1103,1104,1105,1106)
and a.dt_crt > DATEADD(day,-30,%%CURRENT_DATETIME%%)
order by dt_crt desc
