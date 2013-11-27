
CREATE OR REPLACE
procedure addaccounttogroupsub(
p_id_sub IN integer,
p_id_group IN integer,
p_id_po IN integer,
p_id_acc IN integer,
p_startdate IN date,
p_enddate IN date,
p_systemdate IN date,
p_enforce_same_corporation varchar2,
p_status OUT integer,
p_datemodified OUT varchar2,
p_allow_acc_po_curr_mismatch INTEGER default 0,
p_allow_multiple_pi_sub_rcnrc INTEGER default 0
)
as
 existingID integer;
 real_startdate date;
 real_enddate date;
 var_dummy number:=0;
begin
 p_status := 0;
 /* step : if the end date is null get the max date
  XXX this is broken if the end date of the group subscription is not max date*/
  if p_enddate is null then
   real_enddate := dbo.MTMaxDate();
  else
		if p_startdate > p_enddate then
			/* MT_GROUPSUB_STARTDATE_AFTER_ENDDATE*/
			p_status := -486604782;
			p_datemodified := 'N';
			return;
    end if;
   real_enddate := p_enddate;
  end if;
  begin
      select dbo.mtmaxoftwodates(p_startdate,t_sub.vt_start),
      dbo.mtminoftwodates(real_enddate,t_sub.vt_end) into real_startdate,real_enddate
      from
      t_sub where id_sub = p_id_sub;
  exception
      when no_data_found then
/*        real_startdate := p_startdate;*/
/*        real_enddate   := real_enddate;*/
        null;
  end;
  if real_startdate <> p_startdate OR
  (real_enddate <> p_enddate AND real_enddate <> dbo.mtmaxdate()) then
    p_datemodified := 'Y';
  else
    p_datemodified := 'N';
  end if;
 begin
   /* step : check that account is not already part of the group subscription
    in the specified date range*/
   select id_acc into existingID from t_gsubmember where
   /* check againt the account*/
   id_acc = p_id_acc AND id_group = p_id_group
   /* make sure that the specified date range does not conflict with */
   /* an existing range*/
   AND dbo.overlappingdaterange(vt_start,vt_end,
   real_startdate,real_enddate) = 1;
   if existingID = p_id_acc then
    /* MT_ACCOUNT_ALREADY_IN_GROUP_SUBSCRIPTION */
    p_status := -486604790;
    return;
   end if;
  exception when NO_DATA_FOUND then
    p_status := 0;
  end;
 /* step : verify that the date range is inside that of the group subscription*/
 begin
  select dbo.encloseddaterange(vt_start,vt_end,real_startdate,real_enddate) into p_status
  from t_sub where id_group = p_id_group;
    if p_status <> 1 then
        /* MT_GSUB_DATERANGE_NOT_IN_SUB_RANGE*/
        p_status := -486604789;
        return;
    end if;
  exception when NO_DATA_FOUND then
   /* MT_GROUP_SUBSCRIPTION_DOES_NOT_EXIST*/
   p_status := -486604788;
   return;
  end;
 /* step : check that the account does not have any conflicting subscriptions
  note: checksubscriptionconflicts return 0 on success while the other
  functions return 1.  This should be fixed (CS 2-1-2001)*/
 select dbo.checksubscriptionconflicts(p_id_acc,p_id_po,
 real_startdate,real_enddate,p_id_sub,p_allow_acc_po_curr_mismatch,p_allow_multiple_pi_sub_rcnrc) into p_status from dual;
 if p_status <> 1 then
  return;
 end if;

 /* make sure that the member is in the corporate account specified in
  the group subscription*/
 select count(num_generations) into p_status from
 t_account_ancestor ancestor
 INNER JOIN t_group_sub tg on tg.id_group = p_id_group
 where ancestor.id_ancestor = tg.id_corporate_account AND
 ancestor.id_descendent = p_id_acc AND
 real_startdate between ancestor.vt_start AND ancestor.vt_end;
 if p_status = 0 then
  /* MT_ACCOUNT_NOT_IN_GSUB_CORPORATE_ACCOUNT*/
  p_status := -486604769;
  return;
 end if;
		/* check that account type of the member is compatible with the product offering
     since the absense of ANY mappings for the product offering means that PO is "wide open"
     we need to do 2 EXISTS queries */

		select count(1) into var_dummy from dual
		where
		 exists (
      SELECT 1
      FROM t_po_account_type_map atmap
      WHERE atmap.id_po = p_id_po
    )
    /* PO is not wide open - see if susbcription is permitted for the account type */
    AND
    not exists (
      SELECT 1
      FROM  t_account tacc
      INNER JOIN t_po_account_type_map atmap on atmap.id_po = p_id_po AND atmap.id_account_type = tacc.id_type
      WHERE  tacc.id_acc = p_id_acc
    );
    if (var_dummy <>0)
    then
      p_status := -289472435; /* MTPCUSER_CONFLICTING_PO_ACCOUNT_TYPE */
      return;
    end if;
	
var_dummy := 0;
    /* Check for MTPCUSER_ACCOUNT_TYPE_CANNOT_PARTICIPATE_IN_GSUB 0xEEBF004FL -289472433
     BR violation */
		select count(1) into var_dummy from dual 
		where
		 exists (
      SELECT 1
      FROM  t_account tacc 
      INNER JOIN t_account_type tacctype on tacc.id_type = tacctype.id_type
      WHERE tacc.id_acc = p_id_acc AND tacctype.b_CanParticipateInGSub = '0'
    );


 /* end business rule checks
  step : insert the data*/
 CreateGSubMemberRecord(p_id_group,p_id_acc,real_startdate,real_enddate,p_systemdate,p_status);

  /* post-creation business rule check (relies on rollback of work done up until this point)
   CR9906: check to make sure the newly added member does not violate a BCR constraint*/
  p_status := dbo.CHECKGROUPMEMBERSHIPCYCLECONST(p_systemdate, p_id_group);
  IF p_status <> 1 then
    RETURN;
  END IF;
  /* checks to make sure the member's payer's do not violate EBCR cycle constraints*/
  p_status := dbo.CheckGroupMembershipEBCRConstr(p_systemdate, p_id_group);

 /* end*/
end;
		