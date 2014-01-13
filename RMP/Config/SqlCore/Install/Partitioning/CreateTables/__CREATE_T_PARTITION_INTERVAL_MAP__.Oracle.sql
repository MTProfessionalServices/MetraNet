
        create or replace force view t_partition_interval_map as
          select 
            ui.id_interval, p.id_partition
          from t_usage_interval ui
          left outer join t_partition p
            on ui.dt_end between p.dt_start and p.dt_end
      