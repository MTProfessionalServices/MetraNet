
CREATE procedure DeletePriceableItemInstance
		(@piID int, @poID int, @status int output)
as
Begin

	DECLARE @kind int, @id_pi_template int, @id_sched int, @pt_status int
	
	/* Check to see if adjustment transactions exist for any ajustment instances on this piInstance */
	if exists(
		select at.id_adj_trx
		from
			t_adjustment_transaction at
			inner join
			t_adjustment a with(updlock) on at.id_aj_instance = a.id_prop
		where
			a.id_pi_instance = @piID )
	BEGIN
		set @status = -10;
		return
	END
	
	DECLARE @id_aj int
	DECLARE ajCursor CURSOR STATIC FOR
		select id_prop from t_adjustment with(updlock) where id_pi_instance = @piID
		
	OPEN ajCursor
	FETCH NEXT FROM ajCursor into @id_aj
	WHILE @@FETCH_STATUS = 0
	BEGIN
		/* DELETE Adjustment instances */
		DELETE FROM t_adjustment WHERE id_prop = @id_aj
		
		Exec DeleteBaseProps @id_aj
		
		FETCH NEXT FROM ajCursor into @id_aj
	END
	
	CLOSE ajCursor
	DEALLOCATE ajCursor
	
	/* DELETE rate schedule */
	SELECT	@id_pi_template = [id_pi_template]
	FROM	[t_pl_map] with(updlock)
	WHERE	[id_po] = @poID
	AND		[id_pi_instance] = @piID
	AND		[id_paramtable] is null


	-- Fetch all parameter tables.
	-- Delete Rate Schedules that are mapped to non-shared price list (leave those mapped to shared pricelists)
	DECLARE ptcursor CURSOR STATIC FOR
	SELECT	rs.id_sched
	FROM	t_rsched rs with(updlock)
	INNER JOIN t_pl_map pl ON (rs.id_pt = pl.id_paramtable and rs.id_pt = pl.id_paramtable)
	INNER JOIN t_po po ON (po.id_nonshared_pl = rs.id_pricelist AND po.id_po = pl.id_po)
	WHERE	pl.id_pi_instance = @piID
	AND		pl.id_pi_template = @id_pi_template
	AND		po.id_po = @poID
	
	OPEN ptcursor
	
	FETCH NEXT FROM ptcursor INTO @id_sched
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC DeleteRateSchedule @id_sched, @pt_status
		FETCH NEXT FROM ptcursor INTO @id_sched
	END
	
	CLOSE ptcursor
    DEALLOCATE ptcursor
	
   	-- Determine the PI instance kind
	Select  @kind = n_kind from t_base_props with(updlock) where id_prop = @piID       

	-- Delete PI Instance from PL Map removing it from the PO
	Delete from t_pl_map where id_pi_instance = @piID

	Declare @n_unit_name int, @n_unit_display_name int

	-- Delete kind specific properties
	if(@kind = 25)
	Begin
		Delete from t_recur_enum where id_prop = @piID
		
		select @n_unit_name = n_unit_name, @n_unit_display_name = n_unit_display_name 
		from t_recur with(updlock) where id_prop = @piID
	End

	-- Delete Extended Properties
	DECLARE @sqlStr nvarchar(255)
    DECLARE @epTableName nvarchar(200)
    /* Note: Need to use kind = 20 when kind=25 for this query because UDRC's are somehow mapped to RC EP records */
    DECLARE epTables cursor for select nm_ep_tablename from t_ep_map where id_principal= case when @kind=25 then 20 else @kind end
    open epTables

    fetch next from epTables into @epTableName

    while @@FETCH_STATUS = 0
    BEGIN
		set @sqlStr = 'delete from ' + @epTableName + ' where id_prop = ' + cast(@piID as nvarchar(10))
        Execute (@sqlStr)
		fetch next from epTables into @epTableName
	END
	
	CLOSE epTables
	DEALLOCATE epTables

	if(@kind = 25)
	BEGIN
		delete from t_description where id_desc = @n_unit_display_name
		delete from t_description where id_desc = @n_unit_name
	END

	-- Delete Base props
	Exec DeleteBaseProps @piID
	
	set @status = 0
end
    