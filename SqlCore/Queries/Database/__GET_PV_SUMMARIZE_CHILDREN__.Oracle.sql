select %%VIEW_ID%% ViewID, '%%VIEW_NAME%%' ViewName, '%%VIEW_TYPE%%' ViewType, 
			  %%DESC_ID%% DescriptionID, sum(au.amount) Amount, au.am_currency Currency, count(1) Count,
        sum(nvl(au.tax_federal, 0.0) + nvl(au.tax_state, 0.0) + nvl(au.tax_county, 0.0) + 
        nvl(au.tax_local, 0.0) + nvl(au.tax_other, 0.0)) TaxAmount, 
        sum(nvl(au.Amount,0.0)  
			        /*If implied taxes, then taxes are already included, don't add them again */
			        + (CASE WHEN (au.is_implied_tax = 'N') THEN (nvl(au.Tax_Federal,0.0) + nvl(au.Tax_State,0.0) 
					    + nvl(au.Tax_County,0.0) + nvl(au.Tax_Local,0.0) + nvl(au.Tax_Other,0.0)) else 0 end) 
			        /*If informational taxes, then they shouldn't be in the total */
			        - (CASE WHEN (au.tax_informational = 'Y') THEN (nvl(au.Tax_Federal,0.0) + nvl(au.Tax_State,0.0)
    				    + nvl(au.Tax_County,0.0) + nvl(au.Tax_Local,0.0) + nvl(au.Tax_Other,0.0)) else 0 end))
			AmountWithTax,
        %%ACCOUNT_ID%% AccountID, %%INTERVAL_ID%% IntervalID from t_acc_usage au 
        where au.id_parent_sess = %%PARENT_ID%% and au.id_acc = %%ACCOUNT_ID%% and 
        au.id_usage_interval = %%INTERVAL_ID%% and au.id_view = %%VIEW_ID%% group by au.am_currency