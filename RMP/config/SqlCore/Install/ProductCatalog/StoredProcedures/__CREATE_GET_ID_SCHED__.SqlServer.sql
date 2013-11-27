
/* Get all the rsched rows for a given subscription/param table combo for a given date range and return a cursor of the id_rsched and dates */
/* Will need 2 versions of this: one to find the private rscheds (ICBs) the GUI looks at and one to find the public rscheds (ICBs + inheritance) the pipeline looks at */
/* Only difference is which version of t_rsched we go to */
CREATE PROCEDURE get_id_sched(
	@my_id_sub int,
	@my_id_pt int,
	@my_id_pi_template int,
	@my_start_dt datetime,
	@my_end_dt datetime,
	@my_id_sched_curs CURSOR VARYING OUT
)
AS
BEGIN
	SET @my_id_sched_curs = CURSOR FOR
		SELECT r.id_sched, e.dt_start, e.dt_end
		FROM   t_pl_map pm
				INNER JOIN t_rsched r on r.id_pricelist = pm.id_pricelist and r.id_pt = @my_id_pt and pm.id_pi_template = r.id_pi_template
				INNER JOIN t_effectivedate e on r.id_eff_date = e.id_eff_date and dbo.determine_absolute_dates(e.dt_start,e.n_begintype, e.n_beginoffset,0,1) <= @my_end_dt and dbo.determine_absolute_dates(e.dt_end, e.n_endtype, e.n_endoffset,0,0) >= @my_start_dt
		WHERE  pm.id_sub = @my_id_sub and pm.id_paramtable = @my_id_pt and pm.id_pi_template = @my_id_pi_template
		ORDER BY e.n_begintype ASC, dbo.determine_absolute_dates(e.dt_start,e.n_begintype, e.n_beginoffset,0,1) DESC

	OPEN @my_id_sched_curs
END
