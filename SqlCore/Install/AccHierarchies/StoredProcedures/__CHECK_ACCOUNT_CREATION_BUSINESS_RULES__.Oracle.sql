
create or replace procedure checkaccountcreationbusinessru(
   p_nm_space            nvarchar2,
   p_acc_type            varchar2,
   p_id_ancestor         int,
   status          out   int)
as
   tx_typ_space   varchar(40);
begin
   /* 1. check account and its ancestor business rules.
   if the account being created belongs to a hierarchy, then it should not
   have system_user or system_auth namespace      */
   for i in (select tx_typ_space
               into tx_typ_space
               from t_namespace
              where nm_space = p_nm_space)
   loop
      tx_typ_space := i.tx_typ_space;
   end loop;

   if (tx_typ_space in
          ('system_user',
           'system_auth',
           'system_mcm',
           'system_ops',
           'system_rate',
           'system_csr'))
   then
      /* An account with this account type and namespace cannot be
      created*/
      if (lower(p_acc_type) not in('systemaccount'))
      then    /* MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH ((DWORD)0xE2FF0046L)*/
         status := -486604732;
         return;
      end if;
   end if;

   /* If an account is not a subscriber or an independent account
   and its namespace is system_mps, that shouldnt be allowed either*/
   if (lower(tx_typ_space) = 'system_mps')
   then
      if (lower(p_acc_type) in('systemaccount'))
      then   /* MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH ((DWORD)0xE2FF0046L)*/
         status := -486604732;
         return;
      end if;
   end if;

   status := 1;
end;
 	 