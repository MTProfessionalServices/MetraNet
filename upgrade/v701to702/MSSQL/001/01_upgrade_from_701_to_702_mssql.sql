/*
Run this script on:

        10.200.31.160.NetMeter    -  This database will be modified

to synchronize it with:

        10.200.31.166.NetMeter

You are recommended to back up your database before running this script

Script created by SQL Compare version 10.4.8 from Red Gate Software Ltd at 6/26/2013 11:25:53 AM

*/
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id=OBJECT_ID('tempdb..#tmpErrors')) DROP TABLE #tmpErrors
GO
CREATE TABLE #tmpErrors (Error INT)
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
GO
PRINT N'Inserting upgrade information to [dbo].[t_sys_upgrade] table'
GO
INSERT INTO [dbo].[t_sys_upgrade]
(target_db_version, dt_start_db_upgrade, db_upgrade_status)
VALUES
('7.0.2', getdate(), 'R')
GO
PRINT N'Dropping all constraints from T_PT_* tables ...'
GO
BEGIN
	DECLARE @sqlText NVARCHAR(256)
    DECLARE drop_fk CURSOR FOR
        SELECT 'ALTER TABLE ' + t.name + ' DROP CONSTRAINT ' + fk.name AS sqlText
		FROM   sys.tables t join sys.foreign_keys fk on t.object_id = fk.parent_object_id
		WHERE  t.name LIKE 'T\_PT\_%' ESCAPE '\'
		   AND EXISTS (SELECT 1
					   FROM   sys.tables st
							  JOIN sys.foreign_key_columns c
								ON st.object_id = c.referenced_object_id
					   WHERE  st.name = 't_rsched' and c.parent_object_id = t.object_id)

	OPEN drop_fk
	FETCH NEXT FROM drop_fk INTO @sqlText
    
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC (@sqlText)

		FETCH NEXT FROM drop_fk INTO @sqlText
	END

	CLOSE drop_fk
	DEALLOCATE drop_fk
END

GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO


