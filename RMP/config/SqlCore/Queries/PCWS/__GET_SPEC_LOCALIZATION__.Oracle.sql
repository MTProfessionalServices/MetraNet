
      
              BEGIN			  
              open :1 for
              select 
                id_desc ID,
                id_lang_code LanguageCode,
                tx_desc CategoryDescription                         
              from t_description where id_desc = %%ID_CATEGORY%%;
              
              open :2 for
              select 
                id_desc ID,
                id_lang_code LanguageCode,
                tx_desc DisplayNameDescription                         
              from t_description where id_desc = %%ID_DISPLAY_NAME%%;
              
             open :3 for 
             select 
                id_desc ID,
                id_lang_code LanguageCode,
                tx_desc Description                         
              from t_description where id_desc = %%ID_DESCRIPTION%%;                  
              end;
        