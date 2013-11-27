
INNER JOIN
(
  SELECT
    dt_start,
    dt_end
  FROM t_usage_interval
  WHERE id_interval = %%ID_INTERVAL%%
) ui ON inst.dt_arg_start <= ui.dt_end AND
        inst.dt_arg_end >= ui.dt_start
      