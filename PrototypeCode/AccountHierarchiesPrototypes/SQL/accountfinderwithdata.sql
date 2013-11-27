-- new account finder query  
-- declare inputs : login name, ancestor ID, date and returns stuff
-- as an example, i want to assign the following values
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
	accuc.id_usage_cycle,
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
	accancestor.id_ancestor,
	accancestor.id_descendent,
	accancestor.num_generations,
	accancestor.b_children,
	accancestor.vt_start accancestorstart,
	accancestor.vt_end accancestorend,
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
    acccontact.C_COMPANY
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
		accpr.id_payer = acc.id_acc and
	    -- payment redirection effective date stuff
		('04-Feb-02' >= accpr.vt_start and 
		 '04-Feb-02' <= accpr.vt_end)

	-- t_acc_usage_cycle join 
    inner join t_acc_usage_cycle accuc on
		accuc.id_acc = acc.id_acc

	-- t_av_internal join 
    inner join t_av_internal accinternal on
		accinternal.id_acc = acc.id_acc

    -- join with t_account_ancestor
	LEFT OUTER JOIN t_account_ancestor accancestor on 
		accancestor.id_descendent = acc.id_acc 	 

	-- join with t_av_contact
	LEFT OUTER JOIN t_av_contact acccontact on 
		acccontact.id_acc = acc.id_acc
where 
	-- login check, example fred.  TODO: need to change this.
	-- doing a lower on the column might end up in a table scan
	lower(accmapper.nm_login) like lower('%Fred%') and
	   
	-- account ancestor ID check, example UI and also the date
	accancestor.id_ancestor = 152 and 
    ('04-Feb-02' >= accancestor.vt_start and 
	 '04-Feb-02' <= accancestor.vt_end) and

    -- accstate effective date stuff
    ('04-Feb-02' >= accstate.vt_start and 
	 '04-Feb-02' <= accstate.vt_end)



	
--select * from t_account_mapper where nm_login like '%Fred%';
--select * from t_Av_internal where id_acc = 155;
--select * from t_av_contact where id_acc = 155;
--select * from t_account_ancestor where id_ancestor = 152 and id_descendent = 155; -- UI folder
--select * from t_Account_state where id_acc = 155
--select * from t_payment_redirection; -- where id_payer 
---select * from t_acc_usage_cycle where id_acc = 152;
--update t_account_state set vt_start = '04-Feb-02' where id_acc = 155
--commit;
