
CREATE OR REPLACE 
procedure updateaccount (
p_loginname IN nvarchar2,
p_namespace IN nvarchar2,
p_id_acc IN int,
p_acc_state in varchar2,
p_acc_state_ext in int,
p_acc_statestart in date,
p_tx_password IN nvarchar2,
p_ID_CYCLE_TYPE IN integer,
p_DAY_OF_MONTH IN integer,
p_DAY_OF_WEEK IN integer,
p_FIRST_DAY_OF_MONTH IN integer,
p_SECOND_DAY_OF_MONTH IN integer,
p_START_DAY IN integer,
p_START_MONTH IN integer,
p_START_YEAR IN integer,
p_id_payer IN integer,
p_payer_login IN nvarchar2,
p_payer_namespace IN nvarchar2,
p_payer_startdate IN date,
p_payer_enddate IN date,
p_id_ancestor IN int,
p_ancestor_name IN nvarchar2,
p_ancestor_namespace IN nvarchar2,
p_hierarchy_movedate IN date,
p_systemdate IN date,
p_billable IN varchar2,
p_enforce_same_corporation varchar2,
p_account_currency nvarchar2,
p_status OUT int,
p_cyclechanged OUT int,
p_newcycle OUT int,
p_accountID OUT int,
p_hierarchy_path OUT varchar2,
p_old_id_ancestor_out OUT int ,
p_id_ancestor_out OUT int ,
p_corporate_account_id OUT int,
p_ancestor_type OUT varchar2,
p_acc_type out varchar2 
)
as
accountID integer;
oldcycleID integer;
usagecycleID integer;
intervalenddate date;
intervalID integer;
pc_start date;
pc_end date;
oldpayerstart date;
oldpayerend date;
oldpayer integer;
payerenddate date;
payerID integer;
AncestorID integer;
payerbillable varchar2(1);
p_count integer;
begin
 accountID  := -1;
 oldcycleID := 0;
 p_status   := 0;

 p_ancestor_type := ' ';

 p_old_id_ancestor_out := p_id_ancestor;

 /* step : resolve the account if necessary*/
 if p_id_acc is NULL then
  if p_loginname is not NULL and p_namespace is not NULL then
    accountID := dbo.lookupaccount(p_loginname, p_namespace);
    if accountID < 0 then
        /* MTACCOUNT_RESOLUTION_FAILED*/
     p_status := -509673460;
    end if;
  else
   /* MTACCOUNT_RESOLUTION_FAILED*/
   p_status := -509673460;
  end if;
else
  accountID := p_id_acc;
end if;

if p_status < 0 then
  return;
