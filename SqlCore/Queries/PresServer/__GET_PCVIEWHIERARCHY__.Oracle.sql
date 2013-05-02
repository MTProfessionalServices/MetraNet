
select 
tb_po.n_display_name id_po, /* use the display name as the product offering ID
--au.id_prod id_po, */
pi_template.id_template_parent id_template_parent,
/* po_nm_name = case when t_description.tx_desc is NULL then template_desc.tx_desc else t_description.tx_desc end, */
case when t_description.tx_desc is NULL then template_desc.tx_desc else t_description.tx_desc end as po_nm_name,
ed.nm_enum_data pv_child,
ed.id_enum_data pv_childID,
case when parent_kind.nm_productview is NULL then tb_po.n_display_name else tenum_parent.id_enum_data end as pv_parentID,
case when pi_props.n_kind = 15 then 'Y' else 'N' end as AggRate,
case when ed.nm_enum_data like '%_temp%' then 'N' else 'Y' end SecondPass,
case when au.id_pi_instance is NULL then id_view else 
	( case when pi_props.n_kind = 15 AND child_kind.nm_productview = ed.nm_enum_data then
	-(au.id_pi_instance + hextonum('0x40000000'))
	else
	-au.id_pi_instance 
	end )
end as viewID,
id_view realPVID,
/* ViewName = case when tb_instance.nm_display_name is NULL then tb_template.nm_display_name else tb_instance.nm_display_name end, */
case when instance_desc.id_desc is NULL then template_desc.tx_desc else instance_desc.tx_desc end as ViewName,
'Product' ViewType,
/* id_view DescriptionID, */
case when t_description.tx_desc is NULL then template_props.n_display_name else id_view end as DescriptionID,
sum(au.amount) Amount,
count(au.id_sess) Count,
au.am_currency Currency, sum((nvl((au.tax_federal), 
0.0) + nvl((au.tax_state), 0.0) + nvl((au.tax_county), 0.0) + 
nvl((au.tax_local), 0.0) + nvl((au.tax_other), 0.0))) TaxAmount, 
sum(au.amount + (nvl((au.tax_federal), 0.0) + nvl((au.tax_state), 0.0) + 
nvl((au.tax_county), 0.0) + nvl((au.tax_local), 0.0) + 
nvl((au.tax_other), 0.0))) AmountWithTax
from t_usage_interval
JOIN t_acc_usage au on au.id_acc = %%ID_ACC%%
AND au.id_usage_interval = %%INTERVAL%% AND au.id_pi_template is not NULL
JOIN t_base_props tb_template on tb_template.id_prop = au.id_pi_template
JOIN t_pi_template pi_template on pi_template.id_template = au.id_pi_template
JOIN t_pi child_kind on child_kind.id_pi = pi_template.id_pi
JOIN t_base_props pi_props on pi_props.id_prop = child_kind.id_pi
JOIN t_enum_data ed on ed.id_enum_data = au.id_view
JOIN t_base_props template_props on pi_template.id_template = template_props.id_prop
JOIN t_description template_desc on template_props.n_display_name = template_desc.id_desc AND template_desc.id_lang_code = 840 /*%%LANG_ID%%*/
LEFT OUTER JOIN t_base_props tb_instance on tb_instance.id_prop = au.id_pi_instance 
LEFT OUTER JOIN t_description instance_desc on instance_desc.id_desc = tb_instance.n_display_name  AND instance_desc.id_lang_code = 80 /*%%INTERVAL%%*/
LEFT OUTER JOIN t_pi_template parent_template on parent_template.id_template = pi_template.id_template_parent
LEFT OUTER JOIN t_pi parent_kind on parent_kind.id_pi = parent_template.id_pi
LEFT OUTER JOIN t_enum_data tenum_parent on tenum_parent.nm_enum_data = parent_kind.nm_productview
LEFT OUTER JOIN t_base_props tb_po on tb_po.id_prop = au.id_prod
LEFT OUTER JOIN t_description on t_description.id_desc = tb_po.n_display_name AND t_description.id_lang_code = 840 /*%%LANG_ID%%*/
where
t_usage_interval.id_interval = %%INTERVAL%%
GROUP BY 
/* t_pl_map.id_po,t_pl_map.id_pi_instance_parent, */
tb_po.n_display_name,tb_instance.n_display_name,
t_description.tx_desc,template_desc.tx_desc,
tb_instance.nm_display_name,tb_template.nm_display_name,
tb_instance.nm_display_name, /* this shouldn't need to be here!! */
child_kind.nm_productview,
parent_kind.nm_productview,tenum_parent.id_enum_data,
pi_props.n_kind,
id_view,ed.nm_enum_data,ed.id_enum_data,
au.am_currency,
tb_template.nm_name,
pi_template.id_template_parent,
au.id_pi_instance,
template_props.n_display_name,
instance_desc.id_desc,instance_desc.tx_desc,template_desc.id_desc
ORDER BY tb_po.n_display_name ASC, pi_template.id_template_parent ASC		
