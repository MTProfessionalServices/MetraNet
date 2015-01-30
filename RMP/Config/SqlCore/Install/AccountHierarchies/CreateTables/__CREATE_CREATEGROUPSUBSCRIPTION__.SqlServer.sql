
create procedure CreateGroupSubscription(
@p_sub_GUID varbinary(16),
@p_group_GUID varbinary(16),
@p_name  nvarchar(255),
@p_desc nvarchar(255),
@p_usage_cycle int,
@p_startdate datetime,
@p_enddate datetime,
@p_id_po int,
@p_proportional varchar,
@p_supportgroupops varchar,
@p_discountaccount int,
@p_CorporateAccount int,
@p_systemdate datetime,
@p_enforce_same_corporation varchar,
@p_allow_acc_po_curr_mismatch int = 0,
@p_id_sub int,
@p_quoting_batch_id     varchar(256),
@p_id_group int OUTPUT,
@p_status int OUTPUT,
@p_datemodified varchar OUTPUT
)
as
begin
declare @existingPO as int
declare @realenddate as datetime
declare @varMaxDateTime as datetime
select @p_datemodified = 'N'
 -- business rule checks
select @varMaxDateTime = dbo.MTMaxDate()
select @p_status = 0
exec CheckGroupSubBusinessRules @p_name,@p_desc,@p_startdate,@p_enddate,@p_id_po,@p_proportional,
@p_discountaccount,@p_CorporateAccount,NULL,@p_usage_cycle,@p_systemdate, @p_enforce_same_corporation, @p_allow_acc_po_curr_mismatch, @p_status OUTPUT
if (@p_status <> 1) 
	begin
	return
	end 
	-- set the end date to max date if it is not specified
if (@p_enddate is null) 
	begin
	select @realenddate = @varMaxDateTime
	end
else
	begin
	select @realenddate = @p_enddate
	end 
	insert into t_group_sub (id_group_ext,tx_name,tx_desc,b_visable,b_supportgroupops,
	id_usage_cycle,b_proportional,id_discountAccount,id_corporate_account)
	select @p_group_GUID,@p_name,@p_desc,'N',@p_supportgroupops,@p_usage_cycle,
	@p_proportional,@p_discountaccount,@p_CorporateAccount
	-- group subscription ID
	select @p_id_group =@@identity
 -- add group entry
   exec AddSubscriptionBase 
      NULL,
      @p_id_group,
      @p_id_po,
      @p_startdate,
      @p_enddate,
      @p_group_GUID,
      @p_systemdate,
      @p_id_sub, 
      @p_status output,
      @p_datemodified output, 
      0,
      0, 
      @p_quoting_batch_id
end
			