PRINT N'Dropping constraints from [dbo].[mvm_scheduled_tasks]'
GO
ALTER TABLE [dbo].[mvm_scheduled_tasks] DROP CONSTRAINT [pk_mvm_scheduled_tasks]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping table [dbo].[t_months]'
GO
DROP TABLE [dbo].[t_months]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[mtsp_generate_stateful_rcs_for_quoting]'
GO
DROP PROCEDURE [dbo].[mtsp_generate_stateful_rcs_for_quoting]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[mtsp_generate_stateful_nrcs_for_quoting]'
GO
DROP PROCEDURE [dbo].[mtsp_generate_stateful_nrcs_for_quoting]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[T_VW_EFFECTIVE_SUBS]'
GO
EXEC sp_refreshview N'[dbo].[T_VW_EFFECTIVE_SUBS]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[t_av_Internal]'
GO
ALTER TABLE [dbo].[t_av_Internal] ADD
[c_UseStdImpliedTaxAlg] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[t_rsched_pub]'
GO
CREATE TABLE [dbo].[t_rsched_pub]
(
[id_sched] [int] NOT NULL,
[id_pt] [int] NOT NULL,
[id_eff_date] [int] NOT NULL,
[id_pricelist] [int] NOT NULL,
[dt_mod] [datetime] NULL,
[id_pi_template] [int] NOT NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [t_rsched_pub_pk] on [dbo].[t_rsched_pub]'
GO
ALTER TABLE [dbo].[t_rsched_pub] ADD CONSTRAINT [t_rsched_pub_pk] PRIMARY KEY CLUSTERED  ([id_sched])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [fk5idx_t_rsched_pub] on [dbo].[t_rsched_pub]'
GO
CREATE NONCLUSTERED INDEX [fk5idx_t_rsched_pub] ON [dbo].[t_rsched_pub] ([id_pt])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [fk2idx_t_rsched_pub] on [dbo].[t_rsched_pub]'
GO
CREATE NONCLUSTERED INDEX [fk2idx_t_rsched_pub] ON [dbo].[t_rsched_pub] ([id_eff_date])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [fk4idx_t_rsched_pub] on [dbo].[t_rsched_pub]'
GO
CREATE NONCLUSTERED INDEX [fk4idx_t_rsched_pub] ON [dbo].[t_rsched_pub] ([id_pricelist])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [fk3idx_t_rsched_pub] on [dbo].[t_rsched_pub]'
GO
CREATE NONCLUSTERED INDEX [fk3idx_t_rsched_pub] ON [dbo].[t_rsched_pub] ([id_pi_template])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_flatdiscount_ID_SCHED] on [dbo].[t_pt_FlatDiscount]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_flatdiscount_ID_SCHED] ON [dbo].[t_pt_FlatDiscount] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_flatdiscount table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_flatdiscount_nocond_ID_SCHED] on [dbo].[t_pt_FlatDiscount_NoCond]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_flatdiscount_nocond_ID_SCHED] ON [dbo].[t_pt_FlatDiscount_NoCond] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_flatdiscount_nocond table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[determine_absolute_dates]'
GO
CREATE FUNCTION [dbo].[determine_absolute_dates](
	@v_date DATETIME,
	@my_date_type INT,
	@my_date_offset INT,
	@my_id_acc INT,
	@is_start INT
) RETURNS DATETIME
AS
BEGIN
	DECLARE @my_date DATETIME
	DECLARE @my_acc_start DATETIME
	DECLARE @curr_id_cycle_type INT
	DECLARE @curr_day_of_month INT
	DECLARE @my_cycle_cutoff DATETIME

    SELECT @my_date = @v_date
    IF (@my_date_type = 1 AND @my_date IS NOT NULL)
        RETURN @my_date
    
    IF (@my_date_type = 4 OR (@my_date_type = 1 AND @my_date IS NULL))
	BEGIN
        IF (@is_start = 1)
            IF (@my_id_acc IS NOT NULL AND @my_id_acc > 0)
                SELECT @my_date = dt_crt FROM t_account WHERE id_acc = @my_id_acc
            ELSE
                SELECT @my_date = dbo.mtmindate()
        ELSE
            SELECT @my_date = dbo.mtmaxdate()
        
        RETURN @my_date
    END

    IF (@my_date_type = 3)
	BEGIN
        SELECT @my_acc_start  = dt_crt FROM t_account WHERE id_acc = @my_id_acc
        IF (@my_acc_start > @my_date OR @my_date IS NULL)
            SELECT @my_date = @my_acc_start
        
        SELECT @curr_id_cycle_type = id_cycle_type, @curr_day_of_month = day_of_month
            FROM t_acc_usage_cycle a, t_usage_cycle b
            WHERE a.id_usage_cycle = b.id_usage_cycle AND a.id_acc = @my_id_acc;
        IF (@curr_id_cycle_type = 1)
		BEGIN
            SELECT @my_cycle_cutoff =
					CAST((CAST(YEAR(@my_date) AS NVARCHAR) + '-' + CAST(MONTH(@my_date) AS NVARCHAR) + '-1') AS DATETIME) +
					(CASE @curr_day_of_month WHEN 31 THEN 0 ELSE @curr_day_of_month END)
            IF (@my_date > @my_cycle_cutoff)
                SELECT @my_cycle_cutoff = DATEADD (mm, 1, @my_date)
            
            SELECT @my_date = @my_cycle_cutoff
            SELECT @my_date = @my_date + @my_date_offset
        END
        RETURN @my_date
    END

    RETURN @my_date
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[templt_persist_rsched]'
GO
CREATE PROCEDURE [dbo].[templt_persist_rsched](
    @my_id_acc INT,
    @my_id_pt INT,
    @v_id_sched INT,
    @my_id_pricelist INT,
    @my_id_pi_template INT,
    @v_start_dt DATETIME,
    @v_start_type INT,
    @v_begin_offset INT,
    @v_end_dt DATETIME,
    @v_end_type INT,
    @v_end_offset INT,
    @is_public INT,
    @my_id_sub INT,
    @v_id_csr INT = 137,
	@v_id_sched_out INT OUT
)
AS
BEGIN
	SET NOCOUNT ON

    DECLARE @my_id_eff_date INT
    DECLARE @curr_id_cycle_type INT
    DECLARE @curr_day_of_month INT
    DECLARE @my_start_dt DATETIME
    DECLARE @my_start_type INT
    DECLARE @my_begin_offset INT
    DECLARE @my_end_dt DATETIME
    DECLARE @my_end_type INT
    DECLARE @my_end_offset INT
    DECLARE @my_id_sched INT
    DECLARE @has_tpl_map INT
    DECLARE @l_id_audit INT
	DECLARE @audit_msg NVARCHAR(200)

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
        INSERT INTO t_base_props
					(n_kind, n_name, n_desc, nm_name, nm_desc, b_approved, b_archive, n_display_name, nm_display_name)
			VALUES ( 130, 0, 0, NULL, NULL, 'N', 'N', 0, NULL)
		SET @my_id_sched = SCOPE_IDENTITY()

		SET @v_id_sched = @my_id_sched
        IF (@is_public = 0)
		BEGIN
            /* insert rate schedule create audit */
            EXEC getcurrentid 'id_audit', @l_id_audit OUT
			SET @audit_msg = 'MASS RATE: Adding schedule for pt: ' + CAST(@my_id_pt AS NVARCHAR(10)) + ' Rate Schedule Id: ' + CAST(@my_id_sched AS NVARCHAR(10))
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

        INSERT INTO t_base_props
					(n_kind, n_name, n_desc, nm_name, nm_desc, b_approved, b_archive, n_display_name, nm_display_name)
			 VALUES (160, 0, 0, NULL, NULL, 'N', 'N', 0, NULL)
		SET @my_id_eff_date = SCOPE_IDENTITY()

        INSERT INTO t_effectivedate
					(id_eff_date, n_begintype, dt_start, n_beginoffset, n_endtype, dt_end, n_endoffset)
			VALUES(  @my_id_eff_date, @my_start_type, @my_start_dt, @my_begin_offset, @my_end_type, @my_end_dt, @my_end_offset)

        IF (@is_public = 1)
		BEGIN
			INSERT INTO t_rsched_pub
						(id_sched, id_pt, id_eff_date, id_pricelist, dt_mod, id_pi_template)
				VALUES  (@my_id_sched, @my_id_pt, @my_id_eff_date, @my_id_pricelist, GETUTCDATE(), @my_id_pi_template)
		END
        ELSE
            INSERT INTO t_rsched
						(id_sched, id_pt, id_eff_date, id_pricelist, dt_mod, id_pi_template)
				VALUES  (@my_id_sched, @my_id_pt, @my_id_eff_date, @my_id_pricelist, GETUTCDATE(), @my_id_pi_template)
        
        SELECT @has_tpl_map = COUNT(*)
		FROM   t_pl_map
		WHERE id_sub = @my_id_sub AND id_paramtable = @my_id_pt AND id_pricelist = @my_id_pricelist AND id_pi_template = @my_id_pi_template
        
		IF (@has_tpl_map = 0)
            INSERT INTO t_pl_map (dt_modified, id_paramtable, id_pi_type, id_pi_template, id_pi_instance,
                    id_pi_instance_parent, id_sub, id_acc, id_po, id_pricelist, b_canicb)
                SELECT GETUTCDATE(), a.id_paramtable, id_pi_type, id_pi_template, id_pi_instance,
                    id_pi_instance_parent, @my_id_sub, NULL, a.id_po, @my_id_pricelist, 'N'
                FROM t_pl_map a, t_sub b
                WHERE b.id_sub = @my_id_sub
                AND b.id_po = a.id_po
                AND a.id_sub IS NULL
                AND a.id_acc IS NULL
                AND a.id_pi_template = @my_id_pi_template
                AND a.id_paramtable IS NOT NULL
        
    ELSE
        IF (@is_public = 1)
            SELECT @my_id_eff_date = id_eff_date FROM t_rsched_pub WHERE id_sched = @my_id_sched
        ELSE
            SELECT @my_id_eff_date = id_eff_date FROM t_rsched WHERE id_sched = @my_id_sched
        
        IF (@is_public = 0)
		BEGIN
            /* insert rate schedule rules audit */
            EXEC getcurrentid 'id_audit', @l_id_audit OUT
			SET @audit_msg = N'MASS RATE: Changing schedule for pt: ' + CAST(@my_id_pt AS NVARCHAR(10)) + N' Rate Schedule Id: ' + CAST(@my_id_sched AS NVARCHAR(10))
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
            UPDATE t_effectivedate
			SET    n_begintype = @my_start_type,
			       dt_start = @my_start_dt,
				   n_beginoffset = @my_begin_offset,
				   n_endtype = @my_end_type,
                   dt_end = @my_end_dt,
				   n_endoffset = @my_end_offset
            WHERE  id_eff_date = @my_id_eff_date
			  AND (   n_begintype != @my_start_type
			       OR dt_start != @my_start_dt
				   OR n_beginoffset != @my_begin_offset
                   OR n_endtype != @my_end_type
				   OR dt_end != @my_end_dt
				   OR n_endoffset != @my_end_offset)
		END
        ELSE
            /* do NOT support nulls for public scheds */
            UPDATE t_effectivedate
			SET    n_begintype = @my_start_type,
			       dt_start = @my_start_dt,
				   n_beginoffset = @my_begin_offset,
				   n_endtype = @my_end_type,
                   dt_end = @my_end_dt,
				   n_endoffset = @my_end_offset
            WHERE  id_eff_date = @my_id_eff_date
			  AND (   n_begintype != @my_start_type
			       OR dt_start != @my_start_dt
				   OR n_beginoffset != @my_begin_offset
                   OR n_endtype != @my_end_type
				   OR dt_end != @my_end_dt
				   OR n_endoffset != @my_end_offset)
        
    END

	SET @v_id_sched_out = @my_id_sched
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[get_id_pl_by_pt]'
GO
CREATE PROCEDURE [dbo].[get_id_pl_by_pt](
    @my_id_acc INT,
    @my_id_sub INT,
    @my_id_pt INT,
    @my_id_pi_template INT,
    @my_id_pricelist INT OUT
)
AS
BEGIN
    DECLARE @my_currency_code NVARCHAR(100)

    SELECT @my_id_pricelist = ISNULL(MIN(pm.id_pricelist), 0)
    FROM   t_pl_map pm
        INNER JOIN t_pricelist pl ON pm.id_pricelist = pl.id_pricelist AND pl.n_type = 0
    WHERE  id_sub = @my_id_sub AND pm.id_paramtable = @my_id_pt AND pm.id_pi_template = @my_id_pi_template
        
    IF (@my_id_pricelist = 0)
	BEGIN
        SELECT @my_currency_code = c_currency
		FROM   t_av_internal
		WHERE  id_acc = @my_id_acc

        INSERT INTO t_base_props
                    (n_kind, n_name, n_desc, nm_name, nm_desc, b_approved, b_archive, n_display_name, nm_display_name)
             VALUES (150, 0, 0, NULL, NULL, 'N', 'N', 0, NULL);
		SELECT @my_id_pricelist = SCOPE_IDENTITY()

        INSERT INTO t_pricelist
                    (id_pricelist, n_type, nm_currency_code)
            VALUES  (@my_id_pricelist, 0, @my_currency_code)
    END
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Creating [dbo].[get_id_pi_template]'
GO
CREATE PROCEDURE [dbo].[get_id_pi_template](
    @my_id_sub int,
    @my_id_pt int,
    @my_id_pi_template int OUT
)
AS
BEGIN
    SELECT @my_id_pi_template = MIN(id_pi_template)
    FROM   t_pl_map a, t_sub b
    WHERE  b.id_sub = @my_id_sub
        AND a.id_sub IS NULL
        AND a.id_po = b.id_po
        AND a.id_paramtable = @my_id_pt
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Creating [dbo].[templt_write_schedules]'
GO
CREATE PROCEDURE [dbo].[templt_write_schedules](
	@my_id_acc INT,
	@my_id_sub INT,
	@v_id_audit INT,
	@is_public INT,
	@v_id_pricelist INT,
	@v_id_pi_template INT,
	--@v_param_table_def IN TP_PARAM_TABLE_DEF,
	@v_id_pt INT,
	--@v_schedules IN OUT TP_SCHEDULE_ARRAY,
	@v_id_csr INT = 137
)
AS
BEGIN
	DECLARE @sched_idx INT
	DECLARE @rates_idx INT
	--DECLARE @my_schedule TP_SCHEDULE;
	DECLARE @my_id_sched INT
	DECLARE @my_chg_dates INT
	DECLARE @my_chg_rates INT
	DECLARE @my_tt_start DATETIME
	DECLARE @my_tt_end DATETIME
	DECLARE @my_id_sched_key UNIQUEIDENTIFIER
	--DECLARE @my_rates TP_PARAM_ARRAY;
	DECLARE @l_n_order  INT
	DECLARE @l_sql      NVARCHAR (4000)
	--DECLARE @l_sql_explicit nvarchar (4000)
	DECLARE @l_i        INT
	--DECLARE @l_rate     TP_PARAM_ROW;
	DECLARE @l_id_prm   INT
	DECLARE @l_param_id INT
	DECLARE @l_id_audit INT
	DECLARE @is_persisted INT
	DECLARE @my_id_pricelist INT
	DECLARE @my_id_pi_template INT
	--DECLARE @my_rate TP_PARAM_ROW;
	DECLARE @my_tt_date_cutoff DATETIME
	--DECLARE @l_vali int
	DECLARE @l_val1     NVARCHAR (100)
	DECLARE @l_val2     NVARCHAR (100)
	DECLARE @l_val3     NVARCHAR (100)
	DECLARE @l_val4     NVARCHAR (100)
	DECLARE @l_val5     NVARCHAR (100)
	DECLARE @l_val6     NVARCHAR (100)
	DECLARE @l_val7     NVARCHAR (100)
	DECLARE @l_val8     NVARCHAR (100)
	DECLARE @l_val9     NVARCHAR (100)
	DECLARE @l_val10     NVARCHAR (100)
	DECLARE @l_val11     NVARCHAR (100)
	DECLARE @l_val12     NVARCHAR (100)
	DECLARE @l_val13     NVARCHAR (100)
	DECLARE @l_val14     NVARCHAR (100)
	DECLARE @l_val15     NVARCHAR (100)
	DECLARE @nm_pt       NVARCHAR (100)
	DECLARE @audit_msg   NVARCHAR(256)

	SET @l_n_order = 0

	SELECT @my_tt_date_cutoff = GETUTCDATE()
	SET @my_id_pricelist = @v_id_pricelist
	SET @my_id_pi_template = @v_id_pi_template
	IF (@my_id_pi_template = 0 OR @my_id_pi_template IS NULL)
		EXEC get_id_pi_template @my_id_sub, @v_id_pt, @my_id_pi_template OUT
	
	IF (@my_id_pricelist = 0 OR @my_id_pricelist IS NULL)
		EXEC get_id_pl_by_pt @my_id_acc, @my_id_sub, @v_id_pt, @my_id_pi_template, @my_id_pricelist OUT
	
	SELECT @nm_pt = nm_pt FROM #tmp_cached_param_defs WHERE id_pt = @v_id_pt

	IF (@is_public = 1)
	BEGIN
		--my_schedule.id_sched := NULL;
		/* do not date bound it, nuke them all */
		SET @l_sql = 'DELETE ' + @nm_pt + ' WHERE id_sched in(select id_sched from t_rsched_pub a, t_pl_map c where c.id_sub = ' + CAST(@my_id_sub AS NVARCHAR(10)) +
		' and c.id_paramtable = ' + CAST(@v_id_pt AS NVARCHAR(10)) +
		' and c.id_pricelist = a.id_pricelist and c.id_paramtable = a.id_pt and c.id_pi_template = a.id_pi_template)';
		EXECUTE (@l_sql)
		DECLARE @msg NVARCHAR(100)
		DELETE t_rsched_pub
		WHERE  id_sched IN (
				SELECT id_sched
				FROM   t_rsched_pub a, t_pl_map c
				WHERE  c.id_sub = @my_id_sub
				   AND c.id_paramtable = @v_id_pt
				   AND c.id_pricelist = a.id_pricelist
				   AND c.id_paramtable = a.id_pt
				   AND a.id_pi_template = c.id_pi_template)
		SET @msg = '---------DELETE t_rsched_pub: ' + CAST(@@ROWCOUNT AS NVARCHAR(10))
		PRINT (@msg)
	END

	DECLARE @id_sched INT
	DECLARE v_schedules CURSOR FOR
		SELECT id_sched, id_sched AS my_id_sched, chg_dates, chg_rates, tt_start, tt_end, id_sched_key
		FROM   #my_schedule_array

	OPEN v_schedules
	FETCH NEXT FROM v_schedules INTO @id_sched, @my_id_sched, @my_chg_dates, @my_chg_rates, @my_tt_start, @my_tt_end, @my_id_sched_key

	--sched_idx := v_schedules.first();
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		--print '----inside schedules, @my_chg_rates='+cast(@my_chg_rates as varchar(10))
		SET @is_persisted = 0
		--my_schedule := v_schedules(sched_idx);
		IF (@is_public = 1)
			SET @my_id_sched = NULL
		
		IF (@my_chg_dates > 0 AND @my_id_sched IS NOT NULL AND @is_public = 0)
		BEGIN
			SET @is_persisted = 1
			--print '-----EXEC templt_persist_rsched 01'
			EXEC templt_persist_rsched @my_id_acc, @v_id_pt, @my_id_sched, @my_id_pricelist, @my_id_pi_template, @my_tt_start, 1, 0, @my_tt_end, 1, 0, @is_public, @my_id_sub, @v_id_csr, @my_id_sched OUT
		END

		IF (@is_public = 1 OR @my_chg_rates > 0)
		BEGIN
			DECLARE @p NVARCHAR(100)
			IF (@v_id_audit = 0 OR @v_id_audit IS NULL)
			BEGIN
				SET @p = N'@p int OUT'
				SET @l_sql = N'SELECT @p = ISNULL(max(id_audit + 1),1) from ' + @nm_pt + N' where id_sched = ' + CAST(@my_id_sched AS NVARCHAR(10))
				EXEC sp_executesql @l_sql, @p, @l_id_audit OUT
			END
			ELSE
				SET @l_id_audit = @v_id_audit
			
			IF (@is_public = 0)
			BEGIN
				SET @p = N'@l_tt_end datetime, @v_id_sched int'
				SET @l_sql = N'UPDATE ' + @nm_pt + N' SET tt_end = @l_tt_end WHERE id_sched = @v_id_sched AND tt_end = dbo.mtmaxdate()'
				DECLARE @tt DATETIME
				SET @tt = dbo.SubtractSecond(@my_tt_date_cutoff)
				EXEC sp_executesql @l_sql, @p, @tt, @my_id_sched
			END
			SET @l_n_order = 0

			DECLARE @my_id_rate INT
			DECLARE rates CURSOR FOR
				SELECT id_rate
				FROM   #tmp_schedule_rates
				WHERE  id_sched_key = @my_id_sched_key

			SET @rates_idx = 0
			OPEN rates
			FETCH NEXT FROM rates INTO @my_id_rate
			--print '--- before rates. @@FETCH_STATUS='+cast(@@FETCH_STATUS as varchar(1))
			--rates_idx := my_schedule.rates.first();
			WHILE (@@FETCH_STATUS = 0)
			BEGIN
			  IF (@is_persisted = 0 AND @rates_idx = 0 AND @my_id_sched IS NULL)
			  BEGIN
				SET @is_persisted = 1
				--print '------EXEC templt_persist_rsched 02'
				EXEC templt_persist_rsched @my_id_acc, @v_id_pt, @my_id_sched, @my_id_pricelist, @my_id_pi_template, @my_tt_start, 1, 0, @my_tt_end, 1, 0, @is_public, @my_id_sub, @v_id_csr, @my_id_sched OUT
			  END
			  ELSE
			  BEGIN
				IF (@is_persisted = 0 AND @is_public = 0)
				BEGIN
				  SET @is_persisted = 1
				  /* insert rate schedule rules audit */
				  EXEC getcurrentid 'id_audit', @l_id_audit OUT
				  SET @audit_msg = N'MASS RATE: Updating rules for param table: ' + @nm_pt + N' Rate Schedule Id: ' + CAST(@my_id_sched AS NVARCHAR(10))
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
				END
			  END

				--my_rate := my_schedule.rates(rates_idx);
				SET @l_sql = N'INSERT INTO ' + @nm_pt + N' (id_sched, id_audit, n_order, tt_start, tt_end'
				--SET @l_vali = 0
				--l_id_prm := v_param_table_def.param_defs.first ();
				SELECT @l_sql = @l_sql + N', ' + nm_column_name
				FROM   #tmp_param_defs
				WHERE  id_pt = @v_id_pt
				/*WHILE (l_id_prm IS NOT NULL)
				LOOP
					--SET @l_vali = l_vali + 1
					SET @l_sql = @l_sql + N', ' + v_param_table_def.param_defs (l_id_prm).nm_column_name;
					--SET @l_sql_explicit = @l_sql_explicit + N' l_' + @l_vali + N' NVARCHAR2(100) := :l_' + @l_vali + N';'
					SET @l_id_prm := v_param_table_def.param_defs.next (l_id_prm);
				END LOOP;*/
				SET @l_sql = @l_sql + N') VALUES (@v_id_sched, @v_id_audit, @l_n_order, @v_tt_start, dbo.mtmaxdate()'
				/*SET @l_sql_explicit = l_sql;
				SET @l_id_prm := v_param_table_def.param_defs.first ();
				SET @l_val1 = NULL
				SET @l_val2 = NULL
				SET @l_val3 = NULL
				SET @l_val4 = NULL
				SET @l_val5 = NULL
				SET @l_val6 = NULL
				SET @l_val7 = NULL
				SET @l_val8 = NULL
				SET @l_val9 = NULL
				SET @l_val10 = NULL
				SET @l_val11 = NULL
				SET @l_val12 = NULL
				SET @l_val13 = NULL
				SET @l_val14 = NULL
				SET @l_val15 = NULL*/
				--SET @l_vali = 0

				DECLARE v_param_table_def CURSOR FOR
					SELECT id_param_table_prop
					FROM   #tmp_param_defs
					WHERE  id_pt = @v_id_pt

				OPEN v_param_table_def
				FETCH NEXT FROM v_param_table_def INTO @l_param_id

				WHILE (@@FETCH_STATUS = 0)
				BEGIN
					--l_param_id := v_param_table_def.param_defs (l_id_prm).id_param_table_prop;
					--SET @l_vali = @l_vali + 1
					--IF (my_rate.params.exists (l_param_id))
					IF EXISTS (SELECT 1 FROM #tmp_schedule_rate_params WHERE id_rate = @my_id_rate AND id_param = @l_param_id)
					BEGIN
						SELECT @l_sql = @l_sql + N', ''' + nm_param + N''''
						FROM   #tmp_schedule_rate_params
						WHERE  id_rate = @my_id_rate AND id_param = @l_param_id

						/*IF (@l_vali = 1) THEN SET @l_val1 := my_rate.params (l_param_id)
						IF (@l_vali = 2) THEN SET @l_val2 := my_rate.params (l_param_id)
						IF (@l_vali = 3) THEN SET @l_val3 := my_rate.params (l_param_id)
						IF (@l_vali = 4) THEN SET @l_val4 := my_rate.params (l_param_id)
						IF (@l_vali = 5) THEN SET @l_val5 := my_rate.params (l_param_id)
						IF (@l_vali = 6) THEN SET @l_val6 := my_rate.params (l_param_id)
						IF (@l_vali = 7) THEN SET @l_val7 := my_rate.params (l_param_id)
						IF (@l_vali = 8) THEN SET @l_val8 := my_rate.params (l_param_id)
						IF (@l_vali = 9) THEN SET @l_val9 := my_rate.params (l_param_id)
						IF (@l_vali = 10) THEN SET @l_val10 := my_rate.params (l_param_id)
						IF (@l_vali = 11) THEN SET @l_val11 := my_rate.params (l_param_id)
						IF (@l_vali = 12) THEN SET @l_val12 := my_rate.params (l_param_id)
						IF (@l_vali = 13) THEN SET @l_val13 := my_rate.params (l_param_id)
						IF (@l_vali = 14) THEN SET @l_val14 := my_rate.params (l_param_id)
						IF (@l_vali = 15) THEN SET @l_val15 := my_rate.params (l_param_id)*/
					END
					ELSE
					BEGIN
						SET @l_sql = @l_sql + N', NULL'
						/*IF (@l_vali = 1) THEN SET @l_val1 = NULL
						IF (@l_vali = 2) THEN SET @l_val2 = NULL
						IF (@l_vali = 3) THEN SET @l_val3 = NULL
						IF (@l_vali = 4) THEN SET @l_val4 = NULL
						IF (@l_vali = 5) THEN SET @l_val5 = NULL
						IF (@l_vali = 6) THEN SET @l_val6 = NULL
						IF (@l_vali = 7) THEN SET @l_val7 = NULL
						IF (@l_vali = 8) THEN SET @l_val8 = NULL
						IF (@l_vali = 9) THEN SET @l_val9 = NULL
						IF (@l_vali = 10) THEN SET @l_val10 = NULL
						IF (@l_vali = 11) THEN SET @l_val11 = NULL
						IF (@l_vali = 12) THEN SET @l_val12 = NULL
						IF (@l_vali = 13) THEN SET @l_val13 = NULL
						IF (@l_vali = 14) THEN SET @l_val14 = NULL
						IF (@l_vali = 15) THEN SET @l_val15 = NULL*/
					END

					/*IF (@l_vali = v_param_table_def.param_defs.COUNT)
					BEGIN
						SET @l_sql_explicit = @l_sql_explicit + N', DECODE(1,1,:l_' + @l_vali
						WHILE (@l_vali < 15)
						LOOP
						  SET @l_vali = @l_vali + 1
						  SET @l_sql_explicit = @l_sql_explicit + N',' + @l_vali + N',:l_' + @l_vali
						END LOOP;
						SET @l_sql_explicit = @l_sql_explicit + N')'
					END
					ELSE
						SET @l_sql_explicit = @l_sql_explicit + N', :l_' + @l_vali*/
					
					--l_id_prm := v_param_table_def.param_defs.next (l_id_prm);
					FETCH NEXT FROM v_param_table_def INTO @l_param_id
				END

				CLOSE v_param_table_def
				DEALLOCATE v_param_table_def

				SET @l_sql = @l_sql + N')'
				--SET @l_sql_explicit = @l_sql_explicit + N')'
				--IF (v_param_table_def.param_defs.COUNT > 15)
				  --EXECUTE IMMEDIATE l_sql USING my_schedule.id_sched, l_id_audit, l_n_order, my_tt_date_cutoff;
				SET @p = N'@v_id_sched int, @v_id_audit int, @l_n_order int, @v_tt_start datetime'
				EXEC sp_executesql @l_sql, @p, @my_id_sched, @l_id_audit, @l_n_order, @my_tt_date_cutoff

				/*ELSE
				  EXECUTE IMMEDIATE l_sql_explicit USING my_schedule.id_sched, l_id_audit, l_n_order, my_tt_date_cutoff,
														 l_val1, l_val2, l_val3, l_val4, l_val5, l_val6, l_val7, l_val8,
														 l_val9, l_val10, l_val11, l_val12, l_val13, l_val14, l_val15;*/
				
				SET @l_n_order = @l_n_order + 1
				SET @rates_idx = @rates_idx + 1
				--rates_idx := my_schedule.rates.next(rates_idx);
				FETCH NEXT FROM rates INTO @my_id_rate
			END

			CLOSE rates
			DEALLOCATE rates
		END
		--v_schedules(sched_idx) := my_schedule;
		UPDATE #my_schedule_array
		SET		tt_start = @my_tt_start,
				tt_end = @my_tt_end,
				chg_dates = @my_chg_dates,
				chg_rates = @my_chg_rates,
				id_sched = @my_id_sched
		WHERE  id_sched_key = @my_id_sched_key

		--sched_idx := v_schedules.next(sched_idx);
		FETCH NEXT FROM v_schedules INTO @id_sched, @my_id_sched, @my_chg_dates, @my_chg_rates, @my_tt_start, @my_tt_end, @my_id_sched_key
	END

	CLOSE v_schedules
	DEALLOCATE v_schedules
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[mt_replace_nulls]'
GO
CREATE PROCEDURE [dbo].[mt_replace_nulls](
	@new_id_sched INT,
	@id_sched INT,
	@v_id_pt INT
)
AS
BEGIN
	SET NOCOUNT ON

    DECLARE @l_src_i  INT
    DECLARE @l_tgt_i  INT
    DECLARE @l_prm_i  INT
    DECLARE @l_src_v  NVARCHAR(100)
    DECLARE @l_tgt_v  NVARCHAR(100)
    DECLARE @l_p_cnt  INT
    DECLARE @l_v_cnt  INT
    DECLARE @l_isnull INT

	SET @l_isnull = 1


	DECLARE @id_rate INT
	DECLARE v_rates_high CURSOR FOR
		SELECT r.id_rate
		FROM   #tmp_schedule_rates r
		WHERE  id_sched = @id_sched
    
	OPEN v_rates_high
	FETCH NEXT FROM v_rates_high INTO @id_rate

	WHILE @@FETCH_STATUS = 0
    BEGIN
		DECLARE @id_param_table_prop INT
		DECLARE @is_rate_key INT
		DECLARE v_param_defs CURSOR FOR
			SELECT id_param_table_prop, is_rate_key
			FROM   #tmp_param_defs
			WHERE  id_pt = @v_id_pt

		OPEN v_param_defs
		FETCH NEXT FROM v_param_defs INTO @id_param_table_prop, @is_rate_key

		SET @l_isnull = 0
		
		WHILE @@FETCH_STATUS = 0 /* see if we have any nulls first */
		BEGIN
			SELECT @l_src_v = MAX(nm_param) FROM #tmp_schedule_rate_params WHERE id_rate = @id_rate AND id_param = @id_param_table_prop
			
			IF (@is_rate_key = 0 AND @l_src_v IS NULL)
				SET @l_isnull = @l_isnull + 1

			FETCH NEXT FROM v_param_defs INTO @id_param_table_prop, @is_rate_key
		END

		CLOSE v_param_defs
		DEALLOCATE v_param_defs

		DECLARE @id_rate_low INT
		IF (@l_isnull <> 0)
		BEGIN
			DECLARE v_rates_low CURSOR FOR
				SELECT r.id_rate
				FROM   #tmp_schedule_rates r
				WHERE  id_sched = @new_id_sched

			OPEN v_rates_low
			FETCH NEXT FROM v_rates_low INTO @id_rate_low

			WHILE (@l_isnull <> 0 AND @@FETCH_STATUS = 0)
			BEGIN
				DECLARE v_param_defs2 CURSOR FOR
					SELECT id_param_table_prop, is_rate_key
					FROM   #tmp_param_defs
					WHERE  id_pt = @v_id_pt

				OPEN v_param_defs2
				FETCH NEXT FROM v_param_defs2 INTO @id_param_table_prop, @is_rate_key

				SET @l_p_cnt = 0
				SET @l_v_cnt = 0
				WHILE (@@FETCH_STATUS = 0)  /* see if our keys match (always wildcard) */
				BEGIN
					SELECT @l_src_v = MAX(nm_param) FROM #tmp_schedule_rate_params WHERE id_rate = @id_rate AND id_param = @id_param_table_prop
					SELECT @l_tgt_v = MAX(nm_param) FROM #tmp_schedule_rate_params WHERE id_rate = @id_rate_low AND id_param = @id_param_table_prop

					IF (@is_rate_key <> 0)
					BEGIN
						SET @l_p_cnt = @l_p_cnt + 1
						IF (@l_src_v IS NULL)
							SET @l_v_cnt = @l_v_cnt + 1
						ELSE IF (@l_tgt_v IS NOT NULL AND @l_src_v = @l_tgt_v)
							SET @l_v_cnt = @l_v_cnt + 1
					END
					
					FETCH NEXT FROM v_param_defs2 INTO @id_param_table_prop, @is_rate_key
				END

				CLOSE v_param_defs2
				DEALLOCATE v_param_defs2

				IF (@l_p_cnt = @l_v_cnt AND @l_isnull <> 0)
				BEGIN
					UPDATE #tmp_schedule_rates
					SET    updated = 1
					WHERE  id_rate = @id_rate_low

					DECLARE v_param_defs3 CURSOR FOR
						SELECT id_param_table_prop, is_rate_key
						FROM   #tmp_param_defs
						WHERE  id_pt = @v_id_pt

					OPEN v_param_defs3
					FETCH NEXT FROM v_param_defs3 INTO @id_param_table_prop, @is_rate_key

					/* replace nulls */
					WHILE (@l_isnull <> 0 AND @@FETCH_STATUS = 0)
					BEGIN
						IF (@is_rate_key = 0)
						BEGIN
							SELECT @l_src_v = MAX(nm_param) FROM #tmp_schedule_rate_params WHERE id_rate = @id_rate AND id_param = @id_param_table_prop
							SELECT @l_tgt_v = MAX(nm_param) FROM #tmp_schedule_rate_params WHERE id_rate = @id_rate_low AND id_param = @id_param_table_prop
							
							IF (@l_src_v IS NULL AND @l_tgt_v IS NOT NULL)
							BEGIN
								UPDATE #tmp_schedule_rate_params
								SET    nm_param = @l_tgt_v
								WHERE id_rate = @id_rate AND id_param = @id_param_table_prop
								SET @l_isnull = @l_isnull - 1
							END
						END
						
						FETCH NEXT FROM v_param_defs3 INTO @id_param_table_prop, @is_rate_key
					END
				END

				FETCH NEXT FROM v_rates_low INTO @id_rate_low
			END
		END
		
		INSERT INTO #tmp_rates
					(id_rate, id_sched, id_sched_key, id_audit, n_order, updated)
		SELECT id_rate, id_sched, id_sched_key, id_audit, n_order, updated
		FROM   #tmp_schedule_rates
		WHERE  id_rate = @id_rate

		FETCH NEXT FROM v_rates_high INTO @id_rate
    END

	CLOSE v_rates_high
	DEALLOCATE v_rates_high
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[mt_copy_tmp_rates_by_key]'
GO
CREATE PROCEDURE [dbo].[mt_copy_tmp_rates_by_key] (
	@id_sched_key UNIQUEIDENTIFIER,
	@id_sched_out_key UNIQUEIDENTIFIER
)
AS
	SET NOCOUNT ON

	DECLARE @id_rate INT
	DECLARE @id_rate_new INT
	DECLARE rates CURSOR FOR
		SELECT id_rate
		FROM   #tmp_schedule_rates
		WHERE  id_sched_key = @id_sched_key

	OPEN rates
	FETCH NEXT FROM rates INTO @id_rate

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #tmp_schedule_rates
					(id_sched, id_sched_key, id_audit, n_order, updated)
		SELECT id_sched, @id_sched_out_key, id_audit, n_order, updated
		FROM   #tmp_schedule_rates
		WHERE  id_rate = @id_rate

		SELECT @id_rate_new = SCOPE_IDENTITY()

		INSERT INTO #tmp_schedule_rate_params
					(id_rate, id_param, nm_param)
		SELECT @id_rate_new, par.id_param, par.nm_param
		FROM   #tmp_schedule_rate_params par
		WHERE  par.id_rate = @id_rate

		FETCH NEXT FROM rates INTO @id_rate
	END

	CLOSE rates
	DEALLOCATE rates
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[mt_merge_rates]'
GO
CREATE PROCEDURE [dbo].[mt_merge_rates](
	@v_update INT,
	@v_id_pt INT,
	--v_param_defs IN TP_PARAM_DEF_ARRAY,
	--v_rates_low IN TP_PARAM_ARRAY,
	@new_id_sched_key UNIQUEIDENTIFIER,
	--v_rates_high IN TP_PARAM_ARRAY,
	--v_rates_out OUT TP_PARAM_ARRAY
	@id_sched_out_key UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @l_src_i INT
	DECLARE @l_tgt_i INT
	DECLARE @l_prm_i INT
	DECLARE @l_src_v NVARCHAR(100)
	DECLARE @l_tgt_v NVARCHAR(100)
	--DECLARE @l_src   TP_PARAM_ROW;
	--DECLARE @l_tgt   TP_PARAM_ROW;
	DECLARE @l_found INT
	--DECLARE @l_pd    TP_PARAM_DEF;
	DECLARE @l_p_cnt INT
	DECLARE @l_v_cnt INT
	DECLARE @l_exact INT

	--v_rates_out := v_rates_high;
	--l_src_i := v_rates_low.first ();

	DECLARE @tmp_rate_id TABLE
	(
		id_rate INT
	)

	INSERT INTO @tmp_rate_id
	SELECT r.id_rate
	FROM   #tmp_schedule_rates r
	WHERE  id_sched_key = @new_id_sched_key

	DECLARE @id_rate_low INT
	DECLARE v_rates_low CURSOR FOR
		SELECT r.id_rate
		FROM   @tmp_rate_id r

	OPEN v_rates_low
	FETCH NEXT FROM v_rates_low INTO @id_rate_low

	WHILE @@FETCH_Status = 0
	BEGIN
		--l_src := v_rates_low (l_src_i);
		SET @l_found = 0
		SET @l_exact = 1
		--l_tgt_i := v_rates_high.first ();

		DECLARE @id_rate INT
		DECLARE v_rates_high CURSOR FOR
			SELECT r.id_rate
			FROM   #tmp_rates r

		OPEN v_rates_high
		FETCH NEXT FROM v_rates_high INTO @id_rate

		WHILE (@l_found = 0 AND @@FETCH_STATUS = 0)
		BEGIN
			--l_tgt := v_rates_high (l_tgt_i);
			--l_prm_i := v_param_defs.first ();
			SET @l_p_cnt = 0
			SET @l_v_cnt = 0

			DECLARE @id_param_table_prop INT
			DECLARE @is_rate_key INT
			DECLARE v_param_defs CURSOR FOR
				SELECT id_param_table_prop, is_rate_key
				FROM   #tmp_param_defs
				WHERE  id_pt = @v_id_pt

			OPEN v_param_defs
			FETCH NEXT FROM v_param_defs INTO @id_param_table_prop, @is_rate_key

			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				
				IF (@is_rate_key <> 0)
				BEGIN
					SELECT @l_src_v = MAX(nm_param) FROM #tmp_schedule_rate_params WHERE id_rate = @id_rate_low AND id_param = @id_param_table_prop
					SELECT @l_src_v = MAX(nm_param) FROM #tmp_schedule_rate_params WHERE id_rate = @id_rate AND id_param = @id_param_table_prop
					
					IF (@l_tgt_v IS NULL)
					BEGIN
						SET @l_v_cnt = @l_v_cnt + 1
						IF (@l_src_v IS NOT NULL)
							SET @l_exact = 0
					END
					ELSE
					BEGIN
						IF (@l_src_v IS NOT NULL AND @l_src_v = @l_tgt_v)
						BEGIN
							SET @l_v_cnt = @l_v_cnt + 1
						END
						ELSE
						BEGIN
							SET @l_exact = 0
						END
					END
				END
				
				FETCH NEXT FROM v_param_defs INTO @id_param_table_prop, @is_rate_key
			END

			CLOSE v_param_defs
			DEALLOCATE v_param_defs

			IF (@l_p_cnt = @l_v_cnt)
			BEGIN
				SET @l_found = 1
				IF (@v_update <> 0 AND @l_exact = 1)
				BEGIN
					/* found an exact non-wildcard match, we update those */
					--l_prm_i := v_param_defs.first ();
					DECLARE v_param_defs2 CURSOR FOR
						SELECT id_param_table_prop, is_rate_key
						FROM   #tmp_param_defs
						WHERE  id_pt = @v_id_pt

					OPEN v_param_defs2
					FETCH NEXT FROM v_param_defs2 INTO @id_param_table_prop, @is_rate_key

					WHILE (@@FETCH_STATUS = 0)
					BEGIN
						--l_pd := v_param_defs (l_prm_i);
						IF (@is_rate_key = 0)
						BEGIN
							SELECT @l_src_v = MAX(nm_param) FROM #tmp_schedule_rate_params WHERE id_rate = @id_rate_low AND id_param = @id_param_table_prop

							IF (@l_src_v IS NOT NULL)
							BEGIN
								IF (UPPER(@l_src_v) = 'NULL')
								BEGIN
									DELETE #tmp_schedule_rate_params
									WHERE  id_rate = @id_rate AND id_param = @id_param_table_prop
								END
								ELSE
								BEGIN
									UPDATE #tmp_schedule_rate_params
									SET    nm_param = @l_src_v
									WHERE  id_rate = @id_rate AND id_param = @id_param_table_prop
								END
							END
						END
						
						FETCH NEXT FROM v_param_defs2 INTO @id_param_table_prop, @is_rate_key
					END

					CLOSE v_param_defs2
					DEALLOCATE v_param_defs2

					--v_rates_out (l_tgt_i) := l_tgt;
				END
			END
			--l_tgt_i := v_rates_high.next (l_tgt_i);
			FETCH NEXT FROM v_rates_high INTO @id_rate
		END

		CLOSE v_rates_high
		DEALLOCATE v_rates_high

		IF (@l_found = 0)
		BEGIN
			DECLARE @tmp_id_rate INT

			INSERT INTO #tmp_schedule_rates
						(id_sched, id_sched_key, id_audit, n_order, updated)
			SELECT NULL, id_sched_key, NULL, n_order, updated
			FROM   #tmp_schedule_rates
			WHERE  id_rate = @id_rate_low

			SELECT @tmp_id_rate = SCOPE_IDENTITY()

			INSERT INTO #tmp_schedule_rate_params
						(id_rate, id_param, nm_param)
			SELECT DISTINCT @tmp_id_rate, par.id_param, par.nm_param
			FROM   #tmp_schedule_rate_params par
			WHERE  id_rate = @id_rate_low
		END
		--l_src_i := v_rates_low.next (l_src_i);
		FETCH NEXT FROM v_rates_low INTO @id_rate_low
	END

	CLOSE v_rates_low
	DEALLOCATE v_rates_low

	-- Generate the output
	EXEC mt_copy_tmp_rates_by_key
		@id_sched_key = @new_id_sched_key,
		@id_sched_out_key = @id_sched_out_key

END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[mt_copy_tmp_rates]'
GO
CREATE PROCEDURE [dbo].[mt_copy_tmp_rates] (
	@id_sched INT,
	@id_sched_key UNIQUEIDENTIFIER
)
AS
	SET NOCOUNT ON

	DECLARE @id_rate INT
	DECLARE @id_rate_new INT
	DECLARE rates CURSOR FOR
		SELECT id_rate
		FROM   #tmp_schedule_rates
		WHERE  id_sched = @id_sched

	OPEN rates
	FETCH NEXT FROM rates INTO @id_rate

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #tmp_schedule_rates
				(id_sched, id_sched_key, id_audit, n_order, updated)
		SELECT NULL, @id_sched_key, id_audit, n_order, updated
		FROM   #tmp_schedule_rates
		WHERE  id_rate = @id_rate

		SELECT @id_rate_new = SCOPE_IDENTITY()
				
		INSERT INTO #tmp_schedule_rate_params
					(id_rate, id_param, nm_param)
		SELECT @id_rate_new, id_param, nm_param
		FROM   #tmp_schedule_rate_params
		WHERE  id_rate = @id_rate

		FETCH NEXT FROM rates INTO @id_rate
	END

	CLOSE rates
	DEALLOCATE rates
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[mt_copy_tempopary_rates]'
GO
CREATE PROCEDURE [dbo].[mt_copy_tempopary_rates] (
	@id_sched_key UNIQUEIDENTIFIER
)
AS
	SET NOCOUNT ON

	DECLARE @id_rate INT
	DECLARE @id_rate_new INT
	DECLARE rates CURSOR FOR
		SELECT id_rate
		FROM   #tmp_rates

	OPEN rates
	FETCH NEXT FROM rates INTO @id_rate

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #tmp_schedule_rates
				(id_sched, id_sched_key, id_audit, n_order, updated)
		SELECT id_sched, @id_sched_key, id_audit, n_order, updated
		FROM   #tmp_rates
		WHERE  id_rate = @id_rate

		SELECT @id_rate_new = SCOPE_IDENTITY()
				
		INSERT INTO #tmp_schedule_rate_params
					(id_rate, id_param, nm_param)
		SELECT @id_rate_new, id_param, nm_param
		FROM   #tmp_schedule_rate_params
		WHERE  id_rate = @id_rate

		FETCH NEXT FROM rates INTO @id_rate
	END

	CLOSE rates
	DEALLOCATE rates
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[mt_resolve_overlaps]'
GO
CREATE PROCEDURE [dbo].[mt_resolve_overlaps](
    @v_id_acc INT,
    @v_replace_nulls INT,
    @v_merge_rates INT,
    @v_update INT,
	@v_id_pt INT,
    --@v_param_defs IN TP_PARAM_DEF_ARRAY,
    --@v_schedules_in IN TP_SCHEDULE_ARRAY,
	@new_id_sched_key UNIQUEIDENTIFIER,
    @new_id_sched INT,
	@new_start DATETIME,
	@new_end DATETIME
    --@v_schedules_out OUT TP_SCHEDULE_ARRAY
)
AS
BEGIN
    --DECLARE @l_schedule     TP_SCHEDULE;
    --DECLARE @l_schedule_new TP_SCHEDULE := v_schedule_new;
    DECLARE @l_s_start      DATETIME
    DECLARE @l_s_end        DATETIME
    DECLARE @l_s_n_start    DATETIME
    DECLARE @l_s_n_end      DATETIME
    DECLARE @l_start        DATETIME
    DECLARE @l_last_new_i   INT

	DECLARE @new_chg_dates  INT
	
	SELECT @l_s_n_start = CASE WHEN @new_start IS NULL THEN dbo.determine_absolute_dates(@new_start, 4, 0, @v_id_acc, 1) ELSE @new_start END,
		   @l_s_n_end = CASE WHEN @new_end IS NULL THEN dbo.determine_absolute_dates(@new_end, 4, 0, @v_id_acc, 0) ELSE @new_end END

	DECLARE @tmp_schedules TABLE
	(
		id_sched_key UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
		n_order INT NOT NULL IDENTITY,
		id_sched INT,
		tt_start DATETIME,
		tt_end DATETIME,
		chg_dates INT,
		chg_rates INT,
		deleted INT
	)
	
	/*INSERT INTO @tmp_schedules
	SELECT * FROM #my_schedule_array*/

	DECLARE v_schedules_in CURSOR LOCAL FOR
		SELECT id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted
		FROM   #my_schedule_array
		ORDER BY n_order
	DECLARE @id_sched INT
	DECLARE @tt_start DATETIME
	DECLARE @tt_end DATETIME
	DECLARE @chg_dates INT
	DECLARE @chg_rates INT
	DECLARE @deleted INT
	DECLARE @id_sched_key UNIQUEIDENTIFIER

	OPEN v_schedules_in
	FETCH NEXT FROM v_schedules_in INTO @id_sched, @tt_start, @tt_end, @chg_dates, @chg_rates, @deleted

    WHILE @@FETCH_STATUS = 0
    BEGIN
		--print '------tt_start='+cast(@tt_start as nvarchar(100))+', tt_end='+cast(@tt_end as nvarchar(100))
		SELECT @l_s_start = CASE WHEN @tt_start IS NULL THEN dbo.determine_absolute_dates(@tt_start, 4, 0, @v_id_acc, 0) ELSE @tt_start END,
		       @l_s_end = CASE WHEN @tt_end IS NULL THEN dbo.determine_absolute_dates(@tt_end, 4, 0, @v_id_acc, 0) ELSE @tt_end END

		DECLARE @id_sched_key_0 UNIQUEIDENTIFIER
		DECLARE @id_sched_0 INT
		DECLARE @tt_start_0 DATETIME
		DECLARE @tt_end_0 DATETIME
		DECLARE @chg_dates_0 INT
		DECLARE @chg_rates_0 INT
		DECLARE @deleted_0 INT

		DECLARE @id_sched_key_1 UNIQUEIDENTIFIER
		DECLARE @id_sched_1 INT
		DECLARE @tt_start_1 DATETIME
		DECLARE @tt_end_1 DATETIME
		DECLARE @chg_dates_1 INT
		DECLARE @chg_rates_1 INT
		DECLARE @deleted_1 INT

		DECLARE @id_sched_key_2 UNIQUEIDENTIFIER
		DECLARE @id_sched_2 INT
		DECLARE @tt_start_2 DATETIME
		DECLARE @tt_end_2 DATETIME
		DECLARE @chg_dates_2 INT
		DECLARE @chg_rates_2 INT
		DECLARE @deleted_2 INT

		DECLARE @id_sched_key_3 UNIQUEIDENTIFIER
		DECLARE @id_sched_3 INT
		DECLARE @tt_start_3 DATETIME
		DECLARE @tt_end_3 DATETIME
		DECLARE @chg_dates_3 INT
		DECLARE @chg_rates_3 INT
		DECLARE @deleted_3 INT

		--l_tmp_rates  TP_PARAM_ARRAY;
		IF OBJECT_ID('tempdb..#tmp_rates') IS NOT NULL
			DROP TABLE #tmp_rates

		CREATE TABLE #tmp_rates /*TP_PARAM_ARRAY*/
		(
			id_rate INT NOT NULL PRIMARY KEY,
			id_sched INT NULL,
			id_sched_key UNIQUEIDENTIFIER,
			id_audit INT,
			n_order INT,
			updated INT
		)

        IF (@tt_start IS NULL)
			SELECT @l_s_start = dbo.determine_absolute_dates(@tt_start, 4, 0, @v_id_acc, 1)
        ELSE
			SELECT @l_s_start = @tt_start;
        
        IF (@tt_end IS NULL)
			SELECT @l_s_end = dbo.determine_absolute_dates(@tt_end, 4, 0, @v_id_acc, 0)
        ELSE
			SELECT @l_s_end = @tt_end
        
        IF (@v_merge_rates <> 0 AND (@l_s_start > @l_s_n_start AND (@l_start IS NULL OR @l_start <= @l_s_n_start)))
		BEGIN
			/* gap in the existing schedules, where l_schedule_new will fit in */
			IF (@l_s_n_end < @l_s_start)
			BEGIN
				/* l_schedule_new fits into the gap cleanly, so we add it */
				/* v.start -> v.end (new) */
				SELECT @id_sched_0 = NULL
				SELECT @chg_rates_0 = 1
				
				SELECT @tt_start_0 = @new_start
				SELECT @tt_end_0 = @new_end

				SELECT @id_sched_key_0 = NEWID()
				EXEC mt_copy_tmp_rates @new_id_sched, @id_sched_key_0

				SELECT @chg_dates_0 = @new_chg_dates
				
				--print '------INTO tmp_schedules 01'
				INSERT INTO @tmp_schedules-- #my_schedule_array
							(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
					 VALUES (@id_sched_key_0, @id_sched_0, @tt_start_0, @tt_end_0, @chg_dates_0, @chg_rates_0, @deleted_0)
			END
			ELSE
			BEGIN
				/* l_schedule_new overlaps with l_schedule, so we add just the non-overlap to the gap (overlap will be handled by code below) */
				/* v.start -> l.start (new) (v.start := l.start) */
				SELECT @id_sched_0 = NULL
				SELECT @chg_rates_0 = 1

				SELECT @tt_start_0 = @new_start
				SELECT @tt_end_0 = @tt_start

				SELECT @id_sched_key_0 = NEWID()
				EXEC mt_copy_tmp_rates @new_id_sched, @id_sched_key_0

				SELECT @chg_dates_0 = 1
				--print '------INTO tmp_schedules 02'
				INSERT INTO @tmp_schedules --#my_schedule_array
							(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
					 VALUES (@id_sched_key_0, @id_sched_0, @tt_start_0, @tt_end_0, @chg_dates_0, @chg_rates_0, @deleted_0)

				SELECT @new_start = @tt_start
				IF (@new_start IS NULL)
					SELECT @l_s_n_start = dbo.determine_absolute_dates(@new_start, 4, 0, @v_id_acc, 1)
				ELSE
					SELECT @l_s_n_start = @new_start
				
				SELECT @new_chg_dates = 1
			END
        END

		IF (@l_s_n_start < @l_s_end AND @l_s_n_end > @l_s_start)
		BEGIN
			/* this means that l_schedule_new overlaps with l_schedule, so we WILL be merging and/or bisecting */
			IF (@l_s_start < @l_s_n_start)
			BEGIN
				/* l_schedule starts before l_schedule_new */
				IF (@l_s_end <= @l_s_n_end)
				BEGIN
					/* l_schedule starts and ends before l_schedule_new, so we bisect then add l_schedule (with new dates) and then portion of l_schedule_new */
					/* l.start -> v.start (orig) , v.start -> l.end (merged) (v.start := l.end) == bisect with possible leftover */
					SELECT @id_sched_1 = @id_sched
					SELECT @tt_start_1 = @tt_start
					SELECT @tt_end_1 = @new_start

					SELECT @id_sched_key_1 = NEWID()
					EXEC mt_copy_tmp_rates @id_sched, @id_sched_key_1

					SELECT @chg_rates_1 = @chg_rates
					SELECT @chg_dates_1 = 1
				
					--print '------INTO tmp_schedules 03'
					INSERT INTO @tmp_schedules --#my_schedule_array
								(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
						 VALUES (@id_sched_key_1, @id_sched_1, @tt_start_1, @tt_end_1, @chg_dates_1, @chg_rates_1, @deleted_1)

					SELECT @id_sched_2 = NULL
					SELECT @tt_start_2 = @new_start
					SELECT @tt_end_2 = @tt_end

					SELECT @id_sched_key_2 = NEWID()
					EXEC mt_copy_tmp_rates @id_sched, @id_sched_key_2
				
					SELECT @chg_rates_2 = 1
					SELECT @chg_dates_2 = 1

					EXEC mt_replace_nulls @new_id_sched, @id_sched, @v_id_pt --v_param_defs, l_schedule_new.rates, l_schedule.rates, l_tmp_rates
				
					IF (@v_merge_rates > 0)
						EXEC mt_merge_rates @v_update, @v_id_pt, @new_id_sched_key, @id_sched_key_2
						--mt_merge_rates (@v_update, v_param_defs, l_schedule_new.rates, l_tmp_rates, l_schedule_2.rates);
					ELSE
						EXEC mt_copy_tempopary_rates @id_sched_key = @id_sched_key_2
						--l_schedule_2.rates := l_tmp_rates;
				
					--print '------INTO tmp_schedules 04'
					INSERT INTO @tmp_schedules --#my_schedule_array
								(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
						 VALUES (@id_sched_key_2, @id_sched_2, @tt_start_2, @tt_end_2, @chg_dates_2, @chg_rates_2, @deleted_2)

					SELECT @new_start = @tt_end
					IF (@new_start IS NULL)
						SELECT @l_s_n_start = dbo.determine_absolute_dates(@new_start, 4, 0, @v_id_acc, 1)
					ELSE
						SELECT @l_s_n_start = @new_start
				
					SELECT @new_chg_dates = 1
				END
				ELSE
				BEGIN
					/* l_schedule starts before l_schedule_new, and ends after it, so we trisect then add l_schedule (with new dates) then l_schedule_new, then remainder of l_schedule */
					/* l.start -> v.start (orig), v.start -> v.end (merged), v.end -> l.end (orig) == trisect */
					SELECT @id_sched_1 = @id_sched
					SELECT @tt_start_1 = @tt_start
					SELECT @tt_end_1 = @new_start

					SELECT @id_sched_key_1 = NEWID()
					EXEC mt_copy_tmp_rates @id_sched, @id_sched_key_1

					SELECT @chg_rates_1 = @chg_rates
					SELECT @chg_dates_1 = 1
				
					--print '------INTO tmp_schedules 05'
					INSERT INTO @tmp_schedules --#my_schedule_array
								(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
						 VALUES (@id_sched_key_1, @id_sched_1, @tt_start_1, @tt_end_1, @chg_dates_1, @chg_rates_1, @deleted_1)
				
					SELECT @id_sched_2 = NULL
					SELECT @tt_start_2 = @new_start
					SELECT @tt_end_2 = @new_end
					SELECT @chg_rates_2 = 1
					SELECT @chg_dates_2 = @new_chg_dates
					SELECT @id_sched_key_2 = NEWID()
					
					EXEC mt_replace_nulls @new_id_sched, @id_sched, @v_id_pt --v_param_defs, l_schedule_new.rates, l_schedule.rates, l_tmp_rates
				
					--print '------INTO tmp_schedules 06'
					INSERT INTO @tmp_schedules --#my_schedule_array
								(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
						 VALUES (@id_sched_key_2, @id_sched_2, @tt_start_2, @tt_end_2, @chg_dates_2, @chg_rates_2, @deleted_2)

					IF (@v_merge_rates > 0)
						EXEC mt_merge_rates @v_update, @v_id_pt, @new_id_sched_key, @id_sched_key_2
						--mt_merge_rates v_update, v_param_defs, l_schedule_new.rates, l_tmp_rates, l_schedule_2.rates
					ELSE
						EXEC mt_copy_tempopary_rates @id_sched_key = @id_sched_key_2
						--l_schedule_2.rates := l_tmp_rates;
				
					SELECT @id_sched_3 = NULL
					SELECT @tt_start_3 = @new_end
					SELECT @tt_end_3 = @tt_end

					SELECT @id_sched_key_3 = NEWID()
					EXEC mt_copy_tmp_rates @id_sched, @id_sched_key_3
				
					SELECT @chg_rates_3 = 1
					SELECT @chg_dates_3 = 1
				
					--print '------INTO tmp_schedules 07'
					INSERT INTO @tmp_schedules --#my_schedule_array
								(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
						 VALUES (@id_sched_key_3, @id_sched_3, @tt_start_3, @tt_end_3, @chg_dates_3, @chg_rates_3, @deleted_3)
				END
			END
			ELSE
			BEGIN
				/* l_schedule starts after (or same as) l_schedule_new */
				IF (@l_s_end <= @l_s_n_end)
				BEGIN
					/* l_schedule is completely encompassed by l_schedule_new */
					/* l.start -> l.end (merged) (v.start := l.end) == merge with possible leftover */
					SELECT @tt_start_1 = @tt_start
					SELECT @tt_end_1 = @tt_end
					SELECT @id_sched_1 = @id_sched
					SELECT @chg_dates_1 = @chg_dates
					SELECT @chg_rates_1 = 1
					SELECT @id_sched_key_1 = NEWID()
					
					EXEC mt_replace_nulls @new_id_sched, @id_sched, @v_id_pt --v_param_defs, l_schedule_new.rates, l_schedule.rates, l_tmp_rates
				
					--print '------INTO tmp_schedules 08'
					INSERT INTO @tmp_schedules --#my_schedule_array
								(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
						 VALUES (@id_sched_key_1, @id_sched_1, @tt_start_1, @tt_end_1, @chg_dates_1, @chg_rates_1, @deleted_1)
					
					IF (@v_merge_rates > 0)
						EXEC mt_merge_rates @v_update, @v_id_pt, @new_id_sched_key, @id_sched_key_1
						--mt_merge_rates v_update, v_param_defs, l_schedule_new.rates, l_tmp_rates, l_schedule_1.rates
					ELSE
						EXEC mt_copy_tempopary_rates @id_sched_key = @id_sched_key_1
						--l_schedule_1.rates := l_tmp_rates;
				
					SELECT @new_start = @tt_end
					IF (@new_start IS NULL)
					BEGIN
						SELECT @l_s_n_start = dbo.determine_absolute_dates(@new_start, 4, 0, @v_id_acc, 1)
					END
					ELSE
					BEGIN
						SELECT @l_s_n_start = @new_start
					END
				
					SELECT @new_chg_dates = 1
				END
				ELSE
				BEGIN
					IF (@v_merge_rates > 0)
					BEGIN
						/* l_schedule starts after, and ends after l_schedule_new, we bisect, with first portion merged, second portion original */
						/* l.start -> v.end (merged), v.end -> l.end (orig) == bisect */
						SELECT @tt_start_1 = @tt_start
						SELECT @tt_end_1 = @new_end
						SELECT @id_sched_1 = @id_sched
						SELECT @chg_rates_1 = 1
						SELECT @chg_dates_1 = @chg_dates
						SELECT @id_sched_key_1 = NEWID()

						EXEC mt_replace_nulls @new_id_sched, @id_sched, @v_id_pt --v_param_defs, l_schedule_new.rates, l_schedule.rates, l_tmp_rates

						--print '------INTO tmp_schedules 09'
						INSERT INTO @tmp_schedules --#my_schedule_array
									(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
							 VALUES (@id_sched_key_1, @id_sched_1, @tt_start_1, @tt_end_1, @chg_dates_1, @chg_rates_1, @deleted_1)
						
						IF (@v_merge_rates > 0)
							EXEC mt_merge_rates @v_update, @v_id_pt, @new_id_sched_key, @id_sched_key_1
							--mt_merge_rates (v_update, v_param_defs, l_schedule_new.rates, l_tmp_rates, l_schedule_1.rates);
						ELSE
							EXEC mt_copy_tempopary_rates @id_sched_key = @id_sched_key_1
							--l_schedule_1.rates := l_tmp_rates;

						SELECT @tt_start_2 = @new_end
						SELECT @tt_end_2 = @tt_end

						SELECT @id_sched_key_2 = NEWID()
						EXEC mt_copy_tmp_rates @id_sched, @id_sched_key_2
						
						SELECT @id_sched_2 = NULL
						SELECT @chg_rates_2 = 1
						SELECT @chg_dates_2 = 1

						--print '------INTO tmp_schedules 10'
						INSERT INTO @tmp_schedules --#my_schedule_array
									(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
							 VALUES (@id_sched_key_2, @id_sched_2, @tt_start_2, @tt_end_2, @chg_dates_2, @chg_rates_2, @deleted_2)
					END
					ELSE
					BEGIN
						/* no merge, or low-profile public merge, which hides the new row */
						SELECT @id_sched_key = NEWID()
						EXEC mt_copy_tmp_rates @id_sched, @id_sched_key
				
						--print '------INTO tmp_schedules 11'
						INSERT INTO @tmp_schedules --#my_schedule_array
									(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
							 VALUES (@id_sched_key, @id_sched, @tt_start, @tt_end, @chg_dates, @chg_rates, @deleted)
					END
				END
			END
		END
		ELSE
		BEGIN
			/* l_schedule does not overlap with l_schedule_new so we just add l_schedule */
			SELECT @id_sched_key = NEWID()
			EXEC mt_copy_tmp_rates @id_sched, @id_sched_key
				
			--print '------INTO tmp_schedules 12'
			INSERT INTO @tmp_schedules --#my_schedule_array
						(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
				VALUES  (@id_sched_key, @id_sched, @tt_start, @tt_end, @chg_dates, @chg_rates, @deleted)
		END
		
		DROP TABLE #tmp_rates
		SET @l_start = @l_s_end  /* just marking how far we have traversed */
		--select * from @tmp_schedules
		FETCH NEXT FROM v_schedules_in INTO @id_sched, @tt_start, @tt_end, @chg_dates, @chg_rates, @deleted
    END

    IF (@v_merge_rates <> 0)
	BEGIN
		--IF (v_schedules_in IS NULL OR v_schedules_in.COUNT = 0)
		IF NOT EXISTS (SELECT 1 FROM #my_schedule_array)
		BEGIN
			/* if we didnt use v_schedules_new, then add it (e.g., if v_schedules_in was empty) */
			--l_schedule_new.id_sched := NULL;
			
			--v_schedules_out (v_schedules_out.COUNT) := l_schedule_new;
			SET @id_sched_key_0 = NULL

			--print '------INTO tmp_schedules 13'
			INSERT INTO @tmp_schedules
						(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
				VALUES  (@new_id_sched_key, @new_id_sched, @new_start, @new_end, @new_chg_dates, NULL, NULL)

			--select * from @tmp_schedules
		END
		ELSE
		BEGIN
			--print '---14 condition 01'
			IF (@l_start IS NULL OR (@l_start <= @l_s_n_start AND @l_s_n_end > @l_start))
			BEGIN
				--print '---14 condition 02'
				--DECLARE @l_schedule_0 TP_SCHEDULE
				
				/* leftover new schedule starts and ends after end of v_schedules and overlaps with v_start/v_end */
				
				--l_schedule_0.rates := l_schedule_new.rates;
				--v_schedules_out (v_schedules_out.COUNT) := l_schedule_0;
				SET @id_sched_key_0 = NEWID()
				EXEC mt_copy_tmp_rates_by_key
					@id_sched_key = @new_id_sched_key,
					@id_sched_out_key = @id_sched_key_0

			--print '------INTO tmp_schedules 14'
				INSERT INTO @tmp_schedules
							(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
					VALUES  (@id_sched_key_0, NULL, @new_start, @new_end, @new_chg_dates, 1, NULL)
			END
		END
    END

	DELETE FROM #my_schedule_array

	INSERT INTO #my_schedule_array
	SELECT * FROM @tmp_schedules ts

END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[mt_load_schedule_params]'
GO
CREATE PROCEDURE [dbo].[mt_load_schedule_params](
	@v_id_sched INT,
	@v_is_wildcard INT,
	@v_id_pt INT,
	@new_id_sched_key UNIQUEIDENTIFIER,
	@new_id_sched INT OUT
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @l_sql        NVARCHAR(4000)
	--DECLARE @l_cursor     CURSOR
	DECLARE @l_first      INT
	DECLARE @l_value      NVARCHAR(100)
	DECLARE @l_row        INT
	DECLARE @l_id_param   INT
	DECLARE @is_rate_key  INT
	DECLARE @l_param_name NVARCHAR(100)
	DECLARE @l_id_sched   INT
	DECLARE @l_id_audit   INT
	DECLARE @l_n_order    INT
	DECLARE @l_start      DATETIME
	DECLARE @l_end        DATETIME
	DECLARE @l_current    INT
	DECLARE @l_id         INT

	SET @l_first = 1
	SELECT @l_sql = N'INSERT INTO #tmp_cursor SELECT /*+ INDEX(A END_' + SUBSTRING(pd.nm_pt, 0, 19) + N'_IDX) */ id_sched, id_audit, n_order, tt_start, tt_end, id_param_table_prop p_id, CASE id_param_table_prop'
	FROM   #tmp_cached_param_defs pd
	WHERE  pd.id_pt = @v_id_pt

	SELECT @l_sql = @l_sql + ' WHEN ' + CAST(pd.id_param_table_prop AS NVARCHAR(10)) + N' THEN CAST(' + pd.nm_column_name + ' AS nvarchar)'
	FROM   #tmp_param_defs pd
	WHERE  pd.id_pt = @v_id_pt
	ORDER BY id_param_defs

	SELECT @l_sql = @l_sql + N' ELSE NULL END p_val FROM ' + pd.nm_pt +
		   N' A, T_PARAM_TABLE_PROP B WHERE id_sched = ' + CAST(@v_id_sched AS NVARCHAR(10)) +
		   N' AND tt_end = @maxdate AND id_param_table = ' + CAST(@v_id_pt AS NVARCHAR)
	FROM   #tmp_cached_param_defs pd
	WHERE  pd.id_pt = @v_id_pt

	IF EXISTS (SELECT 1 FROM #tmp_filter_vals)
	BEGIN
		DECLARE param_defs CURSOR FOR
			SELECT pd.id_param_table_prop, pd.nm_column_name, pd.is_rate_key
			FROM   #tmp_param_defs pd
			WHERE  pd.id_pt = @v_id_pt
			ORDER BY id_param_defs

		OPEN param_defs
		FETCH NEXT FROM param_defs INTO @l_id_param, @l_param_name, @is_rate_key
		WHILE @@FETCH_STATUS = 0
		BEGIN
			/* add in filtering */
			IF (@l_id_param IS NOT NULL)
			BEGIN
				IF (@is_rate_key <> 0)
				BEGIN
					SELECT @l_value = MAX(nm_val) FROM #tmp_filter_vals WHERE id_param_table_prop = @l_id_param

					IF @l_value IS NULL
					BEGIN
						IF (@v_is_wildcard = 0)
							SET @l_sql = @l_sql + N' AND ' + @l_param_name + N' IS NULL'
					END
					ELSE
						SET @l_sql = @l_sql + N' AND ' + @l_param_name + N' = ''' + @l_value + '''';
				END
			END
			FETCH NEXT FROM param_defs INTO @l_id_param, @l_value, @is_rate_key
		END

		CLOSE param_defs
		DEALLOCATE param_defs
	END
	
	IF OBJECT_ID('tempdb..#tmp_cursor') IS NOT NULL
		DROP TABLE #tmp_cursor

	CREATE TABLE #tmp_cursor
	(
		id_sched INT,
		id_audit INT,
		n_order INT,
		dt_start DATETIME,
		dt_end DATETIME,
		id_param INT,
		value NVARCHAR(100)
	)

	SELECT @l_sql = N'DECLARE @maxdate datetime; SET @maxdate = dbo.mtmaxdate(); ' + @l_sql + N' '
	EXEC sp_executesql @l_sql

	DECLARE l_cursor CURSOR FOR
		SELECT id_sched, id_audit, n_order, dt_start, dt_end, id_param, value
		FROM   #tmp_cursor
		ORDER BY n_order ASC

	OPEN l_cursor
	FETCH NEXT FROM l_cursor INTO @l_id_sched, @l_id_audit, @l_n_order, @l_start, @l_end, @l_id_param, @l_value

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (@l_id_param IS NOT NULL)
		BEGIN
			IF (@l_current IS NULL OR @l_current <> @l_n_order)
			BEGIN
				SET @l_current = @l_n_order
				INSERT INTO #tmp_schedule_rates
							(id_sched_key, id_sched, id_audit, n_order, updated)
					 VALUES (@new_id_sched_key, @l_id_sched, @l_id_audit, @l_n_order, 0)
				SET @l_id = SCOPE_IDENTITY()
				SET @new_id_sched  = @l_id_sched
			END
			
			IF @l_value IS NOT NULL
				INSERT INTO #tmp_schedule_rate_params
							(id_rate, id_param, nm_param)
						VALUES (@l_id, @l_id_param, @l_value)
		END

		FETCH NEXT FROM l_cursor INTO @l_id_sched, @l_id_audit, @l_n_order, @l_start, @l_end, @l_id_param, @l_value
	END
	CLOSE l_cursor
	DEALLOCATE l_cursor

	DROP TABLE #tmp_cursor
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[mt_load_schedule]'
GO
CREATE PROCEDURE [dbo].[mt_load_schedule] (
    @v_id_sched INT,
    @v_start DATETIME,
    @v_end DATETIME,
    @v_is_wildcard INT,
	@v_id_pt INT,
	@new_id_sched_key UNIQUEIDENTIFIER OUT,
	@new_id_sched INT OUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET @new_id_sched_key = NEWID()
	EXEC mt_load_schedule_params @v_id_sched, @v_is_wildcard, @v_id_pt, @new_id_sched_key, @new_id_sched OUT
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[mt_resolve_overlaps_by_sched]'
GO
CREATE PROCEDURE [dbo].[mt_resolve_overlaps_by_sched] (
    @v_id_acc INT,
    @v_start DATETIME,
    @v_end DATETIME,
    @v_replace_nulls INT,
    @v_merge_rates INT,
    --@v_reuse_sched int,
	@v_id_pt INT,
    --@v_pt IN TP_PARAM_TABLE_DEF,
    --@v_schedules_in IN TP_SCHEDULE_ARRAY,
    @v_id_sched INT
    --,@v_schedules_out OUT TP_SCHEDULE_ARRAY
)
AS
BEGIN
    DECLARE @l_id_sched INT
	DECLARE @l_id_sched_key UNIQUEIDENTIFIER
    --l_empty    TP_PARAM_ASSOC;

    EXEC mt_load_schedule @v_id_sched, @v_start, @v_end, 0, @v_id_pt, @l_id_sched_key OUT, @l_id_sched OUT
	
    EXEC mt_resolve_overlaps
		@v_id_acc,
		@v_replace_nulls,
		@v_merge_rates,
		0,
		@v_id_pt,
		--v_pt.param_defs,
		--v_schedules_in,
		@l_id_sched_key,
		@l_id_sched,
		@v_start,
		@v_end
		--,v_schedules_out
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[mt_load_param_defs]'
GO
CREATE PROCEDURE [dbo].[mt_load_param_defs](
	@v_id_pt INT
)
AS
BEGIN
	/*DECLARE @l_nm_column_name      nvarchar(100)
	DECLARE @l_is_rate_key         int
	DECLARE @l_id_param_table_prop int*/

	INSERT INTO #tmp_param_defs(
	       id_pt,
		   nm_column_name,
		   is_rate_key,
		   id_param_table_prop
		   )
	SELECT @v_id_pt,
	       TPTP.nm_column_name,
		   CASE WHEN (CASE WHEN TPTP.b_columnoperator = 'N' THEN TPTP.nm_operatorval ELSE TPTP.b_columnoperator END) IS NULL THEN 0 ELSE 1 END AS is_rate_key,
		   TPTP.id_param_table_prop
	FROM   t_param_table_prop TPTP
	WHERE  TPTP.id_param_table = @v_id_pt

	/*OPEN l_cursor
	LOOP
	FETCH l_cursor INTO l_nm_column_name, l_is_rate_key, l_id_param_table_prop;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		l_param_def.nm_column_name := l_nm_column_name;
		l_param_def.is_rate_key := l_is_rate_key;
		l_param_def.id_param_table_prop := l_id_param_table_prop;
		v_param_defs (l_id_param_table_prop) := l_param_def;
	END

	CLOSE l_cursor
	DEALLOCATE l_cursor*/
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[mt_load_param_table_def]'
GO
CREATE PROCEDURE [dbo].[mt_load_param_table_def](
    @v_id_pt INT
)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM #tmp_cached_param_defs WHERE id_pt = @v_id_pt)
	BEGIN
		INSERT INTO #tmp_cached_param_defs
		       (id_pt, nm_pt)
		SELECT @v_id_pt, nm_instance_tablename
		FROM   t_rulesetdefinition
		WHERE  id_paramtable = @v_id_pt
    
		EXEC mt_load_param_defs @v_id_pt
	END
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[get_inherit_id_sub]'
GO
CREATE PROCEDURE [dbo].[get_inherit_id_sub](
    @my_id_acc INT,
    @my_id_po INT,
    @my_start_dt DATETIME,
    @my_end_dt DATETIME,
    @inherit_id_sub_curs CURSOR VARYING OUT
)
AS
BEGIN
	SET NOCOUNT ON

    DECLARE @inherit_id_acc_templt_pub INT

    SELECT TOP 1 @inherit_id_acc_templt_pub = ats.id_acc_template
    FROM   t_account_ancestor aa
        INNER JOIN t_acc_template at ON aa.id_ancestor = at.id_folder
        INNER JOIN t_acc_template_subs ats ON at.id_acc_template = ats.id_acc_template
        INNER JOIN t_sub s ON s.id_group = ats.id_group AND s.id_po = @my_id_po
    WHERE aa.id_descendent = @my_id_acc
        AND aa.id_ancestor != aa.id_descendent
    ORDER BY aa.num_generations ASC, at.id_acc_template DESC
    
    SET @inherit_id_sub_curs = CURSOR FOR
        SELECT s.id_sub, CASE WHEN ats.vt_start < @my_start_dt THEN @my_start_dt ELSE ats.vt_start END,
            CASE WHEN ats.vt_end > @my_end_dt THEN @my_end_dt ELSE ats.vt_end END
        FROM   t_acc_template_subs ats
            INNER JOIN t_sub s ON s.id_group = ats.id_group AND s.id_po = @my_id_po
        WHERE  ats.id_acc_template = @inherit_id_acc_templt_pub
            AND ats.vt_start < @my_end_dt
            AND ats.vt_end > @my_start_dt
        ORDER BY ats.vt_start, ats.vt_end

	OPEN @inherit_id_sub_curs
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[get_id_sched_pub]'
GO
CREATE PROCEDURE [dbo].[get_id_sched_pub](
    @my_id_sub INT,
    @my_id_pt INT,
    @my_id_pi_template INT,
    @my_start_dt DATETIME,
    @my_end_dt DATETIME,
    @my_id_sched_curs CURSOR VARYING OUT
)
AS
BEGIN
    SET @my_id_sched_curs = CURSOR FOR
        SELECT r.id_sched,
                case when e.dt_start < @my_start_dt then @my_start_dt else e.dt_start end start_dt,
                case when e.dt_end > @my_end_dt then @my_end_dt else e.dt_end end end_dt
        FROM   t_pl_map pm
            INNER JOIN t_rsched_pub r on r.id_pricelist = pm.id_pricelist and r.id_pt = @my_id_pt and pm.id_pi_template = r.id_pi_template
            INNER JOIN t_effectivedate e on r.id_eff_date = e.id_eff_date and dbo.determine_absolute_dates(e.dt_start,e.n_begintype, e.n_beginoffset,0,1) <= @my_end_dt and dbo.determine_absolute_dates(e.dt_end, e.n_endtype, e.n_endoffset,0,0) >= @my_start_dt
        WHERE  pm.id_sub = @my_id_sub and pm.id_paramtable = @my_id_pt and pm.id_pi_template = @my_id_pi_template
        ORDER BY e.n_begintype ASC, dbo.determine_absolute_dates(e.dt_start,e.n_begintype, e.n_beginoffset,0,1) DESC

	OPEN @my_id_sched_curs
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[get_id_sched]'
GO
CREATE PROCEDURE [dbo].[get_id_sched](
	@my_id_sub INT,
	@my_id_pt INT,
	@my_id_pi_template INT,
	@my_start_dt DATETIME,
	@my_end_dt DATETIME,
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
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[get_child_gsubs_private]'
GO
CREATE PROCEDURE [dbo].[get_child_gsubs_private](
    @my_id_acc INT,
    @my_id_po INT,
    @my_start_dt DATETIME,
    @my_end_dt DATETIME,
    @my_id_gsub_curs CURSOR VARYING OUT
)
AS
BEGIN
	SET @my_id_gsub_curs = CURSOR FOR
		SELECT /*+ ORDERED USE_NL(AT ats s) */ aa.id_descendent id_acc, s.id_sub
		FROM   t_account_ancestor aa
			INNER JOIN t_acc_template at ON aa.id_descendent = at.id_folder
			INNER JOIN t_acc_template_subs ats ON at.id_acc_template = ats.id_acc_template
			INNER JOIN t_sub s ON s.id_group = ats.id_group AND s.id_po = @my_id_po
		WHERE   aa.id_ancestor = @my_id_acc
			and num_generations > 0
			and s.vt_start < @my_end_dt
			and s.vt_end > @my_start_dt
		ORDER BY aa.num_generations ASC

	OPEN @my_id_gsub_curs
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[recursive_inherit]'
GO
CREATE PROCEDURE [dbo].[recursive_inherit](
    @v_id_audit INT,
    @my_id_acc INT,
    @v_id_sub INT,
    @v_id_po INT,
    @v_id_pi_template INT,
    @my_id_sched INT,
    @my_id_pt INT,
    @pass_to_children INT,
    @v_id_csr INT = 129
    --@cached_param_defs TP_PARAM_TABLE_DEF_ARRAY INPUT OUT
)
AS
BEGIN
	SET NOCOUNT ON

    DECLARE @my_rsched_start DATETIME
    DECLARE @my_rsched_end DATETIME
    DECLARE @my_id_sub_curs CURSOR
    DECLARE @my_id_sched_curs CURSOR
    DECLARE @my_id_gsub_curs CURSOR
    DECLARE @my_parent_sub_start DATETIME
    DECLARE @my_parent_sub_end DATETIME
    DECLARE @my_parent_id_sub INT
    DECLARE @my_parent_sched_start DATETIME
    DECLARE @my_parent_sched_end DATETIME
    DECLARE @my_parent_id_sched INT
    --DECLARE @my_param_def_array TP_PARAM_TABLE_DEF;
    --DECLARE @my_schedule_array TP_SCHEDULE_ARRAY;
    --DECLARE @my_empty_schedule_array TP_SCHEDULE_ARRAY;
    --DECLARE @my_empty_param_assoc_array TP_PARAM_ASSOC;
    --DECLARE @my_schedule TP_SCHEDULE;
    DECLARE @my_child_id_acc INT
    DECLARE @my_child_id_sub INT
    DECLARE @my_child_sched_start DATETIME
    DECLARE @my_child_sched_end DATETIME
    DECLARE @my_child_id_sched INT
    DECLARE @my_id_pricelist INT
    DECLARE @my_id_pi_template INT
    DECLARE @my_id_sub INT
    DECLARE @my_id_po INT
    DECLARE @l_id_sched     INT
    DECLARE @l_cnt INT

	IF OBJECT_ID('tempdb..#my_schedule_array') IS NOT NULL
		DROP TABLE #my_schedule_array
	IF OBJECT_ID('tempdb..#tmp_schedule_rates') IS NOT NULL
		DROP TABLE #tmp_schedule_rates
	IF OBJECT_ID('tempdb..#tmp_schedule_rate_params') IS NOT NULL
		DROP TABLE #tmp_schedule_rate_params

	CREATE TABLE #my_schedule_array /*TP_SCHEDULE_ARRAY*/
	(
		id_sched_key UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
		n_order INT,
		id_sched INT,
		tt_start DATETIME,
		tt_end DATETIME,
		chg_dates INT,
		chg_rates INT,
		deleted INT
	)

	CREATE TABLE #tmp_schedule_rates /*TP_PARAM_ARRAY*/
	(
		id_rate INT NOT NULL IDENTITY PRIMARY KEY,
		id_sched INT NULL,
		id_sched_key UNIQUEIDENTIFIER,
		id_audit INT,
		n_order INT,
		updated INT
	)

	CREATE INDEX #tmp_schedule_rates_idx_1 ON #tmp_schedule_rates(id_sched)
	CREATE INDEX #tmp_schedule_rates_idx_2 ON #tmp_schedule_rates(id_sched_key)

	CREATE TABLE #tmp_schedule_rate_params /*TP_PARAM_ASSOC*/
	(
		id_rate INT NOT NULL,
		id_param INT,
		nm_param NVARCHAR(100)
	)
	
	CREATE INDEX #tmp_schedule_rate_params_idx1 ON #tmp_schedule_rate_params(id_rate)
	CREATE INDEX #tmp_schedule_rate_params_idx2 ON #tmp_schedule_rate_params(id_param)

    SET @my_id_sub = @v_id_sub
    SET @my_id_po = @v_id_po

	DECLARE @mindate DATETIME
	DECLARE @maxdate DATETIME
	SET @mindate = dbo.mtmindate()
	SET @maxdate = dbo.mtmaxdate()

    IF (@my_id_sched IS NOT NULL)
	BEGIN
        SELECT @my_rsched_start = dbo.determine_absolute_dates(ed.dt_start, ed.n_begintype, ed.n_beginoffset, @my_id_acc, 1),
               @my_rsched_end = dbo.determine_absolute_dates(ed.dt_end, ed.n_endtype, ed.n_endoffset, @my_id_acc, 0),
               @my_id_pricelist = r.id_pricelist,
			   @my_id_pi_template = r.id_pi_template
        FROM   t_rsched r
		       JOIN t_effectivedate ed ON r.id_eff_date = ed.id_eff_date
        WHERE  r.id_sched = @my_id_sched
            
        IF (@my_id_sub IS NULL OR @my_id_po IS NULL)
		BEGIN
            SELECT @my_id_sub = MIN(id_sub), @my_id_po = MIN(id_po)
			FROM   t_pl_map pm, t_rsched rs
            WHERE  rs.id_sched = @my_id_sched
                AND rs.id_pricelist = pm.id_pricelist
                AND rs.id_pi_template = pm.id_pi_template
                AND pm.id_paramtable = @my_id_pt
                AND rs.id_pt = pm.id_paramtable
                AND id_sub IS NOT NULL;
        END
	END
    ELSE
	BEGIN

        /* FIXME: derive id_pricelist and id_pi_template */
        SELECT @my_rsched_start = vt_start, @my_rsched_end = ISNULL(vt_end, dbo.mtmaxdate())
		FROM   t_sub
		WHERE  id_sub = @my_id_sub

        IF (@v_id_pi_template IS NULL)
            EXEC get_id_pi_template @my_id_sub, @my_id_pt, @my_id_pi_template OUT
        ELSE
            SET @my_id_pi_template = @v_id_pi_template
        
        EXEC get_id_pl_by_pt @my_id_acc, @my_id_sub, @my_id_pt, @my_id_pi_template, @my_id_pricelist OUT
    END

    EXEC mt_load_param_table_def @my_id_pt
	
    /* loop over all private scheds ORDER BY n_begin_type ASC, determine_absolute_dates(dt_start) */
    EXEC get_id_sched @my_id_sub, @my_id_pt, @my_id_pi_template, @mindate, @maxdate, @my_id_sched_curs OUT

	FETCH @my_id_sched_curs INTO @l_id_sched, @my_rsched_start, @my_rsched_end

    WHILE @@FETCH_STATUS = 0
	BEGIN
        EXEC mt_resolve_overlaps_by_sched --@my_id_acc, my_rsched_start, my_rsched_end, 1, -1, 0, @my_param_def_array, my_schedule_array, l_id_sched, my_schedule_array);
			@v_id_acc = @my_id_acc,
			@v_start = @my_rsched_start,
			@v_end = @my_rsched_end,
			@v_replace_nulls = 1,
			@v_merge_rates = -1 ,
			--@v_reuse_sched int,
			@v_id_pt = @my_id_pt,
			--@v_pt IN TP_PARAM_TABLE_DEF,
			--@v_schedules_in IN TP_SCHEDULE_ARRAY,
			@v_id_sched = @my_id_sched
		FETCH @my_id_sched_curs INTO @l_id_sched, @my_rsched_start, @my_rsched_end
    END
    CLOSE @my_id_sched_curs
	DEALLOCATE @my_id_sched_curs

    SET @my_rsched_start = dbo.mtmindate()
    SET @my_rsched_end = dbo.mtmaxdate()

    EXEC get_inherit_id_sub @my_id_acc, @my_id_po, @my_rsched_start, @my_rsched_end, @my_id_sub_curs OUT
	
	FETCH NEXT FROM @my_id_sub_curs INTO @my_parent_id_sub, @my_parent_sub_start, @my_parent_sub_end

    WHILE @@FETCH_STATUS = 0
	BEGIN
        IF (@my_parent_sub_start < @my_rsched_start)
            SET @my_parent_sub_start = @my_rsched_start
        
        IF (@my_parent_sub_end > @my_rsched_end)
            SET @my_parent_sub_end = @my_rsched_end
        
        EXEC get_id_sched_pub @my_parent_id_sub, @my_id_pt, @my_id_pi_template, @my_parent_sub_start, @my_parent_sub_end, @my_id_sched_curs OUT
		FETCH NEXT FROM @my_id_sched_curs INTO @my_parent_id_sched, @my_parent_sched_start, @my_parent_sched_end

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF (@my_parent_sched_start < @my_parent_sub_start)
                SET @my_parent_sched_start = @my_parent_sub_start
            
            IF (@my_parent_sched_end < @my_parent_sub_end)
                SET @my_parent_sched_end = @my_parent_sub_end
            
            EXEC mt_resolve_overlaps_by_sched --(my_id_acc, my_parent_sched_start, my_parent_sched_end, 1, 1, 0, @my_param_def_array, my_schedule_array, my_parent_id_sched, my_schedule_array);
				@v_id_acc = @my_id_acc,
				@v_start = @my_parent_sched_start,
				@v_end = @my_parent_sched_end,
				@v_replace_nulls = 1,
				@v_merge_rates =1 ,
				--@v_reuse_sched int,
				@v_id_pt = @my_id_pt,
				--@v_pt IN TP_PARAM_TABLE_DEF,
				--@v_schedules_in IN TP_SCHEDULE_ARRAY,
				@v_id_sched = @my_parent_id_sched
			
			FETCH NEXT FROM @my_id_sched_curs INTO @my_parent_id_sched, @my_parent_sched_start, @my_parent_sched_end
        END

		CLOSE @my_id_sched_curs
		DEALLOCATE @my_id_sched_curs

		FETCH NEXT FROM @my_id_sub_curs INTO @my_parent_id_sub, @my_parent_sub_start, @my_parent_sub_end
    END
    CLOSE @my_id_sub_curs
	DEALLOCATE @my_id_sub_curs

    EXEC templt_write_schedules --@my_id_acc, my_id_sub, v_id_audit, 1, my_id_pricelist, my_id_pi_template, @my_param_def_array, my_schedule_array, v_id_csr);
		@my_id_acc = @my_id_acc,
		@my_id_sub = @my_id_sub,
		@v_id_audit = @v_id_audit,
		@is_public = 1,
		@v_id_pricelist = @my_id_pricelist,
		@v_id_pi_template = @my_id_pi_template,
		--@v_param_table_def IN TP_PARAM_TABLE_DEF,
		@v_id_pt = @my_id_pt,
		--@v_schedules IN OUT TP_SCHEDULE_ARRAY,
		@v_id_csr = @v_id_csr

    IF (@pass_to_children = 1)
	BEGIN
        EXEC get_child_gsubs_private @my_id_acc, @my_id_po, @my_rsched_start, @my_rsched_end, @my_id_gsub_curs OUT

		FETCH NEXT FROM @my_id_gsub_curs INTO @my_child_id_acc, @my_child_id_sub

        WHILE @@FETCH_STATUS = 0
		BEGIN
            SET @l_cnt = 0
            EXEC get_id_sched @my_child_id_sub, @my_id_pt, @my_id_pi_template, @my_rsched_start, @my_rsched_end, @my_id_sched_curs OUT
			
			FETCH NEXT FROM @my_id_sched_curs INTO @my_child_id_sched, @my_child_sched_start, @my_child_sched_end

            WHILE @@FETCH_STATUS = 0
			BEGIN
                SET @l_cnt = @l_cnt + 1
                EXEC recursive_inherit --(v_id_audit, my_child_id_acc, my_child_id_sub, my_id_po, my_id_pi_template, my_child_id_sched, my_id_pt, 0, cached_param_defs, v_id_csr);
				    @v_id_audit = @v_id_audit,
					@my_id_acc = @my_child_id_acc,
					@v_id_sub = @my_child_id_sub,
					@v_id_po = @my_id_po,
					@v_id_pi_template = @my_id_pi_template,
					@my_id_sched = @my_child_id_sched,
					@my_id_pt = @my_id_pt,
					@pass_to_children = 0,
					@v_id_csr = @v_id_csr

				FETCH NEXT FROM @my_id_sched_curs INTO @my_child_id_sched, @my_child_sched_start, @my_child_sched_end
            END

			CLOSE @my_id_sched_curs
			DEALLOCATE @my_id_sched_curs

            IF @l_cnt = 0
                EXEC recursive_inherit --(v_id_audit, my_child_id_acc, my_child_id_sub, my_id_po, my_id_pi_template, NULL, my_id_pt, 0, cached_param_defs, v_id_csr);
				    @v_id_audit = @v_id_audit,
					@my_id_acc = @my_child_id_acc,
					@v_id_sub = @my_child_id_sub,
					@v_id_po = @my_id_po,
					@v_id_pi_template = @my_id_pi_template,
					@my_id_sched = NULL,
					@my_id_pt = @my_id_pt,
					@pass_to_children = 0,
					@v_id_csr = @v_id_csr
            
			FETCH NEXT FROM @my_id_gsub_curs INTO @my_child_id_acc, @my_child_id_sub
        END

        CLOSE @my_id_gsub_curs
		DEALLOCATE @my_id_gsub_curs
    END

	DROP TABLE #tmp_schedule_rate_params
	DROP TABLE #tmp_schedule_rates
	DROP TABLE #my_schedule_array
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[get_all_pts_by_sub]'
GO
CREATE PROCEDURE [dbo].[get_all_pts_by_sub](
    @my_id_sub INT,
    @my_id_pt_curs CURSOR VARYING OUT
)
AS
BEGIN
    SET @my_id_pt_curs = CURSOR FORWARD_ONLY FOR
        SELECT pm.id_paramtable, pm.id_pi_template
        FROM   t_sub s, t_pl_map pm, t_rulesetdefinition rd
        WHERE   s.id_sub = @my_id_sub
            AND s.id_po = pm.id_po
            AND pm.id_sub IS NULL
            AND pm.id_acc IS NULL
            AND pm.id_paramtable = rd.id_paramtable

	OPEN @my_id_pt_curs
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[recursive_inherit_sub]'
GO
CREATE PROCEDURE [dbo].[recursive_inherit_sub](
	@v_id_audit INT,
	@v_id_acc INT,
	@v_id_sub INT,
	@v_id_group INT
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @my_id_sub INT
	DECLARE @my_id_audit INT
	DECLARE @my_id_po INT
	DECLARE @my_id_pt INT
	DECLARE @my_id_pt_curs CURSOR
	DECLARE @my_id_sched_curs CURSOR
	DECLARE @my_child_id_sched INT
	DECLARE @my_child_sched_start DATETIME
	DECLARE @my_child_sched_end DATETIME
	DECLARE @my_counter INT
	DECLARE @my_id_pi_template INT
	DECLARE @audit_msg NVARCHAR(255)

	IF OBJECT_ID('tempdb..#tmp_cached_param_defs') IS NOT NULL
		DROP TABLE #tmp_cached_param_defs
	IF OBJECT_ID('tempdb..#tmp_param_defs') IS NOT NULL
		DROP TABLE #tmp_param_defs
	IF OBJECT_ID('tempdb..#tmp_filter_vals') IS NOT NULL
		DROP TABLE #tmp_filter_vals
	
	CREATE TABLE #tmp_cached_param_defs
	(
		id_pt INT NOT NULL PRIMARY KEY,
		nm_pt NVARCHAR(100)
	)

	CREATE TABLE #tmp_param_defs
	(
		id_param_defs INT NOT NULL IDENTITY PRIMARY KEY,
		id_pt INT NOT NULL,
		nm_column_name NVARCHAR(255),
        is_rate_key INT,
        id_param_table_prop INT
	)

	CREATE INDEX #tmp_param_defs_idx ON #tmp_param_defs (id_pt)

	CREATE TABLE #tmp_filter_vals
	(
		id_param_table_prop INT NOT NULL PRIMARY KEY,
		nm_val  NVARCHAR(100)
	)

	SELECT @my_id_sub = @v_id_sub
	IF @my_id_sub IS NULL
		SELECT @my_id_sub = MAX(id_sub) FROM t_sub WHERE id_group = @v_id_group

	SELECT @my_id_po = MIN(id_po) FROM t_sub WHERE id_sub = @my_id_sub

	SELECT @my_id_audit = @v_id_audit --ISNULL(@v_id_audit, current_id_audit)
	IF @my_id_audit IS NULL
	BEGIN
		EXEC getcurrentid 'id_audit', @my_id_audit OUT
		SET @audit_msg = N'Creating public rate for account ' + CAST(@v_id_acc AS NVARCHAR(10)) + N' subscription ' + CAST(@my_id_sub AS NVARCHAR(10))
		DECLARE @curr_date DATETIME
		SET @curr_date = GETDATE()
		EXEC insertauditevent
			@id_userid           = NULL,
			@id_event            = 1451,
			@id_entity_type      = 2,
			@id_entity           = @my_id_sub,
			@dt_timestamp        = @curr_date,
			@id_audit            = @my_id_audit,
			@tx_details          = @audit_msg,
			@tx_logged_in_as     = NULL,
			@tx_application_name = NULL
	END

	DECLARE @mindate DATETIME
	DECLARE @maxdate DATETIME
	SET @mindate = dbo.mtmindate()
	SET @maxdate = dbo.mtmaxdate()

	EXEC get_all_pts_by_sub @my_id_sub, @my_id_pt_curs OUT

	FETCH @my_id_pt_curs INTO @my_id_pt, @my_id_pi_template
    
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @my_counter = 0
		EXEC get_id_sched @my_id_sub, @my_id_pt, @my_id_pi_template, @mindate, @maxdate, @my_id_sched_curs OUT
		
		FETCH @my_id_sched_curs INTO @my_child_id_sched, @my_child_sched_start, @my_child_sched_end
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @my_counter = @my_counter + 1
			EXEC recursive_inherit @my_id_audit, @v_id_acc, @my_id_sub, @my_id_po, @my_id_pi_template, @my_child_id_sched, @my_id_pt, 1
			FETCH @my_id_sched_curs INTO @my_child_id_sched, @my_child_sched_start, @my_child_sched_end
		END
		
		CLOSE @my_id_sched_curs
		DEALLOCATE @my_id_sched_curs

		IF @my_counter = 0
			EXEC recursive_inherit @my_id_audit, @v_id_acc, @my_id_sub, @my_id_po, @my_id_pi_template, NULL, @my_id_pt, 1

		FETCH @my_id_pt_curs INTO @my_id_pt, @my_id_pi_template
	END

	CLOSE @my_id_pt_curs
	DEALLOCATE @my_id_pt_curs

	DROP TABLE #tmp_filter_vals
	DROP TABLE #tmp_param_defs
	DROP TABLE #tmp_cached_param_defs
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[trg_gsubmember_icb_rates] on [dbo].[t_gsubmember]'
GO
CREATE TRIGGER [dbo].[trg_gsubmember_icb_rates] ON [dbo].[t_gsubmember]
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @id_acc INT
	DECLARE @id_group INT
	DECLARE new_members CURSOR LOCAL FOR
		SELECT id_acc, id_group
		FROM   inserted

	OPEN new_members
	FETCH NEXT FROM new_members INTO @id_acc, @id_group

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC recursive_inherit_sub
			@v_id_audit = NULL,
			@v_id_acc   = @id_acc,
			@v_id_sub   = NULL,
			@v_id_group = @id_group

		FETCH NEXT FROM new_members INTO @id_acc, @id_group
    END

	CLOSE new_members
	DEALLOCATE new_members
END;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_flatrecurringcharge_ID_SCHED] on [dbo].[t_pt_FlatRecurringCharge]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_flatrecurringcharge_ID_SCHED] ON [dbo].[t_pt_FlatRecurringCharge] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_flatrecurringcharge table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[MTSP_GENERATE_ST_NRCS_QUOTING]'
GO
CREATE PROCEDURE [dbo].[MTSP_GENERATE_ST_NRCS_QUOTING]

@dt_start DATETIME,
@dt_end DATETIME,
@v_id_accounts VARCHAR(4000),
@v_id_interval INT,
@v_id_batch VARCHAR(256),
@v_n_batch_size INT,
@v_run_date DATETIME,
@v_is_group_sub INT,
@p_count INT OUTPUT

AS BEGIN

DECLARE @id_nonrec INT,
		@n_batches  INT,
		@total_nrcs INT,
		@id_message BIGINT,
		@id_ss INT,
		@tx_batch BINARY(16);
		
IF OBJECT_ID('tempdb..#TMP_NRC_ACCOUNTS_FOR_RUN') IS NOT NULL
DROP TABLE #TMP_NRC_ACCOUNTS_FOR_RUN

IF OBJECT_ID('tempdb..#TMP_NRC') IS NOT NULL
DROP TABLE #TMP_NRC

CREATE TABLE #TMP_NRC
  (
  id_source_sess UNIQUEIDENTIFIER,
  c_NRCEventType INT,
  c_NRCIntervalStart DATETIME,
  c_NRCIntervalEnd DATETIME,
  c_NRCIntervalSubscriptionStart DATETIME,
  c_NRCIntervalSubscriptionEnd DATETIME,
  c__AccountID INT,
  c__PriceableItemInstanceID INT,
  c__PriceableItemTemplateID INT,
  c__ProductOfferingID INT,
  c__SubscriptionID INT,
  c__IntervalID INT,
  c__Resubmit INT,
  c__TransactionCookie INT,
  c__CollectionID BINARY (16)
  )


SELECT * INTO #TMP_NRC_ACCOUNTS_FOR_RUN FROM(SELECT value AS id_acc FROM CSVToInt(@v_id_accounts)) A;

SELECT @tx_batch = CAST(N'' AS XML).value('xs:base64Binary(sql:variable("@v_id_batch"))', 'binary(16)');

IF @v_is_group_sub > 0
BEGIN

	INSERT INTO #TMP_NRC
	(
		id_source_sess,
		c_NRCEventType,
		c_NRCIntervalStart,
		c_NRCIntervalEnd,
		c_NRCIntervalSubscriptionStart,
		c_NRCIntervalSubscriptionEnd,
		c__AccountID,
		c__PriceableItemInstanceID,
		c__PriceableItemTemplateID,
		c__ProductOfferingID,
		c__SubscriptionID,
		c__IntervalID,
		c__Resubmit,
		c__TransactionCookie,
		c__CollectionID
	)
	
	SELECT
			NEWID() AS id_source_sess,
			nrc.n_event_type AS	c_NRCEventType,
			@dt_start AS c_NRCIntervalStart,
			@dt_end AS 	c_NRCIntervalEnd,
			mem.vt_start AS	c_NRCIntervalSubscriptionStart,
			mem.vt_end AS	c_NRCIntervalSubscriptionEnd,
			mem.id_acc AS	c__AccountID,
			plm.id_pi_instance AS	c__PriceableItemInstanceID,
			plm.id_pi_template AS	c__PriceableItemTemplateID,
			sub.id_po AS c__ProductOfferingID,
			sub.id_sub AS	c__SubscriptionID,
			@v_id_interval AS c__IntervalID,
			'0' AS c__Resubmit,
			NULL AS c__TransactionCookie,
			@tx_batch AS c__CollectionID
	FROM	t_sub sub
			INNER JOIN t_gsubmember mem ON mem.id_group = sub.id_group
			INNER JOIN #TMP_NRC_ACCOUNTS_FOR_RUN acc ON acc.id_acc = mem.id_acc
			INNER JOIN t_po ON sub.id_po = t_po.id_po
			INNER JOIN t_pl_map plm ON sub.id_po = plm.id_po AND plm.id_paramtable IS NULL
			INNER JOIN t_base_props bp ON bp.id_prop = plm.id_pi_instance AND bp.n_kind = 30
			INNER JOIN t_nonrecur nrc ON nrc.id_prop = bp.id_prop AND nrc.n_event_type = 1
	WHERE	sub.vt_start >= @dt_start AND sub.vt_start < @dt_end
	;

END
ELSE
BEGIN

	INSERT INTO #TMP_NRC
	(
		id_source_sess,
		c_NRCEventType,
		c_NRCIntervalStart,
		c_NRCIntervalEnd,
		c_NRCIntervalSubscriptionStart,
		c_NRCIntervalSubscriptionEnd,
		c__AccountID,
		c__PriceableItemInstanceID,
		c__PriceableItemTemplateID,
		c__ProductOfferingID,
		c__SubscriptionID,
		c__IntervalID,
		c__Resubmit,
		c__TransactionCookie,
		c__CollectionID
	)
	SELECT
			NEWID() AS id_source_sess,
			nrc.n_event_type AS	c_NRCEventType,
			@dt_start AS c_NRCIntervalStart,
			@dt_end AS 	c_NRCIntervalEnd,
			sub.vt_start AS	c_NRCIntervalSubscriptionStart,
			sub.vt_end AS	c_NRCIntervalSubscriptionEnd,
			sub.id_acc AS	c__AccountID,
			plm.id_pi_instance AS	c__PriceableItemInstanceID,
			plm.id_pi_template AS	c__PriceableItemTemplateID,
			sub.id_po AS c__ProductOfferingID,
			sub.id_sub AS	c__SubscriptionID,
			@v_id_interval AS c__IntervalID,
			'0' AS c__Resubmit,
			NULL AS c__TransactionCookie,
			@tx_batch AS c__CollectionID
	FROM	t_sub sub
			INNER JOIN #TMP_NRC_ACCOUNTS_FOR_RUN acc ON acc.id_acc = sub.id_acc
			INNER JOIN t_po ON sub.id_po = t_po.id_po
			INNER JOIN t_pl_map plm ON sub.id_po = plm.id_po AND plm.id_paramtable IS NULL
			INNER JOIN t_base_props bp ON bp.id_prop = plm.id_pi_instance AND bp.n_kind = 30
			INNER JOIN t_nonrecur nrc ON nrc.id_prop = bp.id_prop AND nrc.n_event_type = 1
	WHERE	sub.vt_start >= @dt_start AND sub.vt_start < @dt_end
	;

END

SET @total_nrcs = (SELECT COUNT(*) FROM #tmp_nrc)

SET @id_nonrec = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
	'metratech.com/nonrecurringcharge');

SET @n_batches = (@total_nrcs / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT 	INTO t_message
(
	id_message,
	id_route,
	dt_crt,
	dt_metered,
	dt_assigned,
	id_listener,
	id_pipeline,
	dt_completed,
	id_feedback,
	tx_TransactionID,
	tx_sc_username,
	tx_sc_password,
	tx_sc_namespace,
	tx_sc_serialized,
	tx_ip_address
)
SELECT
	id_message,
	NULL,
	@v_run_date,
	@v_run_date,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	'127.0.0.1'
FROM
	(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY id_source_sess) % @n_batches) AS id_message
	FROM #tmp_nrc
	) a
GROUP BY a.id_message;
    
INSERT INTO t_session
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY id_source_sess) % @n_batches) AS id_ss,
    id_source_sess
FROM #tmp_nrc
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, @id_nonrec, b_root, COUNT(1) AS session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY id_source_sess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY id_source_sess) % @n_batches) AS id_ss,
    1 AS b_root
FROM #tmp_nrc) a
GROUP BY a.id_message, a.id_ss, a.b_root;
 
INSERT INTO t_svc_NonRecurringCharge
(
	id_source_sess,
    id_parent_source_sess,
    id_external,
    c_NRCEventType,
	c_NRCIntervalStart,
	c_NRCIntervalEnd,
	c_NRCIntervalSubscriptionStart,
	c_NRCIntervalSubscriptionEnd,
	c__AccountID,
	c__PriceableItemInstanceID,
	c__PriceableItemTemplateID,
	c__ProductOfferingID,
	c__SubscriptionID,
    c__IntervalID,
    c__Resubmit,
    c__TransactionCookie,
    c__CollectionID
)
SELECT
    id_source_sess,
    NULL AS id_parent_source_sess,
    NULL AS id_external,
	c_NRCEventType,
	c_NRCIntervalStart,
	c_NRCIntervalEnd,
	c_NRCIntervalSubscriptionStart,
	c_NRCIntervalSubscriptionEnd,
	c__AccountID,
	c__PriceableItemInstanceID,
	c__PriceableItemTemplateID,
	c__ProductOfferingID,
	c__SubscriptionID,
    c__IntervalID,
    c__Resubmit,
    c__TransactionCookie,
    c__CollectionID
FROM #tmp_nrc

DROP TABLE #tmp_nrc
SET @p_count = @total_nrcs
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[RemoveGroupSubscription_Quoting]'
GO
CREATE PROCEDURE [dbo].[RemoveGroupSubscription_Quoting](
  @p_id_sub INT,
  @p_systemdate DATETIME,
  @p_status INT OUTPUT)

  AS
  BEGIN
    
    DECLARE @groupID INT
    DECLARE @maxdate DATETIME
    DECLARE @nmembers INT
    DECLARE @icbID INT

    SET @p_status = 0

    SELECT @groupID = id_group,@maxdate = dbo.mtmaxdate()
    FROM t_sub WHERE id_sub = @p_id_sub

    SELECT DISTINCT @icbID = id_pricelist FROM t_pl_map WHERE id_sub=@p_id_sub
	    
    DELETE FROM t_gsub_recur_map WHERE id_group = @groupID
    DELETE FROM t_recur_value WHERE id_sub = @p_id_sub

    -- In the t_acc_template_subs, either id_po or id_group have to be null.
    -- If a subscription is added to a template, then id_po points to the subscription
    -- If a group subscription is added to a template, then id_group points to the group subscription.
    DELETE FROM t_acc_template_subs WHERE id_group = @groupID AND id_po IS NULL

    -- Eventually we would need to make sure that the rules for each icb rate schedule are removed from the proper parameter tables
    DELETE FROM t_pl_map WHERE id_sub = @p_id_sub

    UPDATE t_recur_value SET tt_end = @p_systemdate
      WHERE id_sub = @p_id_sub AND tt_end = @maxdate
    UPDATE t_sub_history SET tt_end = @p_systemdate
      WHERE tt_end = @maxdate AND id_sub = @p_id_sub

    DELETE FROM t_sub WHERE id_sub = @p_id_sub
    
    DELETE FROM t_char_values WHERE id_entity = @p_id_sub
    
      IF (@icbID IS NOT NULL)
      BEGIN
        EXEC sp_DeletePricelist @icbID, @p_status OUTPUT
        IF @p_status <> 0 RETURN
      END
  
    UPDATE t_group_sub SET tx_name = CAST('[DELETED ' + CAST(GETDATE() AS NVARCHAR) + ']' + tx_name AS NVARCHAR(255)) WHERE id_group = @groupID

  END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_nonrecurringcharge_ID_SCHED] on [dbo].[t_pt_NonRecurringCharge]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_nonrecurringcharge_ID_SCHED] ON [dbo].[t_pt_NonRecurringCharge] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_nonrecurringcharge table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_percentdiscount_ID_SCHED] on [dbo].[t_pt_PercentDiscount]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_percentdiscount_ID_SCHED] ON [dbo].[t_pt_PercentDiscount] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_percentdiscount table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Rebuilding [dbo].[t_acc_usage]'

EXEC sp_RENAME 't_acc_usage.tax_inclusive' , 'is_implied_tax', 'COLUMN'
GO
UPDATE t_acc_usage SET is_implied_tax='N' WHERE is_implied_tax IS NULL
UPDATE t_acc_usage SET tax_informational='N' WHERE tax_informational IS NULL
GO
ALTER TABLE t_acc_usage ALTER COLUMN is_implied_tax NVARCHAR(1) NOT NULL
ALTER TABLE t_acc_usage ALTER COLUMN tax_informational NVARCHAR(1) NOT NULL
GO

IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[VW_AJ_INFO]'
GO
EXEC sp_refreshview N'[dbo].[VW_AJ_INFO]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[MTSP_GENERATE_ST_RCS_QUOTING]'
GO
CREATE PROCEDURE [dbo].[MTSP_GENERATE_ST_RCS_QUOTING]
                                            @v_id_interval  INT
                                           ,@v_id_billgroup INT
                                           ,@v_id_run       INT
										   ,@v_id_accounts VARCHAR(4000)
                                           ,@v_id_batch     VARCHAR(256)
                                           ,@v_n_batch_size INT
										   ,@v_run_date   DATETIME
                                           ,@p_count      INT OUTPUT
AS
BEGIN
	/* SET NOCOUNT ON added to prevent extra result sets from
	   interfering with SELECT statements. */
	SET NOCOUNT ON;
  DECLARE @total_rcs  INT,
          @total_flat INT,
          @total_udrc INT,
          @n_batches  INT,
          @id_flat    INT,
          @id_udrc    INT,
          @id_message BIGINT,
          @id_ss      INT,
          @tx_batch   BINARY(16);
--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Retrieving RC candidates');

/* Create the list of accounts to generate for */
IF OBJECT_ID('tempdb..#TMP_RC_ACCOUNTS_FOR_RUN') IS NOT NULL
DROP TABLE #TMP_RC_ACCOUNTS_FOR_RUN

SELECT * INTO #TMP_RC_ACCOUNTS_FOR_RUN FROM(SELECT value AS id_acc FROM CSVToInt(@v_id_accounts)) A;



SELECT
*
INTO
#TMP_RC
FROM(
SELECT
NEWID() AS idSourceSess,
      'Arrears' AS c_RCActionType
      ,pci.dt_start      AS c_RCIntervalStart
      ,pci.dt_end      AS c_RCIntervalEnd
      ,ui.dt_start      AS c_BillingIntervalStart
      ,ui.dt_end          AS c_BillingIntervalEnd
      ,dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)          AS c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart          AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
      ,rw.c_advance          AS c_Advance
      ,rcr.b_prorate_on_activate          AS c_ProrateOnSubscription
      ,rcr.b_prorate_instantly          AS c_ProrateInstantly
      ,rcr.b_prorate_on_deactivate          AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
      ,rw.c__accountid AS c__AccountID
      ,rw.c__payingaccount      AS c__PayingAccount
      ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
      ,rw.c__productofferingid      AS c__ProductOfferingID
      ,pci.dt_end      AS c_BilledRateDate
      ,rw.c__subscriptionid      AS c__SubscriptionID
,rw.c_payerstart,rw.c_payerend,CASE WHEN rw.c_unitvaluestart < '1970-01-01 00:00:00' THEN '1970-01-01 00:00:00' ELSE rw.c_unitvaluestart END AS c_unitvaluestart ,rw.c_unitvalueend
, rw.c_unitvalue
, rcr.n_rating_type AS c_RatingType
      FROM t_usage_interval ui
      /*INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
      INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup*/
	  LEFT JOIN #TMP_RC_ACCOUNTS_FOR_RUN bgm ON 1=1
      INNER LOOP JOIN t_recur_window rw WITH(INDEX(rc_window_time_idx)) ON bgm.id_acc = rw.c__payingaccount
                                   AND rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* interval overlaps with payer */
                                   AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* interval overlaps with cycle */
                                   AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* interval overlaps with membership */
                                   AND rw.c_subscriptionstart   < ui.dt_end AND rw.c_subscriptionend   > ui.dt_start /* interval overlaps with subscription */
                                   AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* interval overlaps with UDRC */
      INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
      INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle WHEN rcr.tx_cycle_mode LIKE 'BCR%' THEN ui.id_usage_cycle WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) ELSE NULL END
      /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
      INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_end BETWEEN ui.dt_start        AND ui.dt_end                             /* rc end falls in this interval */
                                   AND pci.dt_end BETWEEN rw.c_payerstart    AND rw.c_payerend                         /* rc end goes to this payer */
                                   AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
                                   AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
      INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      WHERE 1=1
      AND ui.id_interval = @v_id_interval
      /*and bg.id_billgroup = @v_id_billgroup*/
      AND rcr.b_advance <> 'Y'
UNION ALL
SELECT
NEWID() AS idSourceSess,
      'Advance' AS c_RCActionType
      ,pci.dt_start      AS c_RCIntervalStart
      ,pci.dt_end      AS c_RCIntervalEnd
      ,ui.dt_start      AS c_BillingIntervalStart
      ,ui.dt_end          AS c_BillingIntervalEnd
      ,CASE WHEN rcr.tx_cycle_mode <> 'Fixed' AND nui.dt_start <> c_cycleEffectiveDate
       THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(c_cycleEffectiveDate), pci.dt_start)
       ELSE pci.dt_start END AS c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart          AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
      ,rw.c_advance          AS c_Advance
      ,rcr.b_prorate_on_activate          AS c_ProrateOnSubscription
      ,rcr.b_prorate_instantly          AS c_ProrateInstantly
      ,rcr.b_prorate_on_deactivate          AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
      ,rw.c__accountid AS c__AccountID
      ,rw.c__payingaccount      AS c__PayingAccount
      ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
      ,rw.c__productofferingid      AS c__ProductOfferingID
      ,pci.dt_start      AS c_BilledRateDate
      ,rw.c__subscriptionid      AS c__SubscriptionID
,rw.c_payerstart,rw.c_payerend,CASE WHEN rw.c_unitvaluestart < '1970-01-01 00:00:00' THEN '1970-01-01 00:00:00' ELSE rw.c_unitvaluestart END AS c_unitvaluestart,rw.c_unitvalueend
, rw.c_unitvalue
, rcr.n_rating_type AS c_RatingType
      FROM t_usage_interval ui
      INNER LOOP JOIN t_usage_interval nui ON ui.id_usage_cycle = nui.id_usage_cycle AND dbo.AddSecond(ui.dt_end) = nui.dt_start
      /*INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
      INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup*/
	  LEFT JOIN #TMP_RC_ACCOUNTS_FOR_RUN bgm ON 1=1
      INNER LOOP JOIN t_recur_window rw WITH(INDEX(rc_window_time_idx)) ON bgm.id_acc = rw.c__payingaccount
                                   AND rw.c_payerstart          < nui.dt_end AND rw.c_payerend          > nui.dt_start /* next interval overlaps with payer */
                                   AND rw.c_cycleeffectivestart < nui.dt_end AND rw.c_cycleeffectiveend > nui.dt_start /* next interval overlaps with cycle */
                                   AND rw.c_membershipstart     < nui.dt_end AND rw.c_membershipend     > nui.dt_start /* next interval overlaps with membership */
                                   AND rw.c_subscriptionstart   < nui.dt_end AND rw.c_subscriptionend   > nui.dt_start /* next interval overlaps with subscription */
                                   AND rw.c_unitvaluestart      < nui.dt_end AND rw.c_unitvalueend      > nui.dt_start /* next interval overlaps with UDRC */
      INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
      INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle WHEN rcr.tx_cycle_mode LIKE 'BCR%' THEN ui.id_usage_cycle WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) ELSE NULL END
      INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_start BETWEEN nui.dt_start     AND nui.dt_end                            /* rc start falls in this interval */
                                   AND pci.dt_start BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
                                   AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
                                   AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
      INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      WHERE 1=1
      AND ui.id_interval = @v_id_interval
      /*and bg.id_billgroup = @v_id_billgroup*/
      AND rcr.b_advance = 'Y'
)A      ;

SELECT @total_rcs  = COUNT(1) FROM #tmp_rc;

--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'RC Candidate Count: ' + CAST(@total_rcs AS VARCHAR));

IF @total_rcs > 0
BEGIN

SELECT @total_flat = COUNT(1) FROM #tmp_rc WHERE c_unitvalue IS NULL;
SELECT @total_udrc = COUNT(1) FROM #tmp_rc WHERE c_unitvalue IS NOT NULL;

--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Flat RC Candidate Count: ' + CAST(@total_flat AS VARCHAR));
--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'UDRC RC Candidate Count: ' + CAST(@total_udrc AS VARCHAR));

--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Session Set Count: ' + CAST(@v_n_batch_size AS VARCHAR));
--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch: ' + @v_id_batch);

SELECT @tx_batch = CAST(N'' AS XML).value('xs:base64Binary(sql:variable("@v_id_batch"))', 'binary(16)');
--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch ID: ' + CAST(@tx_batch AS varchar));

IF @total_flat > 0
BEGIN

    
SET @id_flat = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
	'metratech.com/flatrecurringcharge');
    
SET @n_batches = (@total_flat / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT INTO t_session
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    idSourceSess AS id_source_sess
FROM #tmp_rc WHERE c_unitvalue IS NULL;
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, id_svc, b_root, COUNT(1) AS session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    @id_flat AS id_svc,
    1 AS b_root
FROM #tmp_rc
 WHERE c_unitvalue IS NULL) a
GROUP BY a.id_message, a.id_ss, a.id_svc, a.b_root;
 
INSERT INTO t_svc_FlatRecurringCharge
(id_source_sess
    ,id_parent_source_sess
    ,id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
    ,c_ProrateInstantly
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,c__IntervalID
    ,c__Resubmit
    ,c__TransactionCookie
    ,c__CollectionID)
SELECT
    idSourceSess AS id_source_sess
    ,NULL AS id_parent_source_sess
    ,NULL AS id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
    ,c_ProrateInstantly
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,@v_id_interval AS c__IntervalID
    ,'0' AS c__Resubmit
    ,NULL AS c__TransactionCookie
    ,@tx_batch AS c__CollectionID
FROM #tmp_rc
 WHERE c_unitvalue IS NULL;
          INSERT
          INTO t_message
            (
              id_message,
              id_route,
              dt_crt,
              dt_metered,
              dt_assigned,
              id_listener,
              id_pipeline,
              dt_completed,
              id_feedback,
              tx_TransactionID,
              tx_sc_username,
              tx_sc_password,
              tx_sc_namespace,
              tx_sc_serialized,
              tx_ip_address
            )
            SELECT
              id_message,
              NULL,
              @v_run_date,
              @v_run_date,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              '127.0.0.1'
            FROM
              (SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message
              FROM #tmp_rc
              WHERE c_unitvalue IS NULL
              ) a
            GROUP BY a.id_message;

/*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting Flat RCs');*/

END;
IF @total_udrc > 0
BEGIN

SET @id_udrc = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
	'metratech.com/udrecurringcharge');
    
SET @n_batches = (@total_udrc / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT INTO t_session
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    idSourceSess AS id_source_sess
FROM #tmp_rc WHERE c_unitvalue IS NOT NULL;
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, id_svc, b_root, COUNT(1) AS session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    @id_udrc AS id_svc,
    1 AS b_root
FROM #tmp_rc
 WHERE c_unitvalue IS NOT NULL) a
GROUP BY a.id_message, a.id_ss, a.id_svc, a.b_root;
 
INSERT INTO t_svc_UDRecurringCharge
(id_source_sess, id_parent_source_sess, id_external, c_RCActionType, c_RCIntervalStart,c_RCIntervalEnd,c_BillingIntervalStart,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
/*    ,c_ProrateInstantly */
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,c__IntervalID
    ,c__Resubmit
    ,c__TransactionCookie
    ,c__CollectionID
	,c_unitvaluestart
	,c_unitvalueend
	,c_unitvalue
	,c_ratingtype)
SELECT
    idSourceSess AS id_source_sess
    ,NULL AS id_parent_source_sess
    ,NULL AS id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
/*    ,c_ProrateInstantly */
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,@v_id_interval AS c__IntervalID
    ,'0' AS c__Resubmit
    ,NULL AS c__TransactionCookie
    ,@tx_batch AS c__CollectionID
	,c_unitvaluestart
	,c_unitvalueend
	,c_unitvalue
	,c_ratingtype
FROM #tmp_rc
 WHERE c_unitvalue IS NOT NULL;

          INSERT
          INTO t_message
            (
              id_message,
              id_route,
              dt_crt,
              dt_metered,
              dt_assigned,
              id_listener,
              id_pipeline,
              dt_completed,
              id_feedback,
              tx_TransactionID,
              tx_sc_username,
              tx_sc_password,
              tx_sc_namespace,
              tx_sc_serialized,
              tx_ip_address
            )
            SELECT
              id_message,
              NULL,
              @v_run_date,
              @v_run_date,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              '127.0.0.1'
            FROM
              (SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message
              FROM #tmp_rc
              WHERE c_unitvalue IS NOT NULL
              ) a
            GROUP BY a.id_message;

			/*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting UDRC RCs');*/

END;
 
 END;
 
 SET @p_count = @total_rcs;

/*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Info', 'Finished submitting RCs, count: ' + CAST(@total_rcs AS VARCHAR));*/

END;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[GetAccByType]'
GO
CREATE PROCEDURE [dbo].[GetAccByType]
	@acc_type NVARCHAR(100)
AS
BEGIN
SELECT map.NM_LOGIN AS Loggin,
       map.NM_SPACE AS Mn_Space,
       tp.name AS Acc_Type
FROM T_ACCOUNT_MAPPER map
INNER JOIN T_ACCOUNT acc
ON acc.id_acc= map.id_acc
INNER JOIN T_ACCOUNT_TYPE tp
ON acc.id_type= tp.id_type
WHERE tp.name = @acc_type
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_percentdiscount_nocond_ID_SCHED] on [dbo].[t_pt_PercentDiscount_NoCond]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_percentdiscount_nocond_ID_SCHED] ON [dbo].[t_pt_PercentDiscount_NoCond] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_percentdiscount_nocond table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[vw_all_billing_groups_status]'
GO
EXEC sp_refreshview N'[dbo].[vw_all_billing_groups_status]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[vw_interval_billgroup_counts]'
GO
EXEC sp_refreshview N'[dbo].[vw_interval_billgroup_counts]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[vw_paying_accounts]'
GO
EXEC sp_refreshview N'[dbo].[vw_paying_accounts]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_udrctapered_ID_SCHED] on [dbo].[t_pt_UDRCTapered]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_udrctapered_ID_SCHED] ON [dbo].[t_pt_UDRCTapered] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_udrctapered table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[vw_unassigned_accounts]'
GO
EXEC sp_refreshview N'[dbo].[vw_unassigned_accounts]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_udrctiered_ID_SCHED] on [dbo].[t_pt_UDRCTiered]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_udrctiered_ID_SCHED] ON [dbo].[t_pt_UDRCTiered] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_udrctiered table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_bulkdiscountpt_ID_SCHED] on [dbo].[t_pt_BulkDiscountPT]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_bulkdiscountpt_ID_SCHED] ON [dbo].[t_pt_BulkDiscountPT] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_bulkdiscountpt table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_bulkeventratespt_ID_SCHED] on [dbo].[t_pt_BulkEventRatesPT]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_bulkeventratespt_ID_SCHED] ON [dbo].[t_pt_BulkEventRatesPT] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_bulkeventratespt table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_bulkunitratespt_ID_SCHED] on [dbo].[t_pt_BulkUnitRatesPT]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_bulkunitratespt_ID_SCHED] ON [dbo].[t_pt_BulkUnitRatesPT] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_bulkunitratespt table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_commitmentpt_ID_SCHED] on [dbo].[t_pt_CommitmentPT]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_commitmentpt_ID_SCHED] ON [dbo].[t_pt_CommitmentPT] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_commitmentpt table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_freeusagept_ID_SCHED] on [dbo].[t_pt_FreeUsagePT]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_freeusagept_ID_SCHED] ON [dbo].[t_pt_FreeUsagePT] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_freeusagept table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_incrementaldiscountpt_ID_SCHED] on [dbo].[t_pt_IncrementalDiscountPT]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_incrementaldiscountpt_ID_SCHED] ON [dbo].[t_pt_IncrementalDiscountPT] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_incrementaldiscountpt table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_tieredeventratespt_ID_SCHED] on [dbo].[t_pt_TieredEventRatesPT]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_tieredeventratespt_ID_SCHED] ON [dbo].[t_pt_TieredEventRatesPT] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_tieredeventratespt table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_tieredunitratespt_ID_SCHED] on [dbo].[t_pt_TieredUnitRatesPT]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_tieredunitratespt_ID_SCHED] ON [dbo].[t_pt_TieredUnitRatesPT] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_tieredunitratespt table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[GetBalances]'
GO
ALTER PROCEDURE [dbo].[GetBalances](
@id_acc INT,
@id_interval INT,
@previous_balance NUMERIC(22,10) OUTPUT,
@balance_forward NUMERIC(22,10) OUTPUT,
@current_balance NUMERIC(22,10) OUTPUT,
@currency NVARCHAR(3) OUTPUT,
@estimation_code INT OUTPUT, -- 0 = NONE: no estimate, all balances taken from t_invoice
                             -- 1 = CURRENT_BALANCE: balance_forward and current_balance estimated, @previous_balance taken from t_invoice
                             -- 2 = PREVIOUS_BALANCE: all balances estimated
@return_code INT OUTPUT
)
AS
BEGIN
DECLARE
  @balance_date DATETIME,
  @unbilled_prior_charges NUMERIC(22,10), -- unbilled charges from interval after invoice and before this one
  @previous_charges NUMERIC(22,10),       -- payments, adjsutments for this interval
  @current_charges NUMERIC(22,10),        -- current charges for this interval
  @interval_start DATETIME,
  @tmp_amount NUMERIC(22,10),
  @tmp_currency NVARCHAR(3)

  SET @return_code = 0

  -- step1: check for existing t_invoice, and use that one if exists
  SELECT @current_balance = current_balance,
    @balance_forward = current_balance - invoice_amount - tax_ttl_amt,
    @previous_balance = @balance_forward - payment_ttl_amt - postbill_adj_ttl_amt - ar_adj_ttl_amt,
    @currency = invoice_currency
  FROM t_invoice
  WHERE id_acc = @id_acc
  AND id_interval = @id_interval

  IF NOT @current_balance IS NULL
    BEGIN
    SET @estimation_code = 0
    RETURN --done
    END

  -- step2: get balance (as of @interval_start) from previous invoice
  --set @interval_start = (select dt_start from t_usage_interval where id_interval = @id_interval)

  -- AR: Bug fix for 10238, when billing cycle is changed.

  SELECT @interval_start =
	CASE WHEN aui.dt_effective IS NULL THEN
		ui.dt_start
	     ELSE DATEADD(s, 1, aui.dt_effective)
	END
  FROM t_acc_usage_interval aui
	INNER JOIN t_usage_interval ui ON aui.id_usage_interval = ui.id_interval
	WHERE aui.id_acc = @id_acc
	AND ui.id_interval = @id_interval

  EXEC GetLastBalance @id_acc, @interval_start, @previous_balance OUTPUT, @balance_date OUTPUT, @currency OUTPUT

  -- step3: calc @unbilled_prior_charges
  SET @unbilled_prior_charges = 0

  -- add unbilled payments, and ar adjustments
  SELECT @tmp_amount = SUM(au.Amount),
    @tmp_currency = au.am_currency
  FROM t_acc_usage au
   INNER JOIN t_prod_view pv ON au.id_view = pv.id_view
   INNER JOIN t_acc_usage_interval aui ON au.id_acc = aui.id_acc AND au.id_usage_interval = aui.id_usage_interval
   INNER JOIN t_usage_interval ui ON aui.id_usage_interval = ui.id_interval
  WHERE pv.nm_table_name IN ('t_pv_Payment', 't_pv_ARAdjustment')
    AND au.id_acc = @id_acc
    AND ui.dt_end > @balance_date
    AND ui.dt_start < @interval_start
  GROUP BY au.am_currency

  IF @@ROWCOUNT > 1 OR (@@ROWCOUNT = 1 AND @tmp_currency <> @currency)
  BEGIN
    SET @return_code = 1 -- currency mismatch
    RETURN 1
  END

  SET @tmp_amount = ISNULL(@tmp_amount, 0)
  SET @unbilled_prior_charges = @unbilled_prior_charges + @tmp_amount

  SET @tmp_amount = 0.0

  -- add unbilled current charges
  SELECT @tmp_amount = SUM(ISNULL(au.Amount, 0.0)) +
            /*For implied taxes, tax is already included, so don't add it again*/
                       SUM(CASE WHEN (au.is_implied_tax = 'N') THEN  ISNULL(au.Tax_Federal,0.0) +
                       ISNULL(au.Tax_State,0.0) +
                       ISNULL(au.Tax_County,0.0) +
                       ISNULL(au.Tax_Local,0.0) +
                       ISNULL(au.Tax_Other,0.0) ELSE 0 END) -
			/* Informational taxes don't get added into total */
					   SUM(CASE WHEN (au.tax_informational = 'Y') THEN  ISNULL(au.Tax_Federal,0.0) +
                       ISNULL(au.Tax_State,0.0) +
                       ISNULL(au.Tax_County,0.0) +
                       ISNULL(au.Tax_Local,0.0) +
                       ISNULL(au.Tax_Other,0.0) ELSE 0 END),
    @tmp_currency = au.am_currency
  FROM t_acc_usage au
    INNER JOIN t_view_hierarchy vh ON au.id_view = vh.id_view
    LEFT OUTER JOIN t_pi_template piTemplated2 ON piTemplated2.id_template=au.id_pi_template
    LEFT OUTER JOIN t_base_props pi_type_props ON pi_type_props.id_prop=piTemplated2.id_pi
    INNER JOIN t_enum_data enumd2 ON au.id_view=enumd2.id_enum_data
    INNER JOIN t_acc_usage_interval aui ON au.id_acc = aui.id_acc AND au.id_usage_interval = aui.id_usage_interval
    INNER JOIN t_usage_interval ui ON aui.id_usage_interval = ui.id_interval
  WHERE
    vh.id_view = vh.id_view_parent
    AND au.id_acc = @id_acc
    AND ((au.id_pi_template IS NULL AND au.id_parent_sess IS NULL) OR (au.id_pi_template IS NOT NULL AND piTemplated2.id_template_parent IS NULL))
    AND (pi_type_props.n_kind IS NULL OR pi_type_props.n_kind <> 15 OR UPPER(enumd2.nm_enum_data) NOT LIKE '%_TEMP')
    AND ui.dt_end > @balance_date
    AND ui.dt_start < @interval_start
  GROUP BY au.am_currency

  IF @@ROWCOUNT > 1 OR (@@ROWCOUNT = 1 AND @tmp_currency <> @currency)
  BEGIN
    SET @return_code = 1 -- currency mismatch
    RETURN 1
  END

  SET @tmp_amount = ISNULL(@tmp_amount, 0)
  SET @unbilled_prior_charges = @unbilled_prior_charges + @tmp_amount

  -- add unbilled pre-bill and post-bill adjustments
  SET @unbilled_prior_charges = @unbilled_prior_charges + ISNULL(
    (SELECT SUM(ISNULL(PrebillAdjAmt, 0.0)) +
            SUM(ISNULL(PostbillAdjAmt, 0.0)) +
            SUM(ISNULL(PrebillTaxAdjAmt, 0.0)) +
            SUM(ISNULL(PostbillTaxAdjAmt, 0.0))
     FROM vw_adjustment_summary
     WHERE id_acc = @id_acc
     AND dt_end > @balance_date
     AND dt_start < @interval_start), 0)


  -- step4: add @unbilled_prior_charges to @previous_balance if any found
  IF @unbilled_prior_charges <> 0
    BEGIN
    SET @estimation_code = 2
    SET @previous_balance = @previous_balance + @unbilled_prior_charges
    END
  ELSE
    SET @estimation_code = 1

  -- step5: get previous charges
  SELECT
    @previous_charges = SUM(au.Amount),
    @tmp_currency = au.am_currency
  FROM t_acc_usage au
   INNER JOIN t_prod_view pv ON au.id_view = pv.id_view
  WHERE pv.nm_table_name IN ('t_pv_Payment', 't_pv_ARAdjustment')
  AND au.id_acc = @id_acc
  AND au.id_usage_interval = @id_interval
  GROUP BY au.am_currency

  IF @@ROWCOUNT > 1 OR (@@ROWCOUNT = 1 AND @tmp_currency <> @currency)
  BEGIN
    SET @return_code = 1 -- currency mismatch
    RETURN 1
  END

  IF @previous_charges IS NULL
    SET @previous_charges = 0

  -- add post-bill adjustments
  SET @previous_charges = @previous_charges + ISNULL(
    (SELECT SUM(ISNULL(PostbillAdjAmt, 0.0)) +
            SUM(ISNULL(PostbillTaxAdjAmt, 0.0)) FROM vw_adjustment_summary
     WHERE id_acc = @id_acc AND id_usage_interval = @id_interval), 0)


  -- step6: get current charges
  SELECT
   @current_charges = SUM(ISNULL(au.Amount, 0.0)) +
   /*For implied taxes, tax is already included, so don't add it again*/
                       SUM(CASE WHEN (au.is_implied_tax = 'N') THEN  ISNULL(au.Tax_Federal,0.0) +
                       ISNULL(au.Tax_State,0.0) +
                       ISNULL(au.Tax_County,0.0) +
                       ISNULL(au.Tax_Local,0.0) +
                       ISNULL(au.Tax_Other,0.0) ELSE 0 END) -
			/* Informational taxes don't get added into total */
					   SUM(CASE WHEN (au.tax_informational = 'Y') THEN  ISNULL(au.Tax_Federal,0.0) +
                       ISNULL(au.Tax_State,0.0) +
                       ISNULL(au.Tax_County,0.0) +
                       ISNULL(au.Tax_Local,0.0) +
                       ISNULL(au.Tax_Other,0.0) ELSE 0 END),
   @tmp_currency = au.am_currency
  FROM t_acc_usage au
    INNER JOIN t_view_hierarchy vh ON au.id_view = vh.id_view
    LEFT OUTER JOIN t_pi_template piTemplated2 ON piTemplated2.id_template=au.id_pi_template
    LEFT OUTER JOIN t_base_props pi_type_props ON pi_type_props.id_prop=piTemplated2.id_pi
    INNER JOIN t_enum_data enumd2 ON au.id_view=enumd2.id_enum_data
  WHERE
    vh.id_view = vh.id_view_parent
  AND au.id_acc = @id_acc
  AND ((au.id_pi_template IS NULL AND au.id_parent_sess IS NULL) OR (au.id_pi_template IS NOT NULL AND piTemplated2.id_template_parent IS NULL))
  AND (pi_type_props.n_kind IS NULL OR pi_type_props.n_kind <> 15 OR UPPER(enumd2.nm_enum_data) NOT LIKE '%_TEMP')
  AND au.id_usage_interval = @id_interval
  GROUP BY au.am_currency

  IF @@ROWCOUNT > 1 OR (@@ROWCOUNT = 1 AND @tmp_currency <> @currency)
  BEGIN
    SET @return_code = 1 -- currency mismatch
    RETURN 1
  END

  IF @current_charges IS NULL
    SET @current_charges = 0

  -- add pre-bill adjustments
  SET @current_charges = @current_charges + ISNULL(
    (SELECT SUM(ISNULL(PrebillAdjAmt, 0.0) +
                ISNULL(PrebillTaxAdjAmt, 0.0)) FROM vw_adjustment_summary
     WHERE id_acc = @id_acc AND id_usage_interval = @id_interval), 0)

  SET @balance_forward = @previous_balance + @previous_charges
  SET @current_balance = @balance_forward + @current_charges
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[MTSP_INSERTINVOICE_BALANCES]'
GO
ALTER  PROCEDURE [dbo].[MTSP_INSERTINVOICE_BALANCES]
@id_billgroup INT,
@exclude_billable CHAR, -- '1' to only return non-billable accounts, '0' to return all accounts
@id_run INT,
@return_code INT OUTPUT
AS
BEGIN
DECLARE
@debug_flag BIT,
@SQLError INT,
@ErrMsg VARCHAR(200)
SET NOCOUNT ON
SET @debug_flag = 1 -- yes
--SET @debug_flag = 0 -- no

-- Creating bigint id_sess values to set bounds
DECLARE @id_sess_min BIGINT
DECLARE @id_sess_max BIGINT

SELECT @id_sess_min = MIN(id_sess), @id_sess_max = MAX(id_sess) FROM t_acc_usage WITH(NOLOCK)
WHERE id_acc IN (SELECT id_acc FROM t_billgroup_member WHERE id_billgroup = @id_billgroup)
AND id_usage_interval = (SELECT id_usage_interval FROM t_billgroup WHERE id_billgroup = @id_billgroup)


-- populate the driver table with account ids
INSERT INTO #tmp_all_accounts
(id_acc, namespace)
SELECT /*DISTINCT*/
bgm.id_acc,
map.nm_space
	FROM t_billgroup_member bgm
	INNER JOIN t_acc_usage au ON au.id_acc = bgm.id_acc
	INNER JOIN t_account_mapper map WITH(INDEX(t_account_mapper_idx1))
	ON map.id_acc = au.id_acc
	INNER JOIN t_namespace ns
	ON ns.nm_space = map.nm_space
	WHERE ns.tx_typ_space = 'system_mps' AND
	bgm.id_billgroup = @id_billgroup AND
    au.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
		                     WHERE id_billgroup = @id_billgroup)
UNION

SELECT /*DISTINCT*/
ads.id_acc,
map.nm_space
	FROM vw_adjustment_summary ads
	INNER JOIN t_billgroup_member bgm ON bgm.id_acc = ads.id_acc
	INNER JOIN t_account_mapper map WITH(INDEX(t_account_mapper_idx1))
	ON map.id_acc = ads.id_acc
	INNER JOIN t_namespace ns
	ON ns.nm_space = map.nm_space
	WHERE ns.tx_typ_space = 'system_mps' AND
	bgm.id_billgroup = @id_billgroup AND
    ads.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
		                     WHERE id_billgroup = @id_billgroup)
UNION

  SELECT inv.id_acc, inv.namespace FROM t_invoice inv
  INNER JOIN t_billgroup_member bgm ON inv.id_acc = bgm.id_acc
  INNER JOIN t_billgroup bg ON bgm.id_billgroup = bg.id_billgroup
  INNER JOIN t_usage_interval uii ON bg.id_usage_interval = uii.id_interval
  INNER JOIN t_namespace ns ON inv.namespace = ns.nm_space
  WHERE ns.tx_typ_space = 'system_mps' AND bgm.id_billgroup = @id_billgroup
  GROUP BY inv.id_acc, inv.namespace
  HAVING (SUM(invoice_amount) + SUM(payment_ttl_amt) + SUM(postbill_adj_ttl_amt) + SUM(ar_adj_ttl_amt))  <> 0

-- Populate with accounts that are non-billable but have payers that are billable.
-- in specified billing group
IF @exclude_billable = '1'
BEGIN
	INSERT INTO #tmp_all_accounts
	(id_acc, namespace)

	-- Get all payee accounts (for the payers in the given billing group) with usage
	SELECT /*DISTINCT*/
	pr.id_payee,
	map.nm_space
		FROM t_billgroup_member bgm
		INNER JOIN t_payment_redirection pr	ON pr.id_payer = bgm.id_acc
		INNER JOIN t_acc_usage au ON au.id_acc = pr.id_payee
		INNER JOIN t_account_mapper map	WITH(INDEX(t_account_mapper_idx1)) ON map.id_acc = au.id_acc
		INNER JOIN t_namespace ns ON ns.nm_space = map.nm_space
		WHERE ns.tx_typ_space = 'system_mps' AND
		bgm.id_billgroup = @id_billgroup AND
		pr.id_payee NOT IN (SELECT id_acc FROM #tmp_all_accounts) AND
		au.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
								WHERE id_billgroup = @id_billgroup)
	UNION

	-- Get all payee accounts (for the payers in the given billing group) with adjustments
	SELECT /*DISTINCT*/
	ads.id_acc,
	map.nm_space
		FROM vw_adjustment_summary ads
		INNER JOIN t_payment_redirection pr	ON pr.id_payee = ads.id_acc
		INNER JOIN t_billgroup_member bgm ON bgm.id_acc = pr.id_payer
		INNER JOIN t_account_mapper map	WITH(INDEX(t_account_mapper_idx1))ON map.id_acc = ads.id_acc
		INNER JOIN t_namespace ns ON ns.nm_space = map.nm_space
		WHERE ns.tx_typ_space = 'system_mps' AND
		bgm.id_billgroup = @id_billgroup AND
		pr.id_payee NOT IN (SELECT id_acc FROM #tmp_all_accounts) AND
		ads.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
								WHERE id_billgroup = @id_billgroup)
	UNION

  SELECT inv.id_acc, inv.namespace FROM t_invoice inv
  INNER JOIN t_payment_redirection pr ON pr.id_payee  = inv.id_acc
  INNER JOIN t_billgroup_member bgm ON pr.id_payer = bgm.id_acc
  INNER JOIN t_billgroup bg ON bgm.id_billgroup = bg.id_billgroup
  INNER JOIN t_usage_interval uii ON bg.id_usage_interval = uii.id_interval
  INNER JOIN t_namespace ns ON inv.namespace = ns.nm_space
  WHERE ns.tx_typ_space = 'system_mps' AND pr.id_payee NOT IN (SELECT id_acc FROM #tmp_all_accounts)
      AND bgm.id_billgroup = @id_billgroup
  GROUP BY inv.id_acc, inv.namespace
  HAVING (SUM(invoice_amount) + SUM(payment_ttl_amt) + SUM(postbill_adj_ttl_amt) + SUM(ar_adj_ttl_amt)) <> 0
END

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

-- populate #tmp_acc_amounts with accounts and their invoice amounts
IF (@debug_flag = 1 AND @id_run IS NOT NULL)
  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
    VALUES (@id_run, 'Debug', 'Invoice-Bal: Begin inserting to the #tmp_acc_amounts table', GETUTCDATE())

-- check if datamarts are being used
-- if no datamarts
-- then...

IF ((SELECT value FROM t_db_values WHERE parameter = N'DATAMART') = 'false')

BEGIN
INSERT INTO #tmp_acc_amounts
  (namespace,
  id_interval,
  id_acc,
  invoice_currency,
  payment_ttl_amt,
  postbill_adj_ttl_amt,
  ar_adj_ttl_amt,
  previous_balance,
  tax_ttl_amt,
  current_charges,
  id_payer,
  id_payer_interval
)
SELECT
  RTRIM(ammps.nm_space) namespace,
  au.id_usage_interval id_interval,
  ammps.id_acc,
  avi.c_currency invoice_currency,
  SUM(CASE WHEN pvpay.id_sess IS NULL THEN 0 ELSE ISNULL(au.amount,0) END) payment_ttl_amt,
  0, --postbill_adj_ttl_amt
  SUM(CASE WHEN pvar.id_sess IS NULL THEN 0 ELSE ISNULL(au.amount,0) END) ar_adj_ttl_amt,
  0, --previous_balance
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
	(ISNULL(au.Tax_Federal,0.0)) ELSE 0 END) +
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
	(ISNULL(au.Tax_State,0.0))ELSE 0 END) +
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
	(ISNULL(au.Tax_County,0.0))ELSE 0 END) +
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
	(ISNULL(au.Tax_Local,0.0))ELSE 0 END) +
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
	(ISNULL(au.Tax_Other,0.0))ELSE 0 END) tax_ttl_amt,
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL AND NOT vh.id_view IS NULL) THEN
   ISNULL(au.Amount, 0.0) -
   /*If implied taxes, then taxes are already included, don't add them again */
   ((CASE WHEN (au.is_implied_tax = 'Y') THEN (ISNULL(au.Tax_Federal,0.0) + ISNULL(au.Tax_State,0.0) +
          ISNULL(au.Tax_County,0.0) + ISNULL(au.Tax_Local,0.0) + ISNULL(au.Tax_Other,0.0)) ELSE 0 END)
/*If informational taxes, then they shouldn't be in the total */
    + (CASE WHEN (au.tax_informational = 'Y') THEN (ISNULL(au.Tax_Federal,0.0) + ISNULL(au.Tax_State,0.0) +
          ISNULL(au.Tax_County,0.0) + ISNULL(au.Tax_Local,0.0) + ISNULL(au.Tax_Other,0.0)) ELSE 0 END))
		  ELSE 0 END) current_charges,
  CASE WHEN avi.c_billable = '0' THEN pr.id_payer ELSE ammps.id_acc END id_payer,
  CASE WHEN avi.c_billable = '0' THEN auipay.id_usage_interval ELSE au.id_usage_interval END id_payer_interval
FROM  #tmp_all_accounts tmpall
INNER JOIN t_av_internal avi WITH(READCOMMITTED) ON avi.id_acc = tmpall.id_acc
INNER JOIN t_account_mapper ammps WITH(INDEX(t_account_mapper_idx1))ON ammps.id_acc = tmpall.id_acc
INNER JOIN t_namespace ns ON ns.nm_space = ammps.nm_space
	AND ns.tx_typ_space = 'system_mps'
INNER JOIN t_acc_usage_interval aui ON aui.id_acc = tmpall.id_acc
INNER JOIN t_usage_interval ui ON aui.id_usage_interval = ui.id_interval
	AND ui.id_interval IN (SELECT id_usage_interval
                                               FROM t_billgroup
                                               WHERE id_billgroup = @id_billgroup)/*= @id_interval*/
INNER JOIN t_payment_redirection pr WITH(READCOMMITTED) ON tmpall.id_acc = pr.id_payee
	AND ui.dt_end BETWEEN pr.vt_start AND pr.vt_end
INNER JOIN t_acc_usage_interval auipay ON auipay.id_acc = pr.id_payer
INNER JOIN t_usage_interval uipay ON auipay.id_usage_interval = uipay.id_interval
        AND ui.dt_end BETWEEN CASE WHEN auipay.dt_effective IS NULL THEN uipay.dt_start ELSE DATEADD(s, 1, auipay.dt_effective) END AND uipay.dt_end

LEFT OUTER JOIN
(SELECT au1.id_usage_interval, au1.amount, au1.Tax_Federal, au1.Tax_State, au1.Tax_County, au1.Tax_Local, au1.Tax_Other, au1.id_sess, au1.id_acc,
    au1.id_view, au1.is_implied_tax, au1.tax_informational
FROM t_acc_usage au1
LEFT OUTER JOIN t_pi_template piTemplated2
ON piTemplated2.id_template=au1.id_pi_template
LEFT OUTER JOIN t_base_props pi_type_props ON pi_type_props.id_prop=piTemplated2.id_pi
LEFT OUTER JOIN t_enum_data enumd2 ON au1.id_view=enumd2.id_enum_data
AND (pi_type_props.n_kind IS NULL OR pi_type_props.n_kind <> 15 OR (enumd2.nm_enum_data) NOT LIKE '%_TEMP')

WHERE au1.id_sess BETWEEN @id_sess_min AND @id_sess_max
AND au1.id_parent_sess IS NULL
AND au1.id_usage_interval IN (SELECT id_usage_interval
                                                 FROM t_billgroup
                                                 WHERE id_billgroup = @id_billgroup) /*= @id_interval*/
AND ((au1.id_pi_template IS NULL AND au1.id_parent_sess IS NULL) OR (au1.id_pi_template IS NOT NULL AND piTemplated2.id_template_parent IS NULL))
) au ON

	au.id_acc = tmpall.id_acc
-- join with the tables used for calculating the sums
LEFT OUTER JOIN t_view_hierarchy vh
	ON au.id_view = vh.id_view
	AND vh.id_view = vh.id_view_parent
LEFT OUTER JOIN t_pv_aradjustment pvar ON pvar.id_sess = au.id_sess AND au.id_usage_interval=pvar.id_usage_interval
LEFT OUTER JOIN t_pv_payment pvpay ON pvpay.id_sess = au.id_sess AND au.id_usage_interval=pvpay.id_usage_interval
-- non-join conditions
WHERE
(@exclude_billable = '0' OR avi.c_billable = '0')
GROUP BY ammps.nm_space, ammps.id_acc, au.id_usage_interval, avi.c_currency, pr.id_payer, auipay.id_usage_interval, avi.c_billable


SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
---------------------------------------------------------------

-- populate #tmp_adjustments with postbill and prebill adjustments
INSERT INTO #tmp_adjustments
 ( id_acc,
   PrebillAdjAmt,
   PrebillTaxAdjAmt,
   PostbillAdjAmt,
   PostbillTaxAdjAmt
 )
SELECT ISNULL(adjtrx.id_acc, #tmp_all_accounts.id_acc) id_acc,
       ISNULL(PrebillAdjAmt, 0) PrebillAdjAmt,
       ISNULL(PrebillTaxAdjAmt, 0) PrebillTaxAdjAmt,
       ISNULL(PostbillAdjAmt, 0) PostbillAdjAmt,
       ISNULL(PostbillTaxAdjAmt, 0) PostbillTaxAdjAmt
  FROM vw_adjustment_summary adjtrx
   INNER JOIN t_billgroup_member bgm ON bgm.id_acc = adjtrx.id_acc
   FULL OUTER JOIN #tmp_all_accounts ON adjtrx.id_acc = #tmp_all_accounts.id_acc
   WHERE bgm.id_billgroup = @id_billgroup AND
   adjtrx.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
		                            WHERE id_billgroup = @id_billgroup)
  /* where adjtrx.id_usage_interval = @id_interval*/

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

END

ELSE

-- else datamarts are being used.
-- join against t_mv_payer_interval
BEGIN

INSERT INTO #tmp_acc_amounts
  (namespace,
  id_interval,
  id_acc,
  invoice_currency,
  payment_ttl_amt,
  postbill_adj_ttl_amt,
  ar_adj_ttl_amt,
  previous_balance,
  tax_ttl_amt,
  current_charges,
  id_payer,
  id_payer_interval
)

SELECT

  RTRIM(ammps.nm_space) namespace,
  dm.id_usage_interval id_interval,
  tmpall.id_acc, -- changed
  avi.c_currency invoice_currency,
  SUM(CASE WHEN ed.nm_enum_data = 'metratech.com/Payment' THEN ISNULL(dm.TotalAmount, 0) ELSE 0 END) payment_ttl_amt,
  0, --postbill_adj_ttl_amt
  SUM(CASE WHEN ed.nm_enum_data = 'metratech.com/ARAdjustment' THEN ISNULL(dm.TotalAmount, 0) ELSE 0 END) ar_adj_ttl_amt,
  0, --previous_balance
  SUM(CASE WHEN (ed.nm_enum_data <> 'metratech.com/Payment'
                 AND ed.nm_enum_data <> 'metratech.com/ARAdjustment')
           THEN
           (ISNULL(dm.TotalTax,0.0))
           ELSE 0
           END),  --tax_ttl_amt
  SUM(CASE WHEN (ed.nm_enum_data <> 'metratech.com/Payment'
		AND ed.nm_enum_data <> 'metratech.com/ARAdjustment')
		/*Subtract out implied taxes and informational taxes, then add back their intersection, because it would have been subtracted twice*/
        THEN  (ISNULL(dm.TotalAmount, 0.0) - ISNULL(dm.TotalImpliedTax, 0.0) - ISNULL(dm.TotalInformationalTax, 0.0) + ISNULL(dm.TotalImplInfTax, 0.0))
	    ELSE 0
      END) current_charges,
  CASE WHEN avi.c_billable = '0'
       THEN pr.id_payer
       ELSE tmpall.id_acc
       END id_payer,
  CASE WHEN avi.c_billable = '0'
       THEN auipay.id_usage_interval
       ELSE dm.id_usage_interval
       END id_payer_interval

FROM  #tmp_all_accounts tmpall

-- added
INNER JOIN t_av_internal avi
ON avi.id_acc = tmpall.id_acc

-- Select accounts which are of type 'system_mps'
INNER JOIN t_account_mapper ammps WITH(INDEX(t_account_mapper_idx1))
ON ammps.id_acc = tmpall.id_acc

INNER JOIN t_namespace ns
ON ns.nm_space = ammps.nm_space
   AND ns.tx_typ_space = 'system_mps'

-- Select accounts which belong
-- to the given usage interval
INNER JOIN t_acc_usage_interval aui
ON aui.id_acc = tmpall.id_acc

INNER JOIN t_usage_interval ui
ON aui.id_usage_interval = ui.id_interval
	AND ui.id_interval IN (SELECT id_usage_interval
                           FROM t_billgroup
                           WHERE id_billgroup = @id_billgroup)/*= @id_interval*/

--
INNER JOIN t_payment_redirection pr
ON tmpall.id_acc = pr.id_payee
   AND ui.dt_end BETWEEN pr.vt_start AND pr.vt_end

INNER JOIN t_acc_usage_interval auipay
ON auipay.id_acc = pr.id_payer

INNER JOIN t_usage_interval uipay
ON auipay.id_usage_interval = uipay.id_interval
   AND ui.dt_end BETWEEN
     CASE WHEN auipay.dt_effective IS NULL
          THEN uipay.dt_start
          ELSE DATEADD(s, 1, auipay.dt_effective)
          END
     AND uipay.dt_end

LEFT OUTER JOIN t_mv_payer_interval dm
ON dm.id_acc = tmpall.id_acc AND dm.id_usage_interval IN (SELECT id_usage_interval
														  FROM t_billgroup
							                              WHERE id_billgroup = @id_billgroup) /*= @id_interval*/
LEFT OUTER JOIN t_enum_data ed
ON dm.id_view = ed.id_enum_data

-- non-join conditions
WHERE
(@exclude_billable = '0' OR avi.c_billable = '0')
GROUP BY  ammps.nm_space, tmpall.id_acc, dm.id_usage_interval, avi.c_currency, pr.id_payer, auipay.id_usage_interval, avi.c_billable

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

-- populate #tmp_adjustments with postbill and prebill adjustments
INSERT INTO #tmp_adjustments
 ( id_acc,
   PrebillAdjAmt,
   PrebillTaxAdjAmt,
   PostbillAdjAmt,
   PostbillTaxAdjAmt
 )
SELECT ISNULL(adjtrx.id_acc, #tmp_all_accounts.id_acc) id_acc,
       ISNULL(PrebillAdjAmt, 0) PrebillAdjAmt,
       ISNULL(PrebillTaxAdjAmt, 0) PrebillTaxAdjAmt,
       ISNULL(PostbillAdjAmt, 0) PostbillAdjAmt,
       ISNULL(PostbillTaxAdjAmt, 0) PostbillTaxAdjAmt
  FROM vw_adjustment_summary adjtrx
  INNER JOIN t_billgroup_member bgm ON bgm.id_acc = adjtrx.id_acc
  FULL OUTER JOIN #tmp_all_accounts ON adjtrx.id_acc = #tmp_all_accounts.id_acc
  WHERE bgm.id_billgroup = @id_billgroup AND
   adjtrx.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
		                            WHERE id_billgroup = @id_billgroup)

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

END

-- populate #tmp_prev_balance with the previous balance
INSERT INTO #tmp_prev_balance
  (id_acc,
  previous_balance)
SELECT id_acc, CONVERT(DECIMAL(22,10), SUBSTRING(comp,CASE WHEN PATINDEX('%-%',comp) = 0 THEN 10 ELSE PATINDEX('%-%',comp) END,28)) previous_balance
FROM 	(SELECT inv.id_acc,
ISNULL(MAX(CONVERT(CHAR(8),ui.dt_end,112)+
			REPLICATE('0',20-LEN(inv.current_balance)) +
			CONVERT(CHAR,inv.current_balance)),'00000000000') comp
	FROM t_invoice inv
	INNER JOIN t_usage_interval ui ON ui.id_interval = inv.id_interval
	INNER JOIN #tmp_all_accounts ON inv.id_acc = #tmp_all_accounts.id_acc
	GROUP BY inv.id_acc) maxdtend

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

IF (@debug_flag = 1  AND @id_run IS NOT NULL)
  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
    VALUES (@id_run, 'Debug', 'Invoice-Bal: Completed successfully', GETUTCDATE())

SET @return_code = 0

RETURN 0

FatalError:
  IF @ErrMsg IS NULL
    SET @ErrMsg = 'Invoice-Bal: Stored procedure failed'
  IF (@debug_flag = 1  AND @id_run IS NOT NULL)
    INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
      VALUES (@id_run, 'Debug', @ErrMsg, GETUTCDATE())

  SET @return_code = -1

  RETURN -1

END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[amp_sorted_decisions]'
GO
EXEC sp_refreshview N'[dbo].[amp_sorted_decisions]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[account_qualification_groups]'
GO
EXEC sp_refreshview N'[dbo].[account_qualification_groups]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[agg_param_table_col_map]'
GO
EXEC sp_refreshview N'[dbo].[agg_param_table_col_map]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[agg_param_table_master]'
GO
EXEC sp_refreshview N'[dbo].[agg_param_table_master]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[T_VW_GET_ACCOUNTS_BY_TMPL_ID]'
GO
EXEC sp_refreshview N'[dbo].[T_VW_GET_ACCOUNTS_BY_TMPL_ID]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[LeastDate]'
GO
CREATE FUNCTION [dbo].[LeastDate](@val1 DATETIME, @val2 DATETIME) RETURNS DATETIME
AS
BEGIN
	RETURN CASE WHEN @val1 < @val2 THEN @val1 WHEN @val2 IS NULL THEN @val1 ELSE @val2 END
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[GreatestDate]'
GO
CREATE FUNCTION [dbo].[GreatestDate](@val1 DATETIME, @val2 DATETIME) RETURNS DATETIME
AS
BEGIN
	RETURN CASE WHEN @val1 > @val2 THEN @val1 WHEN @val2 IS NULL THEN @val1 ELSE @val2 END
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[subscribe_account]'
GO

CREATE PROCEDURE subscribe_account 
(
   @id_acc              int,
   @id_po               int,
   @id_group            int,
   @sub_start           datetime,
   @sub_end             datetime,
   @systemdate          datetime
)
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @v_guid      uniqueidentifier
	DECLARE @curr_id_sub int
	DECLARE @maxdate     datetime

	SET @maxdate = dbo.MTMaxDate()

	IF @id_group IS NOT NULL
	BEGIN
		INSERT INTO #tmp_gsubmember (id_group, id_acc, vt_start, vt_end)
			VALUES (@id_group, @id_acc, @sub_start, @sub_end)
	END
	ELSE
	BEGIN
		EXEC GetCurrentID 'id_subscription', @curr_id_sub OUT
		SELECT @v_guid = NEWID()
		INSERT INTO #tmp_sub (id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end)
			VALUES (@curr_id_sub, @v_guid, @id_acc, NULL, @id_po, @systemdate, @sub_start, @sub_end)
	END

END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[apply_subscriptions_to_acc]'
GO


CREATE PROCEDURE apply_subscriptions_to_acc (
    @id_acc                     int,
    @id_acc_template            int,
    @next_cycle_after_startdate char, /* Y or N */
    @next_cycle_after_enddate   char, /* Y or N */
    @user_id                    int,
    @id_audit                   int,
    @id_event_success           int,
    @systemdate                 datetime,
    @id_template_session        int,
    @retrycount                 int,
    @detailtypesubs             int,
    @detailresultfailure        int
)
AS
    SET NOCOUNT ON
    DECLARE @v_vt_start        datetime
    DECLARE @v_vt_end          datetime
    DECLARE @v_acc_start       datetime
    DECLARE @v_sub_end         datetime
    DECLARE @curr_id_sub       int
    DECLARE @my_id_audit       int
    DECLARE @my_user_id        int
	DECLARE @id_acc_type       int

    SELECT @my_user_id = ISNULL(@user_id, 1), @my_id_audit = @id_audit
	SELECT @id_acc_type = id_type FROM t_account WHERE id_acc = @id_acc

    IF @my_id_audit IS NULL
    BEGIN
        EXEC getcurrentid 'id_audit', @my_id_audit OUT

        INSERT INTO t_audit
                    (id_audit, id_event, id_userid, id_entitytype, id_entity, dt_crt
                    )
            VALUES (@my_id_audit, @id_event_success, @user_id, 1, @id_acc, getutcdate ()
                    )
    END

    SELECT @v_acc_start = vt_start
    FROM   t_account_state
    WHERE  id_acc = @id_acc
    
    DECLARE @id_po            int
    DECLARE @id_group         int
    DECLARE @vt_start         datetime
    DECLARE @vt_end           datetime
    DECLARE @conflicts        int
    DECLARE @my_sub_start     datetime
    DECLARE @my_sub_end       datetime
    
    DECLARE subs CURSOR LOCAL FOR
		SELECT  id_po,
				id_group,
				dbo.GreatestDate(t1.v_sub_start, @v_acc_start) AS vt_start,
				t1.v_sub_end,
				dbo.GreatestDate(t1.v_sub_start, @v_acc_start) AS v_sub_start,
				t1.v_sub_end
			FROM (
				SELECT
					id_po,
					id_group,
					CASE
						WHEN @next_cycle_after_startdate = 'Y'
						THEN
							(
								SELECT dbo.GreatestDate(DATEADD(s, 1, tpc.dt_end), tvs.po_start)
									FROM   t_pc_interval tpc
									INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
									WHERE  tauc.id_acc = @id_acc
									AND tvs.sub_start BETWEEN tpc.dt_start AND tpc.dt_end
							)
						ELSE tvs.sub_start
					END AS v_sub_start,
					CASE
						WHEN @next_cycle_after_enddate = 'Y'
						THEN
							(
								SELECT dbo.LeastDate(dbo.LeastDate(DATEADD(s, 1, tpc.dt_end), dbo.MTMaxDate()), tvs.po_end)
									FROM   t_pc_interval tpc
									INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
									WHERE  tauc.id_acc = @id_acc
									AND tvs.sub_end BETWEEN tpc.dt_start AND tpc.dt_end
							)
						ELSE tvs.sub_end
					END AS v_sub_end
					FROM #t_acc_template_valid_subs tvs
			) t1
--            WHERE tvs.id_acc_template_session = apply_subscriptions_to_acc.id_template_session


    --  SELECT ts.id_po,
    --         ts.id_group,
    --         dbo.GreatestDate(dbo.LeastDate(MIN(s.vt_start), MIN(gm.vt_start)), @v_acc_start) AS vt_start,
    --         dbo.GreatestDate(MAX(s.vt_end), MAX(gm.vt_end)) AS vt_end,
    --         SUM(CASE WHEN s.id_sub IS NULL THEN 0 ELSE 1 END) + SUM(CASE WHEN gm.id_group IS NULL THEN 0 ELSE 1 END) conflicts,
    --         vs.v_sub_start AS my_sub_start,
    --         vs.v_sub_end AS my_sub_end
    --  FROM   t_acc_template_subs ts
    --         JOIN (
    --                SELECT id_po,
    --                       id_group,
    --                        CASE
    --                           WHEN @next_cycle_after_startdate = 'Y'
    --                           THEN
    --                               (
    --                                 SELECT dbo.GreatestDate(DATEADD(s, 1, tpc.dt_end), tvs.po_start)
    --                                 FROM   t_pc_interval tpc
    --                                        INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
    --                                 WHERE  tauc.id_acc = @id_acc
    --                                    AND tvs.sub_start BETWEEN tpc.dt_start AND tpc.dt_end
    --                               )
    --                           ELSE tvs.sub_start
    --                       END AS v_sub_start,
    --                       CASE
    --                           WHEN @next_cycle_after_enddate = 'Y'
    --                           THEN
    --                               (
    --                                 SELECT dbo.LeastDate(dbo.LeastDate(DATEADD(s, 1, tpc.dt_end), dbo.MTMaxDate()), tvs.po_end)
    --                                 FROM   t_pc_interval tpc
    --                                        INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
    --                                 WHERE  tauc.id_acc = @id_acc
    --                                    AND tvs.sub_end BETWEEN tpc.dt_start AND tpc.dt_end
    --                               )
    --                           ELSE tvs.sub_end
    --                       END AS v_sub_end

    --                FROM   #t_acc_template_valid_subs tvs
    --         ) vs ON vs.id_po = ts.id_po OR vs.id_group = ts.id_group
    --         LEFT JOIN t_sub gs ON gs.id_group = ts.id_group
    --         LEFT JOIN t_sub s
    --          ON     s.id_acc = @id_acc
    --             AND s.vt_start <= vs.v_sub_end
    --             AND s.vt_end >= vs.v_sub_start
    --             AND EXISTS (SELECT 1
    --                         FROM   t_pl_map mpo
    --                                JOIN t_pl_map ms ON mpo.id_pi_template = ms.id_pi_template
    --                         WHERE  mpo.id_po = ISNULL(ts.id_po, gs.id_po) AND ms.id_po = s.id_po)
    --         LEFT JOIN t_gsubmember gm
    --          ON     gm.id_acc = @id_acc
    --             AND gm.vt_start <= vs.v_sub_end
    --             AND gm.vt_end >= vs.v_sub_start
    --             AND EXISTS (SELECT 1
    --                         FROM   t_sub ags
    --                                JOIN t_pl_map ms ON ms.id_po = ags.id_po
    --                                JOIN t_pl_map mpo ON mpo.id_pi_template = ms.id_pi_template
    --                         WHERE  ags.id_group = gm.id_group AND mpo.id_po = ISNULL(ts.id_po, gs.id_po))
    --  WHERE  ts.id_acc_template = @id_acc_template
	   --  /* Check if the PO is available for the account's type */
	   --  AND (  (ts.id_po IS NOT NULL AND
		  --        (  EXISTS
		  --           (
				--        SELECT 1
				--	    FROM   t_po_account_type_map atm
				--	    WHERE  atm.id_po = ts.id_po AND atm.id_account_type = @id_acc_type
				--     )
				--  OR NOT EXISTS
				--     (
				--	     SELECT 1 FROM t_po_account_type_map atm WHERE atm.id_po = ts.id_po
				--	 )
				-- )
				--)
		  --   OR (ts.id_group IS NOT NULL AND
			 --     (  EXISTS
			 --        (
				--        SELECT 1
				--	    FROM   t_po_account_type_map atm
				--	           JOIN t_sub tgs ON tgs.id_po = atm.id_po
				--	    WHERE  tgs.id_group = ts.id_group AND atm.id_account_type = @id_acc_type
				--     )
				-- OR NOT EXISTS
				--     (
				--		SELECT 1
				--	    FROM   t_po_account_type_map atm
				--	           JOIN t_sub tgs ON tgs.id_po = atm.id_po
				--	    WHERE  tgs.id_group = ts.id_group
				--	 )
				--  )
				--)
		  --   )
    --  GROUP BY ts.id_po, ts.id_group, vs.v_sub_start, vs.v_sub_end
    
    OPEN subs
    FETCH NEXT FROM subs INTO @id_po, @id_group, @vt_start, @vt_end, @my_sub_start, @my_sub_end

    /* Create new subscriptions */
    WHILE @@FETCH_STATUS = 0
    BEGIN
		DECLARE @v_prev_end DATETIME
		DECLARE @c_vt_start DATETIME
		DECLARE @c_vt_end DATETIME
		SET @v_prev_end = DATEADD(d, -1, @my_sub_start)
		DECLARE csubs CURSOR FOR
            SELECT s.vt_start, s.vt_end
                FROM t_sub s
                WHERE s.vt_end >= @my_sub_start 
                    AND s.vt_start <= @my_sub_end
                    AND s.id_acc = @id_acc
                    AND s.id_po = @id_po
                ORDER BY s.vt_start

		OPEN csubs
		FETCH NEXT FROM csubs INTO @c_vt_start, @c_vt_end

		WHILE @@FETCH_STATUS = 0
		BEGIN
            IF @c_vt_start > @v_prev_end 
			BEGIN
                SET @v_vt_start = DATEADD(d, 1, @v_prev_end)
                SET @v_vt_end = DATEADD(d, -1, @c_vt_start)
            END
            IF @v_vt_start <= @v_vt_end
			BEGIN
                EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
            END
            SET @v_prev_end = @c_vt_end

			FETCH NEXT FROM csubs INTO @c_vt_start, @c_vt_end
		END 
		CLOSE csubs
		DEALLOCATE csubs
        IF @v_prev_end < @my_sub_end
		BEGIN
            SET @v_vt_start = DATEADD(d,1,@v_prev_end)
            SET @v_vt_end = @my_sub_end
                EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
        END

        --/* 1.  There is no conflicting subscription */
        --IF @conflicts = 0
        --BEGIN
        --    SELECT @v_vt_start = @my_sub_start, @v_vt_end = @my_sub_end
            
        --    EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
        --END
        --/* 2.  There is a conflicting subscription for the same or greatest interval */
        --ELSE IF @my_sub_start >= @vt_start AND @my_sub_end <= @vt_end
        --BEGIN
        --    INSERT INTO t_acc_template_session_detail
        --        (
        --            id_session,
        --            n_detail_type,
        --            n_result,
        --            dt_detail,
        --            nm_text,
        --            n_retry_count
        --        )
        --    VALUES
        --        (
        --            @id_template_session,
        --            @detailtypesubs,
        --            @detailresultfailure,
        --            getdate(),
        --            N'Subscription for account ' + CAST(@id_acc AS nvarchar(10)) + N' not created due to ' + CAST(@conflicts AS nvarchar(10)) + N'conflict' + CASE WHEN @conflicts > 1 THEN 's' ELSE '' END,
        --            @retrycount
        --        )
        --END
        --/* 3.  There is a conflicting subscription for an early period */
        --ELSE IF @my_sub_start >= @vt_start AND @my_sub_end > @vt_end
        --BEGIN
        --    SELECT @v_vt_start = DATEADD(d, 1, @vt_end), @v_vt_end = @my_sub_end
            
        --    EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
        --END
        --/* 4.  There is a conflicting subscription for a late period */
        --ELSE IF @my_sub_start < @vt_start AND @my_sub_end <= @vt_end
        --BEGIN
        --    SELECT @v_vt_start = @my_sub_start, @v_vt_end = DATEADD(d, -1, @vt_start)
            
        --    EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
        --END
        --/* 5.  There is a conflicting subscription for the period inside the indicated one */
        --ELSE
        --BEGIN
        --    SELECT @v_vt_start = DATEADD(d, 1, @vt_end), @v_vt_end = @my_sub_end
            
        --    EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate

        --    SELECT @v_vt_start = @my_sub_start, @v_vt_end = DATEADD(d, -1, @vt_start)
            
        --    EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
        --END

        FETCH NEXT FROM subs INTO @id_po, @id_group, @vt_start, @vt_end, @my_sub_start, @my_sub_end
    END

    CLOSE subs
    DEALLOCATE subs
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[apply_subscriptions]'
GO
CREATE PROCEDURE apply_subscriptions (
   @template_id                int,
   @sub_start                  datetime,
   @sub_end                    datetime,
   @next_cycle_after_startdate char, /* Y or N */
   @next_cycle_after_enddate   char, /* Y or N */
   @user_id                    int,
   @id_audit                   int,
   @id_event_success           int,
   @id_event_failure           int,
   @systemdate                 datetime,
   @id_template_session        int,
   @retrycount                 int,
   @doCommit				   char = 'Y' /* Y or N */
)
AS
	SET NOCOUNT ON
	DECLARE @my_id_audit         int
	DECLARE @my_error            nvarchar(1024)
	DECLARE @detailtypesubs      int
	DECLARE @detailresultfailure int
	
	SELECT @my_id_audit = @id_audit
	IF @my_id_audit IS NULL
	BEGIN
		DECLARE @audit_msg       nvarchar(256)
		DECLARE @dt_timestamp    datetime
		SET @audit_msg = N'Apply subscriptions from template ' + CAST(@template_id AS nvarchar)
		SET @dt_timestamp = GETDATE()
		EXEC GetCurrentID 'id_audit', @my_id_audit OUT
		EXEC insertauditevent
			@id_userid           = NULL,
			@id_event            = 1451,
			@id_entity_type      = 2,
			@id_entity           = @template_id,
			@dt_timestamp        = @dt_timestamp,
			@id_audit            = @my_id_audit,
			@tx_details          = @audit_msg,
			@tx_logged_in_as     = NULL,
			@tx_application_name = NULL
	END

	SELECT @detailtypesubs = id_enum_data
	FROM   t_enum_data
	WHERE  nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription'
		 
	SELECT @detailresultfailure = id_enum_data
	FROM  t_enum_data
	WHERE  nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Failure'
  
	IF object_id('tempdb..#t_acc_template_valid_subs') IS NOT NULL
		DROP TABLE #t_acc_template_valid_subs
	
	CREATE TABLE #t_acc_template_valid_subs
	(
		id_po     int,
		id_group  int,
		sub_start datetime,
		sub_end   datetime,
		po_start  datetime,
		po_end    datetime
	)

	CREATE TABLE #tmp_gsubmember
	(
		id_group int,
		id_acc int,
		vt_start datetime,
		vt_end datetime
	)

	CREATE TABLE #tmp_sub
	(
		id_sub	int,
		id_sub_ext	varbinary(16),
		id_acc	int,
		id_po	int,
		dt_crt	datetime,
		vt_start	datetime,
		vt_end	datetime,
		id_group	int
	)

	create index #t_acc_template_valid_subs_ix1 on #t_acc_template_valid_subs(id_po)
	create index #t_acc_template_valid_subs_ix2 on #t_acc_template_valid_subs(id_group)
  
	/* Detect conflicting subscriptions in the template and choice first available of them and without conflicts */
	INSERT INTO #t_acc_template_valid_subs (id_po, id_group, sub_start, sub_end, po_start, po_end)
	SELECT DISTINCT
	       subs.id_po,
		   subs.id_group,
		   dbo.GreatestDate(@sub_start, subs.sub_start),
		   dbo.LeastDate(@sub_end, subs.sub_end),
		   subs.sub_start,
		   subs.sub_end
	FROM
	(
		SELECT t1.id_po
				, MAX(t1.id_group) AS id_group
				, MAX(ed.dt_start) AS sub_start
				, ISNULL(MAX(ed.dt_end), dbo.MTMaxDate()) AS sub_end
			FROM (
				SELECT ISNULL(ts.id_po,s.id_po) AS id_po, s.id_group
					FROM t_acc_template_subs ts
					LEFT JOIN t_sub s ON s.id_group = ts.id_group
					WHERE ts.id_acc_template = @template_id
			) t1
			JOIN t_po po ON po.id_po = t1.id_po
			JOIN t_effectivedate ed ON po.id_eff_date = ed.id_eff_date
			GROUP BY t1.id_po

/*
		SELECT MAX(ts.id_po) AS id_po, NULL AS id_group, ISNULL(MAX(ed.dt_start), @systemdate) AS sub_start, ISNULL(MAX(ed.dt_end), dbo.MTMaxDate()) AS sub_end
		FROM   t_acc_template_subs ts
			   JOIN t_pl_map pm ON pm.id_po = ts.id_po
			   JOIN t_po po ON ts.id_po = po.id_po
			   JOIN t_effectivedate ed ON po.id_eff_date = ed.id_eff_date
		WHERE  ts.id_acc_template = @template_id
		GROUP BY pm.id_pi_template
		UNION ALL
		SELECT NULL AS id_po, MAX(ts.id_group) AS id_group, ISNULL(MAX(ed.dt_start), @systemdate) AS sub_start, ISNULL(MAX(ed.dt_end), dbo.MTMaxDate()) AS sub_end
		FROM   t_acc_template_subs ts
			   JOIN t_sub s ON s.id_group = ts.id_group
			   JOIN t_pl_map pm ON pm.id_po = s.id_po
			   JOIN t_po po ON po.id_po = s.id_po
			   JOIN t_effectivedate ed ON po.id_eff_date = ed.id_eff_date
		WHERE  ts.id_acc_template = @template_id
		GROUP BY pm.id_pi_template
*/
	) subs

	DECLARE @id_acc  int
	DECLARE accounts CURSOR LOCAL FOR
		SELECT id_descendent AS id_acc
		FROM   t_vw_get_accounts_by_tmpl_id v
		WHERE  v.id_template = @template_id

	OPEN accounts
	FETCH NEXT FROM accounts INTO @id_acc

	/* Applying subscriptions to accounts */
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC apply_subscriptions_to_acc
			@id_acc                     = @id_acc,
			@id_acc_template            = @template_id,
			@next_cycle_after_startdate = @next_cycle_after_startdate,
			@next_cycle_after_enddate   = @next_cycle_after_enddate,
			@user_id                    = @user_id,
			@id_audit                   = @my_id_audit,
			@id_event_success           = @id_event_success,
			@systemdate                 = @systemdate,
			@id_template_session        = @id_template_session,
			@retrycount                 = @retrycount,
			@detailtypesubs             = @detailtypesubs,
			@detailresultfailure        = @detailresultfailure
		
		FETCH NEXT FROM accounts INTO @id_acc
	END
	
	CLOSE accounts
	DEALLOCATE accounts

	DECLARE @maxdate datetime
	SELECT @maxdate = dbo.MTMaxDate()

	IF @doCommit = 'Y' BEGIN
		BEGIN TRAN t2
	END

	BEGIN TRY
		/* Persist the data in transaction */
		INSERT INTO t_gsubmember(id_group, id_acc, vt_start, vt_end)
		SELECT id_group, id_acc, vt_start, vt_end
		FROM   #tmp_gsubmember

		--INSERT INTO t_gsubmember_historical (id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
		--SELECT id_group, id_acc, vt_start, vt_end, @systemdate, @maxdate
		--FROM   #tmp_gsubmember

		INSERT INTO t_sub (id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end)
		SELECT id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end
		FROM   #tmp_sub

		--INSERT INTO t_sub_history
		--	  (id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end, tt_start, tt_end)
		--SELECT id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end, @systemdate, @maxdate
		--FROM   #tmp_sub

		INSERT INTO t_audit_details (id_audit, tx_details)
		SELECT @my_id_audit,
			   N'Added subscription to id_groupsub ' + CAST(id_group AS nvarchar(10)) +
			   N' for account ' + CAST(id_acc AS nvarchar(10)) +
			   N' from ' + CAST(vt_start AS nvarchar(20)) +
			   N' to ' + CAST(vt_end AS nvarchar(20)) +
			   N' on ' + CAST(@systemdate AS nvarchar(20))
		FROM   #tmp_gsubmember
		UNION ALL
		SELECT @my_id_audit,
			   N'Added subscription to product offering ' + CAST(id_po AS nvarchar(10)) +
			   N' for account ' + CAST(id_acc AS nvarchar) +
			   N' from ' + CAST(vt_start AS nvarchar(20)) +
			   N' to ' + CAST(vt_end AS nvarchar(20)) +
			   N' on ' + CAST(@systemdate AS nvarchar(20))
		FROM   #tmp_sub

		IF @doCommit = 'Y' BEGIN
			COMMIT
		END
	END TRY
	BEGIN CATCH
		-- we should log this.
		IF @doCommit = 'Y' BEGIN
			ROLLBACK
		END
		 
		SELECT @my_error = substring(error_message(), 1, 1024)

		IF @my_id_audit IS NULL
		BEGIN
			IF @id_audit IS NOT NULL
			BEGIN
				SELECT @my_id_audit = @id_audit
			END
			ELSE
			BEGIN
				EXEC getcurrentid 'id_audit', @my_id_audit OUT

				INSERT INTO t_audit (
					id_audit,
					id_event,
					id_userid,
					id_entitytype,
					id_entity,
					dt_crt
					)
				VALUES (
					@my_id_audit,
					@id_event_failure,
					@user_id,
					1,
					@id_acc,
					getutcdate ()
					)
			END
		END

		INSERT INTO t_audit_details (
			id_audit,
			tx_details
			)
		VALUES (
			@my_id_audit,
			'Error applying template to id_acc: ' + CAST(@id_acc AS nvarchar(10)) + ': ' + @my_error
			)
	END CATCH

	DROP TABLE #t_acc_template_valid_subs
	DROP TABLE #tmp_gsubmember
	DROP TABLE #tmp_sub
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Creating table-valued function [dbo].[fn_months]'
GO
CREATE FUNCTION [dbo].[fn_months]
(
)
RETURNS
@res TABLE (
	num INTEGER NOT NULL,
	name NVARCHAR(50) NOT NULL PRIMARY KEY
)
AS
BEGIN
	INSERT INTO @res(num, name)
		SELECT 1  as num, 'January'   as name UNION ALL
		SELECT 2  as num, 'February'  as name UNION ALL
		SELECT 3  as num, 'March'     as name UNION ALL
		SELECT 4  as num, 'April'     as name UNION ALL
		SELECT 5  as num, 'May'       as name UNION ALL
		SELECT 6  as num, 'June'      as name UNION ALL
		SELECT 7  as num, 'July'      as name UNION ALL
		SELECT 8  as num, 'August'    as name UNION ALL
		SELECT 9  as num, 'September' as name UNION ALL
		SELECT 10 as num, 'October'   as name UNION ALL
		SELECT 11 as num, 'November'  as name UNION ALL
		SELECT 12 as num, 'December'  as name

	RETURN
END
GO

IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Creating table-valued function [dbo].[fn_day_of_week]'
GO
CREATE FUNCTION [dbo].[fn_day_of_week]
(
)
RETURNS @res TABLE
(
	num INTEGER NOT NULL
	,name NVARCHAR(50) NOT NULL PRIMARY KEY
)
AS
BEGIN
	INSERT INTO @res (num, name)
		SELECT 1  as NUM, 'Sunday'    as NAME UNION ALL
		SELECT 2  as NUM, 'Monday'    as NAME UNION ALL
		SELECT 3  as NUM, 'Tuesday'   as NAME UNION ALL
		SELECT 4  as NUM, 'Wednesday' as NAME UNION ALL
		SELECT 5  as NUM, 'Thursday'  as NAME UNION ALL
		SELECT 6  as NUM, 'Friday'    as NAME UNION ALL
		SELECT 7  as NUM, 'Saturday'  as NAME
	RETURN
END
GO

IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Altering [dbo].[ApplyTemplateToAccounts]'
GO
ALTER  PROCEDURE ApplyTemplateToAccounts(
	@idAccountTemplate          int,
	@sub_start                  datetime,
	@sub_end                    datetime,
	@next_cycle_after_startdate char, /* Y or N */
	@next_cycle_after_enddate   char, /* Y or N */
	@user_id                    int,
	@id_event_success           int,
	@id_event_failure           int,
	@systemDate                 datetime,
	@sessionId                  int,
	@retrycount                 int,
	@account_id					int = NULL,
	@doCommit					char = 'Y'
)
as
	SET NOCOUNT ON

	DECLARE @errTbl TABLE (
		dt_detail datetime NOT NULL,
		nm_text nvarchar(4000) NOT NULL
	)

	DELETE FROM @errTbl

	IF @doCommit = 'Y'
	BEGIN
		BEGIN TRANSACTION T1
	END
	BEGIN TRY
		DECLARE @DetailTypeUpdate int
		SELECT @DetailTypeUpdate = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailType/Update'

		DECLARE @DetailResultSuccess int
		DECLARE @DetailResultFailure int
		SELECT @DetailResultFailure = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Failure'
		SELECT @DetailResultSuccess = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Success'

		declare @DetailTypeGeneral int
		declare @DetailResultInformation int
		declare @DetailTypeSubscription int


		SELECT @DetailTypeGeneral = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Success'
		SELECT @DetailResultInformation = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Information'
		SELECT @DetailTypeSubscription = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription'

		DECLARE @errorStr NVARCHAR(4000)

		EXEC UpdateAccPropsFromTemplate @idAccountTemplate, @account_id

		DECLARE @UsageCycleId INTEGER
		DECLARE @PayerId INTEGER

		SET @UsageCycleId = -1;

		SELECT @UsageCycleId = tuc.id_usage_cycle, @PayerId = tprop.PayerID
			FROM t_usage_cycle tuc
			RIGHT OUTER JOIN (
				SELECT 	tp.DayOfMonth
						,tp.StartDay
						,ISNULL(m.num,-1) StartMonth
						,tuct.id_cycle_type
						,ISNULL(dw.num,-1) DayOfWeek
						,tp.StartYear
						,tp.FirstDayOfMonth
						,tp.SecondDayOfMonth
						,tp.PayerID
					FROM (
						SELECT   MAX(CASE WHEN tatp.nm_prop = N'Account.DayOfMonth' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS DayOfMonth
								,MAX(CASE WHEN tatp.nm_prop = N'Account.DayOfWeek' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS DayOfWeek
								,MAX(CASE WHEN tatp.nm_prop = N'Account.StartDay' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS StartDay
								,MAX(CASE WHEN tatp.nm_prop = N'Account.StartMonth' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS StartMonth
								,MAX(CASE WHEN tatp.nm_prop = N'Account.StartYear' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS StartYear
								,MAX(CASE WHEN tatp.nm_prop = N'Account.FirstDayOfMonth' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS FirstDayOfMonth
								,MAX(CASE WHEN tatp.nm_prop = N'Account.SecondDayOfMonth' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS SecondDayOfMonth
								,MAX(CASE WHEN tatp.nm_prop = N'Internal.UsageCycleType' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS UsageCycleType
								,MAX(CASE WHEN tatp.nm_prop = N'Account.PayerID' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS PayerID
							FROM t_acc_template_props tatp
							WHERE tatp.id_acc_template = @idAccountTemplate
							GROUP BY tatp.id_acc_template
					) tp
					LEFT JOIN t_enum_data tedm ON tedm.id_enum_data = tp.StartMonth
					LEFT JOIN t_enum_data tedc ON tedc.id_enum_data = tp.UsageCycleType
					LEFT JOIN t_enum_data tedw ON tedw.id_enum_data = tp.DayOfWeek
					LEFT JOIN fn_months() m ON tedm.nm_enum_data LIKE '%' + m.name
					LEFT JOIN fn_day_of_week() dw ON tedw.nm_enum_data LIKE '%' + dw.name
					LEFT JOIN t_usage_cycle_type tuct ON UPPER(tuct.tx_desc) LIKE REPLACE(UPPER(SUBSTRING(tedc.nm_enum_data, LEN(tedc.nm_enum_data) - CHARINDEX('/',REVERSE(tedc.nm_enum_data))+2, CHARINDEX('/',REVERSE(tedc.nm_enum_data)))), '-', '%')
			) tprop ON tprop.DayOfMonth = ISNULL(tuc.day_of_month, tprop.DayOfMonth)
			  AND tprop.StartDay = ISNULL(tuc.start_day,tprop.StartDay)
			  AND tprop.StartMonth = ISNULL(tuc.start_month,tprop.StartMonth)
			  AND tprop.DayOfWeek = ISNULL(tuc.day_of_week,tprop.DayOfWeek)
			  AND tprop.StartYear = ISNULL(tuc.start_year,tprop.StartYear)
			  AND tprop.FirstDayOfMonth = ISNULL(tuc.first_day_of_month,tprop.FirstDayOfMonth)
			  AND tprop.SecondDayOfMonth = ISNULL(tuc.second_day_of_month,tprop.SecondDayOfMonth)
			  AND tuc.id_cycle_type = tprop.id_cycle_type

		DECLARE acc CURSOR FOR
		SELECT   ta.id_acc
				,tauc.id_usage_cycle
				,tpr.id_payee
				,tpr.id_payer
				,tpr.vt_start
				,tpr.vt_end
				,tavi.c_Currency
			FROM t_vw_get_accounts_by_tmpl_id va
			JOIN t_account ta ON ta.id_acc = va.id_descendent
			JOIN t_acc_usage_cycle tauc ON tauc.id_acc = ta.id_acc
			LEFT JOIN t_payment_redirection tpr ON tpr.id_payee = ta.id_acc
			LEFT JOIN t_av_Internal tavi ON tavi.id_acc = ta.id_acc
			WHERE va.id_template = @idAccountTemplate
				AND @systemDate BETWEEN COALESCE(va.vt_start, @systemDate) AND COALESCE(va.vt_end, @systemDate)
				AND (
					(@UsageCycleId <> -1 AND tauc.id_usage_cycle <> @UsageCycleId)
					OR (@PayerId <> -1 AND tpr.id_payee <> @PayerId)
				)
				AND ta.id_acc = ISNULL(@account_id, ta.id_acc)


		DECLARE @IdAcc INTEGER
		DECLARE @OldUsageCycle INTEGER
		DECLARE @PayeeId INTEGER
		DECLARE @OldPayerId INTEGER
		DECLARE @PaymentStart DATETIME
		DECLARE @PaymentEnd DATETIME
		DECLARE @p_status INTEGER
		DECLARE @oldpayerstart datetime
		DECLARE @oldpayerend datetime
		DECLARE @oldpayer int
		DECLARE @payerenddate datetime
		DECLARE @p_account_currency NVARCHAR(5)

		OPEN acc

		FETCH NEXT FROM acc INTO @IdAcc, @OldUsageCycle, @PayeeId, @OldPayerId, @PaymentStart, @PaymentEnd, @p_account_currency

		WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @errorStr = ''
			EXEC dbo.UpdateUsageCycleFromTemplate @IdAcc, @UsageCycleId, @OldUsageCycle, @systemDate, @errorStr OUTPUT
			IF @errorStr <> '' BEGIN
				INSERT INTO @errTbl(dt_detail, nm_text) VALUES(GETDATE(), @errorStr)
			END

			SET @errorStr = ''
			EXEC UpdatePayerFromTemplate
				@IdAcc = @IdAcc,
				@PayerId = @PayerId,
				@systemDate = @systemDate,
				@PaymentStart = @PaymentStart,
				@PaymentEnd = @PaymentEnd,
				@OldPayerId = @OldPayerId,
				@p_account_currency = @p_account_currency,
				@errorStr = @errorStr OUT
			IF @errorStr <> '' BEGIN
				INSERT INTO @errTbl(dt_detail, nm_text) VALUES(GETDATE(), @errorStr)
			END
			SET @errorStr = ''
			FETCH NEXT FROM acc INTO @IdAcc, @OldUsageCycle, @PayeeId, @OldPayerId, @PaymentStart, @PaymentEnd, @p_account_currency
		END
		CLOSE acc
		DEALLOCATE acc
		IF @doCommit = 'Y' BEGIN
			COMMIT TRANSACTION T1
		END
	END TRY
	BEGIN CATCH
		INSERT INTO @errTbl(dt_detail, nm_text) VALUES(GETDATE(), ERROR_MESSAGE())
		IF @doCommit = 'Y' BEGIN
			ROLLBACK TRANSACTION T1
		END
	END CATCH

	EXEC apply_subscriptions
		@template_id                = @idAccountTemplate,
		@sub_start                  = @sub_start,
		@sub_end                    = @sub_end,
		@next_cycle_after_startdate = @next_cycle_after_startdate,
		@next_cycle_after_enddate   = @next_cycle_after_enddate,
		@user_id                    = @user_id,
		@id_audit                   = null,
		@id_event_success           = @id_event_success,
		@id_event_failure           = @id_event_failure,
		@systemdate                 = @systemDate,
		@id_template_session        = @sessionId,
		@retrycount                 = @retrycount

	INSERT INTO t_acc_template_session_detail
	(
		id_session,
		n_detail_type,
		n_result,
		dt_detail,
		nm_text,
		n_retry_count
	)
	SELECT
			@sessionId,
			@DetailTypeSubscription,
			@DetailResultInformation,
			e.dt_detail,
			e.nm_text,
			@retrycount
	FROM    @errTbl e
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[t_acc_template_session]'
GO
ALTER TABLE [dbo].[t_acc_template_session] ADD
[n_templates] [int] NOT NULL CONSTRAINT [DF__t_acc_tem__n_tem__3C69FB99] DEFAULT ((0)),
[n_templates_applied] [int] NOT NULL CONSTRAINT [DF__t_acc_tem__n_tem__3D5E1FD2] DEFAULT ((0))
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[ApplyAccountTemplate]'
GO
ALTER PROCEDURE ApplyAccountTemplate(
	@accountTemplateId          int,
	@sessionId                  int,
	@systemDate                 datetime,
	@sub_start                  datetime,
	@sub_end                    datetime,
	@next_cycle_after_startdate char, /* Y or N */
	@next_cycle_after_enddate   char, /* Y or N */
	@id_event_success           int,
	@id_event_failure           int,
	@account_id					int = NULL,
	@doCommit                   char = 'Y' /* Y or N */
)
AS
	SET NOCOUNT ON


	DECLARE @nRetryCount int
	SET @nRetryCount = 0

	DECLARE @DetailTypeGeneral int
	DECLARE @DetailResultInformation int
	DECLARE @DetailTypeSubscription int
	DECLARE @id_acc_type int
	DECLARE @id_acc int
	DECLARE @user_id int

	SELECT @id_acc_type = id_acc_type, @id_acc = id_folder FROM t_acc_template WHERE id_acc_template = @accountTemplateId
	SELECT @user_id = ts.id_submitter FROM t_acc_template_session ts WHERE ts.id_session = @sessionId


	SELECT @DetailTypeGeneral = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Success'
	SELECT @DetailResultInformation = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Information'
	SELECT @DetailTypeSubscription = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription'
	--!!!Starting application of template
	INSERT INTO t_acc_template_session_detail
		(
			id_session,
			n_detail_type,
			n_result,
			dt_detail,
			nm_text,
			n_retry_count
		)
		VALUES
		(
			@sessionId,
			@DetailTypeGeneral,
			@DetailResultInformation,
			getdate(),
			'Starting application of template',
			@nRetryCount
		)

	-- Updating session details with a number of themplates to be applied in the session
	UPDATE t_acc_template_session
	SET    n_templates = (SELECT COUNT(1) FROM t_account_ancestor aa JOIN t_acc_template at ON aa.id_ancestor = @id_acc AND aa.id_descendent = at.id_folder)
	WHERE  id_session = @sessionId

	DECLARE @incIdTemplate INT
	--Select account hierarchy for current template and for each child template.
	DECLARE accTemplateCursor CURSOR FOR

	SELECT tat.id_acc_template

	FROM t_account_ancestor taa
	INNER JOIN t_acc_template tat ON taa.id_descendent = tat.id_folder AND tat.id_acc_type = @id_acc_type
	WHERE taa.id_ancestor = @id_acc

	OPEN accTemplateCursor
	FETCH NEXT FROM accTemplateCursor INTO @incIdTemplate

	WHILE @@FETCH_STATUS = 0
	BEGIN

		--Apply account template to appropriate account list.
		EXEC ApplyTemplateToAccounts
			@idAccountTemplate          = @incIdTemplate,
			@sub_start                  = @sub_start,
			@sub_end                    = @sub_end,
			@next_cycle_after_startdate = @next_cycle_after_startdate,
			@next_cycle_after_enddate   = @next_cycle_after_enddate,
			@user_id                    = @user_id,
			@id_event_success           = @id_event_success,
			@id_event_failure           = @id_event_failure,
			@systemDate                 = @systemDate,
			@sessionId                  = @sessionId,
			@retrycount                 = @nRetryCount,
			@account_id				    = @account_id,
			@doCommit					= @doCommit
		
		UPDATE t_acc_template_session
		SET    n_templates_applied = n_templates_applied + 1
		WHERE  id_session = @sessionId

		FETCH NEXT FROM accTemplateCursor INTO @incIdTemplate
	END

	CLOSE accTemplateCursor
	DEALLOCATE accTemplateCursor

    /* Apply default security */
    INSERT INTO t_policy_role
    SELECT pd.id_policy, pr.id_role
    FROM   t_account_ancestor aa
           JOIN t_account_ancestor ap ON ap.id_descendent = aa.id_descendent AND ap.num_generations = 1
           JOIN t_principal_policy pp ON pp.id_acc = ap.id_ancestor AND pp.policy_type = 'D'
           JOIN t_principal_policy pd ON pd.id_acc = aa.id_descendent AND pd.policy_type = 'A'
           JOIN t_policy_role pr ON pr.id_policy = pp.id_policy
           JOIN t_acc_template t ON aa.id_ancestor = t.id_folder AND t.b_applydefaultpolicy = 'Y'
    WHERE  t.id_acc_template = @accountTemplateId
       AND aa.num_generations > 0
       AND NOT EXISTS (SELECT 1 FROM t_policy_role pr2 WHERE pr2.id_policy = pd.id_policy AND pr2.id_role = pr.id_role)
   
	-- Finalize session state
	UPDATE t_acc_template_session
	SET    n_templates = n_templates_applied
	WHERE  id_session = @sessionId

	--!!!Template application complete
	INSERT INTO t_acc_template_session_detail
	(
		id_session,
		n_detail_type,
		n_result,
		dt_detail,
		nm_text,
		n_retry_count
	)
	VALUES
	(
		@sessionId,
		@DetailTypeGeneral,
		@DetailResultInformation,
		getdate(),
		'Template application complete',
		@nRetryCount
	)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[AddNewAccount]'
GO

ALTER PROCEDURE AddNewAccount(
@p_id_acc_ext  varchar(16),
@p_acc_state  varchar(2),
@p_acc_status_ext  int,
@p_acc_vtstart  datetime,
@p_acc_vtend  datetime,
@p_nm_login  nvarchar(255),
@p_nm_space nvarchar(40),
@p_tx_password  nvarchar(1024),
@p_auth_type integer,
@p_langcode  varchar(10),
@p_profile_timezone  int,
@p_ID_CYCLE_TYPE  int,
@p_DAY_OF_MONTH  int,
@p_DAY_OF_WEEK  int,
@p_FIRST_DAY_OF_MONTH  int,
@p_SECOND_DAY_OF_MONTH int,
@p_START_DAY int,
@p_START_MONTH int,
@p_START_YEAR int,
@p_billable varchar,
@p_id_payer int,
@p_payer_startdate datetime,
@p_payer_enddate datetime,
@p_payer_login nvarchar(255),
@p_payer_namespace nvarchar(40),
@p_id_ancestor int,
@p_hierarchy_start datetime,
@p_hierarchy_end datetime,
@p_ancestor_name nvarchar(255),
@p_ancestor_namespace nvarchar(40),
@p_acc_type varchar(40),
@p_apply_default_policy varchar,
@p_systemdate datetime,
@p_enforce_same_corporation varchar,
-- pass the currency through to CreatePaymentRecord
-- stored procedure only to validate it against the payer
-- We have to do it, because the t_av_internal record
--is not created yet
@p_account_currency nvarchar(5),
@p_profile_id int,
@p_login_app varchar(40),
@accountID int,
@status  int OUTPUT,
@p_hierarchy_path varchar(4000) output,
@p_currency nvarchar(10) OUTPUT,
@p_id_ancestor_out int OUTPUT,
@p_corporate_account_id int OUTPUT,
@p_ancestor_type_out varchar(40) OUTPUT
)
as
	declare @existing_account as int
	declare @intervalID as int
	declare @intervalstart as datetime
	declare @intervalend as datetime
	declare @usagecycleID as int
	declare @acc_startdate as datetime
	declare @acc_enddate as datetime
	declare @payer_startdate as datetime
	declare @payer_enddate as datetime
	declare @ancestor_startdate as datetime
	declare @ancestor_enddate as datetime	declare @payerID as int
	declare @ancestorID as int
	declare @siteID as int
	declare @folderName nvarchar(255)
	declare @varMaxDateTime as datetime
	declare @IsNotSubscriber int
	declare @payerbillable as varchar(1)
	declare @authancestor as int
	declare @id_type as int
        declare @dt_end datetime

  set @p_ancestor_type_out = 'Err'
	-- step : validate that the account does not already exist.  Note 
	-- that this check is performed by checking the t_account_mapper table.
	-- However, we don't check the account state so the new account could
	-- conflict with an account that is an archived state.  You would need
	-- to purge the archived account before the new account could be created.
	select @varMaxDateTime = dbo.MTMaxDate()
	select @existing_account = id_acc from t_account_mapper with(updlock) where nm_login=@p_nm_login and nm_space=@p_nm_space
	if (@existing_account is not null) begin
	-- ACCOUNTMAPPER_ERR_ALREADY_EXISTS
	select @status = -501284862
	return
	end 

	-- check account creation business rules
	IF (@p_nm_login not in ('rm', 'mps_folder'))
	BEGIN
	  exec CheckAccountCreationBusinessRules 
			 @p_nm_space, 
			 @p_acc_type, 
			 @p_id_ancestor, 
			 @status output
	  IF (@status <> 1)
		BEGIN
	  	RETURN
		END		
	END	

	-- step : populate the account start dates if the values were
	-- not passed into the sproc
	select 
	@acc_startdate = case when @p_acc_vtstart is NULL then dbo.mtstartofday(@p_systemdate) 
		else dbo.mtstartofday(@p_acc_vtstart) end,
	@acc_enddate = case when @p_acc_vtend is NULL then @varMaxDateTime 
		else dbo.mtendofday(@p_acc_vtend) end
	-- step : populate t_account

 	select @id_type = id_type from t_account_type where name = @p_acc_type
	if (@p_id_acc_ext is null) begin
		insert into t_account(id_acc,id_acc_ext,dt_crt,id_type)
		select @accountID,newid(),@acc_startdate,@id_type 
	end
	else begin
		insert into t_account(id_acc,id_Acc_ext,dt_crt,id_type)
		select @accountID,convert(varbinary(16),@p_id_acc_ext),@acc_startdate,@id_type 
	end 
	-- step : get the account ID
	-- step : initial account state
	insert into t_account_state values (@accountID,
	@p_acc_state /*,p_acc_status_ext*/,
	@acc_startdate,@acc_enddate)
	insert into t_account_state_history values (@accountID,
	@p_acc_state /*,p_acc_status_ext*/,
	@acc_startdate,@acc_enddate,@p_systemdate,@varMaxDateTime)
	-- step : login and namespace information
	insert into t_account_mapper values (@p_nm_login,lower(@p_nm_space),@accountID)
	-- step : user credentials
	-- check if authentification is MetraNetInternal then add user credentials
	IF ISNULL(@p_auth_type,1) = 1 BEGIN
		insert into t_user_credentials (nm_login, nm_space, tx_password) values (@p_nm_login,lower(@p_nm_space),@p_tx_password)
	END

	-- step : t_profile. This looks like it is only for timezone information
	insert into t_profile values (@p_profile_id,'timeZoneID',@p_profile_timezone,'System')
	-- step : site user information
	exec GetlocalizedSiteInfo @p_nm_space,@p_langcode,@siteID OUTPUT
	insert into t_site_user values (@p_nm_login,@siteID,@p_profile_id)


  	--
  	-- associates the account with the Usage Server
  	--

	-- determines the usage cycle ID from the passed in date properties
	if (@p_ID_CYCLE_TYPE IS NOT NULL)
	BEGIN
		SELECT @usagecycleID = id_usage_cycle 
		FROM t_usage_cycle cycle 
	 	 WHERE
		 cycle.id_cycle_type = @p_ID_CYCLE_TYPE AND
	   	(@p_DAY_OF_MONTH = cycle.day_of_month OR @p_DAY_OF_MONTH IS NULL) AND
	   	(@p_DAY_OF_WEEK = cycle.day_of_week OR @p_DAY_OF_WEEK IS NULL) AND
	   	(@p_FIRST_DAY_OF_MONTH = cycle.FIRST_DAY_OF_MONTH OR @p_FIRST_DAY_OF_MONTH IS NULL) AND
	   	(@p_SECOND_DAY_OF_MONTH = cycle.SECOND_DAY_OF_MONTH OR @p_SECOND_DAY_OF_MONTH IS NULL) AND
	   	(@p_START_DAY = cycle.START_DAY OR @p_START_DAY IS NULL) AND
	   	(@p_START_MONTH = cycle.START_MONTH OR @p_START_MONTH IS NULL) AND
	   	(@p_START_YEAR = cycle.START_YEAR OR @p_START_YEAR IS NULL)
	
	  	-- adds the account to usage cycle mapping
		INSERT INTO t_acc_usage_cycle VALUES (@accountID, @usagecycleID)
	
	  	-- creates only needed intervals and mappings for this account only.
	  	-- other accounts affected by any new intervals (same cycle) will
	 	-- be associated later in the day via a usm -create
                -- Compare this logic to that in the batch case by noting the mapping between
                -- variables and temp table columns:
                --
                -- tmp.id_account = @accountID
                -- tmp.id_usage_cycle = @usagecycleID
                -- tmp.acc_vtstart = @acc_startdate
                -- tmp.acc_vtend = @acc_enddate
                -- tmp.acc_state = @p_acc_state
                --
                -- Note also that some predicates don't depend on database tables
                -- and these become a surrounding IF statement

                -- Defines the date range that an interval must fall into to
                -- be considered 'active'.
                SELECT @dt_end = (@p_systemdate + n_adv_interval_creation) FROM t_usage_server

                IF 
                  -- Exclude archived accounts.
                  @p_acc_state <> 'AR' 
                  -- The account has already started or is about to start.
                  AND @acc_startdate < @dt_end 
                  -- The account has not yet ended.
                  AND @acc_enddate >= @p_systemdate
                BEGIN
                INSERT INTO t_usage_interval(id_interval,id_usage_cycle,dt_start,dt_end,tx_interval_status)
                SELECT 
                  ref.id_interval,
                  ref.id_cycle,
                  ref.dt_start,
                  ref.dt_end,
                  'O'  -- Open
                FROM 
                t_pc_interval ref                 
                WHERE
                /* Only add intervals that don't exist */
                NOT EXISTS (SELECT 1 FROM t_usage_interval ui WHERE ref.id_interval = ui.id_interval)
                AND 
                ref.id_cycle = @usagecycleID AND
                -- Reference interval must at least partially overlap the [minstart, maxend] period.
                (ref.dt_end >= @acc_startdate AND 
                 ref.dt_start <= CASE WHEN @acc_enddate < @dt_end THEN @acc_enddate ELSE @dt_end END)

                INSERT INTO t_acc_usage_interval(id_acc,id_usage_interval,tx_status,dt_effective)
                SELECT
                  @accountID,
                  ref.id_interval,
                  ref.tx_interval_status,
		  NULL
                FROM 
                t_usage_interval ref 
                WHERE
                ref.id_usage_cycle = @usagecycleID AND
                -- Reference interval must at least partially overlap the [minstart, maxend] period.
                (ref.dt_end >= @acc_startdate AND 
                ref.dt_start <= CASE WHEN @acc_enddate < @dt_end THEN @acc_enddate ELSE @dt_end END)
                /* Only add mappings for non-blocked intervals */
                AND ref.tx_interval_status <> 'B'
              END
	END

	-- Non-billable accounts must have a payment redirection record
	if ( @p_billable = 'N' AND 
	(@p_id_payer is NULL and
	(@p_id_payer is null AND @p_payer_login is NULL AND @p_payer_namespace is NULL))) begin
	-- MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER
		select @status = -486604768
		return
	end
	-- default the payer start date to the start of the account  
	select @payer_startdate = case when @p_payer_startdate is NULL then @acc_startdate else dbo.mtstartofday(@p_payer_startdate) end,
	 -- default the payer end date to the end of the account if NULL
	@payer_enddate = case when @p_payer_enddate is NULL then @acc_enddate else dbo.mtendofday(@p_payer_enddate) end,
	-- step : default the hierarchy start date to the account start date 
	@ancestor_startdate = case when @p_hierarchy_start is NULL then @acc_startdate else @p_hierarchy_start end,
	-- step : default the hierarchy end date to the account end date
	@ancestor_enddate = case when @p_hierarchy_end is NULL then @acc_enddate else dbo.mtendofday(@p_hierarchy_end) end,
	-- step : resolve the ancestor ID if necessary
	@ancestorID = case when @p_ancestor_name is not NULL and @p_ancestor_namespace is not NULL then
		dbo.LookupAccount(@p_ancestor_name,@p_ancestor_namespace)  else 
		-- if the ancestor ID iis NULL then default to the root
		case when @p_id_ancestor is NULL then 1 else @p_id_ancestor end
	end,
	-- step : resolve the payer account if necessary
	@payerID = case when 	@p_payer_login is not null and @p_payer_namespace is not null then
		 dbo.LookupAccount(@p_payer_login,@p_payer_namespace) else 
			case when @p_id_payer is NULL then @accountID else @p_id_payer 
			end
		  end
  -- Fix CORE-762: step: @payerID must be > 1 (to eliminate root and synthetic root) and must be present
	select id_acc from t_account where id_acc = @payerID 
	if (@@rowcount = 0)
	begin
		-- MT_CANNOT_RESOLVE_PAYING_ACCOUNT
		select @status = -486604792
		return
	end

	select id_acc from t_account where id_acc = @ancestorID
	if (@@rowcount= 0) 
		begin
			-- MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT
			select @status = -486604791
			return
		end 
	else
		begin
			SET @p_id_ancestor_out = @ancestorID
		end
	
	if (upper(@p_acc_type) = 'SYSTEMACCOUNT') begin  -- any one who is not a system account is a subscriber
		select @IsNotSubscriber = 1
	end 
	-- we trust AddAccToHIerarchy to set the status to 1 in case of success
	declare @acc_type_out varchar(40)
	exec AddAccToHierarchy @ancestorID,@accountID,@ancestor_startdate,
	@ancestor_enddate,@acc_startdate,@p_ancestor_type_out output, @acc_type_out output, @status output
	if (@status <> 1)begin 
		return
	end 

	-- Populate t_dm_account and t_dm_account_ancestor table
	declare @id_dm_acc int

      insert into t_dm_account select id_descendent, vt_start, vt_end from
      t_account_ancestor where id_ancestor=1 and id_descendent = @accountID

      set @id_dm_acc = @@identity
      
      insert into t_dm_account_ancestor select dm2.id_dm_acc, dm1.id_dm_acc, aa1.num_generations
      from t_account_ancestor aa1
      inner join t_dm_account dm1 with(readcommitted) on aa1.id_descendent=dm1.id_acc and aa1.vt_start <= dm1.vt_end and dm1.vt_start <= aa1.vt_end
      inner join t_dm_account dm2 with(readcommitted) on aa1.id_ancestor=dm2.id_acc and aa1.vt_start <= dm2.vt_end and dm2.vt_start <= aa1.vt_end
      where dm1.id_acc <> dm2.id_acc
      and dm1.vt_start >= dm2.vt_start
      and dm1.vt_end <= dm2.vt_end
      and aa1.id_descendent = @accountID
      and dm1.id_dm_acc = @id_dm_acc

	insert into t_dm_account_ancestor select id_dm_acc,id_dm_acc,0	from t_dm_account where id_acc = @accountID
	-- pass in the current account's billable flag when creating the payment 
	-- redirection record IF the account is paying for itself
	select @payerbillable = case when @payerID = @accountID then
		@p_billable else NULL end
	exec CreatePaymentRecord @payerID,@accountID,
	@payer_startdate,@payer_enddate,@payerbillable,@p_systemdate,'N', @p_enforce_same_corporation, @p_account_currency, @status OUTPUT
	if (@status <> 1) begin
		return
	end   
	
	select @p_hierarchy_path = tx_path  from t_account_ancestor
	where id_descendent = @accountID and (id_ancestor = 1 OR id_ancestor = -1)
	AND @ancestor_startdate between vt_start AND vt_end

	-- if "Apply Default Policy" flag is set, then
	-- figure out "ancestor" id based on account type in case the account is not
	--a subscriber
	--BP: 10/5 Make sure that t_principal_policy record is always there, otherwise ApplyRoleMembership will break
	declare @polid int
	exec Sp_Insertpolicy 'id_acc', @accountID,'A', @polID output
	
	/* 2/11/2010: TRW - We are now granting the "Manage Account Hierarchies" capability to all accounts
		upon their creation.  They are being granted read/write access to their own account only (not to 
		sub accounts).  This is being done to facilitate access to their own information via the MetraNet
		ActivityServices web services, which are now checking capabilities a lot more */
		
	/* Insert "Manage Account Hierarchies" parent capability */
	insert into t_capability_instance(tx_guid, id_parent_cap_instance, id_policy, id_cap_type)
	select
		0x41424344,
		null,
		@polID,
		id_cap_type
	from
		t_composite_capability_type
	where
		tx_name = 'Manage Account Hierarchies'

	declare @id_parent_cap int
	set @id_parent_cap = @@IDENTITY

	/* Insert MTPathCapability atomic capability */
	insert into t_capability_instance(tx_guid, id_parent_cap_instance, id_policy, id_cap_type)
	select
		0x41424344,
		@id_parent_cap,
		@polID,
		id_cap_type
	from
		t_atomic_capability_type
	where
		tx_name = 'MTPathCapability'
		
	declare @id_atomic_cap int
	set @id_atomic_cap = @@IDENTITY

	/* Insert into t_path_capability account's path */
	insert into t_path_capability(id_cap_instance, tx_param_name, tx_op, param_value)
	values( @id_atomic_cap, null, null, @p_hierarchy_path + '/')
	
	/* Insert MTEnumCapability atomic capability */
	insert into t_capability_instance(tx_guid, id_parent_cap_instance, id_policy, id_cap_type)
	select
		0x41424344,
		@id_parent_cap,
		@polID,
		id_cap_type
	from
		t_atomic_capability_type
	where
		tx_name = 'MTEnumTypeCapability'
		
	set @id_atomic_cap = @@IDENTITY
	
	/* Insert into t_enum_capability to grant Write access */
	insert into t_enum_capability(id_cap_instance, tx_param_name, tx_op, param_value)
	select
		@id_atomic_cap,
		null,
		'=',
		id_enum_data
	from
		t_enum_data
	where
		nm_enum_data = 'Global/AccessLevel/WRITE'
	
	if
		(UPPER(@p_apply_default_policy) = 'Y' OR
		UPPER(@p_apply_default_policy) = 'T' OR
		UPPER(@p_apply_default_policy) = '1') begin
    SET @authancestor = @ancestorID
		if (@IsNotSubscriber > 0) begin
		 	select @folderName = 
			 CASE 
				WHEN UPPER(@p_login_app) = 'CSR' THEN 'csr_folder'
				WHEN UPPER(@p_login_app) = 'MOM' THEN 'mom_folder'
				WHEN UPPER(@p_login_app) = 'MCM' THEN 'mcm_folder'
				WHEN UPPER(@p_login_app) = 'MPS' THEN 'mps_folder'
				END
			SELECT @authancestor = NULL
      SELECT @authancestor = id_acc  FROM t_account_mapper WHERE nm_login = @folderName
			AND nm_space = 'auth'
			if (@authancestor is null) begin
	 			select @status = 1
	 		end
		end 
		--apply default security policy
		if (@authancestor > 1) begin
			exec dbo.CloneSecurityPolicy @authancestor, @accountID , 'D' , 'A'
		end
	End 
	
	--resolve accounts' corporation
	--select ancestor whose ancestor is of a type that has b_iscorporate set to true.
	select @p_corporate_account_id = ancestor.id_ancestor from t_account_ancestor ancestor
	inner join t_account acc on acc.id_acc = ancestor.id_ancestor
	inner join t_account_type atype on acc.id_type = atype.id_type
	where
	ancestor.id_descendent = @accountID and
	atype.b_iscorporate = '1' 
	AND @acc_startdate  BETWEEN ancestor.vt_start and ancestor.vt_end
	
  if (@p_corporate_account_id is null)
   set @p_corporate_account_id = @accountID
   
	if (@ancestorID <> 1 and @ancestorID <> -1)
	begin
		select @p_currency = c_currency from t_av_internal where id_acc = @ancestorID
		--if cross corp business rule is enforced, verify that currencies match
		if(@p_enforce_same_corporation = '1' AND (upper(@p_currency) <> upper(@p_account_currency)) )
		begin
			-- MT_CURRENCY_MISMATCH
			select @status = -486604737
			return
		end
    end
	-- done
	select @status = 1
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[charge_qualification_groups]'
GO
EXEC sp_refreshview N'[dbo].[charge_qualification_groups]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[usage_charge_fields]'
GO
EXEC sp_refreshview N'[dbo].[usage_charge_fields]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[usage_qualification_groups]'
GO
EXEC sp_refreshview N'[dbo].[usage_qualification_groups]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[MoveAccount]'
GO
ALTER  PROCEDURE [dbo].[MoveAccount]
	(@new_parent INT,
	 @account_being_moved INT,
   @vt_move_start DATETIME,
   @p_enforce_same_corporation VARCHAR,
   @p_system_time DATETIME,
   @status INT OUTPUT,
   @p_id_ancestor_out INT OUTPUT,
   @p_ancestor_type VARCHAR(40) OUTPUT,
   @p_acc_type VARCHAR(40) OUTPUT)
AS
BEGIN
DECLARE @vt_move_end DATETIME
SET @vt_move_end = dbo.MTMaxDate()

DECLARE @vt_move_start_trunc DATETIME
SET @vt_move_start_trunc = dbo.MTStartOfDay(@vt_move_start)

-- plug business rules back in
DECLARE @varMaxDateTime AS DATETIME
DECLARE @AccCreateDate AS DATETIME
DECLARE @AccMaxCreateDate AS DATETIME
DECLARE @p_dt_start DATETIME
DECLARE @realstartdate AS DATETIME
DECLARE @p_id_ancestor AS INT
DECLARE @p_id_descendent AS INT
DECLARE @ancestor_acc_type AS INT
DECLARE @descendent_acc_type AS INT


SET @p_dt_start = @vt_move_start_trunc
SET @p_id_ancestor = @new_parent
SET @p_id_descendent = @account_being_moved


SELECT @realstartdate = dbo.mtstartofday(@p_dt_start)

--Take update lock very early as we are deadlocking in MoveAccount
DECLARE @old_parent INT
DECLARE @varMaxDateTimeAlex DATETIME
--lock the account to be moved
SELECT @old_parent = id_ancestor
FROM t_account_ancestor aa WITH (UPDLOCK)
WHERE id_descendent =@account_being_moved AND num_generations = 1
--lock old and new parent in a bold sweeping move
--we need it as we will update b_children='Y' on the new parent and b_children='N' on the old parent
SELECT @varMaxDateTimeAlex=MAX(vt_end) FROM t_account_ancestor WITH (UPDLOCK)
WHERE id_descendent IN ( @old_parent, @new_parent)

SELECT @varMaxDateTime = MAX(vt_end) FROM t_account_ancestor WITH (UPDLOCK) WHERE id_descendent = @p_id_descendent
AND id_ancestor = 1

SELECT @AccCreateDate = dbo.mtminoftwodates(dbo.mtstartofday(ancestor.dt_crt),dbo.mtstartofday(descendent.dt_crt)),
@ancestor_acc_type = ancestor.id_type,
@descendent_acc_type = descendent.id_type
FROM t_account ancestor WITH (UPDLOCK)
INNER JOIN t_account descendent WITH (UPDLOCK) ON
ancestor.id_acc = @p_id_ancestor AND
descendent.id_acc = @p_id_descendent


SELECT @p_ancestor_type = name
FROM t_account_type
WHERE id_type = @ancestor_acc_type


SELECT @p_acc_type = name
FROM t_account_type
WHERE id_type = @descendent_acc_type


--begin business rules check

	SELECT @AccMaxCreateDate =
	dbo.mtmaxoftwodates(dbo.mtstartofday(ancestor.dt_crt),dbo.mtstartofday(descendent.dt_crt))
	FROM t_account ancestor,t_account descendent WHERE ancestor.id_acc = @p_id_ancestor AND
	descendent.id_acc = @p_id_descendent
	IF dbo.mtstartofday(@p_dt_start) < dbo.mtstartofday(@AccMaxCreateDate)  BEGIN
		-- MT_CANNOT_MOVE_ACCOUNT_BEFORE_START_DATE
		SELECT @status = -486604750
		RETURN
	END
	
	-- step : make sure that the new ancestor is not actually a child
	SELECT @status = COUNT(*)
	FROM t_account_ancestor
	WHERE id_ancestor = @p_id_descendent
	AND id_descendent = @p_id_ancestor AND
  	@realstartdate BETWEEN vt_start AND vt_end
	IF @status > 0
   	BEGIN
		-- MT_NEW_PARENT_IS_A_CHILD
	 SELECT @status = -486604797
	 RETURN
  	END

	SELECT @status = COUNT(*)
	FROM t_account_ancestor
	WHERE id_ancestor = @p_id_ancestor
	AND id_descendent = @p_id_descendent
	AND num_generations = 1
	AND @realstartdate >= vt_start
	AND vt_end = @varMaxDateTime
	IF @status > 0
	BEGIN
		-- MT_NEW_ANCESTOR_IS_ALREADY_ A_ANCESTOR
	 SELECT @status = 1
	 RETURN
	END


      -- step : make sure that the account is not archived or closed
	SELECT @status = COUNT(*)  FROM t_account_state
	WHERE id_acc = @p_id_Descendent
	AND (dbo.IsClosed(@status) = 1 OR dbo.isArchived(@status) = 1)
	AND @realstartdate BETWEEN vt_start AND vt_end
	IF (@status > 0 )
	BEGIN
	   -- OPERATION_NOT_ALLOWED_IN_CLOSED_OR_ARCHIVED
	SELECT @status = -469368827
	END

	-- step : make sure that the account is not a corporate account
	--only check next 2 business rules if p_enforce_same_corporation rule is turned on
	IF @p_enforce_same_corporation = 1
	BEGIN
		IF (dbo.iscorporateaccount(@p_id_descendent,@p_dt_start) = 1)
		-- MT_CANNOT_MOVE_CORPORATE_ACCOUNT
			BEGIN
			SELECT @status = -486604770
			RETURN
			END
		-- do this check if the original ancestor of the account being moved is not -1 
		-- or the new ancestor is not -1
		DECLARE @originalAncestor INTEGER
		SELECT @originalAncestor = id_ancestor FROM t_account_ancestor
			WHERE id_descendent =  @p_id_descendent
			AND num_generations = 1
			AND @vt_move_start_trunc >= vt_start AND @vt_move_start_trunc <= vt_end

		IF (@originalAncestor <> -1 AND @p_id_ancestor <> -1 AND dbo.IsInSameCorporateAccount(@p_id_ancestor,@p_id_descendent,@realstartdate) <> 1) BEGIN
			-- MT_CANNOT_MOVE_BETWEEN_CORPORATE_HIERARCHIES
			SELECT @status = -486604759
			RETURN
		END
	END

	--check that both ancestor and descendent are subscriber accounts.  This check has to be recast.. you can 
	-- only move if the new ancestor allows children of type @descendent_acc_type
	IF @descendent_acc_type NOT IN (
	SELECT id_descendent_type FROM t_acctype_descendenttype_map
	WHERE id_type = @ancestor_acc_type)
	BEGIN
	-- MT_ANCESTOR_OF_INCORRECT_TYPE
	SELECT @status = -486604714
	RETURN
	END

	-- check that only accounts whose type says b_canHaveSyntheticRoot is true can have -1 as an ancestor.
	IF (@p_id_ancestor = -1)
	BEGIN
	DECLARE @syntheticroot VARCHAR(1)
	SELECT @syntheticroot = b_CanhaveSyntheticRoot FROM t_account_type WHERE id_type = @descendent_acc_type
	IF (@syntheticroot <> '1')
	BEGIN
	--MT_ANCESTOR_INVALID_SYNTHETIC_ROOT
		SELECT @status = -486604713
		RETURN
	END
	END
	--this check is removed in Kona.
	--if(@b_is_ancestor_folder <> '1')
	--BEGIN
	-- MT_CANNOT_MOVE_TO_NON_FOLDER_ACCOUNT
	--select @status = -486604726
	--return
	--END

-- end business rules

--METRAVIEW DATAMART 

DECLARE @tmp_t_dm_account TABLE(id_dm_acc INT,id_acc INT,vt_start DATETIME,vt_end DATETIME)
INSERT INTO @tmp_t_dm_account  SELECT * FROM t_dm_account WHERE id_acc IN
(
SELECT DISTINCT id_descendent FROM t_account_ancestor WHERE id_ancestor = @account_being_moved
)
--Deleting all the entries from ancestor table
DELETE FROM t_dm_account_ancestor WHERE id_dm_descendent IN (SELECT id_dm_acc FROM @tmp_t_dm_account)
DELETE FROM t_dm_account WHERE id_dm_acc IN (SELECT id_dm_acc FROM @tmp_t_dm_account)

SELECT
aa2.id_ancestor,
aa2.id_descendent,
aa2.num_generations,
aa2.b_children,
dbo.MTMaxOfTwoDates(@vt_move_start_trunc, dbo.MTMaxOfTwoDates(dbo.MTMaxOfTwoDates(aa1.vt_start, aa2.vt_start), aa3.vt_start)) AS vt_start,
dbo.MTMinOfTwoDates(@vt_move_end, dbo.MTMinOfTwoDates(dbo.MTMinOfTwoDates(aa1.vt_end, aa2.vt_end), aa3.vt_end)) AS vt_end,
aa2.tx_path
INTO #deletethese
FROM
t_account_ancestor aa1
INNER JOIN t_account_ancestor aa2 ON aa1.id_ancestor=aa2.id_ancestor AND aa1.vt_start <= aa2.vt_end AND aa2.vt_start <= aa1.vt_end AND aa2.vt_start <= @vt_move_end AND @vt_move_start_trunc <= aa2.vt_end
INNER JOIN t_account_ancestor aa3 ON aa2.id_descendent=aa3.id_descendent AND aa3.vt_start <= aa2.vt_end AND aa2.vt_start <= aa3.vt_end AND aa3.vt_start <= @vt_move_end AND @vt_move_start_trunc <= aa3.vt_end
WHERE
aa1.id_descendent=@account_being_moved
AND
aa1.num_generations > 0
AND
aa1.vt_start <= @vt_move_end
AND
@vt_move_start_trunc <= aa1.vt_end
AND
aa3.id_ancestor=@account_being_moved

--Creating index on temp table #deletethese
CREATE UNIQUE CLUSTERED INDEX IX_Clus_idacc_iddesc ON #deletethese (id_ancestor, id_descendent)

-- select old direct ancestor id
SELECT @p_id_ancestor_out = id_ancestor FROM #deletethese
WHERE num_generations = 1 AND @vt_move_start_trunc BETWEEN vt_start AND vt_end

--select * from #deletethese

-- The four statements of the sequenced delete follow.  Watch carefully :-)
--
-- Create a new interval for the case in which the applicability interval of the update
-- is contained inside the period of validity of the existing interval
-- [------------------] (existing)
--    [-----------] (update)
INSERT INTO t_account_ancestor(id_ancestor, id_descendent, num_generations,b_children, vt_start, vt_end,tx_path)
SELECT aa.id_ancestor, aa.id_descendent, aa.num_generations, d.b_children,d.vt_start, d.vt_end,
CASE WHEN aa.id_descendent = 1 THEN
    aa.tx_path + d.tx_path
    ELSE
    d.tx_path + '/' + aa.tx_path
    END
FROM
t_account_ancestor aa
INNER JOIN #deletethese d ON aa.id_ancestor=d.id_ancestor AND aa.id_descendent=d.id_descendent AND
	aa.num_generations=d.num_generations AND aa.vt_start < d.vt_start AND aa.vt_end > d.vt_end

-- Update end date of existing records for which the applicability interval of the update
-- starts strictly inside the existing record:
-- [---------] (existing)
--    [-----------] (update)
-- or
-- [---------------] (existing)
--    [-----------] (update)
UPDATE t_account_ancestor
SET
t_account_ancestor.vt_end = DATEADD(s, -1, d.vt_start)
--select *
FROM
t_account_ancestor aa
INNER JOIN #deletethese d ON aa.id_ancestor=d.id_ancestor AND aa.id_descendent=d.id_descendent AND
	aa.num_generations=d.num_generations AND aa.vt_start < d.vt_start AND aa.vt_end > d.vt_start

-- Update start date of existing records for which the effectivity interval of the update
-- ends strictly inside the existing record:
--              [---------] (existing)
--    [-----------] (update)
UPDATE t_account_ancestor
SET
t_account_ancestor.vt_start = DATEADD(s, 1, d.vt_end)
--select *
FROM
t_account_ancestor aa
INNER JOIN #deletethese d ON aa.id_ancestor=d.id_ancestor AND aa.id_descendent=d.id_descendent AND
	aa.num_generations=d.num_generations AND aa.vt_start <= d.vt_end AND aa.vt_end > d.vt_end

-- Delete existing records for which the effectivity interval of the update
-- contains the existing record:
--       [---------] (existing)
--     [---------------] (update)
DELETE aa
--select *
FROM
t_account_ancestor aa
INNER JOIN #deletethese d ON aa.id_ancestor=d.id_ancestor AND aa.id_descendent=d.id_descendent AND
	aa.num_generations=d.num_generations AND aa.vt_start >= d.vt_start AND aa.vt_end <= d.vt_end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- SEQUENCED INSERT JOIN
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Now do the sequenced insert into select from with the sequenced
-- cross join as the source of the data.

INSERT INTO t_account_ancestor(id_ancestor, id_descendent, num_generations,b_children, vt_start, vt_end,tx_path)
SELECT aa1.id_ancestor,
aa2.id_descendent,
aa1.num_generations+aa2.num_generations+1 AS num_generations,
aa2.b_children,
dbo.MTMaxOfTwoDates(@vt_move_start_trunc, dbo.MTMaxOfTwoDates(aa1.vt_start, aa2.vt_start)) AS vt_start,
dbo.MTMinOfTwoDates(@vt_move_end, dbo.MTMinOfTwoDates(aa1.vt_end, aa2.vt_end)) AS vt_end,
CASE WHEN aa2.id_descendent = 1 THEN
    aa1.tx_path + aa2.tx_path
    ELSE
    aa1.tx_path + '/' + aa2.tx_path
    END
FROM
t_account_ancestor aa1
INNER JOIN t_account_ancestor aa2 WITH (UPDLOCK) ON aa1.vt_start < aa2.vt_end AND aa2.vt_start < aa1.vt_end AND aa2.vt_start < @vt_move_end AND @vt_move_start_trunc < aa2.vt_end
WHERE
aa1.id_descendent = @new_parent
AND
aa1.vt_start < @vt_move_end
AND
@vt_move_start_trunc < aa1.vt_end
AND
aa2.id_ancestor = @account_being_moved

-- Implement the coalescing step.
-- TODO: Improve efficiency by restricting the updates to the rows that
-- might need coalesing.
WHILE 1=1
BEGIN
UPDATE t_account_ancestor
SET t_account_ancestor.vt_end = (
	SELECT MAX(aa2.vt_end)
	FROM
	t_account_ancestor AS aa2
	WHERE
	t_account_ancestor.id_ancestor=aa2.id_ancestor
	AND
	t_account_ancestor.id_descendent=aa2.id_descendent
	AND
	t_account_ancestor.num_generations=aa2.num_generations
	AND
	t_account_ancestor.vt_start < aa2.vt_start
	AND
	DATEADD(s,1,t_account_ancestor.vt_end) >= aa2.vt_start
	AND
	t_account_ancestor.vt_end < aa2.vt_end
	AND
	t_account_ancestor.tx_path=aa2.tx_path
)
WHERE
EXISTS (
	SELECT *
	FROM
	t_account_ancestor AS aa2
	WHERE
	t_account_ancestor.id_ancestor=aa2.id_ancestor
	AND
	t_account_ancestor.id_descendent=aa2.id_descendent
	AND
	t_account_ancestor.num_generations=aa2.num_generations
	AND
	t_account_ancestor.vt_start < aa2.vt_start
	AND
	DATEADD(s,1,t_account_ancestor.vt_end) >= aa2.vt_start
	AND
	t_account_ancestor.vt_end < aa2.vt_end
	AND
	t_account_ancestor.tx_path=aa2.tx_path
)
AND id_descendent IN (SELECT id_descendent FROM #deletethese)

IF @@rowcount <= 0 BREAK
END

DELETE FROM t_account_ancestor
WHERE
EXISTS (
	SELECT *
	FROM t_account_ancestor aa2 WITH (UPDLOCK)
	WHERE
	t_account_ancestor.id_ancestor=aa2.id_ancestor
	AND
	t_account_ancestor.id_descendent=aa2.id_descendent
	AND
	t_account_ancestor.num_generations=aa2.num_generations
	AND
	t_account_ancestor.tx_path=aa2.tx_path
	AND
 	(
	(aa2.vt_start < t_account_ancestor.vt_start AND t_account_ancestor.vt_end <= aa2.vt_end)
	OR
	(aa2.vt_start <= t_account_ancestor.vt_start AND t_account_ancestor.vt_end < aa2.vt_end)
	)
)
AND id_descendent IN (SELECT id_descendent FROM #deletethese)

/* update t_path_capabilities */
UPDATE pc
SET param_value = aa.tx_path + '/'
FROM
t_account_ancestor aa
INNER JOIN #deletethese d ON aa.id_descendent=d.id_descendent AND aa.id_ancestor = 1
INNER JOIN t_principal_policy p ON p.id_acc = aa.id_descendent
INNER JOIN t_capability_instance ci ON ci.id_policy = p.id_policy
INNER JOIN t_path_capability pc ON ci.id_cap_instance = pc.id_cap_instance
WHERE @p_system_time BETWEEN aa.vt_start AND aa.vt_end

	UPDATE new SET b_Children = 'Y' FROM t_account_ancestor new WHERE
	id_descendent = @new_parent
	AND b_children='N'

	UPDATE old SET b_Children = 'N' FROM t_account_ancestor old WHERE
	id_descendent = @p_id_ancestor_out AND
	NOT EXISTS (SELECT 1 FROM t_account_ancestor new WHERE new.id_ancestor=old.id_descendent
	AND num_generations <>0 )
	-- to avoid update locks only update one that need to be updated
	AND b_children = 'Y'
  
--DataMart insert new id_dm_acc for moving account and descendents
		INSERT INTO t_dm_account(id_acc,vt_start,vt_end) SELECT anc.id_descendent, anc.vt_start, anc.vt_end
		FROM t_account_ancestor	anc
		INNER JOIN @tmp_t_dm_account acc ON anc.id_descendent = acc.id_acc
		WHERE anc.id_ancestor=1
		AND acc.vt_end = @varMaxDateTime
	
		INSERT INTO t_dm_account_ancestor
		SELECT dm2.id_dm_acc, dm1.id_dm_acc, aa1.num_generations
		FROM
		t_account_ancestor aa1
		INNER JOIN t_dm_account dm1 ON aa1.id_descendent=dm1.id_acc AND aa1.vt_start <= dm1.vt_end AND dm1.vt_start <= aa1.vt_end
		INNER JOIN t_dm_account dm2 ON aa1.id_ancestor=dm2.id_acc AND aa1.vt_start <= dm2.vt_end AND dm2.vt_start <= aa1.vt_end
		INNER JOIN @tmp_t_dm_account acc ON aa1.id_descendent = acc.id_acc
		WHERE dm1.id_acc <> dm2.id_acc
		AND dm1.vt_start >= dm2.vt_start
		AND dm1.vt_end <= dm2.vt_end
		AND acc.vt_end = @varMaxDateTime

		--we are adding 0 level record for all children of moving account
		INSERT INTO t_dm_account_ancestor SELECT dm1.id_dm_acc,dm1.id_dm_acc,0
		FROM
		t_dm_account dm1
		INNER JOIN @tmp_t_dm_account acc ON dm1.id_acc = acc.id_acc
		AND acc.vt_end = @varMaxDateTime

	-- Process templates after moving account


	DECLARE @allTypesSupported INT
    SELECT @allTypesSupported = all_types
        FROM t_acc_tmpl_types

	SET @allTypesSupported = ISNULL(@allTypesSupported,0)

	DECLARE @templateId INT
	DECLARE @templateOwner INT
	DECLARE @templateType VARCHAR(200)

	SELECT TOP 1 @templateId = id_acc_template
			, @templateOwner = template.id_folder
			, @templateType = atype.name
	FROM
				t_acc_template template
	INNER JOIN t_account_ancestor ancestor ON template.id_folder = ancestor.id_ancestor
	INNER JOIN t_account_mapper mapper ON mapper.id_acc = ancestor.id_ancestor
	INNER JOIN t_account_type atype ON template.id_acc_type = atype.id_type
			WHERE id_descendent = @new_parent AND
				@p_system_time BETWEEN vt_start AND vt_end AND
				(atype.name = @p_acc_type OR @allTypesSupported = 1)
	ORDER BY num_generations ASC

	DECLARE @sessionId INTEGER
	IF @templateId IS NOT NULL
	BEGIN
		EXECUTE UpdatePrivateTempates @templateId, @p_system_time
		EXECUTE GetCurrentID 'id_template_session', @sessionId OUT
        INSERT INTO t_acc_template_session(id_session, id_template_owner, nm_acc_type, dt_submission, id_submitter, nm_host, n_status, n_accts, n_subs)
        VALUES (@sessionId, @templateOwner, @p_acc_type, @p_system_time, 0, '', 0, 0, 0)
		EXECUTE ApplyAccountTemplate @templateId, @sessionId, @p_system_time, NULL, NULL, 'N', 'N', NULL, NULL, NULL
	END
	ELSE BEGIN
		DECLARE tmpl CURSOR FOR
            SELECT template.id_acc_template, template.id_folder, atype.name
                FROM t_account_ancestor ancestor
                JOIN t_acc_template template ON ancestor.id_descendent = template.id_folder
                JOIN t_account_type atype ON template.id_acc_type = atype.id_type
                WHERE ancestor.id_ancestor = @new_parent AND
				    @p_system_time BETWEEN vt_start AND vt_end
		OPEN tmpl
		FETCH NEXT FROM tmpl INTO @templateId, @templateOwner, @templateType
		WHILE @@FETCH_STATUS = 0 BEGIN
			EXECUTE UpdatePrivateTempates @templateId, @p_system_time
			EXECUTE GetCurrentID 'id_template_session', @sessionId OUT
			INSERT INTO t_acc_template_session(id_session, id_template_owner, nm_acc_type, dt_submission, id_submitter, nm_host, n_status, n_accts, n_subs)
			VALUES (@sessionId, @templateOwner, @p_acc_type, @p_system_time, 0, '', 0, 0, 0)
			EXECUTE ApplyAccountTemplate @templateId, @sessionId, @p_system_time, NULL, NULL, 'N', 'N', NULL, NULL, NULL
			FETCH NEXT FROM tmpl INTO @templateId, @templateOwner, @templateType
		END
		CLOSE tmpl
		DEALLOCATE tmpl
	END

	SELECT @status=1
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[T_VW_ACCTRES]'
GO
EXEC sp_refreshview N'[dbo].[T_VW_ACCTRES]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[vw_audit_log]'
GO
EXEC sp_refreshview N'[dbo].[vw_audit_log]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[t_vw_expanded_sub]'
GO
EXEC sp_refreshview N'[dbo].[t_vw_expanded_sub]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[t_vw_pilookup]'
GO
EXEC sp_refreshview N'[dbo].[t_vw_pilookup]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[t_vw_rc_arrears_fixed]'
GO
EXEC sp_refreshview N'[dbo].[t_vw_rc_arrears_fixed]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[t_vw_rc_arrears_relative]'
GO
EXEC sp_refreshview N'[dbo].[t_vw_rc_arrears_relative]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[T_VW_ACCTRES_BYID]'
GO
EXEC sp_refreshview N'[dbo].[T_VW_ACCTRES_BYID]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[GetPCViewHierarchy]'
GO
ALTER PROC [dbo].[GetPCViewHierarchy](@id_acc AS INT,
					@id_interval AS INT,
					@id_lang_code AS INT)
				AS
				SELECT
				tb_po.n_display_name id_po,-- use the display name as the product offering ID
				--au.id_prod id_po,
				pi_template.id_template_parent id_template_parent,
				--po_nm_name = case when t_description.tx_desc is NULL then template_desc.tx_desc else t_description.tx_desc end,
				po_nm_name = CASE WHEN t_description.tx_desc IS NULL THEN template_desc.tx_desc ELSE t_description.tx_desc END,
				ed.nm_enum_data pv_child,
				ed.id_enum_data pv_childID,
				pv_parentID = CASE WHEN parent_kind.nm_productview IS NULL THEN tb_po.n_display_name ELSE tenum_parent.id_enum_data END,
				AggRate = CASE WHEN pi_props.n_kind = 15 THEN 'Y' ELSE 'N' END,
				viewID = CASE WHEN au.id_pi_instance IS NULL THEN id_view ELSE
					(SELECT viewID = CASE WHEN pi_props.n_kind = 15 AND child_kind.nm_productview = ed.nm_enum_data THEN
					-(au.id_pi_instance + 0x40000000)
					ELSE
					-au.id_pi_instance
					END)
				END,
				id_view realPVID,
				--ViewName = case when tb_instance.nm_display_name is NULL then tb_template.nm_display_name else tb_instance.nm_display_name end,
				ViewName = CASE WHEN tb_instance.nm_display_name IS NULL THEN tb_template.nm_display_name ELSE tb_instance.nm_display_name END,
				'Product' ViewType,
				--id_view DescriptionID,
				DescriptionID = CASE WHEN t_description.tx_desc IS NULL THEN template_props.n_display_name ELSE id_view END,
				SUM(au.amount) 'Amount',
				COUNT(au.id_sess) 'Count',
				au.am_currency 'Currency', SUM((ISNULL((au.tax_federal),
				0.0) + ISNULL((au.tax_state), 0.0) + ISNULL((au.tax_county), 0.0) +
				ISNULL((au.tax_local), 0.0) + ISNULL((au.tax_other), 0.0))) TaxAmount,
				SUM(au.amount +
				/*If implied taxes, then taxes are already included, don't add them again */
				  (CASE WHEN au.is_implied_tax = 'N' THEN (ISNULL((au.tax_federal), 0.0) + ISNULL((au.tax_state), 0.0) +
				    ISNULL((au.tax_county), 0.0) + ISNULL((au.tax_local), 0.0) + ISNULL((au.tax_other), 0.0)) ELSE 0 END)
				/*If informational taxes, then they shouldn't be in the total */
                  - (CASE WHEN au.tax_informational = 'Y' THEN (ISNULL((au.tax_federal), 0.0) + ISNULL((au.tax_state), 0.0) +
				    ISNULL((au.tax_county), 0.0) + ISNULL((au.tax_local), 0.0) + ISNULL((au.tax_other), 0.0)) ELSE 0 END))
					AmountWithTax
				FROM t_usage_interval
				JOIN t_acc_usage au ON au.id_acc = @id_acc AND au.id_usage_interval = @id_interval AND au.id_pi_template IS NOT NULL
				JOIN t_base_props tb_template ON tb_template.id_prop = au.id_pi_template
				JOIN t_pi_template pi_template ON pi_template.id_template = au.id_pi_template
				JOIN t_pi child_kind ON child_kind.id_pi = pi_template.id_pi
				JOIN t_base_props pi_props ON pi_props.id_prop = child_kind.id_pi
				JOIN t_enum_data ed ON ed.id_enum_data = au.id_view
				JOIN t_base_props template_props ON pi_template.id_template = template_props.id_prop
				JOIN t_description template_desc ON template_props.n_display_name = template_desc.id_desc AND template_desc.id_lang_code = @id_lang_code
				LEFT OUTER JOIN t_pi_template parent_template ON parent_template.id_template = pi_template.id_template_parent
				LEFT OUTER JOIN t_pi parent_kind ON parent_kind.id_pi = parent_template.id_pi
				LEFT OUTER JOIN t_enum_data tenum_parent ON tenum_parent.nm_enum_data = parent_kind.nm_productview
				LEFT OUTER JOIN t_base_props tb_po ON tb_po.id_prop = au.id_prod
				LEFT OUTER JOIN t_base_props tb_instance ON tb_instance.id_prop = au.id_pi_instance
				LEFT OUTER JOIN t_description ON t_description.id_desc = tb_po.n_display_name AND t_description.id_lang_code = @id_lang_code
				WHERE
				t_usage_interval.id_interval = @id_interval
				GROUP BY
				--t_pl_map.id_po,t_pl_map.id_pi_instance_parent,
				tb_po.n_display_name,tb_instance.n_display_name,
				t_description.tx_desc,template_desc.tx_desc,
				tb_instance.nm_display_name,tb_template.nm_display_name,
				tb_instance.nm_display_name, -- this shouldn't need to be here!!
				child_kind.nm_productview,
				parent_kind.nm_productview,tenum_parent.id_enum_data,
				pi_props.n_kind,
				id_view,ed.nm_enum_data,ed.id_enum_data,
				au.am_currency,
				tb_template.nm_name,
				pi_template.id_template_parent,
				au.id_pi_instance,
				template_props.n_display_name
				ORDER BY tb_po.n_display_name ASC, pi_template.id_template_parent ASC
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[recursive_inherit_sub_to_accs]'
GO
CREATE PROCEDURE [dbo].[recursive_inherit_sub_to_accs](
    @v_id_sub INT
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @id_acc INT
	DECLARE @id_group INT
	DECLARE accounts CURSOR LOCAL FOR
		SELECT s.id_acc, s.id_group
        FROM   t_sub s
        WHERE  s.id_sub = @v_id_sub AND s.id_group IS NULL
        UNION ALL
        SELECT gm.id_acc, gm.id_group
        FROM   t_sub s
                INNER JOIN t_gsubmember gm ON gm.id_group = s.id_group
        WHERE  s.id_sub = @v_id_sub

	OPEN accounts
	FETCH NEXT FROM accounts INTO @id_acc, @id_group

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC recursive_inherit_sub
            @v_id_audit = NULL,
            @v_id_acc   = @id_acc,
            @v_id_sub   = NULL,
            @v_id_group = @id_group

		FETCH NEXT FROM accounts INTO @id_acc, @id_group
	END

	CLOSE accounts
	DEALLOCATE accounts
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[VW_ADJUSTMENT_DETAILS]'
GO
EXEC sp_refreshview N'[dbo].[VW_ADJUSTMENT_DETAILS]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[VW_NOTDELETED_ADJ_DETAILS]'
GO
EXEC sp_refreshview N'[dbo].[VW_NOTDELETED_ADJ_DETAILS]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_calendar_ID_SCHED] on [dbo].[t_pt_Calendar]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_calendar_ID_SCHED] ON [dbo].[t_pt_Calendar] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_calendar table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[TR_t_pt_currencyexchangerates_ID_SCHED] on [dbo].[t_pt_CurrencyExchangeRates]'
GO
CREATE TRIGGER [dbo].[TR_t_pt_currencyexchangerates_ID_SCHED] ON [dbo].[t_pt_CurrencyExchangeRates] AFTER INSERT, UPDATE AS BEGIN 	DECLARE @n_counter INT 	SELECT @n_counter = COUNT(1) 	FROM   inserted i 	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) 	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) 	IF @n_counter > 0 		RAISERROR('Parent key not found for record in t_pt_currencyexchangerates table', 16, 1) END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[t_be_cor_qu_udrcforquoting]'
GO
CREATE TABLE [dbo].[t_be_cor_qu_udrcforquoting]
(
[c_UDRCForQuoting_Id] [uniqueidentifier] NOT NULL,
[c__version] [int] NOT NULL,
[c_internal_key] [uniqueidentifier] NOT NULL,
[c_CreationDate] [datetime] NULL,
[c_UpdateDate] [datetime] NULL,
[c_UID] [int] NULL,
[c_PI_Id] [int] NULL,
[c_PI_Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[c_StartDate] [datetime] NULL,
[c_EndDate] [datetime] NULL,
[c_Value] [decimal] (22, 10) NULL,
[c_POforQuote_Id] [uniqueidentifier] NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK__t_be_cor__9982FC0861F40838] on [dbo].[t_be_cor_qu_udrcforquoting]'
GO
ALTER TABLE [dbo].[t_be_cor_qu_udrcforquoting] ADD CONSTRAINT [PK__t_be_cor__9982FC0861F40838] PRIMARY KEY CLUSTERED  ([c_UDRCForQuoting_Id])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [acc_template_subs_pub_idx1] on [dbo].[t_acc_template_subs_pub]'
GO
CREATE CLUSTERED INDEX [acc_template_subs_pub_idx1] ON [dbo].[t_acc_template_subs_pub] ([id_acc_template], [id_po])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [pk_mvm_scheduled_tasks] on [dbo].[mvm_scheduled_tasks]'
GO
ALTER TABLE [dbo].[mvm_scheduled_tasks] ADD CONSTRAINT [pk_mvm_scheduled_tasks] PRIMARY KEY CLUSTERED  ([mvm_logical_cluster], [mvm_status], [mvm_scheduled_dt], [mvm_poll_guid], [mvm_task_guid])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [acc_template_subs_pub_idx2] on [dbo].[t_acc_template_subs_pub]'
GO
CREATE NONCLUSTERED INDEX [acc_template_subs_pub_idx2] ON [dbo].[t_acc_template_subs_pub] ([id_acc_template], [id_group])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [dbo].[t_rsched_pub]'
GO
ALTER TABLE [dbo].[t_rsched_pub] ADD CONSTRAINT [fk1_t_rsched_pub] FOREIGN KEY ([id_sched]) REFERENCES [dbo].[t_base_props] ([id_prop])
ALTER TABLE [dbo].[t_rsched_pub] ADD CONSTRAINT [fk5_t_rsched_pub] FOREIGN KEY ([id_pt]) REFERENCES [dbo].[t_rulesetdefinition] ([id_paramtable])
ALTER TABLE [dbo].[t_rsched_pub] ADD CONSTRAINT [fk2_t_rsched_pub] FOREIGN KEY ([id_eff_date]) REFERENCES [dbo].[t_effectivedate] ([id_eff_date])
ALTER TABLE [dbo].[t_rsched_pub] ADD CONSTRAINT [fk4_t_rsched_pub] FOREIGN KEY ([id_pricelist]) REFERENCES [dbo].[t_pricelist] ([id_pricelist])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating extended properties'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tells the calculate tax adapters which algorithm to use when calculating the tax amount for tax inclusive amounts. If set to True, then the standard implied tax algorithm is tax=amount - amount/(1.0+rate). If set to False, the alternate implied tax algorithm is tax=amount*rate.', 'SCHEMA', N'dbo', 'TABLE', N't_av_Internal', 'COLUMN', N'c_UseStdImpliedTaxAlg'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_addextendedproperty N'MS_Description', N'', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_udrcforquoting', NULL, NULL
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_addextendedproperty N'MS_Description', 'Version of Business Model Entity', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_udrcforquoting', 'COLUMN', N'c__version'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of creation Business Model Entity', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_udrcforquoting', 'COLUMN', N'c_CreationDate'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_addextendedproperty N'MS_Description', '', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_udrcforquoting', 'COLUMN', N'c_EndDate'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priceable item identity', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_udrcforquoting', 'COLUMN', N'c_PI_Id'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priceable item name', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_udrcforquoting', 'COLUMN', N'c_PI_Name'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_addextendedproperty N'MS_Description', '', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_udrcforquoting', 'COLUMN', N'c_StartDate'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Id', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_udrcforquoting', 'COLUMN', N'c_UID'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of update Business Model Entity', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_udrcforquoting', 'COLUMN', N'c_UpdateDate'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_addextendedproperty N'MS_Description', '', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_udrcforquoting', 'COLUMN', N'c_Value'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Altering UpdatePrivateTempates procedure'
GO
ALTER PROCEDURE UpdatePrivateTempates
(
	@id_template INT,
	@p_systemdate  DATETIME
)    
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @id_account INT
	DECLARE @id_parent_account_template INT
	DECLARE @id_acc_type INT
	
	SELECT @id_acc_type = id_acc_type, @id_account = id_folder
	  FROM t_acc_template WHERE id_acc_template = @id_template
	
  /*delete old values for properties of private templates of current account and child accounts*/
  DELETE tp
    FROM t_acc_template_props tp
   WHERE tp.id_acc_template IN
        (SELECT t.id_acc_template
           FROM t_account_ancestor aa
                JOIN t_acc_template t on aa.id_descendent = t.id_folder AND t.id_acc_type = @id_acc_type
          WHERE aa.id_ancestor = @id_account)
  
  /*delete old values for subscriptions of private templates of current account and child accounts*/
  DELETE tp
    FROM t_acc_template_subs tp
   WHERE tp.id_acc_template IN
        (SELECT t.id_acc_template
           FROM t_account_ancestor aa
                JOIN t_acc_template t on aa.id_descendent = t.id_folder AND t.id_acc_type = @id_acc_type
          WHERE aa.id_ancestor = @id_account)
  
  /*insert new values for private template from public template for all sub-tree of current account.*/
  INSERT INTO t_acc_template_props 
          (id_acc_template, nm_prop_class, nm_prop, nm_value)
   SELECT id_acc_template, nm_prop_class, nm_prop, nm_value
     FROM t_acc_template_props_pub
    WHERE id_acc_template IN
        (SELECT t.id_acc_template
           FROM t_account_ancestor aa
                JOIN t_acc_template t on aa.id_descendent = t.id_folder AND t.id_acc_type = @id_acc_type
          WHERE aa.id_ancestor = @id_account)

  INSERT INTO t_acc_template_subs
          (id_po, id_group, id_acc_template, vt_start, vt_end)
   SELECT id_po, id_group, id_acc_template, vt_start, vt_end
     FROM t_acc_template_subs_pub
    WHERE id_acc_template IN
        (SELECT t.id_acc_template
           FROM t_account_ancestor aa
                JOIN t_acc_template t on aa.id_descendent = t.id_folder AND t.id_acc_type = @id_acc_type
          WHERE aa.id_ancestor = @id_account)

    /*insert private template of an account's parent*/
    INSERT INTO t_acc_template_props
                (id_acc_template, nm_prop_class, nm_prop, nm_value)
    SELECT @id_template, nm_prop_class, nm_prop, nm_value 
      FROM t_acc_template_props tatpp
           JOIN (SELECT TOP 1 aa.num_generations, t.id_acc_template
                   FROM t_account_ancestor aa
                        JOIN t_acc_template t ON aa.id_ancestor = t.id_folder AND t.id_acc_type = @id_acc_type
                  WHERE aa.id_descendent = @id_account AND aa.id_descendent <> aa.id_ancestor
                 ORDER BY aa.num_generations
                ) a ON tatpp.id_acc_template = a.id_acc_template
     WHERE NOT EXISTS (SELECT 1 FROM t_acc_template_props t WHERE t.id_acc_template = @id_template AND t.nm_prop = tatpp.nm_prop)

    INSERT INTO t_acc_template_subs
                (id_po, id_group, id_acc_template, vt_start, vt_end)
    SELECT id_po, id_group, @id_template, vt_start, vt_end
      FROM t_acc_template_subs tatps
           JOIN (SELECT TOP 1 aa.num_generations, t.id_acc_template
                   FROM t_account_ancestor aa
                        JOIN t_acc_template t ON aa.id_ancestor = t.id_folder AND t.id_acc_type = @id_acc_type
                  WHERE aa.id_descendent = @id_account AND aa.id_descendent <> aa.id_ancestor
                 ORDER BY aa.num_generations
                ) a ON tatps.id_acc_template = a.id_acc_template
     WHERE NOT EXISTS (SELECT 1 FROM t_acc_template_subs t WHERE t.id_acc_template = @id_template AND t.id_po = tatps.id_po)

	--select hierarchy structure of account's tree.
	DECLARE @id_parent_acc_template INT
	DECLARE @current_id INT
	DECLARE db_cursor CURSOR FOR 
	        SELECT ISNULL(pa.id_acc_template, a1.id_acc_template) AS id_parent_acc_template, a2.id_acc_template AS current_id
			FROM   t_account_ancestor aa
					JOIN t_acc_template a1 on aa.id_ancestor = a1.id_folder AND a1.id_acc_type = @id_acc_type
					JOIN t_acc_template a2 on aa.id_descendent = a2.id_folder AND a2.id_acc_type = @id_acc_type
					LEFT JOIN (
					SELECT t2.id_acc_template, a3.id_descendent
					FROM   t_account_ancestor a3
							JOIN t_acc_template t2 ON a3.id_ancestor = t2.id_folder AND t2.id_acc_type = @id_acc_type
					WHERE  num_generations =
							(SELECT MIN(num_generations)
							FROM   t_account_ancestor ac
									JOIN t_acc_template t3 ON ac.id_ancestor = t3.id_folder
							WHERE  ac.id_descendent = a3.id_descendent AND num_generations > 0)

					) pa ON pa.id_descendent = aa.id_descendent
			WHERE aa.id_ancestor = @id_account AND aa.num_generations > 0
			ORDER BY aa.num_generations ASC
	
	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @id_parent_acc_template, @current_id
	WHILE @@FETCH_STATUS = 0   
	BEGIN
		--recursive merge properties to private template of each level of child account from private template of current account 
		INSERT INTO t_acc_template_props
					(id_acc_template, nm_prop_class, nm_prop, nm_value)
		SELECT @current_id, nm_prop_class, nm_prop, nm_value 
		  FROM t_acc_template_props tatpp 
		 WHERE tatpp.id_acc_template = @id_parent_acc_template
		   AND NOT EXISTS (SELECT 1 FROM t_acc_template_props t WHERE t.id_acc_template = @current_id AND t.nm_prop = tatpp.nm_prop)
		
		INSERT INTO t_acc_template_subs
					(id_po, id_group, id_acc_template, vt_start, vt_end)
		SELECT id_po, id_group, @current_id, vt_start, vt_end
		  FROM t_acc_template_subs tatps
		 WHERE tatps.id_acc_template = @id_parent_acc_template
		   AND NOT EXISTS (SELECT 1 FROM t_acc_template_subs t WHERE t.id_acc_template = @current_id AND t.id_po = tatps.id_po)
		
		FETCH NEXT FROM db_cursor INTO @id_parent_acc_template, @current_id
	END

	CLOSE db_cursor
	DEALLOCATE db_cursor
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Altering ApplyAccountTemplate procedure'
GO
ALTER PROCEDURE ApplyAccountTemplate
(
	@accountTemplateId          int,
	@sessionId                  int,
	@systemDate                 datetime,
	@sub_start                  datetime,
	@sub_end                    datetime,
	@next_cycle_after_startdate char, /* Y or N */
	@next_cycle_after_enddate   char, /* Y or N */
	@id_event_success           int,
	@id_event_failure           int,
	@account_id					int = NULL
)
AS
	SET NOCOUNT ON


	DECLARE @nRetryCount int
	SET @nRetryCount = 0

	DECLARE @DetailTypeGeneral int
	DECLARE @DetailResultInformation int
	DECLARE @DetailTypeSubscription int
	DECLARE @id_acc_type int
	DECLARE @id_acc int
	DECLARE @user_id int

	SELECT @id_acc_type = id_acc_type, @id_acc = id_folder FROM t_acc_template WHERE id_acc_template = @accountTemplateId
	SELECT @user_id = ts.id_submitter FROM t_acc_template_session ts WHERE ts.id_session = @sessionId


	SELECT @DetailTypeGeneral = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Success'
	SELECT @DetailResultInformation = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Information'
	SELECT @DetailTypeSubscription = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription'
	--!!!Starting application of template
	INSERT INTO t_acc_template_session_detail
		( 
			id_session,    
			n_detail_type,
			n_result,    
			dt_detail,  
			nm_text,    
			n_retry_count
		)
		VALUES
		(
			@sessionId,
			@DetailTypeGeneral,
			@DetailResultInformation,
			getdate(),
			'Starting application of template',
			@nRetryCount
		)

	-- Updating session details with a number of themplates to be applied in the session
	UPDATE t_acc_template_session
	SET    n_templates = (SELECT COUNT(1) FROM t_account_ancestor aa JOIN t_acc_template at ON aa.id_ancestor = @id_acc AND aa.id_descendent = at.id_folder)
	WHERE  id_session = @sessionId

	DECLARE @incIdTemplate INT
	--Select account hierarchy for current template and for each child template.
	DECLARE accTemplateCursor CURSOR FOR

	SELECT tat.id_acc_template

	FROM t_account_ancestor taa
	INNER JOIN t_acc_template tat ON taa.id_descendent = tat.id_folder AND tat.id_acc_type = @id_acc_type
	WHERE taa.id_ancestor = @id_acc

	OPEN accTemplateCursor   
	FETCH NEXT FROM accTemplateCursor INTO @incIdTemplate

	WHILE @@FETCH_STATUS = 0
	BEGIN

		--Apply account template to appropriate account list.
		EXEC ApplyTemplateToAccounts
			@idAccountTemplate          = @incIdTemplate,
			@sub_start                  = @sub_start,
			@sub_end                    = @sub_end,
			@next_cycle_after_startdate = @next_cycle_after_startdate,
			@next_cycle_after_enddate   = @next_cycle_after_enddate,
			@user_id                    = @user_id,
			@id_event_success           = @id_event_success,
			@id_event_failure           = @id_event_failure,
			@systemDate                 = @systemDate,
			@sessionId                  = @sessionId,
			@retrycount                 = @nRetryCount,
			@account_id				    = @account_id
		
		UPDATE t_acc_template_session
		SET    n_templates_applied = n_templates_applied + 1
		WHERE  id_session = @sessionId

		FETCH NEXT FROM accTemplateCursor INTO @incIdTemplate
	END

	CLOSE accTemplateCursor   
	DEALLOCATE accTemplateCursor

    /* Apply default security */
    INSERT INTO t_policy_role
    SELECT pd.id_policy, pr.id_role
    FROM   t_account_ancestor aa
           JOIN t_account_ancestor ap ON ap.id_descendent = aa.id_descendent AND ap.num_generations = 1
           JOIN t_principal_policy pp ON pp.id_acc = ap.id_ancestor AND pp.policy_type = 'D'
           JOIN t_principal_policy pd ON pd.id_acc = aa.id_descendent AND pd.policy_type = 'A'
           JOIN t_policy_role pr ON pr.id_policy = pp.id_policy
           JOIN t_acc_template t ON aa.id_ancestor = t.id_folder AND t.b_applydefaultpolicy = 'Y'
    WHERE  t.id_acc_template = @accountTemplateId
       AND aa.num_generations > 0
       AND NOT EXISTS (SELECT 1 FROM t_policy_role pr2 WHERE pr2.id_policy = pd.id_policy AND pr2.id_role = pr.id_role)
   
	-- Finalize session state
	UPDATE t_acc_template_session
	SET    n_templates = n_templates_applied
	WHERE  id_session = @sessionId

	--!!!Template application complete
	INSERT INTO t_acc_template_session_detail
	( 
		id_session,
		n_detail_type,
		n_result,
		dt_detail,
		nm_text,
		n_retry_count
	)
	VALUES
	(
		@sessionId,
		@DetailTypeGeneral,
		@DetailResultInformation,
		getdate(),
		'Template application complete',
		@nRetryCount
	)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Creating ApplyTemplateToOneAccount procedure'
GO

CREATE PROCEDURE ApplyTemplateToOneAccount
	@accountID INTEGER
	,@p_systemdate DATETIME
	,@p_acc_type NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @templateId INT
	DECLARE @templateOwner INT

	select top 1 @templateId = id_acc_template
			, @templateOwner = template.id_folder
	from
				t_acc_template template
	INNER JOIN t_account_ancestor ancestor on template.id_folder = ancestor.id_ancestor
	INNER JOIN t_account_mapper mapper on mapper.id_acc = ancestor.id_ancestor
	inner join t_account_type atype on template.id_acc_type = atype.id_type
	left join t_acc_tmpl_types tatt on tatt.id = 1
			WHERE id_descendent = @accountID AND
				@p_systemdate between vt_start AND vt_end AND
				(atype.name = @p_acc_type or tatt.all_types = 1)
	ORDER BY num_generations asc

	IF @templateId IS NOT NULL
	BEGIN
        DECLARE @sessionId INTEGER
		EXECUTE GetCurrentID 'id_template_session', @sessionId OUT
		insert into t_acc_template_session(id_session, id_template_owner, nm_acc_type, dt_submission, id_submitter, nm_host, n_status, n_accts, n_subs)
        values (@sessionId, @templateOwner, @p_acc_type, @p_systemdate, 0, '', 0, 0, 0)
		execute ApplyAccountTemplate @templateId, @sessionId, @p_systemdate, NULL, NULL, 'N', 'N', NULL, NULL, @accountID, 'N'
	END
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Altering ApplyTemplateToOneAccount procedure'
GO

ALTER PROCEDURE
UpdateAccPropsFromTemplate (
	@idAccountTemplate INTEGER,
	@accountId INTEGER = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @values nvarchar(max)
	DECLARE @viewName nvarchar(256)
	DECLARE @tableName nvarchar(256)
	DECLARE @additionalOptionString nvarchar(256)

	--SELECT list of account view by name of tables which start with 't_av'
	DECLARE db_cursor cursor for
		SELECT
			distinct(v.account_view_name)
			,'t_av_' + substring(td.nm_enum_data, charindex('/', td.nm_enum_data) + 1, len(td.nm_enum_data)) as tableName
			,CASE WHEN charindex(']', tp.nm_prop) <> 0
				  THEN substring(tp.nm_prop, charindex('[', tp.nm_prop)+ 1, charindex(']', tp.nm_prop) - charindex('[', tp.nm_prop) - 1)
				  ELSE ''
			 END as additionalOption
		FROM t_enum_data td
		JOIN t_account_type_view_map v on v.id_account_view = td.id_enum_data
		JOIN t_account_view_prop p on v.id_type = p.id_account_view
		JOIN t_acc_template_props tp on tp.nm_prop like v.account_view_name + '%' and tp.nm_prop like '%' + p.nm_name
		WHERE tp.id_acc_template = @idAccountTemplate

	OPEN db_cursor
	FETCH NEXT FROM db_cursor INTO @viewName, @tableName, @additionalOptionString

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @values = ''
		--"Magic numbers" were took FROM MetraTech.Interop.MTYAAC.PropValType enumeration.
		SELECT @values = @values + CASE WHEN ROW_NUMBER() OVER(ORDER BY nm_column_name) = 1 THEN '' ELSE ',' END + nm_column_name + ' '
					+   case when nm_prop_class in(0, 1, 4, 5, 6, 8, 9, 12, 13) then ' = ''' + REPLACE(nm_value,'''','''''') + ''' '
								when nm_prop_class in(2, 3, 10, 11, 14)            then ' = ' + REPLACE(nm_value,'''','''''') + ' '
								when nm_prop_class = 7                             then case when upper(nm_value) = 'TRUE' then ' = 1 ' else ' = 0 ' END
								else ''''' '
						END
			FROM t_account_type_view_map v
			JOIN t_account_view_prop p on v.id_type = p.id_account_view
			JOIN t_acc_template_props tp on tp.nm_prop like v.account_view_name + '%' and tp.nm_prop like '%.' + REPLACE(REPLACE(REPLACE(p.nm_name, N'\', N'\\'), N'_', N'\_'), N'%', N'\%') ESCAPE N'\'
			WHERE tp.id_acc_template = @idAccountTemplate
				and tp.nm_prop like @viewName + '%'
			ORDER BY nm_column_name
		
		DECLARE @condition nvarchar(max)
		SET @condition = ''
		IF(@additionalOptionString <> '')
		BEGIN
			DECLARE @conditionItem nvarchar(max)
			DECLARE conditionCursor cursor for
			SELECT items FROM SplitStringByChar(@additionalOptionString,',')
			OPEN conditionCursor
			fetch next FROM conditionCursor into @conditionItem
			while @@FETCH_STATUS = 0
			BEGIN
				
				DECLARE @enumValue nvarchar(256)
				DECLARE @val1 nvarchar(256)
				DECLARE @val2 nvarchar(256)
				
				SET @val1 = substring(@conditionItem, 0, charindex('=', @conditionItem))
				
				SET @val2 = substring(@conditionItem, charindex('=', @conditionItem) + 1, len(@conditionItem) - charindex('=', @conditionItem) + 1)
				SET @val2 = replace(@val2, '_', '-')
				
				--Select value fot additional condition by namespace and name of enum.
				SELECT @enumValue = id_enum_data FROM t_enum_data
				WHERE nm_enum_data =
					(SELECT nm_space + '/' + nm_enum + '/'
					FROM t_account_type_view_map v JOIN t_account_view_prop p on v.id_type = p.id_account_view
					WHERE upper(account_view_name) = upper(@viewName) AND upper(nm_name) = upper(@val1)) + upper(@val2)
				
				--Creation additional condition for update account view properties for each account view.
				SET @condition = @condition + 'c_' + @val1 + ' = ' + convert(nvarchar, @enumValue) + ' AND '
				fetch next FROM conditionCursor into @conditionItem
			END
			close conditionCursor
			deallocate conditionCursor
		END
				
		DECLARE @dSql nvarchar(max)
		--Completion to creation dynamic sql-string for update account view.
		IF @accountId IS NULL BEGIN
			SET @condition = @condition + 'id_acc in (SELECT id_descendent FROM t_vw_get_accounts_by_tmpl_id WHERE id_template = ' + convert(nvarchar, @idAccountTemplate) + ')'
		END 
		ELSE BEGIN
			SET @condition = @condition + 'id_acc = ' + convert(nvarchar, @accountId) + ' '
		END
		SET @dSql = 'UPDATE ' + @tableName + ' SET ' + @values + ' WHERE ' + @condition
		execute(@dSql)
		fetch next FROM db_cursor into @viewName, @tableName, @additionalOptionString
	END

	close db_cursor
	deallocate db_cursor
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Altering procedure UpdatePayerFromTemplate'
GO
ALTER PROCEDURE UpdatePayerFromTemplate (
	@IdAcc INTEGER
	,@PayerId INTEGER
	,@systemDate DATETIME
	,@PaymentStart DATETIME
	,@PaymentEnd DATETIME
	,@OldPayerId INTEGER
	,@p_account_currency NVARCHAR(5)
	,@errorStr NVARCHAR(4000) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @PayerExists INTEGER
	SELECT @PayerExists = COUNT(*) FROM t_account where id_acc = @PayerID
	IF (@PayerExists <> 0)
	BEGIN
		IF (@PayerID <> -1)
		BEGIN
		DECLARE @payerenddate DATETIME
		DECLARE @p_status INTEGER
		SET @p_status = 0
		SELECT @payerenddate = dbo.MTMaxDate()
			IF (@PayerID = @OldPayerId)
			BEGIN
				EXEC UpdatePaymentRecord @payerID,@IdAcc,@PaymentStart,@PaymentEnd,@systemDate,@payerenddate,@systemDate,1, @p_account_currency, @p_status output
				if (@p_status <> 1)
				begin
					SET @errorStr = 'No payment record changed for account. Return code is ' + CAST(@p_status AS NVARCHAR(255))
					SET @p_status = 0
				end
			end
			else
			begin
				DECLARE @payerbillable NVARCHAR(1)
				select @payerbillable = dbo.IsAccountBillable(@PayerID)
				exec CreatePaymentRecord @payerID,@IdAcc,@systemDate,@payerenddate,@payerbillable,@systemDate,'N', 1, @p_account_currency, @p_status output
				if (@p_status <> 1)
				begin
					SET @errorStr = 'No payment record created for account. Return code is ' + CAST(@p_status AS NVARCHAR(255))
					SET @p_status = 0
				end
			end
		END
	END
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Creating procedure recursive_inherit_sub_by_rsch'
GO
CREATE PROCEDURE recursive_inherit_sub_by_rsch
(
	@v_id_rsched   int
)
AS
	SET NOCOUNT ON

	DECLARE @id_sub int
	SELECT @id_sub = MAX(pm.id_sub)
    FROM   t_pl_map pm
           INNER JOIN t_rsched r
                ON   r.id_pricelist = pm.id_pricelist
                AND pm.id_pi_template = r.id_pi_template
    WHERE  r.id_sched = @v_id_rsched AND pm.id_sub IS NOT NULL

	IF @id_sub IS NOT NULL
		EXEC recursive_inherit_sub_to_accs @v_id_sub = @id_sub
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Altering procedure mtsp_generate_stateful_rcs'
GO
ALTER PROCEDURE [dbo].[mtsp_generate_stateful_rcs]
                                            @v_id_interval  int
                                           ,@v_id_billgroup int
                                           ,@v_id_run       int
                                           ,@v_id_batch     varchar(256)
                                           ,@v_n_batch_size int
                                                               ,@v_run_date   datetime
                                           ,@p_count      int OUTPUT
AS
BEGIN
      /* SET NOCOUNT ON added to prevent extra result sets from
         interfering with SELECT statements. */
      SET NOCOUNT ON;
  DECLARE @total_rcs  int,
          @total_flat int,
          @total_udrc int,
          @n_batches  int,
          @id_flat    int,
          @id_udrc    int,
          @id_message bigint,
          @id_ss      int,
          @tx_batch   binary(16);
INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Retrieving RC candidates');
SELECT
*
INTO
#TMP_RC
FROM(
SELECT
newid() AS idSourceSess,
      'Arrears' AS c_RCActionType
      ,pci.dt_start      AS c_RCIntervalStart
      ,pci.dt_end      AS c_RCIntervalEnd
      ,ui.dt_start      AS c_BillingIntervalStart
      ,ui.dt_end          AS c_BillingIntervalEnd
      ,dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)          AS c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart          AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
      ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
      ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
      ,case when rcr.b_prorate_on_deactivate ='Y' then '1' else '0' end       AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
      ,rw.c__accountid AS c__AccountID
      ,rw.c__payingaccount      AS c__PayingAccount
      ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
      ,rw.c__productofferingid      AS c__ProductOfferingID
      ,pci.dt_end      AS c_BilledRateDate
      ,rw.c__subscriptionid      AS c__SubscriptionID
,rw.c_payerstart,rw.c_payerend,case when rw.c_unitvaluestart < '1970-01-01 00:00:00' THEN '1970-01-01 00:00:00' ELSE rw.c_unitvaluestart END AS c_unitvaluestart ,rw.c_unitvalueend
, rw.c_unitvalue
, rcr.n_rating_type AS c_RatingType
      FROM t_usage_interval ui
      INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
      INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup
      INNER LOOP JOIN t_recur_window rw WITH(INDEX(rc_window_time_idx)) ON bgm.id_acc = rw.c__payingaccount 
                                   AND rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* interval overlaps with payer */
                                   AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* interval overlaps with cycle */
                                   AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* interval overlaps with membership */
                                   AND rw.c_subscriptionstart   < ui.dt_end AND rw.c_subscriptionend   > ui.dt_start /* interval overlaps with subscription */
                                   AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* interval overlaps with UDRC */
      INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
      INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) ELSE NULL END
      /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
      INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_end BETWEEN ui.dt_start        AND ui.dt_end                             /* rc end falls in this interval */
                                   AND pci.dt_end BETWEEN rw.c_payerstart    AND rw.c_payerend                         /* rc end goes to this payer */
                                   AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
                                   AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
      INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      where 1=1
      and ui.id_interval = @v_id_interval
      and bg.id_billgroup = @v_id_billgroup
      and rcr.b_advance <> 'Y'
UNION ALL
SELECT
newid() AS idSourceSess,
      'Advance' AS c_RCActionType
      ,pci.dt_start      AS c_RCIntervalStart
      ,pci.dt_end      AS c_RCIntervalEnd
      ,nui.dt_start      AS c_BillingIntervalStart
      ,nui.dt_end          AS c_BillingIntervalEnd
      ,CASE WHEN rcr.tx_cycle_mode <> 'Fixed' AND nui.dt_start <> c_cycleEffectiveDate 
       THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(c_cycleEffectiveDate), pci.dt_start)
       ELSE pci.dt_start END as c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart          AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
      ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
      ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
      ,case when rcr.b_prorate_on_deactivate ='Y' then '1' else '0' end       AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
      ,rw.c__accountid AS c__AccountID
      ,rw.c__payingaccount      AS c__PayingAccount
      ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
      ,rw.c__productofferingid      AS c__ProductOfferingID
      ,pci.dt_start      AS c_BilledRateDate
      ,rw.c__subscriptionid      AS c__SubscriptionID
,rw.c_payerstart,rw.c_payerend,case when rw.c_unitvaluestart < '1970-01-01 00:00:00' THEN '1970-01-01 00:00:00' ELSE rw.c_unitvaluestart END AS c_unitvaluestart,rw.c_unitvalueend
, rw.c_unitvalue
, rcr.n_rating_type AS c_RatingType
      FROM t_usage_interval ui
      INNER LOOP JOIN t_usage_interval nui ON ui.id_usage_cycle = nui.id_usage_cycle AND dbo.AddSecond(ui.dt_end) = nui.dt_start
      INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
      INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup
      INNER LOOP JOIN t_recur_window rw WITH(INDEX(rc_window_time_idx)) ON bgm.id_acc = rw.c__payingaccount 
                                   AND rw.c_payerstart          < nui.dt_end AND rw.c_payerend          > nui.dt_start /* next interval overlaps with payer */
                                   AND rw.c_cycleeffectivestart < nui.dt_end AND rw.c_cycleeffectiveend > nui.dt_start /* next interval overlaps with cycle */
                                   AND rw.c_membershipstart     < nui.dt_end AND rw.c_membershipend     > nui.dt_start /* next interval overlaps with membership */
                                   AND rw.c_subscriptionstart   < ui.dt_end AND rw.c_subscriptionend   > nui.dt_start /* next interval overlaps with subscription */
                                   AND rw.c_unitvaluestart      < nui.dt_end AND rw.c_unitvalueend      > nui.dt_start /* next interval overlaps with UDRC */
      INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
      INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) ELSE NULL END
      INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_start BETWEEN nui.dt_start     AND nui.dt_end                            /* rc start falls in this interval */
                                   AND pci.dt_start BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
                                   AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
                                   AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
      INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      where 1=1
      and ui.id_interval = @v_id_interval
      and bg.id_billgroup = @v_id_billgroup
      and rcr.b_advance = 'Y'
)A      ;

SELECT @total_rcs  = COUNT(1) FROM #tmp_rc;

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'RC Candidate Count: ' + CAST(@total_rcs AS VARCHAR));

if @total_rcs > 0
BEGIN

SELECT @total_flat = COUNT(1) FROM #tmp_rc where c_unitvalue is null;
SELECT @total_udrc = COUNT(1) FROM #tmp_rc where c_unitvalue is not null;

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Flat RC Candidate Count: ' + CAST(@total_flat AS VARCHAR));
INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'UDRC RC Candidate Count: ' + CAST(@total_udrc AS VARCHAR));

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Session Set Count: ' + CAST(@v_n_batch_size AS VARCHAR));
INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch: ' + @v_id_batch);

SELECT @tx_batch = cast(N'' as xml).value('xs:hexBinary(sql:variable("@v_id_batch"))', 'binary(16)');
INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch ID: ' + CAST(@tx_batch AS varchar));

if @total_flat > 0
begin

    
set @id_flat = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
      'metratech.com/flatrecurringcharge');
    
