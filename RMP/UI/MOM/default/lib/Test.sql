use netmeter

/*Convert(datetime,"01/25/2001 16:45:04")*/

select * from t_enum_data
select * from t_description

sp_help t_acc_usage_1

select * from sysobjects where name like "%_ps_%_1" and type="u"
select * from t_pv_ps_cc_credit_1
select * from t_pv_ps_cc_postauth_1
select * from t_pv_ps_cc_preauth_1  



delete from t_pv_ps_cc_credit_1
elete from t_acc_usage_1


sp_help t_pv_ps_cc_credit_1


/* -----------------------------------------------------
 *  CLEAN DATA IN t_pv_creditfailure_1
 */

/*
DELETE from t_pv_ps_cc_credit_1
go
DELETE from t_acc_usage_1 where id_view=(Select id_enum_data  from t_enum_data where nm_enum_data='metratech.com/ps_cc_credit')
*/

/* -----------------------------------------------------
 *  INSERT DATA IN t_pv_ps_cc_credit_1
 */
Declare @IntervalID 	int
Declare @AccountID 	int
Declare @ViewID 	int

Select @ViewID 		= id_enum_data  from t_enum_data where nm_enum_data='metratech.com/ps_cc_credit'
Select @AccountID	= 123
Select @IntervalID 	= 1000

Insert t_acc_usage_1 (tx_UID,id_acc,id_view,id_usage_interval,id_svc,dt_session,amount,am_currency) values (Convert(varbinary(16), getDate()),@AccountID,@ViewID,@IntervalID,0,Convert(datetime,"01/25/2001 16:45:04"),123.456,"USD")
Declare @NewIdSession int
select @NewIdSession=max(id_sess) from t_acc_usage_1

insert into t_pv_ps_cc_credit_1
	(id_sess,c_originalaccountid,c_creditcardtype,c_lastfourdigits,c_respstring,c_retcode,c_exported)
values
	(@NewIdSession,@AccountID,1,"1234","repstr",1,1)

select * from t_pv_ps_cc_credit_1






/* -----------------------------------------------------
 *  INSERT DATA IN t_pv_ps_cc_postauth_1
 */
Declare @IntervalID 	int
Declare @AccountID 	int
Declare @ViewID 	int

Select @ViewID 		= id_enum_data  from t_enum_data where nm_enum_data='metratech.com/ps_cc_postauth'
Select @AccountID	= 123
Select @IntervalID 	= 1000

Insert t_acc_usage_1 (tx_UID,id_acc,id_view,id_usage_interval,id_svc,dt_session,amount,am_currency) values (Convert(varbinary(16), getDate()),@AccountID,@ViewID,@IntervalID,0,Convert(datetime,"01/25/2001 16:45:04"),123.456,"USD")Declare @NewIdSession int
select @NewIdSession=max(id_sess) from t_acc_usage_1

insert into t_pv_ps_cc_postauth_1
	(id_sess,c_originalaccountid,c_creditcardtype,c_lastfourdigits,c_respstring,c_retcode,c_exported)
values
	(@NewIdSession,@AccountID,1,"1234","repstr",1,1)

select * from t_pv_ps_cc_postauth_1




/* -----------------------------------------------------
 *  INSERT DATA IN t_pv_ps_cc_preauth_1
 */
Declare @IntervalID 	int
Declare @AccountID 	int
Declare @ViewID 	int

Select @ViewID 		= id_enum_data  from t_enum_data where nm_enum_data='metratech.com/ps_cc_preauth'
Select @AccountID	= 123
Select @IntervalID 	= 1000

Insert t_acc_usage_1 (tx_UID,id_acc,id_view,id_usage_interval,id_svc,dt_session,amount,am_currency) values (Convert(varbinary(16), getDate()),@AccountID,@ViewID,@IntervalID,0,Convert(datetime,"01/25/2001 16:45:04"),123.456,"USD")Declare @NewIdSession int
select @NewIdSession=max(id_sess) from t_acc_usage_1

insert into t_pv_ps_cc_preauth_1
	(id_sess,c_originalaccountid,c_creditcardtype,c_lastfourdigits,c_respstring,c_retcode,c_transactionid )
values
	(@NewIdSession,@AccountID,1,"1234","repstr",1,"#TransID")

select * from t_pv_ps_cc_preauth_1





/* -----------------------------------------------------
 *  INSERT DATA IN t_pv_ps_ach_credit_1
 */
