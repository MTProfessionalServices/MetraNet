
			update t_pv_ps_paymentscheduler
			set c_lastfourdigits = N'%%LAST_FOUR_DIGITS%%',
				c_creditcardtype = %%CREDIT_CARD_TYPE%%
			where (
				/*
				*	current-status is pending, pendingapproval, or retry
				*/
				c_currentstatus in (
					select id_enum_data from t_enum_data
						where nm_enum_data in (
							'METRATECH.COM/PAYMENTSERVER/PAYMENTSTATUS/PENDING',
							'METRATECH.COM/PAYMENTSERVER/PAYMENTSTATUS/PENDINGAPPROVAL',
							'METRATECH.COM/PAYMENTSERVER/PAYMENTSTATUS/RETRY'
						)
				)
				/* 
				*	or current-status is failed and retry count not yet exceeded
				*/ 
				or (
					c_currentstatus = (
						select id_enum_data from t_enum_data	where nm_enum_data = (
							'METRATECH.COM/PAYMENTSERVER/PAYMENTSTATUS/FAILED'
						)
					and c_numberretries < c_maxretries)
					)
				)
			and c_originalaccountid = %%ACCOUNT_ID%%
	  