
      select id_run RunID, id_interval IntervalID, dt_start StartDate, dt_end EndDate,
      tx_adapter_name AdapterName from t_recurring_event_run where id_interval = %%INTERVAL_ID%%
        