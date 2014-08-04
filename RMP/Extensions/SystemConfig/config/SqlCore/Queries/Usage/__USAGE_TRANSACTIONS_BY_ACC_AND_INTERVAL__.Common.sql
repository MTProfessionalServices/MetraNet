select
au.id_usage_interval,
au.id_acc,
au.id_sess,
au.dt_session,
au.dt_crt,
au.amount,
au.am_currency,
ev.nm_enum_data as nm_view,
bpo.nm_display_name as nm_po,
bpit.nm_display_name as nm_pi_template,
bpii.nm_display_name as nm_pi_instance,
pv.nm_table_name as nm_pv_table
from t_acc_usage au
inner join agg_usage_audit_trail auat on auat.id_usage_interval = au.id_usage_interval and auat.id_sess = au.id_sess
inner join t_enum_data ev on ev.id_enum_data = au.id_view
inner join t_prod_view pv on pv.id_view = au.id_view
left outer join t_base_props bpo on bpo.id_prop = au.id_prod
left outer join t_base_props bpit on bpit.id_prop = au.id_pi_template
left outer join t_base_props bpii on bpii.id_prop = au.id_pi_instance
where
1=1