SET @n_batches = (@total_flat / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT INTO t_session 
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    idSourceSess AS id_source_sess
FROM #tmp_rc where c_unitvalue is null;
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, id_svc, b_root, COUNT(1) as session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    @id_flat AS id_svc,
    1 AS b_root
FROM #tmp_rc
where c_unitvalue is null) a
GROUP BY a.id_message, a.id_ss, a.id_svc, a.b_root;

INSERT INTO t_svc_FlatRecurringCharge
(id_source_sess
    ,id_parent_source_sess
    ,id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
    ,c_ProrateInstantly 
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,c__IntervalID
    ,c__Resubmit
    ,c__TransactionCookie
    ,c__CollectionID)
SELECT 
    idSourceSess AS id_source_sess
    ,NULL AS id_parent_source_sess
    ,NULL AS id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
    ,c_ProrateInstantly 
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,@v_id_interval AS c__IntervalID
    ,'0' AS c__Resubmit
    ,NULL AS c__TransactionCookie
    ,@tx_batch AS c__CollectionID
FROM #tmp_rc
where c_unitvalue is null;
          INSERT
          INTO t_message
            (
              id_message,
              id_route,
              dt_crt,
              dt_metered,
              dt_assigned,
              id_listener,
              id_pipeline,
              dt_completed,
              id_feedback,
              tx_TransactionID,
              tx_sc_username,
              tx_sc_password,
              tx_sc_namespace,
              tx_sc_serialized,
              tx_ip_address
            )
            SELECT
              id_message,
              NULL,
              @v_run_date,
              @v_run_date,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              '127.0.0.1'
            FROM
              (SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message
              FROM #tmp_rc
              WHERE c_unitvalue IS NULL
              ) a
            GROUP BY a.id_message;

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting Flat RCs');

