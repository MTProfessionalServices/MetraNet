
				select 	
					fp.id_interval, fp.id_acc, fp.id_payment_instrument, 
					fpd.nm_invoice_num, fpd.dt_invoice, fpd.nm_po_number, 
					fp.nm_description, fp.nm_currency, fp.n_amount, 
					(CASE WHEN fp.n_retrycount is NULL THEN 0 ELSE fp.n_retrycount END) n_retrycount,
					pi.n_payment_method_type, pi.id_creditcard_type, pi.nm_truncd_acct_num,
					internal.c_Language, contact.c_Email, contact.c_FirstName, contact.c_LastName, fpd.n_amount n_invoice_amount
				from 
					t_failed_payment fp
					left outer join 
					t_failed_payment_details fpd on fp.id_interval = fpd.id_interval and fp.id_acc = fpd.id_acc and fp.id_payment_instrument = fpd.id_payment_instrument					
					inner join
					t_payment_instrument pi on fp.id_payment_instrument = pi.id_payment_instrument
					inner join
					t_av_internal internal on fp.id_acc = internal.id_acc
					left outer join
					t_av_contact contact on fp.id_acc = contact.id_acc,
					(select id_enum_data from t_enum_data where nm_enum_data = 'metratech.com/accountcreation/contacttype/bill-to') enum
				where 
					contact.c_ContactType = enum.id_enum_data and
					case when dt_lastretry is null then 
						(CAST(%%SYSDATE%% as DATE) -  dt_original_trans)
					else
						(CAST(%%SYSDATE%% as DATE) - dt_lastretry)
					end >= %%RETRY_DAYS%%
					and
					NVL(n_retrycount, 0) <= %%MAX_RETRIES%%
      