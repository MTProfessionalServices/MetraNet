
          select
          ts.id_sub,ts.id_sub_ext,ts.id_acc,
          ts.id_group,ts.id_po,ts.dt_crt,ts.vt_start,ts.vt_end,
          tg.id_group_ext,tg.tx_name,tg.tx_desc,
          tg.b_visable,tg.id_usage_cycle usage_cycle,
          tg.b_proportional,tg.b_supportgroupops,
          tg.id_corporate_account corporate_account,tg.id_discountaccount discount_account
          from t_sub ts
          LEFT OUTER JOIN t_group_sub tg on tg.id_group = ts.id_group
          where id_sub =  %%ID_SUB%%

        