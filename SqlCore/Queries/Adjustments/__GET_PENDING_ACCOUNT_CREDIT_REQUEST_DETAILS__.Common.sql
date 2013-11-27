
              select
                pv.c_Other Other,
                pv.c_Status Status,
                pv.c_CreditAmount AdjustmentAmount,
                pv.c_EmailNotification EmailNotification,
                pv.c_EmailAddress EmailAddress,
                pv.c_ContentionSessionID ContentionSessionId,
                pv.c_Description Description,
                pv.c_SubscriberAccountID SubscriberAccountId,
                pv.c_GuideIntervalID GuideIntervalId,
                au.id_view ViewId,
                au.id_sess SessionId,
                au.amount Amount,
                au.am_currency Currency,
                au.dt_session Timestamp,
                au.id_usage_interval IntervalId,
                pv.c_Reason Reason,
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
			