select
pv.id_view, pv.nm_name, pv.nm_table_name
from t_prod_view pv
where 1=1
order by pv.nm_table_name
