select
pv.id_view, pv.nm_name, pv.nm_table_name, d.tx_desc
from t_prod_view pv
inner join t_description d on d.id_desc = pv.id_view
where 1=1
and d.id_lang_code = %%ID_LANG_CODE%%
order by d.tx_desc
