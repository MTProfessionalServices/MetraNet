
    select 
      ts.id_sub id_sub,
      ts.id_sub_ext id_sub_ext,
      ts.id_group id_group,
      ts.id_po id_po,
      ts.vt_start vt_start,
      ts.vt_end vt_end,
      tg.id_group_ext,
      tg.id_usage_cycle usage_cycle,
      tg.b_visable b_visable,
      tg.tx_name tx_name,
      tg.tx_desc tx_desc,
      tg.b_proportional b_proportional,
      tg.b_supportgroupops b_supportgroupops,
      tg.id_corporate_account corporate_account,
      tg.id_discountaccount discount_account
    FROM
      t_sub ts
    INNER JOIN t_group_sub tg on ts.id_group = tg.id_group
    INNER JOIN t_account_ancestor root on root.id_descendent = %%ID_ACC%% AND
      root.id_ancestor = 1 AND %%REFDATE%% BETWEEN root.vt_start and root.vt_end
    INNER JOIN t_account_ancestor corporate on corporate.num_generations = root.num_generations - 1 AND
      corporate.id_descendent = %%ID_ACC%% AND 
     ((corporate.vt_end IS NOT NULL AND %%REFDATE%% between corporate.vt_start AND corporate.vt_end) or (corporate.vt_end IS NULL AND %%REFDATE%% >= corporate.vt_start)) AND
     ((ts.vt_end IS NOT NULL AND %%REFDATE%% between ts.vt_start AND ts.vt_end) or (ts.vt_end IS NULL AND %%REFDATE%% >= ts.vt_start))
    /* CR 13655 make sure that PO is either wide open or allows template account type */
    LEFT OUTER JOIN t_acc_template at ON id_folder = %%ID_ACC%% and id_acc_type = %%ACCOUNT_TYPE%%
    LEFT OUTER JOIN t_po_account_type_map atm ON ts.id_po = atm.id_po
    LEFT OUTER JOIN t_acc_tmpl_types tp ON tp.id = 1
    WHERE
      ts.id_group IS NOT NULL AND tg.id_corporate_account = %%CORPORATEACCOUNT%% 
    AND ts.id_po not in 
    (
      select ts1.id_po from t_acc_template_subs_pub tsubs
      INNER JOIN t_group_sub tg1 on tsubs.id_group = tg1.id_group
      INNER JOIN t_sub ts1 on ts1.id_group = tg1.id_group
      where id_acc_template = at.id_acc_template
    )
    AND (atm.id_account_type IS NULL OR atm.id_account_type = %%ACCOUNT_TYPE%% OR tp.all_types = 1)
		