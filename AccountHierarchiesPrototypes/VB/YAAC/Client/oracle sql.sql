/* ACCOUNT */




select * from t_account_mapper order by id_acc desc
update t_account_ancestor set vt_start=TO_DATE('2/5/2002 01:01:1' ,'mm/dd/yyyy hh:mi:ss AM') where id_descendent =200

select * from t_payment_redirection
select * from t_account_ancestor order by  id_descendent desc
select * from t_account_state order by id_acc desc


select * from t_av_internal order by id_acc desc
select * from t_av_contact order by id_acc desc

select * from t_account_ancestor where id_Descendent = 189


update t_av_internal set c_folder='Y' where id_acc=136 /* Metratech */

select * from t_user_credentials

select nm_login from t_user_credentials       where nm_login = 'fcsr' and   tx_password='1fd215949eedda323c0dc8493354e67a' and       nm_space = LOWER('csr')

update t_user_credentials 				   		 		   				set tx_password='1fd215949eedda323c0dc8493354e67a' where nm_login='fCsr'


/*  TEMPLATE  */
describe t_acc_template
select * from t_acc_template;
delete from t_acc_template
select * from t_acc_template_props where id_acc_template=30

select *from t_acc_template 
select id_acc_template from t_acc_template where tx_name='MyTemplate1';


INSERT INTO t_acc_template 
	   (id_acc_template,id_folder,dt_crt,tx_name,tx_desc,b_applydefaultpolicy) 
	   select seq_acctemplate.NextVal,
	   (select id_acc from t_account_mapper where nm_login='MetraTech'),
	   getutcdate(),
	   'MyTemplate1',
	   'My description','Y' from dual


/*  TEMPLATE PROPERTY */
describe t_acc_template_props
delete from t_acc_template_props
select * from t_acc_template_props;


delete from t_acc_template_props;
INSERT INTO t_acc_template_props
	   (id_prop,id_acc_template,nm_prop_class,nm_prop,nm_value) 
	   	   select seq_acctemplate.NextVal,
		   (select id_acc_template from t_acc_template where tx_name='MyTemplate1')
		   ,'','Address1','4 rue jose' from dual
		   
INSERT INTO t_acc_template_props (id_prop,id_acc_template,nm_prop_class,nm_prop,nm_value) select seq_acctemplate.NextVal,30,'','address1','4 rue josette' from dual

select * from t_acc_template where id_folder=(select id_acc from t_account_mapper where nm_login='UI')

INSERT INTO t_acc_template_props (id_prop,id_acc_template,nm_prop_class,nm_prop,nm_value) select seq_acctemplate.NextVal,'68','','address1','1/16/2002 3:05:01 PM' from dual
delete from t_acc_template_props where id_acc_template=68

/* PRODUCT OFFERING */
select * from t_po
describe t_po

INSERT INTO t_po
	   (ID_PO,ID_EFF_DATE,ID_AVAIL,B_USER_SUBSCRIBER,B_USER_UNSUBSCRIBER) 
	   select seq_acctemplate.NextVal,
	   select seq_acctemplate.NextVal,
	   select seq_acctemplate.NextVal,	   
       'Y','Y'

/* TEMPLATE SUBSCRIPTION */
describe t_acc_template_subs
delete from t_acc_template_subs
select * from t_acc_template_subs


select * from t_base_props where id_prop=83
select * from t_acc_template_subs where id_acc_Template=68

select * from t_acc_template_subs s, t_base_props p where s.id_acc_Template=232 and s.id_po=p.id_prop 

INSERT INTO t_acc_template_subs
	   (id_po,id_acc_template,b_group,vt_start,vt_end,nm_groupsubname)  values
	   	   (83,(select id_acc_template from t_acc_template where tx_name='MyTemplate1'),'N',getutcdate(),NULL,'' )

INSERT INTO t_acc_template_subs 
(id_po,id_acc_template,b_group,vt_start,vt_end,nm_groupsubname) values 
(86   ,232            ,'N'    ,TO_DATE('1/17/2002 1:27:58','mm/dd/yyyy hh:mi:ss AM'),NULL,'')

