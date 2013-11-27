select d.id_desc DescriptionID, d.id_lang_code LanguageID, l.tx_lang_code LanguageCode, 
        d.tx_desc Description from t_description d, t_language l 
        where d.id_lang_code = l.id_lang_code
      