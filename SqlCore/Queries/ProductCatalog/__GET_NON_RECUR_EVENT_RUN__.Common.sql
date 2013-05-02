
        select id_interval, id_run, dt_start, dt_end
        from t_nonrecurring_event_run
        where t_nonrecurring_event_run.id_interval = %%ID_INTERVAL%%
        