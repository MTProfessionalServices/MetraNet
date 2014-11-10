
create procedure UpdateGroupSubMembership(
@p_id_acc int,
@p_id_sub int,
@p_id_po int,
@p_id_group int,	
@p_startdate datetime,
@p_enddate datetime,
@p_systemdate datetime,
@p_status int OUTPUT,
@p_datemodified varchar OUTPUT,
@p_allow_acc_po_curr_mismatch int = 0,
@p_allow_multiple_pi_sub_rcnrc int = 0
)
as
begin
declare @realstartdate datetime
declare @realenddate datetime

	exec AdjustGsubMemberDates @p_id_sub,@p_startdate,@p_enddate,
	@realstartdate OUTPUT,@realenddate OUTPUT,@p_datemodified OUTPUT,@p_status OUTPUT
	if @p_status <> 1 begin
		return
	end


 -- check that the new date does not conflict with another subscription
	-- to the same product offering
select @p_status = dbo.checksubscriptionconflicts(@p_id_acc,@p_id_po,@realstartdate,@realenddate,@p_id_sub,
 @p_allow_acc_po_curr_mismatch, @p_allow_multiple_pi_sub_rcnrc) 
if (@p_status <> 1)
	begin
	return
	end 
-- end business rule checks
begin
	exec CreateGSubMemberRecord @p_id_group,@p_id_acc,@realstartdate,@realenddate,
		@p_systemdate,@p_status OUTPUT
	if (@@error <> 0)
		begin
		-- not in group subscription, MT_GROUPSUB_ACCOUNT_NOT_IN_GROUP_SUB
		select @p_status = -486604777 
		end
-- done
end
end
		 