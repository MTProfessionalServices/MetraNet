
	  
		/* __GET_PAYMENT_HISTORY__ */
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
				WHERE au.id_acc = :idAcc and au.id_view = :viewId
				ORDER BY event_date


		