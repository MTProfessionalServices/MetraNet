
   		IF EXISTS (SELECT * FROM %%NETMETER_DB_NAME%%.sys.tables WHERE NAME = 't_pv_audioconfcall' and type = 'U')
			BEGIN
	insert into t_rpt_parent_summary
	/* Conferences */
	select inv.id_invoice InvoiceID,
	au.id_payee PayeeIDAcc,
	ISNULL(PayeeContact.c_FirstName + N' ', N'') +
	ISNULL(PayeeContact.c_MiddleInitial + N' ', N'') +
	ISNULL(PayeeContact.c_LastName, N'') PayeeName,
	au.id_sess SessionID,
	call.c_ConferenceID ConferenceID,
	call.c_ActualStartTime  ConfDate,
	call.c_ActualDuration Duration,
	call.c_ConferenceName ConfName,
	call.c_ConferenceSubject ConfSubject,
	call.c_ActualNumConnections TotalConnections,
	au.amount + isnull(au.tax_federal, 0) + isnull(au.tax_state, 0) + isnull(au.tax_county, 0) + isnull(au.tax_local, 0) + isnull(au.tax_other, 0) ConfAmount,
	descr.tx_desc ItemDescription,
	call.c_ReservationCharges ReservationCharges,
	call.c_CancelCharges CancelCharges,
	call.c_OverusedPortCharges OverUsedPortCharges,
	call.c_UnusedPortCharges UnUsedPortCharges,
	call.c_AdjustmentAmount Adjustments

	from %%NETMETER_DB_NAME%%..t_invoice inv
		inner join %%NETMETER_DB_NAME%%..t_billgroup_member bgm
			on inv.id_acc = bgm.id_acc and bgm.id_billgroup = %%ID_BILLGROUP%% 
		inner join %%NETMETER_DB_NAME%%..t_billgroup bg
			on inv.id_interval = bg.id_usage_interval
			and bg.id_billgroup = %%ID_BILLGROUP%% 
		inner join %%NETMETER_DB_NAME%%..t_acc_usage au
			on inv.id_acc = au.id_acc
			and inv.id_interval = au.id_usage_interval
		left outer join %%NETMETER_DB_NAME%%..t_av_contact PayeeContact
			on au.id_payee = PayeeContact.id_acc
		left outer join %%NETMETER_DB_NAME%%..t_enum_data edContactType
			on PayeeContact.c_contacttype = edContactType.id_enum_data
			and edContactType.nm_enum_data = 'metratech.com/accountcreation/contacttype/bill-to'	
		inner join %%NETMETER_DB_NAME%%..t_pv_audioconfcall call
			on au.id_sess = call.id_sess
		inner join %%NETMETER_DB_NAME%%..t_view_hierarchy vw
			on au.id_view = vw.id_view
		inner join %%NETMETER_DB_NAME%%..t_av_internal payerInternal
			on inv.id_acc = payerInternal.id_acc
		inner join %%NETMETER_DB_NAME%%..t_enum_data edLanguage  /* Use the payer's language for localized settings */
			on edLanguage.id_enum_data = payerInternal.c_Language
		inner join %%NETMETER_DB_NAME%%..t_language lang
 			on 'Global/LanguageCode/' + lang.tx_lang_code = edLanguage.nm_enum_data
		inner join %%NETMETER_DB_NAME%%..t_description descr
			on descr.id_desc = vw.id_view
			and descr.id_lang_code = lang.id_lang_code
	where inv.invoice_amount <> 0

	/* Non-Conference Charges */
	union
	select inv.id_invoice InvoiceID,
	au.id_payee PayeeIDAcc,
	ISNULL(PayeeContact.c_FirstName + N' ', N'') +
	ISNULL(PayeeContact.c_MiddleInitial + N' ', N'') +
	ISNULL(PayeeContact.c_LastName, N'') PayeeName,
	au.id_sess SessionID,
	NULL ConferenceID,
	au.dt_session ConfDate,
	NULL Duration,
	NULL ConfName,
	NULL ConfSubject,
	NULL TotalConnections,
	au.amount + isnull(au.tax_federal, 0) + isnull(au.tax_state, 0) + isnull(au.tax_county, 0) + isnull(au.tax_local, 0) + isnull(au.tax_other, 0) ConfAmount,
	descr.tx_desc ItemDescription,
	NULL ReservationCharges,
	NULL CancelCharges,
	NULL OverUsedPortCharges,
	NULL UnUsedPortCharges,
	NULL Adjustments

	from %%NETMETER_DB_NAME%%..t_invoice inv
		inner join %%NETMETER_DB_NAME%%..t_billgroup_member bgm
			on inv.id_acc = bgm.id_acc and bgm.id_billgroup = %%ID_BILLGROUP%% 
		inner join %%NETMETER_DB_NAME%%..t_billgroup bg
			on inv.id_interval = bg.id_usage_interval
			and bg.id_billgroup = %%ID_BILLGROUP%% 
		inner join %%NETMETER_DB_NAME%%..t_acc_usage au
			on inv.id_acc = au.id_acc
			and inv.id_interval = au.id_usage_interval
		left outer join %%NETMETER_DB_NAME%%..t_av_contact PayeeContact
			on au.id_payee = PayeeContact.id_acc
		left outer join %%NETMETER_DB_NAME%%..t_enum_data edContactType
			on PayeeContact.c_contacttype = edContactType.id_enum_data
			and edContactType.nm_enum_data = 'metratech.com/accountcreation/contacttype/bill-to'	
		inner join %%NETMETER_DB_NAME%%..t_enum_data edViewType
			on au.id_view = edViewType.id_enum_data
		inner join %%NETMETER_DB_NAME%%..t_view_hierarchy vw
			on au.id_view = vw.id_view
		inner join %%NETMETER_DB_NAME%%..t_enum_data edView
			on au.id_view = edView.id_enum_data
		inner join %%NETMETER_DB_NAME%%..t_av_internal payerInternal
			on inv.id_acc = payerInternal.id_acc
		inner join %%NETMETER_DB_NAME%%..t_enum_data edLanguage
			on edLanguage.id_enum_data = payerInternal.c_Language
		inner join %%NETMETER_DB_NAME%%..t_language lang
 			on 'Global/LanguageCode/' + lang.tx_lang_code = edLanguage.nm_enum_data
		inner join %%NETMETER_DB_NAME%%..t_description descr
			on descr.id_desc = vw.id_view
			and descr.id_lang_code = lang.id_lang_code
	
	where au.id_parent_sess is NULL
	  and au.amount <> 0
	  and edViewType.nm_enum_data <> ('metratech.com/audioconfcall') /* This list should match the list in the last query of the Call Detail Records */
	  and inv.invoice_amount <> 0
	
