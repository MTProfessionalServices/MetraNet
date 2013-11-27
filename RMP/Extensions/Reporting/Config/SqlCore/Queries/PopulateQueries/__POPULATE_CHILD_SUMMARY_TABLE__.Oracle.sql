
	   begin
	   if table_exists('%%NETMETER_DB_NAME%%.t_pv_audioconfconnection')
	      and table_exists('%%NETMETER_DB_NAME%%.t_pv_audioconffeature') then
         EXECUTE IMMEDIATE ('
		insert into t_rpt_child_summary
		select inv.id_invoice InvoiceID,
       			au.id_parent_sess ParentSessID,
       			au.id_sess ChildSessID,	
       			edview.nm_enum_data ChildDesc,
       			conn.c_UserName Attendee,
       			conn.c_userphonenumber CallNumber,	
       			edcall.nm_enum_data Type,
       			conn.c_ConnectionMinutes Minutes,
       			nvl(au.amount, 0) + nvl(au.tax_federal, 0) + nvl(au.tax_state, 0) + nvl(au.tax_county, 0) + nvl(au.tax_local, 0) + nvl(au.tax_other, 0) Charge
		from       
 			%%NETMETER_DB_NAME%%.t_invoice inv
 			inner join %%NETMETER_DB_NAME%%.t_billgroup_member bgm
			on inv.id_acc = bgm.id_acc
			inner join %%NETMETER_DB_NAME%%.t_billgroup bg
			on inv.id_interval = bg.id_usage_interval
			and bg.id_billgroup = %%ID_BILLGROUP%% 
 			inner join %%NETMETER_DB_NAME%%.t_acc_usage au
 			on inv.id_acc = au.id_acc
 			and inv.id_interval = au.id_usage_interval
			inner join %%NETMETER_DB_NAME%%.t_pv_audioconfconnection conn
 			on au.id_sess = conn.id_sess
 			inner join %%NETMETER_DB_NAME%%.t_enum_data edview
 			on au.id_view = edview.id_enum_data
 			inner join %%NETMETER_DB_NAME%%.t_enum_data edcall
 			on conn.c_CallType = edcall.id_enum_data
 		where
 			bgm.id_billgroup = %%ID_BILLGROUP%% 	
		union
		select inv.id_invoice InvoiceID,
       			au.id_parent_sess ParentSessID,
       			au.id_sess ChildSessID,	
       			edview.nm_enum_data ChildDesc,
      			feat.c_Payer Attendee,
       			NULL CallNumber,	
       			edfeat.nm_enum_data Type,
      			feat.c_Duration Minutes,
       			nvl(au.amount, 0) + nvl(au.tax_federal, 0) + nvl(au.tax_state, 0) + nvl(au.tax_county, 0) + nvl(au.tax_local, 0) + nvl(au.tax_other, 0) Charge
		from       
			%%NETMETER_DB_NAME%%.t_invoice inv
 			inner join %%NETMETER_DB_NAME%%.t_billgroup_member bgm
			on inv.id_acc = bgm.id_acc
 			inner join %%NETMETER_DB_NAME%%.t_billgroup bg
			on inv.id_interval = bg.id_usage_interval
			and bg.id_billgroup = %%ID_BILLGROUP%% 
			inner join %%NETMETER_DB_NAME%%.t_acc_usage au
 			on inv.id_acc = au.id_acc
 			and inv.id_interval = au.id_usage_interval
 			inner join %%NETMETER_DB_NAME%%.t_pv_audioconffeature feat
 			on au.id_sess = feat.id_sess
 			inner join %%NETMETER_DB_NAME%%.t_enum_data edview
 			on au.id_view = edview.id_enum_data
 			inner join %%NETMETER_DB_NAME%%.t_enum_data edfeat
 			on feat.c_FeatureType = edfeat.id_enum_data
 		where
 			bgm.id_billgroup = %%ID_BILLGROUP%%');
 		end if;
		end;
 	   