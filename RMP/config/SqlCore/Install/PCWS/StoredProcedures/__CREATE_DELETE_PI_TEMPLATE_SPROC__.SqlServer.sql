
			  CREATE procedure DeletePITemplate
		(@piTemplateID int, @status int output)
as
Begin

	DECLARE @kind int, @id_sched int, @pt_status int

	SELECT	id_template 
	FROM	t_pi_template WITH (UPDLOCK) 
	WHERE	id_template = @piTemplateID
	 
  	-- Determine the PI instance kind
	Select  @kind = n_kind from t_base_props where id_prop = @piTemplateID       

	IF(@kind = 10 or @kind = 15)
	BEGIN
		set @status = -10
		return
	END
	
	/* Check to see if adjustment transactions exist for any ajustment instances on this piInstance */
	if exists(
		select at.id_adj_trx
		from
			t_adjustment_transaction at
			inner join
			t_adjustment a with(updlock) on at.id_aj_instance = a.id_prop
		where
			a.id_pi_instance = @piTemplateID )
	BEGIN
		set @status = -20
		return
	END
	
	DECLARE @id_aj int
	DECLARE ajCursor CURSOR STATIC FOR
		select id_prop from t_adjustment with(updlock) where id_pi_template = @piTemplateID
		
	OPEN ajCursor
	FETCH NEXT FROM ajCursor into @id_aj
	WHILE @@FETCH_STATUS = 0
	BEGIN
		/* DELETE Adjustment templates*/
		DELETE FROM t_aj_template_reason_code_map where id_adjustment = @id_aj
		
		DELETE FROM t_adjustment WHERE id_prop = @id_aj
		
		Exec DeleteBaseProps @id_aj
		
		FETCH NEXT FROM ajCursor into @id_aj
	END
	
	CLOSE ajCursor
	DEALLOCATE ajCursor
	
	/* Fetch all parameter tables.
	 Delete all remaining Rate Schedules (There should not be any rate schedules on non-shared pls because there
	 should not be any PI instances) */
	DECLARE ptcursor CURSOR STATIC FOR
	SELECT	rs.id_sched
	FROM	t_rsched rs with(updlock)
	INNER JOIN t_pl_map pl ON (rs.id_pt = pl.id_paramtable)
	WHERE	pl.id_pi_template = @piTemplateID
	
	OPEN ptcursor
	
	FETCH NEXT FROM ptcursor INTO @id_sched
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC DeleteRateSchedule @id_sched, @pt_status
		FETCH NEXT FROM ptcursor INTO @id_sched
	END
	
	CLOSE ptcursor
    DEALLOCATE ptcursor
	
	-- Delete PI Instance from PL Map removing it from the PO
	Delete from t_pl_map where id_pi_template = @piTemplateID

	Declare @n_unit_name int, @n_unit_display_name int
	-- Delete kind specific properties
	if(@kind = 25)
	Begin
		Delete from t_recur_enum where id_prop = @piTemplateID
		
		select @n_unit_name = n_unit_name, @n_unit_display_name = n_unit_display_name 
		from t_recur with(updlock) where id_prop = @piTemplateID
	End
	Else if(@kind = 40 or @kind = 15)
	Begin
		-- Delete counters
		Exec RemoveCountersForPI @piTemplateID 
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
		set @sqlStr = 'delete from ' + @epTableName + ' where id_prop = ' + cast(@piTemplateID as nvarchar(10))
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
	Exec DeleteBaseProps @piTemplateID
 
	DELETE FROM t_pi_template
	WHERE id_template = @piTemplateID
		
	set @status = 0
end

