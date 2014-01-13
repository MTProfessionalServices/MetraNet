
create function IsInSameCorporateAccount(@acc1 int,@acc2 int,@refdate datetime) returns int
as
begin

  declare @retval int

  declare @id_corp1 int
  select @id_corp1 = id_ancestor
  from t_account_ancestor anc
  inner join t_account acc
  on anc.id_ancestor = acc.id_acc
  inner join t_account_type atype
  on acc.id_type = atype.id_type
  where anc.id_descendent = @acc1
  and @refdate between anc.vt_start AND anc.vt_end
  and atype.b_iscorporate = '1'


  declare @id_corp2 int
  select @id_corp2 = id_ancestor
  from t_account_ancestor anc
  inner join t_account acc
  on anc.id_ancestor = acc.id_acc
  inner join t_account_type atype
  on acc.id_type = atype.id_type
  where anc.id_descendent = @acc2
  and @refdate between anc.vt_start AND anc.vt_end
  and atype.b_iscorporate = '1'


if (@id_corp1 = @id_corp2)
  select @retval = 1
else if (@id_corp1 is null AND @id_corp2 is null)
	select @retval = 1
else
	select @retval = 0



	return @retval


	return @retval
end
	