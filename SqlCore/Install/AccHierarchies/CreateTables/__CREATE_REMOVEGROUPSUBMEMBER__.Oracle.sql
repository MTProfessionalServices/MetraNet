
create or replace procedure RemoveGroupSubMember(
p_id_acc IN integer,
p_substartdate date,
p_id_group IN integer,
p_b_overrideDateCheck IN varchar2,
p_systemdate IN date,
p_status OUT integer
)
as
startdate date;
varMaxDateTime date;
begin
 varMaxDateTime := dbo.MTMaxDate;
 p_status := 0;

 if p_b_overrideDateCheck = 'N' then
  /* find the start date of the group subscription membership
   that exists at some point in the future.*/
  begin
   for i in (
   select vt_start from t_gsubmember
   where id_acc = p_id_acc AND id_group = p_id_group AND
   vt_start > p_systemdate)
   loop
    startdate := i.vt_start;
   end loop;
   if startdate is null then
       /* MT_GROUPSUB_DELETE_MEMBER_FAILED*/
       p_status := -486604776;
       return;
   end if;
  end;
 end if;

if p_substartdate = dbo.MTMaxDate() then
      delete from t_gsubmember where id_acc = p_id_acc and id_group = p_id_group;
      update t_gsubmember_historical 
      set tt_end = dbo.subtractsecond(p_systemdate)
          where id_acc = p_id_acc 
                      and id_group = p_id_group
                      and tt_end = varMaxDateTime;
else
      delete from t_gsubmember where id_acc = p_id_acc and id_group = p_id_group and p_substartdate = vt_start;
      update t_gsubmember_historical 
      set tt_end = dbo.subtractsecond(p_systemdate)
      where id_acc = p_id_acc 
          and id_group = p_id_group
          and tt_end = varMaxDateTime
          and p_substartdate = vt_start;
end if;

 
 /*done*/
 p_status := 1;
end;
				