
	      INSERT INTO %%TABLE_NAME%% (id_tax_charge, 
	      tax_fed_amount, tax_fed_name, tax_fed_rounded, 
	      tax_state_amount, tax_state_name, tax_state_rounded,
	      tax_county_amount, tax_county_name, tax_county_rounded,
	      tax_local_amount, tax_local_name, tax_local_rounded,
	      tax_other_amount, tax_other_name, tax_other_rounded
	      )
	      VALUES (%%ID_TAX_CHG%%, 
	      %%FED_AMT%%, '%%FED_NAME%%', %%FED_RND%%,
	      %%STATE_AMT%%, '%%STATE_NAME%%', %%STATE_RND%%,
	      %%COUNTY_AMT%%, '%%COUNTY_NAME%%', %%COUNTY_RND%%,
	      %%LOCAL_AMT%%, '%%LOCAL_NAME%%', %%LOCAL_RND%%,
	      %%OTHER_AMT%%, '%%OTHER_NAME%%', %%OTHER_RND%%
	      )
      