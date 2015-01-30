select * FROM
(select /* PO_CHANGE_EVENTS */
sys_guid() as unique_id,
am.nm_login as nm_login,
a.dt_crt as dt_crt,
ad.tx_details as tx_details,
bp.id_prop as id_po,
bp.nm_display_name as nm_po,
d.tx_desc as tx_desc
from t_audit a
inner join t_audit_events ae on a.id_event = ae.id_event
left outer join t_audit_details ad on a.id_audit = ad.id_audit
inner join t_base_props bp on bp.id_prop = a.id_entity
left outer join t_account_mapper am on am.id_acc = a.id_userid and am.nm_space = 'system_user'
left outer join t_description d on d.id_desc = ae.id_desc and d.id_lang_code = 840
where 1=1
and a.id_event in (1100,1101,1102,1103,1104,1105,1106)
and a.dt_crt > TO_DATE('%%CURRENT_DATETIME%%', 'MM/dd/yyyy')-30
order by dt_crt desc)
WHERE ROWNUM <= 100