END;
if @total_udrc > 0
begin

set @id_udrc = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
      'metratech.com/udrecurringcharge');
    
SET @n_batches = (@total_udrc / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT INTO t_session 
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    idSourceSess AS id_source_sess
FROM #tmp_rc where c_unitvalue is not null;
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, id_svc, b_root, COUNT(1) as session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    @id_udrc AS id_svc,
    1 AS b_root
FROM #tmp_rc
where c_unitvalue is not null) a
GROUP BY a.id_message, a.id_ss, a.id_svc, a.b_root;

INSERT INTO t_svc_UDRecurringCharge
(id_source_sess, id_parent_source_sess, id_external, c_RCActionType, c_RCIntervalStart,c_RCIntervalEnd,c_BillingIntervalStart,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
/*    ,c_ProrateInstantly */
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,c__IntervalID
    ,c__Resubmit
    ,c__TransactionCookie
    ,c__CollectionID
      ,c_unitvaluestart
      ,c_unitvalueend
      ,c_unitvalue
      ,c_ratingtype)
SELECT 
    idSourceSess AS id_source_sess
    ,NULL AS id_parent_source_sess
    ,NULL AS id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
/*    ,c_ProrateInstantly */
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,@v_id_interval AS c__IntervalID
    ,'0' AS c__Resubmit
    ,NULL AS c__TransactionCookie
    ,@tx_batch AS c__CollectionID
      ,c_unitvaluestart
      ,c_unitvalueend
      ,c_unitvalue
      ,c_ratingtype
