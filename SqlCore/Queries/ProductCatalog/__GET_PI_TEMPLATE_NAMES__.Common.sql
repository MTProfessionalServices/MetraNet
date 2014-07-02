select
pit.id_template, tbp.nm_display_name
from t_pi_template pit
inner join t_base_props tbp on pit.id_template = tbp.id_prop
where 1=1
order by tbp.nm_display_name
