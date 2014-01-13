
        select
          t_pl_map.id_pi_instance piInstance,
          t_sub.id_acc idAccount,
          t_usage_interval.dt_start subStart,
          t_usage_interval.dt_end subEnd,
          t_sub.vt_start effStart,
          t_sub.vt_end effEnd
        from
          t_base_props,
          t_pl_map,
          t_sub,
          t_account,
          t_acc_usage_interval,
          t_usage_interval
        where
          t_base_props.n_kind = %%PRICEABLE_ITEM_KIND%% AND
          t_base_props.id_prop = t_pl_map.id_pi_type AND
          t_pl_map.id_sub = t_sub.id_sub AND
          t_sub.id_acc = t_account.id_acc AND
          t_account.id_acc = t_acc_usage_interval.id_acc AND
          t_acc_usage_interval.id_usage_interval = t_usage_interval.id_interval AND
          t_acc_usage_interval.id_usage_interval = %%INTERVAL_ID%%
      