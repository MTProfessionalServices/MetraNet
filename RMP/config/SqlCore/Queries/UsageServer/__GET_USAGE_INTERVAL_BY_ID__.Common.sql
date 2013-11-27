

          select ui.id_interval IntervalID, ui.dt_start StartDate,
          ui.dt_end EndDate, ui.id_usage_cycle CycleID,
          ui.tx_interval_status Status from t_usage_interval ui where
          ui.id_interval = %%INTERVAL_ID%%

        