
    create function POContainsOnlyAbsoluteRates(@id_po int) returns int
    as
    begin
    declare @retval as integer
	    select @retval = count(te.id_eff_date)
	    from
	    t_effectivedate te
	    INNER JOIN t_po on t_po.id_po = @id_po
	    INNER JOIN t_pl_map map on map.id_po = t_po.id_po AND id_paramtable is not NULL AND id_sub is NULL
	    LEFT OUTER JOIN t_rsched sched on sched.id_pt = map.id_paramtable AND sched.id_pricelist = map.id_pricelist
	    AND sched.id_pi_template = map.id_pi_template
	    where
	    te.id_eff_date = sched.id_eff_date AND
	    -- only absolute or NULL dates
	    (te.n_begintype in (2,3) OR te.n_endtype in (2,3))
	    if @retval > 0  begin
		    return 0
	    end
	    else begin
		    return 1
	    end
	    return 0
    end
		