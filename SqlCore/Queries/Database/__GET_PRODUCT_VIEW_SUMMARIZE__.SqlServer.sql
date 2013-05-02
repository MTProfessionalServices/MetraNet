
			
			select %%VIEW_ID%% ViewID, '%%VIEW_NAME%%' ViewName, '%%VIEW_TYPE%%' ViewType, 
			  %%DESC_ID%% DescriptionID, sum(au.amount) 'Amount', au.am_currency 'Currency', count(1) 'Count',
        sum((isnull((au.tax_federal), 0.0) + isnull((au.tax_state), 0.0) + 
        isnull((au.tax_county), 0.0) + isnull((au.tax_local), 0.0) + 
        isnull((au.tax_other), 0.0))) TaxAmount, sum(au.amount + (isnull((au.tax_federal), 0.0) + 
        isnull((au.tax_state), 0.0) + isnull((au.tax_county), 0.0) + isnull((au.tax_local), 0.0) + 
        isnull((au.tax_other), 0.0))) AmountWithTax, %%ACCOUNT_ID%% AccountID, %%INTERVAL_ID%% IntervalID
			  from t_acc_usage au where au.id_acc = %%ACCOUNT_ID%% and 
        au.id_usage_interval = %%INTERVAL_ID%% and au.id_view = %%VIEW_ID%% and au.id_parent_sess is NULL %%EXT%%
        group by au.am_currency
		