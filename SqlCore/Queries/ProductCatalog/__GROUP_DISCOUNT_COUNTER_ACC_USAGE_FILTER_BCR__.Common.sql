
/*  CR7065: BCR discounts should count usage that falls into the discount interval */
/*  not based on dt_session, but rather on id_interval */
    t_acc_usage.dt_session BETWEEN tgs.vt_start AND tgs.vt_end AND
    t_acc_usage.id_usage_interval = %%ID_INTERVAL%%