INSERT INTO t_acc_template_subs 
(id_po,id_acc_template,b_group,vt_start,vt_end,nm_groupsubname) values 
(86   ,232            ,'N'    ,TO_DATE('1/17/2002','mm/dd/yyyy'),NULL,'')

select * from t_acc_template_subs s, t_base_props p where s.id_acc_Template=232 and s.id_po=p.id_prop


delete from t_decimal_capability
delete from t_capability_instance
delete from t_policy_role
delete from t_principal_policy
delete from t_role
delete from t_compositor
delete from t_atomic_capability_type
delete from t_composite_capability_type
delete from t_capability_instance
delete from t_enum_capability
commit

select * from t_compositor
select * from t_atomic_capability_type
select * from t_composite_capability_type
select * from t_capability_instance
select * from t_policy_role
select * from t_principal_policy
select * from t_decimal_capability
select * from t_enum_capability
describe t_enum_capability


insert into t_decimal_capability (id_cap_instance,tx_param_name,tx_param_value,tx_op,n_value) values (28,'Amount',NULL,'<',100)


select * from t_description order by id_desc desc
select * from t_enum_data order by id_enum_data desc
select * from t_enum_capability
describe t_enum_capability


begin
	 recompilemetratech;
end;


insert into t_enum_capability (id_cap_instance,tx_param_name,param_value) values (4,'EnumTypeValue',1162)


desc t_decimal_capability 
SELECT cap.id_cap_type, cap.id_cap_instance, capclass.tx_name from t_capability_instance cap, t_composite_capability_type capclass WHERE cap.id_policy= 3 AND cap.id_parent_cap_instance IS NULL AND cap.id_cap_type=capclass.id_cap_type


select * from t_acc_template where id_folder=136

select * from t_base_props order by id_prop desc
select * from t_base_props where nm_name='MStone1-PO-81900'




++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


			    select 
					   a.id_acc, 
					   astate.vt_start dt_start, 
					   astate.vt_end dt_end, 
					   i.c_currency tx_currency,
					   u.id_usage_cycle id_usage_cycle
			    from 
					 t_account a, 
					 t_account_state astate, 
					 t_av_internal i,
					 t_acc_usage_cycle u
				where 
					  a.id_acc = 123 and 
					  a.id_acc = i.id_acc and
					  a.id_acc = u.id_acc and 
					  a.id_acc = astate.id_acc and
					  astate.vt_start = (select max (vt_start) from t_account_state where id_acc = 123)


select * from t_acc_usage order by id_acc desc
select * from t_pv_accountcredit
select * from t_pv_accountcredit ac, t_acc_usage au where ac.id_sess= au.id_sess 
select * from t_Acc_usage_interval where id_Acc in (123, 213)
select * from t_Acc_usage_cycle where id_Acc in (123, 213) 
select * from t_account_State where id_Acc in (123, 213) 
update t_account_State set vt_end = '31-Dec-2002' where id_Acc = 213
commit;


select * from t_usage_cycle  

select aui.id_acc AccountID, aui.id_usage_interval IntervalID,        aui.dt_effective DateEffective from t_acc_usage_interval aui        where aui.id_acc = 123 and aui.tx_status = 'O'

select              a.id_acc,              astate.vt_start dt_start,              astate.vt_end dt_end,              i.c_currency tx_currency,             u.id_usage_cycle id_usage_cycle          from            t_account a,            t_account_state astate,            t_av_internal i,           t_acc_usage_cycle u        where             a.id_acc = 213 and             a.id_acc = i.id_acc and            a.id_acc = u.id_acc and             a.id_acc = astate.id_acc and            astate.vt_start = (select max (vt_start) from t_account_state where id_acc = 213)
SELECT c_taxexempt, c_TaxExemptID, c_timezoneID, c_PaymentMethod, c_SecurityQuestion, c_SecurityAnswer, c_InvoiceMethod, c_UsageCycleType, c_Language, c_StatusReason, c_StatusReasonOther, c_currency, c_pricelist, c_billable, c_folder      FROM t_av_internal a WHERE a.id_acc = 213

  