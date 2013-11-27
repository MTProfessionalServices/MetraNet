
select dbo.addsecond(dt_end) as dt_start 
from t_pc_interval 
where id_cycle=%%ID_USAGE_CYCLE%% 
and dt_start <= %%DT_EFF%% AND %%DT_EFF%% <= dt_end
  