
				SELECT id_lang_code LanguageCode, tx_desc DisplayName
  FROM t_recur JOIN t_description ON t_recur.n_unit_display_name = t_description.id_desc WHERE t_recur.id_prop = @id_prop