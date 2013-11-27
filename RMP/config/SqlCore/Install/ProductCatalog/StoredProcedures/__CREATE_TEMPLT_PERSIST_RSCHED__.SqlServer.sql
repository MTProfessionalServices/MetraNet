
/* Get the id_po for a given id_sub (since we only inherit for a given id_po) */
CREATE PROCEDURE templt_persist_rsched(
    @my_id_acc int,
    @my_id_pt int,
    @v_id_sched int,
    @my_id_pricelist int,
    @my_id_pi_template int,
    @v_start_dt datetime,
    @v_start_type int,
    @v_begin_offset int,
    @v_end_dt datetime,
    @v_end_type int,
    @v_end_offset int,
    @is_public int,
    @my_id_sub int,
    @v_id_csr int = 137,
	@v_id_sched_out int OUT
)
AS
BEGIN
	SET NOCOUNT ON

    DECLARE @my_id_eff_date int
    DECLARE @curr_id_cycle_type int
    DECLARE @curr_day_of_month int
    DECLARE @my_start_dt datetime
    DECLARE @my_start_type int
    DECLARE @my_begin_offset int
    DECLARE @my_end_dt datetime
    DECLARE @my_end_type int
    DECLARE @my_end_offset int
    DECLARE @my_id_sched int
    DECLARE @has_tpl_map int
    DECLARE @l_id_audit int
	DECLARE @audit_msg nvarchar(200)

    SET @my_start_type = @v_start_type
    SET @my_start_dt = @v_start_dt
    SET @my_begin_offset = @v_begin_offset
    SET @my_end_type = @v_end_type
    SET @my_end_dt = @v_end_dt
    SET @my_end_offset = @v_end_offset
    SET @my_id_sched = @v_id_sched
    /* Cleanup relative dates. TBD: not handling type 2 (subscription relative) */
    SET @my_start_dt = dbo.determine_absolute_dates(@my_start_dt, @my_start_type, @my_begin_offset, @my_id_acc, 1)
    SET @my_end_dt = dbo.determine_absolute_dates(@my_end_dt, @my_end_type, @my_end_offset, @my_id_acc, 0)
    SET @my_start_type = 1
    SET @my_begin_offset = 0
    SET @my_end_type = 1
    SET @my_end_offset = 0

    IF (@my_id_sched IS NULL)
	BEGIN
        --select SEQ_T_BASE_PROPS.nextval into my_id_sched from dual;
        insert into t_base_props
					(n_kind, n_name, n_desc, nm_name, nm_desc, b_approved, b_archive, n_display_name, nm_display_name)
			values ( 130, 0, 0, NULL, NULL, 'N', 'N', 0, NULL)
		SET @my_id_sched = SCOPE_IDENTITY()

		SET @v_id_sched = @my_id_sched
        IF (@is_public = 0)
		BEGIN
            /* insert rate schedule create audit */
            EXEC getcurrentid 'id_audit', @l_id_audit OUT
			SET @audit_msg = 'MASS RATE: Adding schedule for pt: ' + CAST(@my_id_pt AS nvarchar(10)) + ' Rate Schedule Id: ' + CAST(@my_id_sched AS nvarchar(10))
            EXEC InsertAuditEvent
				@v_id_csr,
				1400,
				2,
				@my_id_sched,
				getutcdate,
				@l_id_audit,
				@audit_msg,
				@v_id_csr,
				NULL
        END

        insert into t_base_props
					(n_kind, n_name, n_desc, nm_name, nm_desc, b_approved, b_archive, n_display_name, nm_display_name)
			 values (160, 0, 0, NULL, NULL, 'N', 'N', 0, NULL)
		SET @my_id_eff_date = SCOPE_IDENTITY()

        insert into t_effectivedate 
					(id_eff_date, n_begintype, dt_start, n_beginoffset, n_endtype, dt_end, n_endoffset)
			values(  @my_id_eff_date, @my_start_type, @my_start_dt, @my_begin_offset, @my_end_type, @my_end_dt, @my_end_offset)

        IF (@is_public = 1)
		BEGIN
			insert into t_rsched_pub
						(id_sched, id_pt, id_eff_date, id_pricelist, dt_mod, id_pi_template)
				values  (@my_id_sched, @my_id_pt, @my_id_eff_date, @my_id_pricelist, getutcdate(), @my_id_pi_template)
		END
        ELSE
            insert into t_rsched
						(id_sched, id_pt, id_eff_date, id_pricelist, dt_mod, id_pi_template)
				values  (@my_id_sched, @my_id_pt, @my_id_eff_date, @my_id_pricelist, getutcdate(), @my_id_pi_template)
        
        select @has_tpl_map = count(*)
		from   t_pl_map
		where id_sub = @my_id_sub and id_paramtable = @my_id_pt AND id_pricelist = @my_id_pricelist AND id_pi_template = @my_id_pi_template
        
		IF (@has_tpl_map = 0)
            insert into t_pl_map (dt_modified, id_paramtable, id_pi_type, id_pi_template, id_pi_instance,
                    id_pi_instance_parent, id_sub, id_acc, id_po, id_pricelist, b_canicb)
                select getutcdate(), a.id_paramtable, id_pi_type, id_pi_template, id_pi_instance,
                    id_pi_instance_parent, @my_id_sub, NULL, a.id_po, @my_id_pricelist, 'N'
                from t_pl_map a, t_sub b
                where b.id_sub = @my_id_sub
                and b.id_po = a.id_po
                and a.id_sub IS NULL
                and a.id_acc IS NULL
                and a.id_pi_template = @my_id_pi_template
                and a.id_paramtable is not null
        
    ELSE
        IF (@is_public = 1)
            select @my_id_eff_date = id_eff_date from t_rsched_pub where id_sched = @my_id_sched
        ELSE
            select @my_id_eff_date = id_eff_date from t_rsched where id_sched = @my_id_sched
        
        IF (@is_public = 0)
		BEGIN
            /* insert rate schedule rules audit */
            EXEC getcurrentid 'id_audit', @l_id_audit OUT
			SET @audit_msg = N'MASS RATE: Changing schedule for pt: ' + CAST(@my_id_pt AS nvarchar(10)) + N' Rate Schedule Id: ' + CAST(@my_id_sched AS nvarchar(10))
            EXEC InsertAuditEvent
				@v_id_csr,
				1402,
				2,
				@my_id_sched,
				getutcdate,
				@l_id_audit,
				@audit_msg,
				@v_id_csr,
				NULL
            
            /* support nulls for private scheds */
            IF (@v_start_dt IS NULL AND (@v_start_type IS NULL OR @v_start_type = 4 OR @v_start_type = 1))
			BEGIN
				SET @my_start_dt = NULL
				SET @my_start_type = 4
            END

            IF (@v_end_dt IS NULL AND (@v_end_type IS NULL OR @v_end_type = 4 OR @v_end_type = 1))
			BEGIN
				SET @my_end_dt = NULL
				SET @my_end_type = 4
            END
            update t_effectivedate
			set    n_begintype = @my_start_type,
			       dt_start = @my_start_dt,
				   n_beginoffset = @my_begin_offset,
				   n_endtype = @my_end_type,
                   dt_end = @my_end_dt,
				   n_endoffset = @my_end_offset
            where  id_eff_date = @my_id_eff_date
			  and (   n_begintype != @my_start_type
			       or dt_start != @my_start_dt
				   or n_beginoffset != @my_begin_offset
                   or n_endtype != @my_end_type
				   or dt_end != @my_end_dt
				   or n_endoffset != @my_end_offset)
		END
        ELSE
            /* do NOT support nulls for public scheds */
            update t_effectivedate
			set    n_begintype = @my_start_type,
			       dt_start = @my_start_dt,
				   n_beginoffset = @my_begin_offset,
				   n_endtype = @my_end_type,
                   dt_end = @my_end_dt,
				   n_endoffset = @my_end_offset
            where  id_eff_date = @my_id_eff_date
			  and (   n_begintype != @my_start_type
			       or dt_start != @my_start_dt
				   or n_beginoffset != @my_begin_offset
                   or n_endtype != @my_end_type
				   or dt_end != @my_end_dt
				   or n_endoffset != @my_end_offset)
        
    END

	SET @v_id_sched_out = @my_id_sched
END
