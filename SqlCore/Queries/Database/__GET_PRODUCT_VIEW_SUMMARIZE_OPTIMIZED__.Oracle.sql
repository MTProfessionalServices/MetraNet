
                        select id_view ViewID, t_description.tx_desc ViewName, 
			'Product' ViewType, id_view DescriptionID, sum(au.amount) Amount, 
			au.am_currency Currency, count(1) Count, sum(nvl(au.tax_federal, 0.0) 
                        + nvl(au.tax_state, 0.0) + nvl(au.tax_county, 0.0) + 
                        nvl(au.tax_local, 0.0) + nvl(au.tax_other, 0.0)) TaxAmount, 
                        sum(nvl(au.amount, 0.0) + nvl(au.tax_federal, 0.0) + nvl(au.tax_state, 0.0) + 
                        nvl(au.tax_county, 0.0) + nvl(au.tax_local, 0.0) + 
                        nvl(au.tax_other, 0.0)) AmountWithTax,
                        %%ACCOUNT_ID%% AccountID, %%INTERVAL_ID%% IntervalID from 
			t_acc_usage au,t_description where au.id_acc =
                        %%ACCOUNT_ID%% and au.id_usage_interval = %%INTERVAL_ID%% and 
			au.id_view %%VIEW_IDS%% and  
			au.id_parent_sess is NULL AND au.id_prod is NULL AND au.id_pi_instance is NULL
			and t_description.id_lang_code = %%LANGID%% and
			t_description.id_desc = au.id_view
			group by au.am_currency, au.id_view,t_description.tx_desc 
			