
      select COALESCE(de2.tx_desc, de1.tx_desc) tx_desc
      from t_enum_data ed
        inner join t_description de1 on de1.id_desc = ed.id_enum_data and de1.id_lang_code = 840
        left outer join t_description de2 on de2.id_desc = ed.id_enum_data and de2.id_lang_code = %%ID_LANGUAGE%%
      where %%%UPPER%%%(ed.nm_enum_data) = %%%UPPER%%%('%%FQN%%')
