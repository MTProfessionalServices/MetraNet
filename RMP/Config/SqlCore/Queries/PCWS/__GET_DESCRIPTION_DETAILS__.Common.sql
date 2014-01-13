
                  select 
					          id_desc ID,
					          id_lang_code LanguageCode,
					          tx_desc Description,
					          tx_URL_desc URLDesc                           
                  from t_description where id_desc in (%%ID_DESCRIPTIONS%%)
            