select
ui.id_interval, ui.tx_interval_status, ui.dt_start, ui.dt_end, ct.tx_desc, cast(DENSE_RANK() over (order by case when ui.tx_interval_status='O' then 0 else 1 end, ui.dt_start) as int) n_order
from t_usage_interval ui
inner join t_usage_cycle c on c.id_usage_cycle = ui.id_usage_cycle
inner join t_usage_cycle_type ct on ct.id_cycle_type = c.id_cycle_type
where 1=1
and ui.tx_interval_status in ('H', 'O', 'B')
order by ui.id_interval asc
