
      insert into t_description (id_desc, id_lang_code, tx_desc)
				select %%DESC_ID%%,id_lang_code, N'%%TX_DESC%%' from t_language lang
				where LOWER(tx_lang_code) = LOWER('%%COUNTRYCODE_STRING%%')
				AND NOT EXISTS (SELECT * from t_description td WHERE td.id_lang_code = lang.id_lang_code and td.id_desc = %%DESC_ID%%)
      