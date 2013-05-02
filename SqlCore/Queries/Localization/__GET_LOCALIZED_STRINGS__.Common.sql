
        select * from
        (
        select ed.nm_enum_data, d.id_desc DescriptionID, d.id_lang_code LanguageID,
        d.tx_desc Description 
        from t_description d
        left outer join t_enum_data ed on d.id_desc = ed.id_enum_data
        ) innerQuery
				order by DescriptionID
      