Declare @IntervalID 	int
Declare @AccountID 	int
Declare @ViewID 	int

Select @ViewID 		= id_enum_data  from t_enum_data where nm_enum_data='metratech.com/ps_ach_credit'
Select @AccountID	= 123
Select @IntervalID 	= 1000

Insert t_acc_usage_1 (tx_UID,id_acc,id_view,id_usage_interval,id_svc,dt_session,amount,am_currency) values (Convert(varbinary(16), getDate()),@AccountID,@ViewID,@IntervalID,0,Convert(datetime,"01/25/2001 16:45:04"),123.456,"USD")Declare @NewIdSession int
select @NewIdSession=max(id_sess) from t_acc_usage_1

insert into t_pv_ps_ach_credit_1
	(id_sess,c_originalaccountid,c_transactionid,c_retcode,c_respstring,c_currentstatus,c_routingnumber,c_lastfourdigits,c_bankaccounttype,c_reason,c_csrid,c_paymentservicetransactionid,c_exported)
values
	(@NewIdSession,@AccountID,"#TRANSID",1,"repstring=ok",1,"R7890","1234",1,"no reason","csr1","PST-ID-32879",1)

select * from t_pv_ps_ach_credit_1





/* -----------------------------------------------------
 *  INSERT DATA IN t_pv_ps_ach_debit_1
 */
Declare @IntervalID 	int
Declare @AccountID 	int
Declare @ViewID 	int

Select @ViewID 		= id_enum_data  from t_enum_data where nm_enum_data='metratech.com/ps_ach_debit'
Select @AccountID	= 123
Select @IntervalID 	= 1000

Insert t_acc_usage_1 (tx_UID,id_acc,id_view,id_usage_interval,id_svc,dt_session,amount,am_currency) values (Convert(varbinary(16), getDate()),@AccountID,@ViewID,@IntervalID,0,Convert(datetime,"01/25/2001 16:45:04"),123.456,"USD")Declare @NewIdSession int
select @NewIdSession=max(id_sess) from t_acc_usage_1

insert into t_pv_ps_ach_debit_1
	(id_sess,c_originalaccountid,c_transactionid,c_retcode,c_respstring,c_currentstatus,c_routingnumber,c_lastfourdigits,c_bankaccounttype,c_reason,c_csrid,c_paymentservicetransactionid,c_exported)
values
	(@NewIdSession,@AccountID,"#TRANSID",1,"repstring=ok",1,"R7890","1234",1,"no reason","csr1","PST-ID-32879",1)

select * from t_pv_ps_ach_debit_1




/* -----------------------------------------------------
 *  INSERT DATA IN t_pv_ps_ach_prenote_1
 */
Declare @IntervalID 	int
Declare @AccountID 	int
Declare @ViewID 	int

Select @ViewID 		= id_enum_data  from t_enum_data where nm_enum_data='metratech.com/ps_ach_prenote'
Select @AccountID	= 123
Select @IntervalID 	= 1000

Insert t_acc_usage_1 (tx_UID,id_acc,id_view,id_usage_interval,id_svc,dt_session,amount,am_currency) values (Convert(varbinary(16), getDate()),@AccountID,@ViewID,@IntervalID,0,Convert(datetime,"01/25/2001 16:45:04"),123.456,"USD")Declare @NewIdSession int
select @NewIdSession=max(id_sess) from t_acc_usage_1

insert into t_pv_ps_ach_prenote_1
	(id_sess,c_customername,c_address,c_city,c_state,c_zip,c_country,c_retcode,c_respstring,c_paymentservicetransactionid,c_routingnumber,c_lastfourdigits,c_bankaccounttype,c_originalaccountid)
values
	(@NewIdSession,"Freddy pivol","11 worth st","Melrose","MA","02176","US",1,"repstring=ok","PSTID-23879","RN-432","1234",1,0)

select * from t_pv_ps_ach_prenote_1

sp_help t_pv_ps_ach_prenote_1




/* -----------------------------------------------------
 *  INSERT DATA IN t_pv_ps_paymentscheduler_1
 */
Declare @IntervalID 			int
Declare @AccountID 			int
Declare @ViewID 			int
Declare @BackAccountTypeEnumTypeID 	int
Declare @PayementTypeAchEnumID 		int
Declare @BCreditCardTypeEnumTypeID 	int
Declare @BStatusEnumTypeID		int
Declare @UsageCycleTypeEnumTypeID	int
Declare @PaymentServiceTransactionID	int

