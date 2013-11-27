
        select de.tx_desc
        from t_description de
        inner join t_enum_data ed
        on ed.id_enum_data = de.id_desc
        where %%%UPPER%%%(ed.nm_enum_data) = %%%UPPER%%%('%%FQN%%') and de.id_lang_code = %%ID_LANGUAGE%%
      