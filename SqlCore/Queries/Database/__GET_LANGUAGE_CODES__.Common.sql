
        select * from
        (
        select 
	        id_lang_code as "LanguageID", 
	        LOWER(tx_lang_code) as "LanguageCode", 
	        n_order as "PreferredOrder", 
	        tx_description as "Description" 
        from 
	        t_language 
        ) innerQuery
        where 
	        "PreferredOrder" is not null 
        order by 
	        "PreferredOrder"
			