end if;

 /* step : update the account password if necessary.  catch error
  if the account does not exist or the login name is not valid.  The system
  should check that both the login name, namespace, and password are 
  required to change the password.*/
 if p_loginname is not NULL and p_namespace is not NULL and p_tx_password is not NULL then
  begin
   update t_user_credentials set tx_password = p_tx_password
         where upper(nm_login) = upper(p_loginname) and upper(nm_space) =
         upper(p_namespace);
  exception when NO_DATA_FOUND then
   /* MTACCOUNT_FAILED_PASSWORD_UPDATE*/
   p_status :=  -509673461;
  end;
 end if;
 
 /* step : figure out if we need to update the account's billing cycle.  this
  may fail because the usage cycle information may not be present.*/
  begin
   for i in (
   select id_usage_cycle
   from t_usage_cycle cycle where
   cycle.id_cycle_type = p_ID_CYCLE_TYPE 
   AND (p_DAY_OF_MONTH = cycle.day_of_month or p_DAY_OF_MONTH is NULL)
   AND (p_DAY_OF_WEEK = cycle.day_of_week or p_DAY_OF_WEEK is NULL)
   AND (p_FIRST_DAY_OF_MONTH= cycle.FIRST_DAY_OF_MONTH  or p_FIRST_DAY_OF_MONTH is NULL)
   AND (p_SECOND_DAY_OF_MONTH = cycle.SECOND_DAY_OF_MONTH or p_SECOND_DAY_OF_MONTH is NULL)
   AND (p_START_DAY= cycle.START_DAY or p_START_DAY is NULL)
   AND (p_START_MONTH= cycle.START_MONTH or p_START_MONTH is NULL)
   AND (p_START_YEAR = cycle.START_YEAR or p_START_YEAR is NULL))
   loop
       usagecycleID := i.id_usage_cycle ;
   end loop;
   if usagecycleID is null then
       usagecycleID := -1;
   end if;
  end;
  
  for i in (
    select id_usage_cycle from
    t_acc_usage_cycle where id_acc = accountID)
    loop
        oldcycleID := i.id_usage_cycle;
    end loop;
    
  if oldcycleID <> usagecycleID AND usagecycleID <> -1 then

      /* step : update the account's billing cycle*/
      update t_acc_usage_cycle set id_usage_cycle = usagecycleID
      where id_acc = accountID;

      /* post-operation business rule check (relies on rollback of work done up until this point)
       CR9906: checks to make sure the account's new billing cycle matches all of it's and/or payee's 
       group subscription BCR constraints.  TODO:  The function CheckGroupMembershipCycleConstraint is not ported yet!!!!!
       uncomment the following after it is ported */
      
      
      select  NVL(MIN(dbo.checkgroupmembershipcycleconst(p_systemdate, groups.id_group)), 1) into p_status
      from 
      (
        select distinct gsm.id_group id_group
        from t_gsubmember gsm
        inner join t_payment_redirection pay
        on pay.id_payee = gsm.id_acc
        where pay.id_payer = accountID or pay.id_payee = accountID
      ) groups;
      

      IF p_status <> 1 then
        RETURN;
      end if; 

      /* step : delete any records in t_acc_usage_interval that
       exist in the future with the old interval*/
       
      delete from t_acc_usage_interval aui
      where aui.id_acc = AccountID AND id_usage_interval IN 
      ( 
       select id_interval from t_usage_interval ui
       INNER JOIN t_acc_usage_interval aui on aui.id_acc = accountID AND
       aui.id_usage_interval = ui.id_interval
       where
       dt_start > p_systemdate
      );
      
      /* step : delete any previous updates in t_acc_usage_interval 
         (only one can have dt-effective set) and the effective date is in 
         the future.*/
         
         
      delete from t_acc_usage_interval where dt_effective is not null 
      and id_acc = accountID AND dt_effective >= p_systemdate;
  
      /* step : figure out the interval that we should be modifying*/
      for i in
        (select ui.dt_end dt_end
        from t_acc_usage_interval aui
        INNER JOIN t_usage_interval ui on ui.id_interval = aui.id_usage_interval
        AND p_systemdate between ui.dt_start AND ui.dt_end
        where
        aui.id_acc = AccountID)
      loop
        intervalenddate := i.dt_end;
      end loop;

      /* step : figure out the new interval ID based on the end date
       of the existing interval  */
      IF intervalenddate IS NOT NULL then
          for i in
            (select id_interval,dt_start,dt_end
            from 
            t_pc_interval where
            id_cycle = usagecycleID AND
            dbo.addsecond(intervalenddate) between dt_start AND dt_end)
          loop
            intervalID := i.id_interval;
            pc_start   := i.dt_start;
            pc_end     := i.dt_end;
          end loop;
          
          /* step : create new usage interval if it is missing.  Make sure we use
           the end date of the existing interval plus one second AND the new 
           interval id.  populate the usage interval if necessary*/
           
          insert into t_usage_interval
          select
          intervalID,usagecycleID,pc_start,pc_end,'O'
          from dual
          where 
          intervalID not in (select id_interval from t_usage_interval);
          
          /* step : create the t_acc_usage_interval mappings.  the new one is effective
           at the end of the interval.  We also must make sure to 
           populate t_acc_usage_interval with any other intervals in the future that
           may have been created by USM*/
           
           insert into t_acc_usage_interval (id_acc,id_usage_interval,tx_status,dt_effective)
              SELECT accountID, 
                     intervalID, 
                     nvl(tx_interval_status, 'O'),
                     intervalenddate
              FROM t_usage_interval 
              WHERE id_interval = intervalID AND 
                    tx_interval_status != 'B' ;  
                    
          /* this check is necessary if we are creating an association with an interval that begins
          in the past.  This could happen if you create a daily account on tuesday and then
          change to a weekly account (starting on monday) on Thursday.  not that the end date check is 
          only greater than because we want to avoid any intervals that have the same end date as
          @intervalenddate.  The second part of the condition is to pick up intervals that are in the future.
          and ((intervalenddate >= dt_start AND intervalenddate < dt_end) OR
          dt_start > intervalenddate);*/
                  
      END IF;
 
      /* indicate that the cycle changed*/
      p_newcycle := UsageCycleID;
      p_cyclechanged := 1;

  else
      /* indicate that the cycle did not change*/
      p_newcycle := UsageCycleID;
      p_cyclechanged := 0;
  end if;

 /* step : update the payment redirection information.  Only update
  the payment information if the payer and payer_startdate is specified*/
  
 if (p_id_payer is NOT NULL OR (p_payer_login is not NULL AND 
  p_payer_namespace is not NULL)) AND p_payer_startdate is NOT NULL then
  
  /* resolve the paying account id if necessary*/
  if p_payer_login is not null and p_payer_namespace is not null then
   payerID := dbo.LookupAccount(p_payer_login,p_payer_namespace) ;
   if payerID = -1 then
    /* MT_CANNOT_RESOLVE_PAYING_ACCOUNT*/
    p_status := -486604792;
    return;
   end if;
  else
   /* Fix CORE-762: Check that payerid exists */
   begin
     select count(*) into p_count  
     from t_account 
     where id_acc = p_id_payer;
     
     if p_count = 0 then
       p_status := -486604792;
       return;
     end if;
   end;
   payerID := p_id_payer;
  end if;
  
  /* default the payer end date to the end of the account*/
  if p_payer_enddate is NULL then
   payerenddate := dbo.mtmaxdate;
  else
   payerenddate := p_payer_enddate;
  end if;
  
  /* find the old payment information*/
  for i in (
    select vt_start,vt_end ,id_payer
    from t_payment_redirection
    where id_payee = AccountID and
    dbo.overlappingdaterange(vt_start,vt_end,p_payer_startdate,dbo.mtmaxdate)=1)
    loop
        oldpayerstart := i.vt_start;
        oldpayerend   := i.vt_end;
        oldpayer      := i.id_payer;
    end loop;
    
  /* if the new record is in range of the old record and the payer is the same as the older payer,
     update the record*/
     
  if (payerID = oldpayer) then
    UpdatePaymentRecord(payerID,accountID,oldpayerstart,oldpayerend,
                        p_payer_startdate,payerenddate,p_systemdate,
                        p_enforce_same_corporation,p_account_currency,p_status);
    if (p_status <> 1) then
      return;
    end if;
  else
    select case when payerID = accountID then p_billable else null end into payerbillable from dual;
    CreatePaymentRecord(payerID,accountID,p_payer_startdate,payerenddate,payerbillable,
                        p_systemdate,'N',p_enforce_same_corporation,p_account_currency,p_status);
    if (p_status <> 1) then
      return;
    end if;
  end if;
 end if;
 
 /* check if the account has any payees before setting the account as Non-billable.  It is important
    that this check take place after creating any payment redirection records   */
    
 if dbo.IsAccountBillable(AccountID) = '1' AND p_billable = 'N' then
    if dbo.DoesAccountHavePayees(AccountID,p_systemdate) = 'Y' then
          /* MT_ACCOUNT_NON_BILLABLE_AND_HAS_NON_PAYING_SUBSCRIBERS*/
          p_status := -486604767;
          return;
    end if;
 end if;
 /* payer update done */
 
 /* ancestor update begin */
 if ((p_ancestor_name is not null AND p_ancestor_namespace is not NULL)
 or p_id_ancestor is not null) AND p_hierarchy_movedate is not null then
 
  if p_ancestor_name is not NULL and p_ancestor_namespace is not NULL then
   ancestorID := dbo.LookupAccount(p_ancestor_name,p_ancestor_namespace) ;
   p_id_ancestor_out := ancestorID;
   if ancestorID = -1 then
    /* MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT*/
    p_status := -486604791;
    return;
   end if;
  else
   ancestorID := p_id_ancestor;
  end if;
  MoveAccount2(ancestorID,AccountID,p_hierarchy_movedate,p_enforce_same_corporation,p_systemdate,p_status,p_old_id_ancestor_out,p_ancestor_type,p_acc_type,'N');
  if p_status <> 1 then
   return;
  end if;
 end if;
 /* ancestor update done */
 
  if (p_old_id_ancestor_out is null) then
      p_old_id_ancestor_out := -1;
  end if;

  if (p_id_ancestor_out is null) then
      p_id_ancestor_out := -1;
  end if;
 
 /* step : resolve the hierarchy path based on the current time*/
 begin
  select tx_path into p_hierarchy_path from t_account_ancestor
  where id_ancestor =1  and id_descendent = AccountID and
  p_systemdate between vt_start and vt_end;
  exception when NO_DATA_FOUND then
  p_hierarchy_path := '/';  
 end;
 
 /* resolve account's corporate account */
 
 begin
    select max(ancestor.id_ancestor) into p_corporate_account_id from t_account_ancestor ancestor
    inner join t_account acc on ancestor.id_ancestor = acc.id_acc
    inner join t_account_type atype on atype.id_type = acc.id_type
    where
      ancestor.id_descendent = AccountID
      AND atype.b_iscorporate = '1'
      AND p_systemdate  BETWEEN ancestor.vt_start and ancestor.vt_end;
    exception when NO_DATA_FOUND then
        null;
 end;

 /* done*/

 p_accountID := AccountID;
 p_status := 1;
end;
                