/*     post bill / pre bill and ar ajustment details.  This is just useful for making sure the 
        totals match.. we are not splitting out the adjustments with the pi type. */

	union
	select inv.id_invoice InvoiceID,
	au.id_payee PayeeIDAcc,
	ISNULL(PayeeContact.c_FirstName + N' ', N'') +
	ISNULL(PayeeContact.c_MiddleInitial + N' ', N'') +
	ISNULL(PayeeContact.c_LastName, N'') PayeeName,
	/*isnull(au.id_parent_sess, au.id_sess) SessionID,*/
	aj.id_adj_trx SessionID,
	NULL ConferenceID,
	aj.dt_Modified ConfDate,
	NULL Duration,
	NULL ConfName,
	NULL ConfSubject,
	NULL TotalConnections,
	sum(aj.AdjustmentAmount) ConfAmount,
	'Adjustments' ItemDescription,
	NULL ReservationCharges,
	NULL CancelCharges,
	NULL OverUsedPortCharges,
	NULL UnUsedPortCharges,
	NULL Adjustments

	from %%NETMETER_DB_NAME%%..t_invoice inv
		inner join %%NETMETER_DB_NAME%%..t_billgroup_member bgm
			on inv.id_acc = bgm.id_acc and bgm.id_billgroup = %%ID_BILLGROUP%% 
		inner join %%NETMETER_DB_NAME%%..t_billgroup bg
			on inv.id_interval = bg.id_usage_interval
			and bg.id_billgroup = %%ID_BILLGROUP%% 
		inner join %%NETMETER_DB_NAME%%..t_adjustment_transaction aj
			on inv.id_acc = aj.id_acc_payer
			and inv.id_interval = aj.id_usage_interval
		inner join %%NETMETER_DB_NAME%%..t_acc_usage au
			on aj.id_sess = au.id_sess	
		left outer join %%NETMETER_DB_NAME%%..t_av_contact PayeeContact
			on au.id_payee = PayeeContact.id_acc
		left outer join %%NETMETER_DB_NAME%%..t_enum_data edContactType
			on PayeeContact.c_contacttype = edContactType.id_enum_data
			and edContactType.nm_enum_data = 'metratech.com/accountcreation/contacttype/bill-to'	
	where inv.invoice_amount <> 0
        group by aj.id_adj_trx, inv.id_invoice, au.id_payee, aj.dt_modified, PayeeContact.c_firstname,
		 PayeeContact.c_middleinitial, PayeeContact.c_LastName
		END
	   