FROM #tmp_rc
where c_unitvalue is not null;

          INSERT
          INTO t_message
            (
              id_message,
              id_route,
              dt_crt,
              dt_metered,
              dt_assigned,
              id_listener,
              id_pipeline,
              dt_completed,
              id_feedback,
              tx_TransactionID,
              tx_sc_username,
              tx_sc_password,
              tx_sc_namespace,
              tx_sc_serialized,
              tx_ip_address
            )
            SELECT
              id_message,
              NULL,
              @v_run_date,
              @v_run_date,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              '127.0.0.1'
            FROM
              (SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message
              FROM #tmp_rc
              WHERE c_unitvalue IS NOT NULL
              ) a
            GROUP BY a.id_message;

                  INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting UDRC RCs');

END;

 END;

 SET @p_count = @total_rcs;

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Info', 'Finished submitting RCs, count: ' + CAST(@total_rcs AS VARCHAR));

END;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Altering procedure CreateUsagePartitions'
GO
ALTER PROCEDURE CreateUsagePartitions
AS
BEGIN TRY
IF dbo.IsSystemPartitioned() = 0
	RAISERROR('System not enabled for partitioning.', 16, 1)

/* Vars for iterating through the new partition list
*/
DECLARE @cur CURSOR  
DECLARE @dt_start DATETIME
DECLARE @dt_end DATETIME
DECLARE @id_interval_start INT
DECLARE @id_interval_end INT
DECLARE @parts TABLE (
			partition_name NVARCHAR(100),
			dt_start DATETIME,
			dt_end DATETIME,
			interval_start INT,
			interval_end INT
		)
					
