
       select 
       /* __GET_OWNED_ACCOUNTS_HIERARCHICAL__ */
       own.id_owner, own.id_owned, own.id_relation_type, own.n_percent,
      own.vt_start, own.vt_end,
      case WHEN des.tx_desc is NULL THEN ed.nm_enum_data ELSE des.tx_desc END AS RelationType,
      /* gui hint */
      CASE WHEN anc.num_generations = 0 THEN 1 ELSE 0 END DirectOwner,
      ownername.hierarchyname OwnerName,
      ownedname.hierarchyname OwnedName
      from t_account_ancestor anc
      inner join t_acc_ownership own on anc.id_descendent = own.id_owner
      /* make sure that the descendent existed in the hieararchy as of SYSTEMDATE */
      inner join t_account_ancestor ownedanc on ownedanc.id_descendent = own.id_owned AND ownedanc.num_generations = 0
      inner join vw_mps_or_system_hierarchyname ownedname on ownedname.id_acc = own.id_owned
      inner join vw_mps_or_system_hierarchyname ownername on ownername.id_acc = own.id_owner
      inner join t_enum_data ed on own.id_relation_type = ed.id_enum_data
      left outer join t_description des on des.id_desc = ed.id_enum_data AND id_lang_code = %%ID_LANG%%
      WHERE
      anc.id_ancestor = %%ID_ACC%%
      AND own.vt_start <= %%%SYSTEMDATE%%% and own.vt_end > %%%SYSTEMDATE%%%
      AND anc.vt_start <= %%%SYSTEMDATE%%% and anc.vt_end > %%%SYSTEMDATE%%%
      AND ownedanc.vt_start <= %%%SYSTEMDATE%%% and ownedanc.vt_end > %%%SYSTEMDATE%%%
      /* VIEW_CONSTRAINT is based on the combination of capability check and a "ViewHint" flag */
      AND anc.num_generations < %%VIEW_CONSTRAINT%%
      and own.tt_end = %%MAX_DATE%%
      UNION ALL
      /* Also get the accounts owned by folders that you are incumbent of */
      select 
      own.id_owner, own.id_owned, own.id_relation_type, own.n_percent,
      own.vt_start, own.vt_end,
      case WHEN des.tx_desc is NULL THEN ed.nm_enum_data ELSE des.tx_desc END AS RelationType,
      /* gui hint */
      0 DirectOwner,
      ownername.hierarchyname OwnerName,
      ownedname.hierarchyname OwnedName
      from t_impersonate incum
      inner join t_account_ancestor anc ON incum.id_acc = anc.id_ancestor
      inner join t_acc_ownership own on anc.id_descendent = own.id_owner
      /* make sure that the descendent existed in the hieararchy as of SYSTEMDATE */
      inner join t_account_ancestor ownedanc on ownedanc.id_descendent = own.id_owned AND ownedanc.num_generations = 0
      inner join vw_mps_or_system_hierarchyname ownedname on ownedname.id_acc = own.id_owned
      inner join vw_mps_or_system_hierarchyname ownername on ownername.id_acc = own.id_owner
      inner join t_enum_data ed on own.id_relation_type = ed.id_enum_data
      left outer join t_description des on des.id_desc = ed.id_enum_data AND id_lang_code = %%ID_LANG%%
      WHERE
      incum.id_owner = %%ID_ACC%% 
      /* below predicate is to eliminate duplicate results for the case where ID_ACC owns an account directy 
      and is at the same time an incumbent of the folder, which is located above him in SFH */
      AND anc.id_descendent <> %%ID_ACC%%
      AND own.vt_start <= %%%SYSTEMDATE%%% and own.vt_end > %%%SYSTEMDATE%%%
      AND anc.vt_start <= %%%SYSTEMDATE%%% and anc.vt_end > %%%SYSTEMDATE%%%
      AND ownedanc.vt_start <= %%%SYSTEMDATE%%% and ownedanc.vt_end > %%%SYSTEMDATE%%%
      /* VIEW_CONSTRAINT is based on the combination of capability check and a "ViewHint" flag */
      AND anc.num_generations < %%VIEW_CONSTRAINT%%
      and own.tt_end = %%MAX_DATE%%
        