/* Archive, Failed, IncompleteAccountInformation , Investigate ,NotPaid, Open, Pending, Retry  , Sent ,Settled  */
select @BStatusEnumTypeID=id_enum_data 			from t_enum_data where nm_enum_data="metratech.com/paymentserver/PaymentStatus/Failed"

select @PaymentServiceTransactionID = Count(*) 		from t_acc_usage_1
select @PayementTypeAchEnumID=id_enum_data 		from t_enum_data where nm_enum_data="metratech.com/paymentserver/PaymentType/ACH"
select @BackAccountTypeEnumTypeID=id_enum_data 		from t_enum_data where nm_enum_data="metratech.com/paymentserver/BankAccountType/Checking"
select @BCreditCardTypeEnumTypeID=id_enum_data 		from t_enum_data where nm_enum_data="metratech.com/CreditCardType/Visa"
select @UsageCycleTypeEnumTypeID=id_enum_data 		from t_enum_data where nm_enum_data="metratech.com/billingcycle/UsageCycleType/Weekly"

Select @ViewID 		= id_enum_data  from t_enum_data where nm_enum_data='metratech.com/ps_paymentscheduler'
Select @AccountID	= 123
Select @IntervalID 	= 1000

Insert t_acc_usage_1 (tx_UID,id_acc,id_view,id_usage_interval,id_svc,dt_session,amount,am_currency) values (Convert(varbinary(16), getDate()),@AccountID,@ViewID,@IntervalID,0,Convert(datetime,"01/25/2001 16:45:04"),123.456,"USD")Declare @NewIdSession int
select @NewIdSession=max(id_sess) from t_acc_usage_1

insert into t_pv_ps_paymentscheduler_1
	(c_paymentservicetransactionid,id_sess,c_originalaccountid,c_paymenttype,c_lastfourdigits,c_routingnumber,c_bankaccounttype,c_creditcardtype,c_scheduledpayment,c_laststatusupdate,c_currentstatus,c_paymentproviderstatus,c_paymentprovidercode,c_nachacode,c_maxretries,c_retryonfailure,c_numberretries,c_confirmationrequested,c_confirmationreceived,c_email,c_originalIntervalID)
values
	(
	 Convert(varchar(5),@PaymentServiceTransactionID),@NewIdSession,123,@PayementTypeAchEnumId,"1234","RN-89",@BackAccountTypeEnumTypeID,@BCreditCardTypeEnumTypeID, Convert(datetime,"01/25/2001 16:45:04"),
	 Convert(datetime,"01/25/2001 16:45:04"),@BStatusEnumTypeID,"ProviderStatus",1,"nacha",1,1,1,"Y","Y","frederic.torres@metratech.com",@IntervalID
	)
select * from t_pv_ps_paymentscheduler_1


sp_help t_pv_ps_paymentscheduler_1


select * from t_enum_data where id_enum_data=667
select * from t_enum_data where id_enum_data =1164
select * from t_description where id_desc =1164
why...

select * from t_description
select * from t_pv_ps_paymentscheduler_1

select * from t_acc_usage_1 au where 

au.id_acc = 123 and 
	au.id_usage_interval = 1000 and 
	au.id_view = 667 and 			  
	au.id_parent_sess is NULL 

au.id_acc = 123 and au.id_usage_interval = 1000 and au.id_view = 606






select *from t_enum_data where nm_enum_data="metratech.com/paymentserver/PaymentStatus/Failed"


select *		from t_enum_data




select * from t_namespace where tx_typ_space<>'mtprez' and tx_typ_space<>'system_csr'


select * from t_av_internal

update t_av_internal set c_PaymentMethod=864

select *from t_enum_data where id_enum_data =308







select * from t_payment_audit

insert into t_payment_audit

id_acc,nm_action,nm_creditcardtype    nm_lastfourdigits nm_ccnum                       nm_expdate           id_expdatef nm_startdate         id_startdatef nm_issuernumber      dt_occurred                 tx_IP_subscriber     tx_phone_number                tx_IP_CSR            id_CSR               tx_notes                                                                                                                                                                                                                                                        




/* MOM CHANGE PASS WORD b19b5b326fb202232b1c1776e79cf301 */


select * from t_user_credentials 

select tx_password password from t_user_credentials where nm_login='csr1' and nm_space="csr"

update t_user_credentials set tx_password='1fd215949eedda323c0dc8493354e67a' where nm_login='csr1' and nm_space="csr"