EXEC GeneratePartitionSequence @cur OUT

/* Get first row of partition info*/
FETCH @cur INTO	@dt_start, @dt_end, @id_interval_start, @id_interval_end

/* pause pipeline to reduce contention */
IF (@@FETCH_STATUS = 0) EXEC PausePipelineProcessing 1

/* Iterate through partition sequence */
WHILE (@@fetch_status = 0)
BEGIN
	DECLARE @partition_name NVARCHAR(100)
	
	IF NOT EXISTS (SELECT * FROM sys.partition_schemes WHERE name = dbo.prtn_GetUsagePartitionSchemaName())
	BEGIN
		EXEC prtn_CreatePartitionSchema @id_interval_end, @dt_end, @partition_name OUT
		
		-- insert information about default partition						
		INSERT INTO t_partition
		(partition_name, b_default, dt_start, dt_end, id_interval_start, id_interval_end, b_active)
		VALUES
		(dbo.prtn_GetDefaultPartitionName(), 'Y', DATEADD(DAY, 1, @dt_end), dbo.MTMaxdate(), @id_interval_end + 1, 2147483647, 'N')
		
		INSERT INTO @parts
		VALUES
		(dbo.prtn_GetDefaultPartitionName(), DATEADD(DAY, 1, @dt_end), dbo.MTMaxdate(), @id_interval_end + 1, 2147483647)
	END
	ELSE
	BEGIN
		EXEC prtn_AlterPartitionSchema @id_interval_end, @dt_end, @partition_name OUT
		
		-- update start of default partition
		UPDATE t_partition
		SET
			dt_start = DATEADD(DAY, 1, @dt_end),			
			id_interval_start = @id_interval_end + 1
		WHERE  b_default = 'Y'
	END
	
	-- insert information about created partition			
	INSERT INTO t_partition
		(partition_name, b_default, dt_start, dt_end, id_interval_start, id_interval_end, b_active)
		VALUES
		(@partition_name, 'N', @dt_start, @dt_end, @id_interval_start, @id_interval_end, 'Y')
		
	INSERT INTO @parts
		VALUES
		(@partition_name, @dt_start, @dt_end, @id_interval_start, @id_interval_end)
	
	/* Get next patition info */
	FETCH @cur INTO @dt_start, @dt_end, @id_interval_start, @id_interval_end 
