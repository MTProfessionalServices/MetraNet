
			select id_view ViewID, t_description.tx_desc ViewName, 
			'Product' ViewType, id_view DescriptionID, sum(au.amount) 'Amount', 
			au.am_currency 'Currency', count(1) 'Count', sum((isnull((au.tax_federal), 
			0.0) + isnull((au.tax_state), 0.0) + isnull((au.tax_county), 0.0) + 
			isnull((au.tax_local), 0.0) + isnull((au.tax_other), 0.0))) TaxAmount, 
            sum (isnull(au.Amount,0.0)  
			  /*If implied taxes, then taxes are already included, don't add them again */
			  + (CASE WHEN (au.is_implied_tax = 'N') THEN (isnull(au.Tax_Federal,0.0) + isnull(au.Tax_State,0.0) 
			      + isnull(au.Tax_County,0.0) + isnull(au.Tax_Local,0.0) + isnull(au.Tax_Other,0.0)) else 0 end) 
			  /*If informational taxes, then they shouldn't be in the total */
			  - (CASE WHEN (au.tax_informational = 'Y') THEN (isnull(au.Tax_Federal,0.0) + isnull(au.Tax_State,0.0) 
			      + isnull(au.Tax_County,0.0) + isnull(au.Tax_Local,0.0) + isnull(au.Tax_Other,0.0)) else 0 end)) 
			   AmountWithTax, 
			%%ACCOUNT_ID%% AccountID, %%INTERVAL_ID%% IntervalID from 
			t_acc_usage au, t_description where au.id_acc = 
			%%ACCOUNT_ID%% and au.id_usage_interval = %%INTERVAL_ID%% and 
			au.id_view %%VIEW_IDS%% and 
			au.id_parent_sess is NULL AND au.id_prod is NULL AND au.id_pi_instance is NULL
			and t_description.id_lang_code = %%LANGID%% and
			t_description.id_desc = au.id_view
			group by au.am_currency, au.id_view,t_description.tx_desc
			