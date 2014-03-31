
            select 
              pv.*,
              au.am_currency Currency,
							au.amount Amount,
				      au.tax_federal FedTax,
				      au.tax_state StateTax,
				      au.tax_local LocalTax,
				      au.tax_county CountyTax,
				      au.tax_other OtherTax
            from t_pv_AccountCreditRequest pv
            inner join t_acc_usage au on pv.id_sess = au.id_sess 
            where c_Status = 'PENDING' and pv.id_sess in (%%SESSION_IDS%%)          
			