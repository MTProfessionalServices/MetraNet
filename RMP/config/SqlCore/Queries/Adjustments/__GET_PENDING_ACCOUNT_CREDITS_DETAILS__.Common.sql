
              select
                pv.*,
                au.id_view ViewID,
                au.id_sess SessionID,
                au.amount Amount,
				au.tax_federal FederalTaxAmount, 
				au.tax_state StateTaxAmount,
				au.tax_county CountyTaxAmount,
				au.tax_local LocalTaxAmount,
				au.tax_other OtherTaxAmount,
                au.am_currency Currency,
                au.dt_session Timestamp,
                au.id_usage_interval IntervalID,
                
                (%%NULL_CLAUSE%%((au.tax_federal), 0.0) + %%NULL_CLAUSE%%((au.tax_state), 0.0) + %%NULL_CLAUSE%%((au.tax_county), 0.0) +
                %%NULL_CLAUSE%%((au.tax_local), 0.0) + %%NULL_CLAUSE%%((au.tax_other), 0.0)) TaxAmount,
                au.amount +
                /*If implied taxes, then taxes are already included, don't add them again */				
				  (case when au.is_implied_tax = 'N' then (%%NULL_CLAUSE%%((au.tax_federal), 0.0) + %%NULL_CLAUSE%%((au.tax_state), 0.0) + %%NULL_CLAUSE%%((au.tax_county), 0.0) +
                    %%NULL_CLAUSE%%((au.tax_local), 0.0) + %%NULL_CLAUSE%%((au.tax_other), 0.0)) else 0 end)
				  /*If informational taxes, then they shouldn't be in the total */
				  - (case when au.is_implied_tax = 'Y' then (%%NULL_CLAUSE%%((au.tax_federal), 0.0) + %%NULL_CLAUSE%%((au.tax_state), 0.0) + %%NULL_CLAUSE%%((au.tax_county), 0.0) +
                    %%NULL_CLAUSE%%((au.tax_local), 0.0) + %%NULL_CLAUSE%%((au.tax_other), 0.0)) else 0 end)
				  AmountWithTax,
                'Atomic' SessionType
              from t_pv_AccountCreditRequest pv
              inner join t_acc_usage au on au.id_sess = pv.id_sess
              inner join t_description d on pv.c_reason = d.id_desc
              where 
              au.id_parent_sess is NULL AND au.id_pi_instance is NULL
              and id_lang_code = %%ID_LANG_CODE%%
              %%STATUS%%
			