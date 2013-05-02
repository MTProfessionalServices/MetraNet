
              select
                pv.*,
                au.id_view ViewID,
                au.id_sess SessionID,
                au.amount Amount,
                au.am_currency Currency,
                au.dt_session Timestamp,
                au.id_usage_interval IntervalID,
                
                (%%NULL_CLAUSE%%((au.tax_federal), 0.0) + %%NULL_CLAUSE%%((au.tax_state), 0.0) + %%NULL_CLAUSE%%((au.tax_county), 0.0) +
                %%NULL_CLAUSE%%((au.tax_local), 0.0) + %%NULL_CLAUSE%%((au.tax_other), 0.0)) TaxAmount,
                (au.amount +
                %%NULL_CLAUSE%%((au.tax_federal), 0.0) + %%NULL_CLAUSE%%((au.tax_state), 0.0) + %%NULL_CLAUSE%%((au.tax_county), 0.0) +
                %%NULL_CLAUSE%%((au.tax_local), 0.0) + %%NULL_CLAUSE%%((au.tax_other), 0.0)) AmountWithTax,
                'Atomic' SessionType
              from t_pv_AccountCreditRequest pv
              inner join t_acc_usage au on au.id_sess = pv.id_sess
              inner join t_description d on pv.c_reason = d.id_desc
              where 
              au.id_parent_sess is NULL AND au.id_pi_instance is NULL
              and id_lang_code = %%ID_LANG_CODE%%
              %%STATUS%%
			