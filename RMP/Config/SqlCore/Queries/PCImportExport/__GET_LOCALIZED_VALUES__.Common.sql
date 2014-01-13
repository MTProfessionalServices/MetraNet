
				SELECT * FROM t_description td
				INNER JOIN t_language tl ON tl.id_lang_code = td.id_lang_code  
				WHERE td.id_desc = %%DESC_ID%%
			