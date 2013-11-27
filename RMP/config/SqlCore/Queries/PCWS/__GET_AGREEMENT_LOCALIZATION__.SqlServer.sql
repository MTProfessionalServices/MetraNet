
              select 
                id_desc ID,
                id_lang_code LanguageCode,
                tx_desc DisplayNameDescription                         
              from t_description where id_desc = %%ID_DISPLAY_NAME%%;
              
             select 
                id_desc ID,
                id_lang_code LanguageCode,
                tx_desc Description                         
              from t_description where id_desc = %%ID_DESCRIPTION%%;