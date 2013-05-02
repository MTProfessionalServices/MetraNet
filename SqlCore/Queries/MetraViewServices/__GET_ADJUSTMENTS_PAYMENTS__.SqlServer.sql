
			/* __GET_AR_ADJUSTMENTS_REPORT__ */
			SELECT
				au.id_sess as id_sess,
				au.amount as amount,
				au.am_currency as "currency",
				pv.c_Description as "description",
				pv.c_EventDate as event_date,
				rcdescr.tx_desc as reason_code
			  FROM
				t_pv_ARAdjustment pv
				JOIN t_acc_usage au on au.id_sess = pv.id_sess and au.id_usage_interval = pv.id_usage_interval
				LEFT OUTER JOIN t_description rcdescr ON pv.c_ReasonCode = rcdescr.id_desc AND rcdescr.id_lang_code = @idLangcode
			  WHERE au.id_acc = @idAcc AND au.id_usage_interval = @idInterval 
			ORDER BY pv.c_EventDate

			/* __GET_PAYMENTS_REPORT__ */
			SELECT
			  au.id_sess as id_sess,
			  au.amount as amount,
			  au.am_currency as "currency",
			  pv.c_Description as "description",
			  pv.c_EventDate as event_date,
				  pv.c_ReasonCode as reason_code,
				  pv.c_PaymentMethod as payment_method,
				  pv.c_CCType as cc_type,
			  pv.c_CheckOrCardNumber as check_or_card_number
			FROM
				  t_acc_usage au
				  JOIN t_pv_Payment pv on au.id_sess = pv.id_sess and au.id_usage_interval=pv.id_usage_interval
			WHERE au.id_acc = @idAcc AND au.id_usage_interval = @idInterval and au.id_view = @viewId
			ORDER BY pv.c_EventDate

			/* __GET_POSTBILL_ADJUSTMENTS_REPORT__ */
			SELECT
				ajs.PostbillAdjAmt AS amount,
				ajs.PostbillTaxAdjAmt AS tax_adjustment_amount,               
				ajs.PostbillFedTaxAdjAmt AS federal_tax_adjustment_amount,               
				ajs.PostbillStateTaxAdjAmt AS state_tax_adjustment_amount,               
				ajs.PostbillCntyTaxAdjAmt AS county_tax_adjustment_amount,               
				ajs.PostbillLocalTaxAdjAmt AS local_tax_adjustment_amount,               
				ajs.PostbillOtherTaxAdjAmt AS other_tax_adjustment_amount,               
				ajs.am_currency as currency,
				NumPostbillAdjustments AS count
				FROM
				vw_adjustment_summary ajs
			  WHERE ajs.id_acc = @idAcc AND ajs.id_usage_interval = @idInterval
		  
		