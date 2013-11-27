
                select
				  ppt.id_pending_payment "PendingPaymentId",
	              ppt.id_interval "IntervalId", 
                  ppt.id_acc "AccountId",
                  ppt.id_payment_instrument "N_PaymentInstrument",
                  pptd.nm_invoice_num "NM_INVOICENUM",
                  pptd.dt_invoice "DT_INV_DATE",
	              pptd.nm_po_number "NM_PONUM",
                  ppt.nm_description "NM_DESCRIPTION",
                  ppt.nm_currency "NM_CURRENCY",
                  ppt.n_amount "N_AMOUNT",
				  pptd.n_amount "AMOUNTTOPAY"
                from
	                t_pending_payment_trans ppt
					left outer join t_pending_payment_trans_dtl pptd on ppt.id_pending_payment = pptd.id_pending_payment
	                inner join t_payment_instrument pi on ppt.id_payment_instrument = pi.id_payment_instrument
	                inner join t_enum_data ed on pi.n_payment_method_type = ed.id_enum_data
	                inner join t_billgroup bg on bg.id_usage_interval = ppt.id_interval
	                inner join t_billgroup_member bgm on bg.id_billgroup = bgm.id_billgroup and bgm.id_acc = ppt.id_acc
                where
	                ppt.id_interval = %%INTERVAL_ID%% and
	                bg.id_billgroup = %%BILLGROUP_ID%% and
                  ppt.b_scheduled = 0 and
	                ppt.n_amount > 0 and
	                id_authorization is null and
	                ed.nm_enum_data = 'metratech.com/paymentserver/PaymentType/Credit Card'
        