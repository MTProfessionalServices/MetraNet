
create procedure AdjustGsubMemberDates(
@p_id_sub integer,
@p_startdate datetime,
@p_enddate datetime,
@p_adjustedstart datetime OUTPUT,
@p_adjustedend datetime OUTPUT,
@p_datemodified char(1) OUTPUT,
@p_status INT OUTPUT
)
as
begin
	select @p_datemodified = 'N'	

	select @p_adjustedstart = dbo.mtmaxoftwodates(@p_startdate,vt_start),
	@p_adjustedend = dbo.mtminoftwodates(@p_enddate,vt_end) 
	from 
	t_sub where id_sub = @p_id_sub

	if (@p_adjustedstart <> @p_startdate OR @p_adjustedend <> @p_enddate) begin
		select @p_datemodified = 'Y'
	end
	if @p_adjustedend < @p_adjustedstart begin
		-- hmm.... looks like we are outside the effective date of the group subscription
		-- MT_GSUB_DATERANGE_NOT_IN_SUB_RANGE
		select @p_status = -486604789
		return
	end
	select @p_status = 1
	return
end
		