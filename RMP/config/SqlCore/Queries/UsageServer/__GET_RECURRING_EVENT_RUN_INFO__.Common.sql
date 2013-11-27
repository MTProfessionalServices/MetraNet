
      select id_interval IntervalID, tx_adapter_name AdapterName, tx_adapter_method ProgID,
      tx_config_file ConfigFile from t_recurring_event_run where id_run = %%RUN_ID%%
        