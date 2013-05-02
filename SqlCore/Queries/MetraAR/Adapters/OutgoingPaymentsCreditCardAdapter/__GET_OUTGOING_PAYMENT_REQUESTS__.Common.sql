
		  
		  
				select	opr.* , 
						xrate.c_conversionrate as current_xchange_rate
				from t_be_ar_pay_outgoingpaymen opr
				left outer join t_enum_data status_enum on (status_enum.nm_enum_data = 'metratech.com/MetraAR/OutgoingPaymentStatus/Approved')
				left outer join t_foreignexchange_rates xrate on (opr.c_Currency = xrate.c_src_currency and opr.c_DivisionCurrency = xrate.c_target_currency 
				and GETDATE() BETWEEN xrate.dt_start and xrate.dt_end)
				inner join t_enum_data ed on (ed.id_enum_data = opr.c_CcType)
				where c_Status is not null and c_CcType is not null
				and ed.nm_enum_data like 'metratech.com/creditcardtype/%'

      