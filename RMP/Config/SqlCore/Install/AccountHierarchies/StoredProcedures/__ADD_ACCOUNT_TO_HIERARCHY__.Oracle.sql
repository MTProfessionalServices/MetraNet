
create or replace procedure addacctohierarchy (
   p_id_ancestor     in       int default null,
   p_id_descendent   in       int default null,
   p_dt_start        in       date default null,
   p_dt_end          in       date default null,
   p_acc_startdate   in       date default null,
   ancestor_type     out      varchar2,
   acc_type          out      varchar2,
   status            in out   int
)
as
   realstartdate          date;
   realenddate            date;
   varmaxdatetime         date;
   ancestor               int;
   descendentidasstring   varchar2 (50);
   ancestorstartdate      date;
   realaccstartdate       date;
   ancestor_acc_type      int;
   descendent_acc_type    int;
   nfound                 int;
begin
   /* begin business rules */
   varmaxdatetime := dbo.mtmaxdate ();
   descendentidasstring := cast (p_id_descendent as varchar2);

   for x in (select atype.name, atype.id_type
               from t_account acc inner join t_account_type atype on atype.id_type = acc.id_type
              where acc.id_acc = p_id_ancestor)
   loop
      ancestor_type := x.name;
      ancestor_acc_type := x.id_type;
   end loop;

   for x in (select atype.name, atype.id_type
               from t_account acc inner join t_account_type atype on atype.id_type = acc.id_type
              where acc.id_acc = p_id_descendent)
   loop
      acc_type := x.name;
      descendent_acc_type := x.id_type;
   end loop;

   for x in (select id_acc
               from t_account
              where id_acc = p_id_ancestor)
   loop
      ancestor := x.id_acc;
   end loop;

   if p_id_ancestor is null
   then
      /* MT_PARENT_NOT_IN_HIERARCHY */
      status := -486604771;
      return;
   end if;

   select count (*)
     into nfound
     from dual
    where descendent_acc_type not in (select id_descendent_type
                                        from t_acctype_descendenttype_map
                                       where id_type = ancestor_acc_type);

   if nfound <> 0
   then
      /* MT_ANCESTOR_OF_INCORRECT_TYPE */
      status := -486604714;
      return;
   end if;

   if p_acc_startdate is null
   then
      select dt_crt
        into realaccstartdate
        from t_account
       where id_acc = p_id_descendent;
   else
      realaccstartdate := p_acc_startdate;
   end if;

   for x in (select dt_crt
               from t_account
              where id_acc = p_id_ancestor)
   loop
      ancestorstartdate := x.dt_crt;
   end loop;

   if dbo.mtstartofday (realaccstartdate) <
                                          dbo.mtstartofday (ancestorstartdate)
   then
      /* MT_CANNOT_CREATE_ACCOUNT_BEFORE_ANCESTOR_START */
      status := -486604746;
      return;
   end if;

   select count (*)
     into status
     from t_account_ancestor
    where id_descendent = p_id_descendent
      and id_ancestor = p_id_ancestor
      and num_generations = 1
      and (dbo.overlappingdaterange (vt_start, vt_end, p_dt_start, p_dt_end) =
                                                                             1
          );

   if (status > 0)
   then
      /* MT_ACCOUNT_ALREADY_IN_HIEARCHY */
      status := -486604785;
      return;
   end if;

   /* end business rule checks. */
   realstartdate := dbo.mtstartofday (p_dt_start);

   if (p_dt_end is null)
   then
      realenddate := dbo.mtstartofday (dbo.mtmaxdate ());
   else
      realenddate := dbo.mtendofday (p_dt_end);
   end if;

   /* todo: we need error handling code to detect when the ancestor does
   not exist at the time interval!!
   populate t_account_ancestor (no bitemporal data)
   */
   insert into t_account_ancestor
               (id_ancestor, id_descendent, num_generations, vt_start, vt_end,
                tx_path)
      select id_ancestor, p_id_descendent, num_generations + 1,
             dbo.mtmaxoftwodates (vt_start, realstartdate),
             dbo.mtminoftwodates (vt_end, realenddate),
             case
                when (id_descendent = 1 or id_descendent = -1)
                   then tx_path || descendentidasstring
                else tx_path || '/' || descendentidasstring
             end
        from t_account_ancestor
       where id_descendent = p_id_ancestor
         and id_ancestor <> id_descendent
         and dbo.overlappingdaterange (vt_start,
                                       vt_end,
                                       realstartdate,
                                       realenddate
                                      ) = 1
      union all
      /* the new record to parent.  note that the ..?? */
      select p_id_ancestor, p_id_descendent, 1, realstartdate, realenddate,
             case
                when (id_descendent = 1 or id_descendent = -1)
                   then tx_path || descendentidasstring
                else tx_path || '/' || descendentidasstring
             end
        from t_account_ancestor
       where id_descendent = p_id_ancestor
         and num_generations = 0
         and dbo.overlappingdaterange (vt_start,
                                       vt_end,
                                       realstartdate,
                                       realenddate
                                      ) = 1
      /* self pointer */
      union all
      select p_id_descendent, p_id_descendent, 0, realstartdate, realenddate,
             descendentidasstring
        from dual;

   /* update our parent entry to have children */   
    UPDATE   t_account_ancestor
      SET   b_children = 'Y'
    WHERE   id_descendent = p_id_ancestor
            AND dbo.overlappingdaterange (vt_start,
                                          vt_end,
                                          realstartdate,
                                          realenddate) = 1
             and b_Children <> 'Y';   

   if (sqlcode <> 0)
   then
      status := 0;
      return;
   end if;

   status := 1;
end addacctohierarchy;
		