
	      INSERT INTO t_tax_details (id_tax_detail, 
	      id_tax_charge, id_acc, id_usage_inteval, 
	      id_tax_run, dt_calc, amount,
	      rate, tax_jur_level, tax_jur_name,
	      tax_type, tax_type_name, is_implied,
	      notes
	      )
	      VALUES (%%ID_TAX_DETAIL%%, 
	      %%ID_TAX_CHG%%, %%ID_ACC%%, %%ID_USAGE_INTERVAL%%,
	      %%ID_TAX_RUN%%, %%DT_CALC%%, %%AMOUNT%%,
	      %%RATE%%, %%TAX_JUR_LEVEL%%, '%%TAX_JUR_NAME%%',
	      %%TAX_TYPE%%, '%%TAX_TYPE_NAME%%', '%%IS_IMPLIED%%', '%%NOTES%%'
	      )
      