
create procedure AddNewSub(
 @p_id_acc int,
 @p_dt_start datetime,
 @p_dt_end datetime,
 @p_NextCycleAfterStartDate varchar,
 @p_NextCycleAfterEndDate varchar,
 @p_id_po int,
 @p_GUID varbinary(16),
 @p_systemdate datetime,
 @p_id_sub int,
 @p_status int output,
 @p_datemodified varchar(1) output,
 @p_allow_acc_po_curr_mismatch int = 0,
 @p_allow_multiple_pi_sub_rcnrc int = 0,
 @p_quoting_batch_id varchar(256)=null)
as
begin
declare @real_begin_date as datetime
declare @real_end_date as datetime
declare @po_effstartdate as datetime
declare @varMaxDateTime datetime
declare @datemodified varchar(1)
select @varMaxDateTime = dbo.MTMaxDate()
	select @p_status =0
-- compute usage cycle dates if necessary
if (upper(@p_NextCycleAfterStartDate) = 'Y')
 begin
 select @real_begin_date = dbo.NextDateAfterBillingCycle(@p_id_acc,@p_dt_start)
 end
else
 begin
   select @real_begin_date = @p_dt_start
 end
if (upper(@p_NextCycleAfterEndDate) = 'Y' AND @p_dt_end is not NULL)
 begin
 select @real_end_date = dbo.NextDateAfterBillingCycle(@p_id_acc,@p_dt_end)
   end
else
 begin
 select @real_end_date = @p_dt_end
 end
if (@p_dt_end is NULL)
 begin
 select @real_end_date = @varMaxDateTime
 end

exec AddSubscriptionBase 
			@p_id_acc,
			NULL,
			@p_id_po,
			@real_begin_date,
			@real_end_date,
			@p_GUID,
			@p_systemdate,
			@p_id_sub,
			@p_status output,
			@datemodified output,
			@p_allow_acc_po_curr_mismatch,
			@p_allow_multiple_pi_sub_rcnrc, 
			@p_quoting_batch_id 

select @p_datemodified = @datemodified
end