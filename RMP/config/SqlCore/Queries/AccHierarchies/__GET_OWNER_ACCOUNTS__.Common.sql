
       select 
       /* __GET_OWNER_ACCOUNTS__ */
       own.id_owner, own.id_owned, own.id_relation_type, own.n_percent, map.hierarchyname,
      own.vt_start, own.vt_end,
      case WHEN des.tx_desc is NULL THEN ed.nm_enum_data ELSE des.tx_desc END AS RelationType
      from
      t_acc_ownership own
      inner join vw_mps_or_system_hierarchyname map on own.id_owner = map.id_acc
      inner join t_enum_data ed on own.id_relation_type = ed.id_enum_data
      left outer join t_description des on des.id_desc = ed.id_enum_data AND id_lang_code = %%ID_LANG%%
      WHERE
      own.id_owned = %%ID_ACC%%
      /* return all historical data for now */
      /* AND own.vt_start <= %%REF_DATE%% and own.vt_end > %%REF_DATE%%  */
      and own.tt_end = %%MAX_DATE%%
        