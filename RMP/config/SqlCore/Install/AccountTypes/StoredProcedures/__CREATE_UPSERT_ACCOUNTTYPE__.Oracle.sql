
create or replace procedure upsertaccounttype (
	p_name nvarchar2, 
	p_b_cansubscribe varchar2, 
	p_b_canbepayer varchar2,
	p_b_canhavesyntheticroot varchar2, 
	p_b_canparticipateingsub varchar2, 
	p_bisvisibleinhierarchy varchar2,
	p_b_canhavetemplates varchar2, 
	p_b_iscorporate varchar2,
	p_nm_desc nvarchar2, 
	p_id_accounttype out number
)
AS PRAGMA AUTONOMOUS_TRANSACTION;
begin
	
	update t_account_type set 
		b_cansubscribe = p_b_cansubscribe,
		b_canbepayer = p_b_canbepayer,
		b_canhavesyntheticroot = p_b_canhavesyntheticroot,
		b_CanParticipateInGSub = p_b_CanParticipateInGSub,
		b_IsVisibleInHierarchy = p_bIsVisibleInHierarchy,
		b_CanHaveTemplates = p_b_CanHaveTemplates,
		b_IsCorporate = p_b_IsCorporate,
		nm_description = p_nm_desc
	where name = p_name;
	
	if (sql%rowcount = 0) then

		select seq_t_account_type.nextval into p_id_accounttype from dual;

		insert into t_account_type (id_type, name, b_CanSubscribe, b_CanBePayer, 
				b_CanHaveSyntheticRoot, b_CanParticipateInGSub, b_IsVisibleInHierarchy,
				b_CanHaveTemplates, b_IsCorporate, nm_description)
		values (p_id_accounttype, p_name, p_b_cansubscribe, p_b_canbepayer, 
				p_b_canhavesyntheticroot, p_b_CanParticipateInGSub,
				p_bIsVisibleInHierarchy, p_b_CanHaveTemplates, p_b_IsCorporate, p_nm_desc);
	else

		select id_type into p_id_accounttype from t_account_type where upper(name) = upper(p_name);

	end if;
COMMIT;
end;
			