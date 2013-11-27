
create procedure AdjustSubDates(
@p_id_po integer,
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

	select @p_adjustedstart = dbo.mtmaxoftwodates(@p_startdate,po.dt_start),
	@p_adjustedend = dbo.mtminoftwodates(@p_enddate,po.dt_end) 
	from 
	(select te.dt_start,
	case when te.dt_end is NULL then dbo.mtmaxdate() else te.dt_end end as dt_end
	from t_po
	INNER JOIN t_effectivedate te on te.id_eff_date = t_po.id_eff_date
	where t_po.id_po = @p_id_po) po
	if (@p_adjustedstart <> @p_startdate OR @p_adjustedend <> @p_enddate) begin
		select @p_datemodified = 'Y'
	end
	if @p_adjustedend < @p_adjustedstart begin
		-- hmm.... looks like we are outside the effective date of the product offering
		-- MTPCUSER_PRODUCTOFFERING_NOT_EFFECTIVE
		select @p_status = -289472472
		return
	end
	select @p_status = 1
	return
end
		