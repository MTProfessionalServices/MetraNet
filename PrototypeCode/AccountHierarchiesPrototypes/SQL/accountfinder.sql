-- new account finder query  
-- declare inputs : login name, ancestor ID, date and returns stuff
-- as an example, i want to assign the following values
begin
	declare 
	p_nm_login varchar2(40);
	p_id_ancestor integer; 
	p_date date;
		
	begin
        p_nm_login := 'Fred';
	 	p_id_ancestor := 152;
	    p_date := '02/02/02';  
        -- here i want to select from the following tables:
        -- t_account, 
        -- t_account_mapper (like %nm_login%), 
        -- t_account_state (p_date between vt_start and vt_end),
        -- t_payment_redirction (left outer join, p_date between vt_start and 
        -- vt_end) 
        -- t_account_ancestor (left outer join, p_date between vt_start and 
        -- vt_end) 
        -- t_acc_usage_cycle,
        -- t_av_internal,
        -- t_av_contact (left outer join)
        select 
	        acc.id_acc,
	        accmapper.nm_login,
            accmapper.nm_space,
            accstate.STATUS,
            accstate.VT_START accstatestart,
            accstate.VT_END accstartend,
            accpr.id_payer,
            accpr.id_payee,
            accpr.VT_START payerstart,
            accpr.VT_END payerend,
            accinternal.C_USAGECYCLETYPE,
            accinternal.C_PAYMENTMETHOD,
            accinternal.C_INVOICEMETHOD,
            accinternal.c_billable,
            accinternal.c_folder,
            accinternal.c_language,
            accinternal.c_currency,
            accinternal.c_taxexempt,
            accinternal.c_taxexemptid,
            accinternal.C_SECURITYQUESTION,
            accinternal.C_SECURITYANSWER,
            accinternal.C_STATUSREASON,
            accinternal.C_STATUSREASONOTHER,
            accinternal.C_PRICELIST,
            acccontact.C_FIRSTNAME,
            acccontact.c_middleinitial,
            acccontact.c_lastname,
            acccontact.C_ACCOUNTTYPE,
            acccontact.C_ADDRESS1,
            acccontact.c_address2,
            acccontact.c_address3,
            acccontact.c_city,
            acccontact.c_state,
            acccontact.c_zip,
            acccontact.c_country,
            acccontact.c_email,
            acccontact.C_facsimiletelephonenumber,
            acccontact.C_PHONENUMBER,
            acccontact.c_company
        from 
            t_account acc
            -- join between t_account_mapper and t_account
            inner join t_account_mapper accmapper on 
                accmapper.id_acc = acc.id_acc

	        -- account state account ID check
	        inner join t_account_state accstate on 
	            accstate.id_acc = acc.id_acc
	  
            -- account payment redirection account ID check
            left outer join t_payment_redirection accpr on
	            accpr.id_payer = acc.id_acc

            -- t_acc_usage_cycle join 
            inner join t_acc_usage_cycle accuc on
	            accuc.id_acc = acc.id_acc

            -- t_av_internal join 
            inner join t_av_internal accinternal on
	            accinternal.id_acc = acc.id_acc

            -- join with t_account_ancestor
	        LEFT OUTER JOIN t_account_ancestor accancestor on 
	            accancestor.id_ancestor = acc.id_acc 	 

            -- join with t_av_contact
	        LEFT OUTER JOIN t_av_contact acccontact on 
	            acccontact.id_acc = acc.id_acc
        where 
	        -- login check, example fred.  TODO: need to change this.
	        -- doing a lower on the column might end up in a table scan
	        lower(accmapper.nm_login) like lower(p_nm_login) and
	   
	        -- account ancestor ID check, example UI and also the date
	        accancestor.id_ancestor = p_id_ancestor and 
	          (p_date between accancestor.vt_start and vt_end) and

            -- accstate effective date stuff
            (p_date between accstate.vt_start and accstate.vt_end) and

            -- payment redirection effective date stuff
            (p_date between accpr.vt_start and accpr.vt_end);
	end;
end;

--select * from t_account_ancestor
--select * from t_payment_redirection
--select * from t_av_internal
--select * from t_av_contact