END

/* Deallocate the cursor */
CLOSE @cur
DEALLOCATE @cur

/* unpause pipeline */
EXEC PausePipelineProcessing 0

/* Correct default partition start if it was just created */
UPDATE @parts
SET							
	dt_start = DATEADD(DAY, 1, @dt_end),							
	interval_start = @id_interval_end + 1
WHERE dt_end = dbo.MTMaxdate() 

/* Returning partition info*/
SELECT * FROM @parts ORDER BY dt_start

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT	
	SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
	EXEC PausePipelineProcessing 0
	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Altering trigger trig_update_recur_window_on_t_sub'
GO
ALTER trigger trig_update_recur_window_on_t_sub
ON t_sub
for INSERT, UPDATE, delete
as 
BEGIN  
declare @temp datetime
  delete from t_recur_window where exists (
    select 1 from deleted sub where
      t_recur_window.c__AccountID = sub.id_acc
      and t_recur_window.c__SubscriptionID = sub.id_sub
      AND t_recur_window.c_SubscriptionStart = sub.vt_start
      AND t_recur_window.c_SubscriptionEnd = sub.vt_end);

  MERGE into t_recur_window USING (
    select distinct sub.id_sub, sub.id_acc, sub.vt_start, sub.vt_end, plm.id_pi_template, plm.id_pi_instance
    FROM INSERTED sub inner join t_recur_window trw on trw.c__AccountID = sub.id_acc
       AND trw.c__SubscriptionID = sub.id_sub
       inner join t_pl_map plm on sub.id_po = plm.id_po
            and plm.id_sub = sub.id_sub and plm.id_paramtable = null	) AS source
        ON (t_recur_window.c__SubscriptionID = source.id_sub
             and t_recur_window.c__AccountID = source.id_acc)
    WHEN matched AND t_recur_window.c__SubscriptionID = source.id_sub and t_recur_window.c__AccountID = source.id_acc
      THEN UPDATE SET c_SubscriptionStart = source.vt_start, c_SubscriptionEnd = source.vt_end;
    
  SELECT sub.vt_start AS c_CycleEffectiveDate
        ,sub.vt_start AS c_CycleEffectiveStart
        ,sub.vt_end   AS c_CycleEffectiveEnd
        ,sub.vt_start AS c_SubscriptionStart
        ,sub.vt_end   AS c_SubscriptionEnd
        ,rcr.b_advance  AS c_Advance
        ,pay.id_payee AS c__AccountID
        ,pay.id_payer AS c__PayingAccount
        ,plm.id_pi_instance AS c__PriceableItemInstanceID
        ,plm.id_pi_template AS c__PriceableItemTemplateID
        ,plm.id_po    AS c__ProductOfferingID
        ,pay.vt_start AS c_PayerStart
        ,pay.vt_end   AS c_PayerEnd
        ,sub.id_sub   AS c__SubscriptionID
        ,IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
        ,IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
        ,rv.n_value   AS c_UnitValue
        ,dbo.mtmindate() as c_BilledThroughDate
        ,-1 AS c_LastIdRun
        ,dbo.mtmindate() AS c_MembershipStart
        ,dbo.mtmaxdate() AS c_MembershipEnd

      --We'll use #recur_window_holder in the stored proc that operates only on the latest data
        INTO #recur_window_holder
        FROM inserted sub
          INNER JOIN t_payment_redirection pay ON pay.id_payee = sub.id_acc 
         --   AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
          INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
          INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
          INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
          LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub 
            AND rv.tt_end = dbo.MTMaxDate() 
            AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start 
            AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
         WHERE 1=1
        --Make sure not to insert a row that already takes care of this account/sub id
           AND not EXISTS
           (SELECT 1 FROM T_RECUR_WINDOW where c__AccountID = sub.id_acc
              AND c__SubscriptionID = sub.id_sub)
              AND sub.id_group IS NULL
              AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)

   select @temp = max(tsh.tt_start) from t_sub_history tsh join inserted sub on tsh.id_acc = sub.id_acc and tsh.id_sub = sub.id_sub;
   EXEC MeterInitialFromRecurWindow @currentDate = @temp;
   EXEC MeterCreditFromRecurWindow @currentDate = @temp;
	  
   UPDATE #recur_window_holder 
     SET c_BilledThroughDate = dbo.metratime(1,'RC');
  
   INSERT INTO t_recur_window SELECT * FROM #recur_window_holder;

 end;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Creating procedure MeterInitialFromRecurWindow'
