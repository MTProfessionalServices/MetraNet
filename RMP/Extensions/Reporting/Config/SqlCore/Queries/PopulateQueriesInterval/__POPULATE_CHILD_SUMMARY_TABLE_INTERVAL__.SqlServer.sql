
		if EXISTS (SELECT * FROM sysobjects WHERE id=OBJECT_ID('%%NETMETER_DB_NAME%%..t_pv_audioconfconnection'))
			AND EXISTS (SELECT * FROM sysobjects WHERE id=OBJECT_ID('%%NETMETER_DB_NAME%%..t_pv_audioconffeature'))
		BEGIN
		insert into t_rpt_child_summary
		select inv.id_invoice InvoiceID,
       			au.id_parent_sess ParentSessID,
       			au.id_sess ChildSessID,	
       			edview.nm_enum_data ChildDesc,
       			conn.c_UserName Attendee,
       			conn.c_userphonenumber CallNumber,	
       			edcall.nm_enum_data Type,
       			conn.c_ConnectionMinutes Minutes,
       			ISNULL(au.amount, 0) + ISNULL(au.tax_federal, 0) + ISNULL(au.tax_state, 0) + ISNULL(au.tax_county, 0) + ISNULL(au.tax_local, 0) + ISNULL(au.tax_other, 0) Charge
		from       
 			%%NETMETER_DB_NAME%%..t_invoice inv
 			inner join %%NETMETER_DB_NAME%%..t_acc_usage au
 			on inv.id_acc = au.id_acc
 			and inv.id_interval = au.id_usage_interval
 			and au.id_usage_interval = %%ID_INTERVAL%%
 			/* and au.id_view = 5 */
			inner join %%NETMETER_DB_NAME%%..t_pv_audioconfconnection conn
 			on au.id_sess = conn.id_sess
 			inner join %%NETMETER_DB_NAME%%..t_enum_data edview
 			on au.id_view = edview.id_enum_data
 			inner join %%NETMETER_DB_NAME%%..t_enum_data edcall
 			on conn.c_CallType = edcall.id_enum_data
		union
		select inv.id_invoice InvoiceID,
       			au.id_parent_sess ParentSessID,
       			au.id_sess ChildSessID,	
       			edview.nm_enum_data ChildDesc,
      			feat.c_Payer Attendee,
       			NULL CallNumber,	
       			edfeat.nm_enum_data Type,
      			feat.c_Duration Minutes,
       			ISNULL(au.amount, 0) + ISNULL(au.tax_federal, 0) + ISNULL(au.tax_state, 0) + ISNULL(au.tax_county, 0) + ISNULL(au.tax_local, 0) + ISNULL(au.tax_other, 0) Charge
		from       
			%%NETMETER_DB_NAME%%..t_invoice inv
 			inner join %%NETMETER_DB_NAME%%..t_acc_usage au
 			on inv.id_acc = au.id_acc
 			and inv.id_interval = au.id_usage_interval
 			and au.id_usage_interval = %%ID_INTERVAL%%
 			inner join %%NETMETER_DB_NAME%%..t_pv_audioconffeature feat
 			on au.id_sess = feat.id_sess
 			inner join %%NETMETER_DB_NAME%%..t_enum_data edview
 			on au.id_view = edview.id_enum_data
 			inner join %%NETMETER_DB_NAME%%..t_enum_data edfeat
 			on feat.c_FeatureType = edfeat.id_enum_data
 		END
 	   