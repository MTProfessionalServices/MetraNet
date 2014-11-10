
create or replace procedure createpaymentrecord(
  payer int,    
  npa int,    
  startdate date,    
  enddate date,    
  payerbillable varchar2,    
  systemdate date,    
  p_fromupdate char,    
  p_enforce_same_corporation varchar2,    
  p_account_currency nvarchar2,    
  status out int) 
as
  account_currency nvarchar2(5);
  
  realstartdate date;
  realenddate date;
  acccreatedate date;
  billableflag varchar2(1);
  payer_state varchar2(10);
  
  npapayerrule varchar2(1);
  samecurrency int;
  payeecurrentancestor int;
  check1 int;
  check2 int;
  check3 int;
  payer_cycle_type int;
  check4 int;
begin
  status := 0;
  realstartdate := dbo.mtstartofday(startdate);
  account_currency := p_account_currency;

  if(enddate is null) then
    realenddate := dbo.mtstartofday(dbo.mtmaxdate());
  elsif enddate <> dbo.mtstartofday(dbo.mtmaxdate()) then
    realenddate := dbo.mtstartofday(enddate) + 1;
  else
    realenddate := enddate;
  end if;
  
  select dbo.mtstartofday(dt_crt) into acccreatedate
  from t_account
  where id_acc = npa;

  if realstartdate < acccreatedate then
    /* MT_PAYMENT_DATE_BEFORE_ACCOUNT_STARDATE */ 
    status := -486604753;
    return;
  end if;
  
  if realstartdate = realenddate then
    /* MT_PAYMENT_START_AND_END_ARE_THE_SAME */ 
    status := -486604735;
    return;
  end if;

  if realstartdate > realenddate then
    /* MT_PAYMENT_START_AFTER_END  */ 
    status := -486604734;
    return;
  end if;

  /* npa: non paying account      
    assumptions: the system has already checked if an existing payment      
    redirection record exists.  the user is asked whether the      
    system should truncate the existing payment redirection record.      
    business rule checks:      
      mt_account_can_not_pay_for_itself (0xe2ff0007l, -486604793)      
      account_is_not_billable (0xe2ff0005l,-486604795)      
      mt_payment_relationship_exists (0xe2ff0006l, -486604794)      
      step 1: account can not pay for itself    
      if (payer = npa)      
      begin      
        select status = -486604793      
        return      
      end
  */

  if(payer <> -1) then
    billableflag := case when payerbillable is null 
                      then dbo.isaccountbillable(payer)
                      else payerbillable
                    end;

    /* step 2: the account is in a state such that new payment       
      records can be created */
    
    if(billableflag = '0') then
      /*  MT_ACCOUNT_IS_NOT_BILLABLE */ 
      status := -486604795;
      return;
    end if;
  
    /* make sure that the paying account is active for the entire 
      payment period       */
    select status  into payer_state
    from t_account_state
    where dbo.encloseddaterange(vt_start, vt_end, realstartdate, realenddate - 1/(24*60*60)) = 1
      and id_acc = payer
      and rownum <= 1;
  
    if (payer_state is null or lower(payer_state) <> 'ac') AND payer <> NPA then
      /* mt_payer_in_invalid_state */ 
      status := -486604736;
      return;
    end if;
  
    /* always check that payer and payee are on the same currency 
      (if they are not the same, of course)       
      if p_account_currency parameter was passed as empty string, then       
      the call is coming either from mam, and the currency is not available,       
      or the call is coming from account update session, where currency is not being       
      updated. in both cases it won't hurt to resolve it from t_av_internal and check
      that it matches payer currency.. ok, in kona, an account that can never be a payer
      need not have a currency, handle this.
      */
  
    if (npa <> payer) then
    
      if ((length(account_currency) = 0)  OR (length(account_currency) is null)) then
          select c_currency 
          into account_currency
          from t_av_internal
          where id_acc = npa;
    
          if(account_currency is null) then
            /* check if the account type has the b_canbepayer false, if it is
            then just assume that it has the same currency as the
            prospective payer. */
            select b_canbepayer
            into npapayerrule
            from t_account_type atype
            inner join t_account acc 
              on atype.id_type = acc.id_type
            where acc.id_acc = npa;
    
            if(npapayerrule = '0') then
              select c_currency
              into account_currency
              from t_av_internal
              where id_acc = payer;
            end if;
         end if;
      end if;
    
      select count(payerav.id_acc)
      into samecurrency
      from t_av_internal payerav
      where payerav.id_acc = payer
        and upper(payerav.c_currency) = upper(account_currency);
      
      if samecurrency = 0 then
        /* MT_PAYER_PAYEE_CURRENCY_MISMATCH */ 
        status := -486604728;
        return;
      end if;
    end if; /* npa <> payer */
    
    /* check that both the payer and payee are in the same corporate account
    only check this if business rule is enforced
    only check this if the payee's current ancestor is not -1 */
    select id_ancestor
    into payeecurrentancestor
    from t_account_ancestor
    where id_descendent = npa
      and realstartdate between vt_start and vt_end
      and num_generations = 1;
    
    if (p_enforce_same_corporation = 1 
          and payeecurrentancestor <> -1
          and dbo.isinsamecorporateaccount(payer, npa, realstartdate) <> 1) then
      
      /* MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT */ 
      status := -486604758;
      return;
    end if;
  
  end if; /*  payer <> -1 */

  /* return without doing work in cases where nothing needs to be done */
  select count(*) into status
  from t_payment_redirection
  where id_payer = payer
    and id_payee = npa
    and((dbo.encloseddaterange(vt_start, vt_end, realstartdate, realenddate) = 1
    and p_fromupdate = 'n') or(vt_start <= realstartdate
    and vt_end = realenddate
    and p_fromupdate = 'y'));

  if status > 0 then
    /* account is already paying for the account during the interval.       
    simply ignore the action */ 
    status := 1;
    return;
  end if;

  createpaymentrecordbitemporal(payer, npa, realstartdate, realenddate,
      systemdate, status);

  if status <> 1 then
    return;
  end if;

  /* post-operation business rule checks (relies on rollback of work done up    
  until this point) */
  select  
      /* cr9906: checks to make sure the new payer's billing cycle matches all of 
        the payee's group subscriptions' bcr constraints */ 
    nvl(min(dbo.checkgroupmembershipcycleconst(systemdate, grps.id_group)), 1),
     /* ebcr cycle constraint checks */ 
     nvl(min(dbo.checkgroupmembershipebcrconstr(systemdate, grps.id_group)), 1)
  into check1, check2
  from (
    /* gets all of the payee's group subscriptions */
    select distinct gsm.id_group id_group
    from t_gsubmember gsm
    where gsm.id_acc = npa/* payee id */) grps;

  if (check1 <> 1) then
    status := check1;
    return;
  elsif (check2 <> 1) then
    status := check2;
    return;
  end if;

  check3 := 1;
  for i in (
        /* gets all of the payee's receiverships */
        select distinct gsrm.id_group id_group
        from t_gsub_recur_map gsrm
        where gsrm.id_acc = npa /* payee id */)
  loop
    check3 := dbo.checkgroupreceiverebcrcons(systemdate, i.id_group);
    exit;
  end loop;
  
  if(check3 <> 1) then
    status := check3;
  end if;

  /* Part of bug fix for 13588  
  check that - if the payee has individual subscriptions to product offerings with BCR constraints, then the
  new payer's cycle type satisfies those constraints. */ 
  for i in (select type.id_cycle_type
             from t_acc_usage_cycle uc
             inner join t_usage_cycle ucc 
                on uc.id_usage_cycle = ucc.id_usage_cycle
             inner join t_usage_cycle_type type 
                on ucc.id_cycle_type = type.id_cycle_type
             where uc.id_acc = payer)
  loop
    payer_cycle_type := i.id_cycle_type;
  end loop;

  /* g. cieplik 1/29/2009 (CORE-660) poConstrainedCycleType returns zero when there is no "ConstrainedCycleType", added predicate to check value being returned from "poConstrainedCycleType */
  select count(1) into check4 from dual
  where exists (
    select id_po
    from t_sub sub
    where id_acc = npa
      and id_group is null
      and realenddate >= sub.vt_start
      and realstartdate <= sub.vt_end
      and dbo.pocontainsbillingcyclerelative(id_po) = 1
      and payer_cycle_type <> dbo.poconstrainedcycletype(id_po)
      and 0 <> dbo.poConstrainedCycleType(id_po));

  if(check4 <> 0) then
    status := -289472464;
  end if;

end createpaymentrecord;
			 