GO
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'MeterInitialFromRecurWindow')
	DROP PROCEDURE MeterInitialFromRecurWindow
GO

CREATE PROCEDURE [dbo].[MeterInitialFromRecurWindow]
     @currentDate dateTime
    AS
    BEGIN
	IF ((SELECT value FROM t_db_values WHERE parameter = N'InstantRc') = 'false') return;
	
	-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

SELECT       
    'Initial' AS c_RCActionType
    ,pci.dt_start      AS c_RCIntervalStart
    ,pci.dt_end      AS c_RCIntervalEnd
    ,ui.dt_start      AS c_BillingIntervalStart
    ,ui.dt_end          AS c_BillingIntervalEnd
    ,dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)          AS c_RCIntervalSubscriptionStart
    ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
    ,rw.c_SubscriptionStart          AS c_SubscriptionStart
    ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
    --Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.
    ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
    ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
    ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
    ,rw.c_UnitValueStart AS c_UnitValueStart
    ,rw.c_UnitValueEnd AS c_UnitValueEnd
    ,rw.c_UnitValue AS c_UnitValue
    ,rcr.n_rating_type AS c_RatingType
    ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
    ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
    ,dbo.MTMinOfTwoDates(pci.dt_end,rw.c_SubscriptionEnd)  AS c_BilledRateDate
    ,rw.c__subscriptionid      AS c__SubscriptionID
    ,rw.c__accountid AS c__AccountID
    ,rw.c__payingaccount      AS c__PayingAccount
    ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
    ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
    ,rw.c__productofferingid      AS c__ProductOfferingID
    ,currentui.id_interval AS c__IntervalID 
    ,NEWID() AS idSourceSess 
INTO #tmp_rc
FROM #recur_window_holder rw 
    INNER JOIN t_usage_interval ui on 
        rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
    AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* next interval overlaps with cycle */
    AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
    AND rw.c_SubscriptionStart < ui.dt_end AND rw.c_SubscriptionEnd > ui.dt_start
    AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */
    INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__AccountID AND auc.id_usage_cycle = ui.id_usage_cycle
    /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER LOOP JOIN t_pc_interval pci WITH(INDEX(fk1idx_t_pc_interval))
      ON pci.id_cycle = CASE 
        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle 
        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle 
        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) 
        ELSE NULL END
    AND ((rcr.b_advance = 'Y' AND pci.dt_start BETWEEN ui.dt_start     AND ui.dt_end) /* If this is in advance, check if rc start falls in this interval */
        or pci.dt_end BETWEEN ui.dt_start     AND ui.dt_end                           /* or check if the cycle end falls into this interval */
		or (pci.dt_start < ui.dt_start and pci.dt_end > ui.dt_end))                   /* or this interval could be in the middle of the cycle */
    AND pci.dt_end BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
    AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
    AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
    AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
    AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
    INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE 
        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle 
        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle 
        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) 
        ELSE NULL END 
    INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
	inner join t_usage_interval currentui on @currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = ui.id_usage_cycle
where 1=1
--Only meter new subscriptions as initial -- so select only items that have at most one entry in t_sub_history
    AND NOT EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.C__SubscriptionID AND tsh.id_acc = rw.c__AccountID
      AND tsh.tt_end < dbo.MTMaxDate())
--Also no old unit values
    AND NOT EXISTS (SELECT 1 FROM t_recur_value trv WHERE trv.id_sub = rw.c__SubscriptionID AND trv.tt_end < dbo.MTMaxDate())
-- Don't meter in the current interval for initial
    AND pci.dt_start < @currentDate
	AND ui.dt_start <= rw.c_SubscriptionStart 
    ;
    

--If no charges to meter, return immediately
    IF (NOT EXISTS (SELECT 1 FROM #tmp_rc)) RETURN;

   EXEC InsertChargesIntoSvcTables; 

UPDATE #recur_window_holder 
SET c_BilledThroughDate = dbo.metratime(1,'RC');
    END


GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Creating procedure InsertAuditEvent2'
GO
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'InsertAuditEvent2')
	DROP PROCEDURE InsertAuditEvent2
GO

CREATE PROCEDURE InsertAuditEvent2
	@id_userid int,
	@id_event int,
	@id_entity_type int,
	@id_entity int,
	@dt_timestamp datetime,
	@tx_details nvarchar(4000),
	@id_audit int = NULL,
	@tx_logged_in_as nvarchar(50) = NULL,
	@tx_application_name nvarchar(50) = NULL,
	@id_audit_out int out
AS
BEGIN
	DECLARE @new_id int
	IF @id_audit IS NULL OR @id_audit = 0
		EXEC GetCurrentId 'id_audit', @new_id out
	ELSE
		SET @id_audit_out = @id_audit

	EXEC InsertAuditEvent
		@id_userid           = @id_userid,
		@id_event            = @id_event,
		@id_entity_type      = @id_entity_type,
		@id_entity           = @id_entity,
		@dt_timestamp        = @dt_timestamp,
		@id_audit            = @new_id,
		@tx_details          = @tx_details,
		@tx_logged_in_as     = @tx_logged_in_as,
		@tx_application_name = @tx_application_name

	SET @id_audit_out = @new_id
END
GO

IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Updating upgrade information to [dbo].[t_sys_upgrade] table'
GO
UPDATE [dbo].[t_sys_upgrade]
SET db_upgrade_status = 'C',
dt_end_db_upgrade = getdate()
WHERE upgrade_id = (SELECT MAX(upgrade_id) FROM [dbo].[t_sys_upgrade])	
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

IF EXISTS (SELECT * FROM #tmpErrors) ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT>0 BEGIN
PRINT 'The database update succeeded'
COMMIT TRANSACTION
END
ELSE PRINT 'The database update failed'
GO
DROP TABLE #tmpErrors
GO
