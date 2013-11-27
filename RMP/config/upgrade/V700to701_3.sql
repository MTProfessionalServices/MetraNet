/*
You are recommended to back up your database before running this script

Script created by SQL Compare version 10.4.8 from Red Gate Software Ltd at 6/4/2013 11:10:28 AM

And altered to include changes for CR-55, t_sys_upgrade
*/
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

INSERT INTO t_sys_upgrade
(target_db_version, dt_start_db_upgrade, db_upgrade_status)
VALUES
('7.0.1', getdate(), 'R')
go


PRINT N'Dropping extended properties'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_account_type_view_map', NULL, NULL
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_account_type_view_map', 'COLUMN', N'id_account_view'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_account_type_view_map', 'COLUMN', N'id_type'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_export_report_instance', 'COLUMN', N'c_xmlConfig_loc'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_export_reports', 'COLUMN', N'c_rep_query_source'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_export_workqueue', 'COLUMN', N'c_rep_query_source'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_export_workqueue', 'COLUMN', N'c_xmlConfig_loc'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_export_workqueue_temp', 'COLUMN', N'c_rep_query_source'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_export_workqueue_temp', 'COLUMN', N'c_xmlConfig_loc'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_export_execute_audit', 'COLUMN', N'c_rep_query_source'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_export_execute_audit', 'COLUMN', N'c_xmlConfig_loc'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_updatestatsinfo', NULL, NULL
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_updatestatsinfo', 'COLUMN', N'Duration'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_updatestatsinfo', 'COLUMN', N'ObjectName'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_updatestatsinfo', 'COLUMN', N'StatPercentChar'
GO
PRINT N'Dropping constraints from [dbo].[agg_decision_audit_trail]'
GO
ALTER TABLE [dbo].[agg_decision_audit_trail] DROP CONSTRAINT [agg_dec_audit_trail_pk]
GO
PRINT N'Dropping constraints from [dbo].[t_account_type_view_map]'
GO
ALTER TABLE [dbo].[t_account_type_view_map] DROP CONSTRAINT [pk_t_account_view_map]
GO
PRINT N'Dropping index [agg_dec_audit_ndx] from [dbo].[agg_decision_audit_trail]'
GO
DROP INDEX [agg_dec_audit_ndx] ON [dbo].[agg_decision_audit_trail]
GO
PRINT N'Dropping index [amp_staging_ndx] from [dbo].[amp_staging_tables]'
GO
DROP INDEX [amp_staging_ndx] ON [dbo].[amp_staging_tables]
GO
PRINT N'Dropping index [idx_updatestatsinfo] from [dbo].[t_updatestatsinfo]'
GO
DROP INDEX [idx_updatestatsinfo] ON [dbo].[t_updatestatsinfo]
GO
PRINT N'Dropping [dbo].[MT_sys_analyze_all_tables]'
GO
DROP PROCEDURE [dbo].[MT_sys_analyze_all_tables]
GO
PRINT N'Dropping [dbo].[t_updatestats_partition]'
GO
DROP TABLE [dbo].[t_updatestats_partition]
GO
PRINT N'Altering [dbo].[t_archive_queue_partition]'
GO
ALTER TABLE [dbo].[t_archive_queue_partition] ALTER COLUMN [next_allow_run] [datetime] NULL
GO
PRINT N'Creating [dbo].[archive_queue_nonpartition]'
GO
create  procedure [dbo].[archive_queue_nonpartition]
   (
   @update_stats char(1) = 'N',
   @sampling_ratio varchar(3) = '30',
   @result nvarchar(4000) output
   )
  as
/* This SP is called from from basic SP - [archive_queue] if DB is not partitioned */

  --How to run this stored procedure  
--declare @result nvarchar(2000)  
--exec archive_queue_nonpartition @result=@result output  
--print @result 
--OR If we want to update statistics also
--declare @result nvarchar(2000)
--exec archive_queue_nonpartition 'Y',30,@result=@result output
--print @result
 
  set nocount on
  declare @sql1 nvarchar(4000)
  declare @tab1 nvarchar(1000)
  declare @var1 nvarchar(1000)
  declare @vartime datetime
  declare @maxtime datetime
  declare @count nvarchar(10)
  declare @NU_varStatPercentChar varchar(255)
  declare @id char(1)
  
--create table t_archive_queue (id_svc int, status varchar(1), tt_start datetime, tt_end datetime)  
  select @vartime = getdate()
  select @maxtime = dbo.mtmaxdate()
  
  if dbo.IsSystemPartitioned() = 1
  begin
	   set @result = 'DB is partitioned. [archive_queue_nonpartition] SP can be executed only on non-paritioned DB.'
	   return
  end
  
  if object_id('tempdb..##tmp_t_session_state') is not null drop table ##tmp_t_session_state
  if (@@error <> 0)
  begin
	   set @result = '7000001--archive_queue_nonpartition operation failed-->error in dropping ##tmp_t_session_state'
	   return
  end
  
  if object_id('tempdb..#tmp2_t_session_state') is not null drop table #tmp2_t_session_state
  if (@@error <> 0)
  begin
	   set @result = '7000001a--archive_queue_nonpartition operation failed-->error in dropping #tmp2_t_session_state'
	   return
  end
  begin tran
--Lock all the session tables
  declare  c1 cursor fast_forward for
  select nm_table_name from t_service_def_log
  open c1
  fetch next from c1 into @tab1
  while (@@fetch_status = 0)
  begin
	   set @sql1 = 'select 1 from ' + @tab1 + ' with(tablockx) where 0=1'
	   exec (@sql1)
  fetch next from c1 into @tab1
  end
  close c1
  deallocate c1

   set @sql1 = 'select 1 from t_message with(tablockx) where 0=1'
   exec (@sql1)
   set @sql1 = 'select 1 from t_session_set with(tablockx) where 0=1'
   exec (@sql1)
   set @sql1 = 'select 1 from t_session with(tablockx) where 0=1'
   exec (@sql1)
   set @sql1 = 'select 1 from t_session_state with(tablockx) where 0=1'
   exec (@sql1)

  create table ##tmp_t_session_state(id_sess varbinary(16))
  create clustered index idx_tmp_t_session_state on ##tmp_t_session_state(id_sess)
  insert into ##tmp_t_session_state
  select sess.id_source_sess
  from t_session sess where not exists (select 1 from t_session_state state where
  state.id_sess = sess.id_source_sess)
  union all
  select id_sess from t_session_state state where tx_state in ('F','R')
  and state.dt_end = @maxtime
  if (@@error <> 0)
  begin
	set @result = '7000002-archive_queue_nonpartition operation failed-->Error in creating ##tmp_t_session_state'
	rollback tran
	return
  end

  if exists (select 1 from t_prod_view where b_can_resubmit_from = 'N'
  and nm_table_name not like 't_acc_usage')
  begin
		    insert into ##tmp_t_session_state
		    select state.id_sess
		    from t_acc_usage au inner join
		    t_session_state state
		    on au.tx_uid = state.id_sess
		    inner join t_prod_view prod
		    on au.id_view = prod.id_view and prod.b_can_resubmit_from='N'
		    where state.dt_end = @maxtime
		    and au.id_usage_interval in
		    (select distinct id_interval from t_usage_interval
		    where tx_interval_status <> 'H'
		    )
		    if (@@error <> 0)
		    begin
						set @result = '7000003-archive_queue_nonpartition operation failed-->Error in creating ##tmp_t_session_state'
		        rollback tran
						return
		    end
  end
    
  declare  c1 cursor fast_forward for
  select nm_table_name from t_service_def_log
  open c1
  fetch next from c1 into @tab1
  while (@@fetch_status = 0)
  begin
	if object_id('tempdb..##svc') is not null
	drop table ##svc
	if (@@error <> 0)
	begin
	    set @result = '7000005--archive_queue_nonpartition operation failed-->error in dropping ##svc table'
	    rollback tran
	    close c1
	    deallocate c1
	    return
	end
	select @sql1 = N'select * into ##svc from ' + @tab1 + ' where id_source_sess  
   	in (select id_sess from ##tmp_t_session_state)'
   	exec (@sql1)
   	if (@@error <> 0)
   	begin
    		set @result = '7000006-archive_queue_nonpartition operation failed-->Error in t_svc Delete operation'
    		rollback tran
    		close c1
    		deallocate c1
    		return
   	end
   	exec ('truncate table ' + @tab1)
   	if (@@error <> 0)
   	begin
	    set @result = '7000007-archive_queue_nonpartition operation failed-->Error in t_svc Delete operation'
	    rollback tran
	    close c1
	    deallocate c1
	    return
   	end
	select @sql1 = N'insert into ' + @tab1 + ' select * from ##svc'
	exec (@sql1)
	if (@@error <> 0)
	begin
	    set @result = '7000008-archive_queue_nonpartition operation failed-->Error in t_svc Delete operation'
	    rollback tran
	    close c1
	    deallocate c1
	    return
	end
   	--Delete from t_svc tables  
   	insert into t_archive_queue (id_svc,status,tt_start,tt_end)
   	select @tab1,'A',@vartime,@maxtime
   	if (@@error <> 0)
  	begin
	    set @result = '7000009-archive_queue_nonpartition operation failed-->Error in insert t_archive table'
	    rollback tran
	    close c1
	    deallocate c1
	    return
   	end
  fetch next from c1 into @tab1
  end
  close c1
  deallocate c1
  
  --Delete from t_session and t_session_state table  
  if object_id('tempdb..#tmp_t_session') is not null drop table #tmp_t_session
  select * into #tmp_t_session from t_session where id_source_sess
  in (select id_sess from ##tmp_t_session_state)
  if (@@error <> 0)
  begin
	   set @result = '7000010-archive_queue_nonpartition operation failed-->Error in insert into tmp_t_session'
	   rollback tran
	   return
  end
  truncate table t_session
  if (@@error <> 0)
  begin
	   set @result = '7000011-archive_queue_nonpartition operation failed-->Error in Delete from t_session'
	   rollback tran
	   return
  end
  insert into t_session select * from #tmp_t_session
  if (@@error <> 0)
  begin
	   set @result = '7000012-archive_queue_nonpartition operation failed-->Error in insert into t_session'
	   rollback tran
	   return
  end
  if object_id('tempdb..#tmp_t_session_set') is not null drop table #tmp_t_session_set
  select * into #tmp_t_session_set from t_session_set where id_ss in
  (select id_ss from t_session)
  if (@@error <> 0)
  begin
	   set @result = '7000013-archive_queue_nonpartition operation failed-->Error in insert into tmp_t_session_set'
	   rollback tran
	   return
  end
  truncate table t_session_set
  if (@@error <> 0)
  begin
	   set @result = '7000014-archive_queue_nonpartition operation failed-->Error in Delete from t_session_set'
	   rollback tran
	   return
  end
  insert into t_session_set select * from #tmp_t_session_set
  if (@@error <> 0)
  begin
	   set @result = '7000015-archive_queue_nonpartition operation failed-->Error in insert into t_session_set'
	   rollback tran
	   return
  end
  if object_id('tempdb..#tmp_t_message') is not null drop table #tmp_t_message
  select * into #tmp_t_message from t_message where id_message in
  (select id_message from t_session_set)
  if (@@error <> 0)
  begin
	   set @result = '7000016-archive_queue_nonpartition operation failed-->Error in insert into tmp_t_message'
	   rollback tran
	   return
  end
  truncate table t_message
  if (@@error <> 0)
  begin
	   set @result = '7000017-archive_queue_nonpartition operation failed-->Error in Delete from t_message'
	   rollback tran
	   return
  end
  insert into t_message select * from #tmp_t_message
  if (@@error <> 0)
  begin
	   set @result = '7000018-archive_queue_nonpartition operation failed-->Error in insert into t_message'
	   rollback tran
	   return
  end
  select state.* into #tmp2_t_session_state from t_session_state state
  where state.id_sess in
  (select id_sess from ##tmp_t_session_state)
  if (@@error <> 0)
  begin
	   set @result = '7000019-archive_queue_nonpartition operation failed-->Error in creating #tmp2_t_session_state'
	   return
  end
  
  truncate table t_session_state
  if (@@error <> 0)
  begin
	   set @result = '7000020-archive_queue_nonpartition operation failed-->Error in Delete from t_session_state table'
	   rollback tran
	   return
  end
  insert into t_session_state select * from #tmp2_t_session_state
  if (@@error <> 0)
  begin
	   set @result = '7000021-archive_queue_nonpartition operation failed-->Error in insert into t_session_state table'
	   rollback tran
	   return
  end
  
  if object_id('tempdb..##svc') is not null drop table ##svc
  if object_id('tempdb..##tmp_t_session_state') is not null drop table ##tmp_t_session_state
  if object_id('tempdb..#tmp2_t_session_state') is not null drop table #tmp2_t_session_state
  if object_id('tempdb..#tmp_t_session_set') is not null drop table #tmp_t_session_set
  if object_id('tempdb..#tmp_t_message') is not null drop table #tmp_t_message
  if object_id('tempdb..#tmp_t_session') is not null drop table #tmp_t_session
  commit tran

  if (@update_stats = 'Y')
  begin
	declare  c1 cursor fast_forward for select nm_table_name from t_service_def_log
	open c1
	fetch next from c1 into @tab1
	while (@@fetch_status = 0)
	begin
	   IF @sampling_ratio < 5 SET @NU_varStatPercentChar = ' WITH SAMPLE 5 PERCENT '
	   ELSE IF @sampling_ratio >= 100 SET @NU_varStatPercentChar = ' WITH FULLSCAN '
	   ELSE SET @NU_varStatPercentChar = ' WITH SAMPLE ' + CAST(@sampling_ratio AS varchar(20)) + ' PERCENT '
	   SET @sql1 = 'UPDATE STATISTICS ' + @tab1 + @NU_varStatPercentChar
	   EXECUTE (@sql1)
	   if (@@error <> 0)
	   begin
		     set @result = '7000022-archive_queue_nonpartition operation failed-->Error in update stats'
		     rollback tran
		     close c1
		     deallocate c1
		     return
	   end
	fetch next from c1 into @tab1
	end
	close c1
	deallocate c1
	SET @sql1 = 'UPDATE STATISTICS t_session ' + @NU_varStatPercentChar
	EXECUTE (@sql1)
	SET @sql1 = 'UPDATE STATISTICS t_session_set ' + @NU_varStatPercentChar
	EXECUTE (@sql1)
	SET @sql1 = 'UPDATE STATISTICS t_session_state ' + @NU_varStatPercentChar
	EXECUTE (@sql1)
	SET @sql1 = 'UPDATE STATISTICS t_message' + @NU_varStatPercentChar
	EXECUTE (@sql1)
  end
  
  set @result = '0-archive_queue_nonpartition operation successful'
GO
PRINT N'Creating [dbo].[archive_queue_partition_update_def_id_partition]'
GO
CREATE PROCEDURE [dbo].[archive_queue_partition_update_def_id_partition](
    @new_def_id_partition        INT,
    @meter_table_name            NVARCHAR(100),
    @meter_partition_field_name  NVARCHAR(50)
)
AS
	SET NOCOUNT ON
	
	DECLARE @defaultConstraint_name  NVARCHAR(100),
	        @sqlCommand              NVARCHAR(MAX)
	
	SELECT @defaultConstraint_name = cnstr.name
	FROM   sys.all_columns allclmns
	       INNER JOIN sys.tables tbls
	            ON  allclmns.object_id = tbls.object_id
	       INNER JOIN sys.default_constraints cnstr
	            ON  allclmns.default_object_id = cnstr.object_id
	WHERE  tbls.name = @meter_table_name
	       AND allclmns.name = @meter_partition_field_name
	
	IF @defaultConstraint_name IS NOT NULL
	BEGIN
	    SET @sqlCommand = 'ALTER TABLE ' + @meter_table_name + ' DROP CONSTRAINT ' + @defaultConstraint_name
	    EXEC (@sqlCommand)
	END
	
    SET @sqlCommand = 'ALTER TABLE ' + @meter_table_name
        + ' ADD CONSTRAINT DF_' + @meter_table_name + '_' + @meter_partition_field_name
        + ' DEFAULT ' + CAST(@new_def_id_partition AS NVARCHAR(20))
        + ' FOR ' + @meter_partition_field_name
    EXEC (@sqlCommand)
GO
PRINT N'Creating [dbo].[archive_queue_partition_update_def_id_partition_all]'
GO
CREATE PROCEDURE [dbo].[archive_queue_partition_update_def_id_partition_all](
    @new_def_id_partition        INT,
    @meter_partition_field_name  NVARCHAR(50)
)
AS
	SET NOCOUNT ON
	
	EXEC archive_queue_partition_update_def_id_partition @new_def_id_partition = @new_def_id_partition,
	     @meter_table_name = 't_session',
	     @meter_partition_field_name = @meter_partition_field_name
	
	EXEC archive_queue_partition_update_def_id_partition @new_def_id_partition = @new_def_id_partition,
	     @meter_table_name = 't_session_state',
	     @meter_partition_field_name = @meter_partition_field_name
	
	EXEC archive_queue_partition_update_def_id_partition @new_def_id_partition = @new_def_id_partition,
	     @meter_table_name = 't_session_set',
	     @meter_partition_field_name = @meter_partition_field_name
	
	EXEC archive_queue_partition_update_def_id_partition @new_def_id_partition = @new_def_id_partition,
	     @meter_table_name = 't_message',
	     @meter_partition_field_name = @meter_partition_field_name
	
	DECLARE @tab_name NVARCHAR(100)
	DECLARE svc_cursor CURSOR FAST_FORWARD
	FOR
	    SELECT nm_table_name
	    FROM   t_service_def_log
	
	OPEN svc_cursor
	FETCH NEXT FROM svc_cursor INTO @tab_name
	
	WHILE (@@fetch_status = 0)
	BEGIN
	    EXEC archive_queue_partition_update_def_id_partition @new_def_id_partition = @new_def_id_partition,
	         @meter_table_name = @tab_name,
	         @meter_partition_field_name = @meter_partition_field_name
	    
	    FETCH NEXT FROM svc_cursor INTO @tab_name
	END
	CLOSE svc_cursor
	DEALLOCATE svc_cursor
GO
PRINT N'Creating [dbo].[archive_queue_partition_apply_next_partition]'
GO
CREATE PROCEDURE [dbo].[archive_queue_partition_apply_next_partition]
	@new_current_id_partition INT,
	@current_time DATETIME,
	@meter_partition_function_name NVARCHAR(50),
	@meter_partition_schema_name NVARCHAR(50),
	@meter_partition_filegroup_name NVARCHAR(50),
	@meter_partition_field_name NVARCHAR(50)
AS
	SET NOCOUNT ON
	
	DECLARE @sqlCommand NVARCHAR(MAX)
	
	BEGIN TRAN
	
	SET @sqlCommand = 'ALTER PARTITION SCHEME ' + @meter_partition_schema_name
	    + ' NEXT USED ' + @meter_partition_filegroup_name
	EXEC (@sqlCommand)
	
	/* Adding new partition to MeterPartitionSchema*/
	SET @sqlCommand = 'ALTER PARTITION FUNCTION ' + @meter_partition_function_name
	    + '() SPLIT RANGE (' + CAST(@new_current_id_partition AS NVARCHAR(20)) + ')'
	EXEC (@sqlCommand)
	
	/* Call for update default id_partition (@new_current_id_partition) for all meter tables*/
	EXEC archive_queue_partition_update_def_id_partition_all
	     @new_def_id_partition = @new_current_id_partition,
	     @meter_partition_field_name = @meter_partition_field_name
	
	/* Update Default id_partition in [t_archive_queue_partition] table */
	INSERT INTO t_archive_queue_partition
	VALUES
	  (
	    @new_current_id_partition,
	    @current_time,
	    NULL
	  )
	
	COMMIT TRAN
GO
PRINT N'Creating [dbo].[archive_queue_partition_drop_temp_tables]'
GO
CREATE PROCEDURE [dbo].[archive_queue_partition_drop_temp_tables](@temp_table_postfix NVARCHAR(50))
AS
	SET NOCOUNT ON
	DECLARE @tab_name NVARCHAR(100),
			@temp_tab_name NVARCHAR(100)
	
	SET @temp_tab_name = 't_session' + @temp_table_postfix
	IF EXISTS (
	       SELECT *
	       FROM   INFORMATION_SCHEMA.TABLES
	       WHERE  TABLE_SCHEMA = N'dbo'
	              AND TABLE_NAME = @temp_tab_name
	   )
	    EXEC ('DROP TABLE ' + @temp_tab_name)
	
	SET @temp_tab_name = 't_session_state' + @temp_table_postfix
	IF EXISTS (
	       SELECT *
	       FROM   INFORMATION_SCHEMA.TABLES
	       WHERE  TABLE_SCHEMA = N'dbo'
	              AND TABLE_NAME = @temp_tab_name
	   )
	    EXEC ('DROP TABLE ' + @temp_tab_name)
		
	SET @temp_tab_name = 't_session_set' + @temp_table_postfix
	IF EXISTS (
	       SELECT *
	       FROM   INFORMATION_SCHEMA.TABLES
	       WHERE  TABLE_SCHEMA = N'dbo'
	              AND TABLE_NAME = @temp_tab_name
	   )
	    EXEC ('DROP TABLE ' + @temp_tab_name)
	    
	SET @temp_tab_name = 't_message' + @temp_table_postfix
	IF EXISTS (
	       SELECT *
	       FROM   INFORMATION_SCHEMA.TABLES
	       WHERE  TABLE_SCHEMA = N'dbo'
	              AND TABLE_NAME = @temp_tab_name
	   )
	    EXEC ('DROP TABLE ' + @temp_tab_name)
		
	DECLARE svc_cursor CURSOR FAST_FORWARD
	FOR
	    SELECT nm_table_name
	    FROM   t_service_def_log
	
	OPEN svc_cursor
	FETCH NEXT FROM svc_cursor INTO @tab_name
	WHILE (@@fetch_status = 0)
	BEGIN
	    SET @temp_tab_name = @tab_name + @temp_table_postfix
	    IF EXISTS (
	           SELECT *
	           FROM   INFORMATION_SCHEMA.TABLES
	           WHERE  TABLE_SCHEMA = N'dbo'
	                  AND TABLE_NAME = @temp_tab_name
	       )
	        EXEC ('DROP TABLE ' + @temp_tab_name)
	    
	    FETCH NEXT FROM svc_cursor INTO @tab_name
	END
	CLOSE svc_cursor
	DEALLOCATE svc_cursor
GO
PRINT N'Creating [dbo].[archive_queue_partition_get_id_sess_to_keep]'
GO
CREATE PROCEDURE [dbo].[archive_queue_partition_get_id_sess_to_keep](@old_id_partition INT)
AS
	SET NOCOUNT ON
	
	DECLARE @max_time    DATETIME,
	        @preserved_id_partition INT
	
	SELECT @max_time = dbo.mtmaxdate()
	SET @preserved_id_partition = @old_id_partition - 1
	
	IF OBJECT_ID('tempdb..##id_sess_to_keep') IS NOT NULL
	    DROP TABLE ##id_sess_to_keep
	
	SELECT DISTINCT(id_sess) INTO ##id_sess_to_keep
	FROM   t_session_state st
	WHERE  st.id_partition IN (@old_id_partition, @preserved_id_partition)
	       AND tx_state IN ('F', 'R')
	       AND dt_end = @max_time
	OPTION(MAXDOP 1)
	
	INSERT INTO ##id_sess_to_keep
	SELECT sess.id_source_sess
	FROM   t_session sess
	WHERE  sess.id_partition IN (@old_id_partition, @preserved_id_partition)
	       AND NOT EXISTS (
	               SELECT 1
	               FROM   t_session_state st
	               WHERE  st.id_partition IN (@old_id_partition, @preserved_id_partition)
	                      AND st.id_sess = sess.id_source_sess
	           )
	OPTION(MAXDOP 1)
	
	INSERT INTO ##id_sess_to_keep
	SELECT DISTINCT(ts.id_source_sess)
	FROM   t_usage_interval ui
	       JOIN t_uk_acc_usage_tx_uid au
	            ON  au.id_usage_interval = ui.id_interval
	       JOIN t_session ts
	            ON  ts.id_source_sess = au.tx_UID
	WHERE  ts.id_partition IN (@old_id_partition, @preserved_id_partition)
	       AND ui.tx_interval_status <> 'H'
	OPTION(MAXDOP 1)
	
	CREATE CLUSTERED INDEX idx_id_sess_to_keep ON ##id_sess_to_keep(id_sess)
GO
PRINT N'Creating [dbo].[archive_queue_partition_get_status]'
GO
CREATE PROCEDURE [dbo].[archive_queue_partition_get_status](
    @current_time              DATETIME,
    @next_allow_run_time       DATETIME OUT,
    @current_id_partition      INT OUT,
    @new_current_id_partition  INT OUT,
    @old_id_partition          INT OUT,
    @no_need_to_run            BIT OUT
)
AS
	SET NOCOUNT ON
	
	DECLARE @message NVARCHAR(4000)
	SET @no_need_to_run = 0
	
	IF NOT EXISTS(SELECT * FROM t_archive_queue_partition)
	    RAISERROR ('t_archive_queue_partition must contain at least one record.
Try to execute "USM CREATE" command in cmd.
First record inserts to this table on creation of Partition Infrastructure for metering tables', 16, 1)
	
	SELECT @current_id_partition = MAX(current_id_partition)
	FROM   t_archive_queue_partition
	
	SELECT @next_allow_run_time = next_allow_run
	FROM   t_archive_queue_partition
	WHERE  current_id_partition = @current_id_partition
	
	IF @next_allow_run_time IS NULL
	BEGIN
	    SET @message = 'Warning: previouse execution of [archive_queue_partition] failed.
The oldest partition was not archived, but new data already written to new partition with ID: "'
+ CAST(@current_id_partition AS NVARCHAR(20)) + '".
Retrying archivation of the oldest partition...'
	    RAISERROR (@message, 0, 1)
	    
	    SET @new_current_id_partition = @current_id_partition
	    SET @current_id_partition = @new_current_id_partition - 1
	    SET @old_id_partition = @new_current_id_partition - 2
	END
	ELSE
	BEGIN
	    /* Period of full partition cycle should pass since last execution of [archive_queue_partition] */
	    IF (@current_time < @next_allow_run_time)
	    BEGIN
	        SET @no_need_to_run = 1
	        SET @message = 'No need to run archive functionality. '
	            + 'Time of cycle period not elapsed yet since the last run. '
	            + 'Try execute the procedure after "'
	            + CONVERT(VARCHAR, @next_allow_run_time) + '" date.'
	        RAISERROR (@message, 0, 1)
	    END
	    
		SET @new_current_id_partition = @current_id_partition + 1
		SET @old_id_partition = @current_id_partition - 1
	END
GO
PRINT N'Creating [dbo].[archive_queue_partition_clone_table]'
GO
CREATE PROCEDURE [dbo].[archive_queue_partition_clone_table](
    @source_table       NVARCHAR(255),
    @destination_table  NVARCHAR(255),
    @file_group         NVARCHAR(255)
)
AS
	SET NOCOUNT ON
	
	DECLARE @source_schema  NVARCHAR(255),
	        @pk_schema      NVARCHAR(255),
	        @pk_name        NVARCHAR(255),
	        @pk_columns     NVARCHAR(MAX)
	
	SET @source_schema = N'dbo'
	SET @pk_columns = ''
	IF EXISTS (
	       SELECT *
	       FROM   INFORMATION_SCHEMA.TABLES
	       WHERE  TABLE_SCHEMA = @source_schema
	              AND TABLE_NAME = @destination_table
	   )
	    EXEC ('DROP TABLE ' + @destination_table)
	
	-- Clone table
	/* Possible fix for
	* CORE-6477:"archive_queue_partition will fail, if any t_svc_* table in will have large value columns" */
	
	--EXEC ('ALTER DATABASE NetMeter MODIFY FILEGROUP MeterFileGroup DEFAULT')
	
	EXEC ('SELECT TOP (0) * INTO ' + @destination_table + ' FROM ' + @source_table)
	
	--ALTER DATABASE NetMeter MODIFY FILEGROUP [PRIMARY] DEFAULT
	
	SELECT TOP 1 @pk_schema = CONSTRAINT_SCHEMA,
	       @pk_name = CONSTRAINT_NAME
	FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	WHERE  TABLE_SCHEMA = @source_schema
	       AND TABLE_NAME = @source_table
	       AND CONSTRAINT_TYPE = 'PRIMARY KEY'
	
	-- Clone primary key
	IF NOT @pk_schema IS NULL
	   AND NOT @pk_name IS NULL
	BEGIN
	    SELECT @pk_columns = @pk_columns + '[' + COLUMN_NAME + '],'
	    FROM   INFORMATION_SCHEMA.KEY_COLUMN_USAGE
	    WHERE  TABLE_NAME = @source_table
	           AND TABLE_SCHEMA = @source_schema
	           AND CONSTRAINT_SCHEMA = @pk_schema
	           AND CONSTRAINT_NAME = @pk_name
	    ORDER BY
	           ORDINAL_POSITION
	    
	    SET @pk_columns = LEFT(@pk_columns, LEN(@pk_columns) - 1)
	    
	    EXEC (
	             'ALTER TABLE ' + @destination_table
	             + ' ADD CONSTRAINT PK_' + @destination_table
	             + ' PRIMARY KEY CLUSTERED (' + @pk_columns + ') ON ' + @file_group
	         )
	END
GO
PRINT N'Creating [dbo].[archive_queue_partition_switch_out_partition]'
GO
CREATE PROCEDURE [dbo].[archive_queue_partition_switch_out_partition](
    @table_name                NVARCHAR(100),
    @temp_table_postfix        NVARCHAR(50),
    @number_of_partition       INT,
    @partition_filegroup_name  NVARCHAR(50)
)
AS
	SET NOCOUNT ON
	
	DECLARE @temp_table_name  NVARCHAR(100),
	        @sqlCommand       NVARCHAR(MAX)
	
	SET @temp_table_name = @table_name + @temp_table_postfix
	
	EXEC archive_queue_partition_clone_table
		 @source_table = @table_name,
		 @destination_table = @temp_table_name,
		 @file_group = @partition_filegroup_name

	SET @sqlCommand = 'ALTER TABLE ' + @table_name
	    + ' SWITCH PARTITION $PARTITION.MeterPartitionFunction('
		+ CAST(@number_of_partition AS VARCHAR(20)) + ') TO ' + @temp_table_name
	EXEC (@sqlCommand)
GO
PRINT N'Creating [dbo].[archive_queue_partition_clone_all_indexes_and_constraints]'
GO
CREATE PROCEDURE [dbo].[archive_queue_partition_clone_all_indexes_and_constraints]
    @SourceSchema nvarchar(255),
    @SourceTable nvarchar(255),
    @DestinationSchema nvarchar(255),
    @DestinationTable nvarchar(255),
    @FileGroup nvarchar(255)
AS
    /*
        Copies:
            * Structure
            * Primary key
            * Indexes (including ASC/DESC, included columns, filters)
            * Constraints (and unique constraints)
    */
    SET NOCOUNT ON;

    BEGIN TRANSACTION

    DECLARE @PKSchema nvarchar(255), @PKName nvarchar(255)
    SELECT TOP 1 @PKSchema = CONSTRAINT_SCHEMA, @PKName = CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = @SourceSchema AND TABLE_NAME = @SourceTable AND CONSTRAINT_TYPE = 'PRIMARY KEY'

    --create primary key
    IF NOT @PKSchema IS NULL AND NOT @PKName IS NULL
    BEGIN
        DECLARE @PKColumns nvarchar(MAX)
        SET @PKColumns = ''

        SELECT @PKColumns = @PKColumns + '[' + COLUMN_NAME + '],'
            FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
            where TABLE_NAME = @SourceTable and TABLE_SCHEMA = @SourceSchema AND CONSTRAINT_SCHEMA = @PKSchema AND CONSTRAINT_NAME= @PKName
            ORDER BY ORDINAL_POSITION

        SET @PKColumns = LEFT(@PKColumns, LEN(@PKColumns) - 1)

        exec('ALTER TABLE [' + @DestinationSchema + '].[' + @DestinationTable + '] ADD  CONSTRAINT [PK_' + @DestinationTable + '] PRIMARY KEY CLUSTERED (' + @PKColumns + ') ON '+ @FileGroup);
    END

    --create other indexes
    DECLARE @IndexId int, @IndexName nvarchar(255), @IsUnique bit, @IsUniqueConstraint bit, @FilterDefinition nvarchar(max)

    DECLARE indexcursor CURSOR FOR
    SELECT index_id, name, is_unique, is_unique_constraint, filter_definition FROM sys.indexes WHERE type = 2 and object_id = object_id('[' + @SourceSchema + '].[' + @SourceTable + ']')
    OPEN indexcursor;
    FETCH NEXT FROM indexcursor INTO @IndexId, @IndexName, @IsUnique, @IsUniqueConstraint, @FilterDefinition;
    WHILE @@FETCH_STATUS = 0
       BEGIN
            DECLARE @Unique nvarchar(255)
            SET @Unique = CASE WHEN @IsUnique = 1 THEN ' UNIQUE ' ELSE '' END

            DECLARE @KeyColumns nvarchar(max), @IncludedColumns nvarchar(max)
            SET @KeyColumns = ''
            SET @IncludedColumns = ''

            select @KeyColumns = @KeyColumns + '[' + c.name + '] ' + CASE WHEN is_descending_key = 1 THEN 'DESC' ELSE 'ASC' END + ',' from sys.index_columns ic
            inner join sys.columns c ON c.object_id = ic.object_id and c.column_id = ic.column_id
            where index_id = @IndexId and ic.object_id = object_id('[' + @SourceSchema + '].[' + @SourceTable + ']') and key_ordinal > 0
            order by index_column_id

            select @IncludedColumns = @IncludedColumns + '[' + c.name + '],' from sys.index_columns ic
            inner join sys.columns c ON c.object_id = ic.object_id and c.column_id = ic.column_id
            where index_id = @IndexId and ic.object_id = object_id('[' + @SourceSchema + '].[' + @SourceTable + ']') and key_ordinal = 0
            order by index_column_id

            IF LEN(@KeyColumns) > 0
                SET @KeyColumns = LEFT(@KeyColumns, LEN(@KeyColumns) - 1)

            IF LEN(@IncludedColumns) > 0
            BEGIN
                SET @IncludedColumns = ' INCLUDE (' + LEFT(@IncludedColumns, LEN(@IncludedColumns) - 1) + ')'
            END

            IF @FilterDefinition IS NULL
                SET @FilterDefinition = ''
            ELSE
                SET @FilterDefinition = 'WHERE ' + @FilterDefinition + ' '

            if @IsUniqueConstraint = 0
                exec('CREATE ' + @Unique + ' NONCLUSTERED INDEX [' + @IndexName + '] ON [' + @DestinationSchema + '].[' + @DestinationTable + '] (' + @KeyColumns + ')' + @IncludedColumns + @FilterDefinition)
            ELSE
                BEGIN
                    SET @IndexName = REPLACE(@IndexName, @SourceTable, @DestinationTable)
                    exec('ALTER TABLE [' + @DestinationSchema + '].[' + @DestinationTable + '] ADD  CONSTRAINT [' + @IndexName + '] UNIQUE NONCLUSTERED (' + @KeyColumns + ')');
                END

            FETCH NEXT FROM indexcursor INTO @IndexId, @IndexName, @IsUnique, @IsUniqueConstraint, @FilterDefinition;
       END;
    CLOSE indexcursor;
    DEALLOCATE indexcursor;

    --create constraints
    DECLARE @ConstraintName nvarchar(max), @CheckClause nvarchar(max)
    DECLARE constraintcursor CURSOR FOR
        SELECT REPLACE(c.CONSTRAINT_NAME, @SourceTable, @DestinationTable), CHECK_CLAUSE from INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE t
        INNER JOIN INFORMATION_SCHEMA.CHECK_CONSTRAINTS c ON c.CONSTRAINT_SCHEMA = TABLE_SCHEMA AND c.CONSTRAINT_NAME = t.CONSTRAINT_NAME
         WHERE TABLE_SCHEMA = @SourceSchema AND TABLE_NAME = @SourceTable
    OPEN constraintcursor;
    FETCH NEXT FROM constraintcursor INTO @ConstraintName, @CheckClause;
    WHILE @@FETCH_STATUS = 0
       BEGIN
            exec('ALTER TABLE [' + @DestinationSchema + '].[' + @DestinationTable + '] WITH CHECK ADD  CONSTRAINT [' + @ConstraintName + '] CHECK ' + @CheckClause)
            exec('ALTER TABLE [' + @DestinationSchema + '].[' + @DestinationTable + '] CHECK CONSTRAINT [' + @ConstraintName + ']')
            FETCH NEXT FROM constraintcursor INTO @ConstraintName, @CheckClause;
       END;
    CLOSE constraintcursor;
    DEALLOCATE constraintcursor;

    COMMIT TRANSACTION
GO
PRINT N'Creating [dbo].[archive_queue_partition_switch_out_with_keep_sess]'
GO
CREATE PROCEDURE [dbo].[archive_queue_partition_switch_out_with_keep_sess](
    @number_of_partition       INT,
    @table_name  NVARCHAR(100),
    @temp_table_postfix_oldest  NVARCHAR(50),
    @temp_table_postfix_preserved  NVARCHAR(50),
    @partition_filegroup_name  NVARCHAR(50)
)
AS
	SET NOCOUNT ON
	
	DECLARE @table_with_sess_to_keep NVARCHAR(100),
			@preserved_partition INT,
			@sqlCommand NVARCHAR(MAX)
	
	SET @table_with_sess_to_keep = @table_name + '_sess_to_keep'
	SET @preserved_partition = @number_of_partition - 1
		
	SET @sqlCommand = 'IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N''dbo'' AND TABLE_NAME = ''' + @table_with_sess_to_keep + ''')) 
							DROP TABLE ' + @table_with_sess_to_keep
	EXEC (@sqlCommand)
		
	SET @sqlCommand = 'SELECT * INTO ' + @table_with_sess_to_keep
					+ ' FROM ' + @table_name + '
						WHERE  id_source_sess IN (SELECT id_sess
													FROM   ##id_sess_to_keep)
							AND id_partition = ' + CAST(@preserved_partition AS VARCHAR(20))
					+ ' OPTION(MAXDOP 1)'
	EXEC (@sqlCommand)
	
	SET @sqlCommand = 'UPDATE ' + @table_with_sess_to_keep
					+ ' SET id_partition = ' + CAST(@number_of_partition AS VARCHAR(20))
					+ ' OPTION(MAXDOP 1)'
	EXEC (@sqlCommand)
	
	SET @sqlCommand = 'INSERT INTO ' + @table_with_sess_to_keep
					+ ' SELECT * FROM ' + @table_name + '
						WHERE  id_source_sess IN (SELECT id_sess
													FROM   ##id_sess_to_keep)
							AND id_partition = ' + CAST(@number_of_partition AS VARCHAR(20))
					+ ' OPTION(MAXDOP 1)'
	EXEC (@sqlCommand)
	
	EXEC archive_queue_partition_clone_all_indexes_and_constraints
	     @SourceSchema = N'dbo',
	     @SourceTable = @table_name,
	     @DestinationSchema = N'dbo',
	     @DestinationTable = @table_with_sess_to_keep,
	     @FileGroup = @partition_filegroup_name
	
	
	SET @sqlCommand = 'ALTER TABLE ' + @table_with_sess_to_keep
					+ ' WITH CHECK ADD CONSTRAINT CK_' + @table_with_sess_to_keep
					+ ' CHECK((id_partition = ('
					+ CAST(@number_of_partition AS VARCHAR(20)) + ')))'
	EXEC (@sqlCommand)
	
	SET @sqlCommand = 'ALTER TABLE ' + @table_with_sess_to_keep + ' CHECK CONSTRAINT CK_' + @table_with_sess_to_keep
	EXEC (@sqlCommand)
	
	BEGIN TRAN
	
	/* SWITCH OUT 'old' partition */
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = @table_name,
	     @temp_table_postfix = @temp_table_postfix_oldest,
	     @number_of_partition = @number_of_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	/* SWITCH OUT 'preserved' partition */
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = @table_name,
	     @temp_table_postfix = @temp_table_postfix_preserved,
	     @number_of_partition = @preserved_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	/* SWITCH IN new 'preserved' partition with sessions to keep */
	SET @sqlCommand = 'ALTER TABLE ' + @table_with_sess_to_keep
					+ ' SWITCH TO ' + @table_name
					+ ' PARTITION $PARTITION.MeterPartitionFunction('
					+ CAST(@number_of_partition AS VARCHAR(20)) + ')'
	EXEC (@sqlCommand)
	
	COMMIT TRAN
	
	SET @sqlCommand = 'DROP TABLE ' + @table_with_sess_to_keep
	EXEC (@sqlCommand)
GO
PRINT N'Creating [dbo].[archive_queue_partition_switch_out_partition_all]'
GO
CREATE PROCEDURE [dbo].[archive_queue_partition_switch_out_partition_all](
    @number_of_partition           INT,
    @partition_filegroup_name      NVARCHAR(50),
    @temp_table_postfix_oldest     NVARCHAR(50),
    @temp_table_postfix_preserved  NVARCHAR(50)
)
AS
	SET NOCOUNT ON
	
	DECLARE @preserved_partition                INT,
	        @temp_tab_for_switch_out_oldest     NVARCHAR(100),
	        @temp_tab_for_switch_out_preserved  NVARCHAR(100),
	        @mn_db_name                         NVARCHAR(100),
	        @sqlCommand                         NVARCHAR(MAX)
	
	SET @preserved_partition = @number_of_partition - 1
	SET @mn_db_name = DB_NAME()
	
	/* loop by svc_* tables */
	DECLARE @tab_name NVARCHAR(100)
	DECLARE svc_cursor CURSOR FAST_FORWARD
	FOR
	    SELECT nm_table_name
	    FROM   t_service_def_log
	
	OPEN svc_cursor
	FETCH NEXT FROM svc_cursor INTO @tab_name
	
	WHILE (@@fetch_status = 0)
	BEGIN
		
		EXEC archive_queue_partition_switch_out_with_keep_sess
			@number_of_partition = @number_of_partition,
			@table_name = @tab_name,
			@temp_table_postfix_oldest = @temp_table_postfix_oldest,
			@temp_table_postfix_preserved = @temp_table_postfix_preserved,
			@partition_filegroup_name = @partition_filegroup_name
		
	    FETCH NEXT FROM svc_cursor INTO @tab_name
	END
	CLOSE svc_cursor
	DEALLOCATE svc_cursor
	
	
	/* t_message */
	SET @temp_tab_for_switch_out_oldest = 't_message' + @temp_table_postfix_oldest
	SET @temp_tab_for_switch_out_preserved = 't_message' + @temp_table_postfix_preserved
		
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = @temp_tab_for_switch_out_oldest))
		EXEC ('DROP TABLE ' + @temp_tab_for_switch_out_oldest)
		
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = @temp_tab_for_switch_out_preserved))
		EXEC ('DROP TABLE ' + @temp_tab_for_switch_out_preserved)
			
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N't_message_sess_to_keep'))
		DROP TABLE t_message_sess_to_keep
	
	/* Hardcode clonning of t_message due to CORE-6477 */
	EXEC ('ALTER DATABASE ' + @mn_db_name + ' MODIFY FILEGROUP ' + @partition_filegroup_name + ' DEFAULT')
	
	EXEC archive_queue_partition_clone_table
		 @source_table = N't_message',
		 @destination_table = @temp_tab_for_switch_out_oldest,
		 @file_group = @partition_filegroup_name
		 
	EXEC archive_queue_partition_clone_table
		 @source_table = N't_message',
		 @destination_table = @temp_tab_for_switch_out_preserved,
		 @file_group = @partition_filegroup_name
		 		 
	SELECT TOP (0) * INTO t_message_sess_to_keep FROM t_message
	
	EXEC ('ALTER DATABASE ' + @mn_db_name + ' MODIFY FILEGROUP [PRIMARY] DEFAULT')
		
	INSERT INTO t_message_sess_to_keep
	SELECT *
	FROM   t_message m
	WHERE  m.id_message IN (SELECT ss.id_message
	                        FROM   t_session_set ss
	                               JOIN t_session s
	                                    ON  s.id_ss = ss.id_ss
	                               JOIN ##id_sess_to_keep t
	                                    ON  s.id_source_sess = t.id_sess)
	       AND m.id_partition = @preserved_partition
	OPTION(MAXDOP 1)
	
	UPDATE t_message_sess_to_keep SET id_partition = @number_of_partition
	OPTION(MAXDOP 1)
	
	INSERT INTO t_message_sess_to_keep
	SELECT *
	FROM   t_message m
	WHERE  m.id_message IN (SELECT ss.id_message
	                        FROM   t_session_set ss
	                               JOIN t_session s
	                                    ON  s.id_ss = ss.id_ss
	                               JOIN ##id_sess_to_keep t
	                                    ON  s.id_source_sess = t.id_sess)
	       AND m.id_partition = @number_of_partition
	OPTION(MAXDOP 1)
	
	EXEC archive_queue_partition_clone_all_indexes_and_constraints
	     @SourceSchema = N'dbo',
	     @SourceTable = N't_message',
	     @DestinationSchema = N'dbo',
	     @DestinationTable = N't_message_sess_to_keep',
	     @FileGroup = @partition_filegroup_name
	
	SET @sqlCommand = 'ALTER TABLE t_message_sess_to_keep WITH CHECK
						ADD CONSTRAINT CK_t_message_sess_to_keep CHECK((id_partition = ('
						+ CAST(@number_of_partition AS VARCHAR(20)) + ')))'
	EXEC (@sqlCommand)
	
	ALTER TABLE t_message_sess_to_keep CHECK CONSTRAINT CK_t_message_sess_to_keep
	
	BEGIN TRAN
	
	/* SWITCH OUT 'old' partition */
	SET @sqlCommand = 'ALTER TABLE t_message SWITCH PARTITION $PARTITION.MeterPartitionFunction('
					+ CAST(@number_of_partition AS VARCHAR(20))
					+ ') TO ' + @temp_tab_for_switch_out_oldest
	EXEC (@sqlCommand)
	
	/* SWITCH OUT 'preserved' partition */
	SET @sqlCommand = 'ALTER TABLE t_message SWITCH PARTITION $PARTITION.MeterPartitionFunction('
					+ CAST(@preserved_partition AS NVARCHAR(20))
					+ ') TO ' + @temp_tab_for_switch_out_preserved
	EXEC (@sqlCommand)
	
	/* SWITCH IN new 'preserved' partition with sessions to keep */
	SET @sqlCommand = 'ALTER TABLE t_message_sess_to_keep SWITCH TO t_message PARTITION
					$PARTITION.MeterPartitionFunction('
					+ CAST(@number_of_partition AS VARCHAR(20))+ ')'
	EXEC (@sqlCommand)
		
	COMMIT TRAN
	
	DROP TABLE t_message_sess_to_keep
	
	
	/* t_session_set */
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N't_session_set_sess_to_keep'))
		DROP TABLE t_session_set_sess_to_keep
			
	SELECT * INTO t_session_set_sess_to_keep
	FROM   t_session_set ss
	WHERE  ss.id_ss IN (SELECT s.id_ss
	                    FROM   ##id_sess_to_keep t
	                           JOIN t_session s
	                                ON  s.id_source_sess = t.id_sess)
	       AND ss.id_partition = @preserved_partition
	OPTION(MAXDOP 1)
	
	UPDATE t_session_set_sess_to_keep
	SET    id_partition = @number_of_partition
	OPTION(MAXDOP 1)
	
	INSERT INTO t_session_set_sess_to_keep
	SELECT *
	FROM   t_session_set ss
	WHERE  ss.id_ss IN (SELECT s.id_ss
	                    FROM   ##id_sess_to_keep t
	                           JOIN t_session s
	                                ON  s.id_source_sess = t.id_sess)
	       AND ss.id_partition = @number_of_partition
	OPTION(MAXDOP 1)
	
	EXEC archive_queue_partition_clone_all_indexes_and_constraints
	     @SourceSchema = N'dbo',
	     @SourceTable = N't_session_set',
	     @DestinationSchema = N'dbo',
	     @DestinationTable = N't_session_set_sess_to_keep',
	     @FileGroup = N'MeterFileGroup'
		
	SET @sqlCommand = 'ALTER TABLE t_session_set_sess_to_keep WITH CHECK
						ADD CONSTRAINT CK_t_session_set_sess_to_keep CHECK((id_partition = ('
						+ CAST(@number_of_partition AS VARCHAR(20)) + ')))'
	EXEC (@sqlCommand)
	ALTER TABLE t_session_set_sess_to_keep CHECK CONSTRAINT CK_t_session_set_sess_to_keep
	
	BEGIN TRAN
	
	/* SWITCH OUT 'old' partition */
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = N't_session_set',
	     @temp_table_postfix = @temp_table_postfix_oldest,
	     @number_of_partition = @number_of_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	/* SWITCH OUT 'preserved' partition */
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = N't_session_set',
	     @temp_table_postfix = @temp_table_postfix_preserved,
	     @number_of_partition = @preserved_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	/* SWITCH IN new 'preserved' partition with sessions to keep */
	SET @sqlCommand = 'ALTER TABLE t_session_set_sess_to_keep SWITCH TO t_session_set PARTITION 
					$PARTITION.MeterPartitionFunction('
					+ CAST(@number_of_partition AS VARCHAR(20))+ ')'
	EXEC (@sqlCommand)
		
	COMMIT TRAN
	
	DROP TABLE t_session_set_sess_to_keep
	
	
	/* t_session_state */
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N't_session_state_sess_to_keep'))
		DROP TABLE t_session_state_sess_to_keep
	
	SELECT * INTO t_session_state_sess_to_keep
	FROM   t_session_state ss
	WHERE ss.id_sess IN (SELECT t.id_sess
	                          FROM   ##id_sess_to_keep t)
	       AND ss.id_partition = @preserved_partition
	OPTION(MAXDOP 1)
	
	UPDATE t_session_state_sess_to_keep
	SET    id_partition = @number_of_partition
	OPTION(MAXDOP 1)
	
	INSERT INTO t_session_state_sess_to_keep
	SELECT *
	FROM   t_session_state ss
	WHERE ss.id_sess IN (SELECT t.id_sess
	                          FROM   ##id_sess_to_keep t)
	       AND ss.id_partition = @number_of_partition
	OPTION(MAXDOP 1)
	
	EXEC archive_queue_partition_clone_all_indexes_and_constraints
	     @SourceSchema = N'dbo',
	     @SourceTable = N't_session_state',
	     @DestinationSchema = N'dbo',
	     @DestinationTable = N't_session_state_sess_to_keep',
	     @FileGroup = N'MeterFileGroup'
	
	SET @sqlCommand = 'ALTER TABLE t_session_state_sess_to_keep WITH CHECK
						ADD CONSTRAINT CK_t_session_state_sess_to_keep CHECK((id_partition = ('
						+ CAST(@number_of_partition AS VARCHAR(20)) + ')))'
	EXEC (@sqlCommand)
	ALTER TABLE t_session_state_sess_to_keep CHECK CONSTRAINT CK_t_session_state_sess_to_keep
	
	BEGIN TRAN
	
	/* SWITCH OUT 'old' partition */
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = N't_session_state',
	     @temp_table_postfix = @temp_table_postfix_oldest,
	     @number_of_partition = @number_of_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	/* SWITCH OUT 'preserved' partition */
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = N't_session_state',
	     @temp_table_postfix = @temp_table_postfix_preserved,
	     @number_of_partition = @preserved_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	/* SWITCH IN new 'preserved' partition with sessions to keep */
	SET @sqlCommand = 'ALTER TABLE t_session_state_sess_to_keep SWITCH TO t_session_state PARTITION
					$PARTITION.MeterPartitionFunction('
					+ CAST(@number_of_partition AS VARCHAR(20)) + ')'
	EXEC (@sqlCommand)
	
	COMMIT TRAN
	
	DROP TABLE t_session_state_sess_to_keep
	
	
	/* t_session */
	exec archive_queue_partition_switch_out_with_keep_sess
		@number_of_partition = @number_of_partition,
		@table_name = 't_session',
		@temp_table_postfix_oldest = @temp_table_postfix_oldest,
		@temp_table_postfix_preserved = @temp_table_postfix_preserved,
		@partition_filegroup_name = @partition_filegroup_name
GO
PRINT N'Creating [dbo].[archive_queue_partition]'
GO
CREATE PROCEDURE [dbo].[archive_queue_partition](
    @update_stats    CHAR(1) = 'N',
    @sampling_ratio  VARCHAR(3) = '30',
    @current_time DATETIME = NULL,
    @result          NVARCHAR(4000) OUTPUT
)
AS
	/* This SP is called from from basic SP - [archive_queue] if DB is partitioned */

	/*
	How to run this stored procedure:	
	DECLARE @result NVARCHAR(2000)
	EXEC archive_queue_partition @result = @result OUTPUT
	PRINT @result
	
	Or if we want to update statistics and change current date/time also:	
	DECLARE @result			NVARCHAR(2000),
	        @current_time	DATETIME
	SET @current_time = GETDATE()
	EXEC archive_queue_partition 'Y',
	     30,
	     @current_time = @current_time,
	     @result = @result OUTPUT
	PRINT @result	
	*/
	
	SET NOCOUNT ON
	
	DECLARE @next_allow_run_time       DATETIME,
	        @current_id_partition      INT,
	        @new_current_id_partition  INT,
	        @old_id_partition          INT,
	        @no_need_to_run            BIT,
	        @meter_partition_function_name   NVARCHAR(50),
	        @meter_partition_schema_name     NVARCHAR(50),
	        @meter_partition_filegroup_name  NVARCHAR(50),
	        @meter_partition_field_name      NVARCHAR(50),
	        @sqlCommand                      NVARCHAR(MAX)
	
	IF @current_time IS NULL
	    SET @current_time = GETDATE()
	
	SET @meter_partition_filegroup_name = dbo.prtn_GetMeterPartitionFileGroupName()
	SET @meter_partition_function_name = dbo.prtn_GetMeterPartitionFunctionName()
	SET @meter_partition_schema_name = dbo.prtn_GetMeterPartitionSchemaName()
	SET @meter_partition_field_name = 'id_partition'
	
	BEGIN TRY
		IF dbo.IsSystemPartitioned() = 0
			RAISERROR('DB is not partitioned. [archive_queue_partition] SP can be executed only on paritioned DB.', 16, 1)

		EXEC archive_queue_partition_get_status @current_time = @current_time,
		     @next_allow_run_time = @next_allow_run_time OUT,
		     @current_id_partition = @current_id_partition OUT,
		     @new_current_id_partition = @new_current_id_partition OUT,
		     @old_id_partition = @old_id_partition OUT,
		     @no_need_to_run = @no_need_to_run OUT
		
		IF @no_need_to_run = 1
		    RETURN
		
		IF @next_allow_run_time IS NULL
			RAISERROR ('Partition Schema and Default "id_partition" had already been updated. Skipping this step...', 0, 1)
		ELSE
		    EXEC archive_queue_partition_apply_next_partition
		         @new_current_id_partition = @new_current_id_partition,
		         @current_time = @current_time,
		         @meter_partition_function_name = @meter_partition_function_name,
		         @meter_partition_schema_name = @meter_partition_schema_name,
		         @meter_partition_filegroup_name = @meter_partition_filegroup_name,
		         @meter_partition_field_name = @meter_partition_field_name
		
		/* If it is the 1-st time of running [archive_queue_partition] there are only 2 partitions.
		* It is early to archive data.
		* When 3-rd partition is created the oldest one is archiving.
		* So, meter tables always have 2 partition.*/
		IF (
		       (
		           SELECT COUNT(current_id_partition)
		           FROM   t_archive_queue_partition
		       ) > 2
		   )
		BEGIN
			DECLARE @temp_table_postfix_oldest  NVARCHAR(50),
					@temp_table_postfix_preserved  NVARCHAR(50)
					
			SET @temp_table_postfix_oldest = '_switch_out_oldest_partition'
			SET	@temp_table_postfix_preserved = '_switch_out_preserved_partition'
			
		    /* Append temp table ##id_sess_to_keep with IDs of sessions from the 'oldest' partition that should not be archived */
		    EXEC archive_queue_partition_get_id_sess_to_keep @old_id_partition = @old_id_partition
		    
		    /* Move data from old to current partition for all meter tables if id_sess in ##id_sess_to_keep */
		    /* Switch out data from meter tables with @old_id_partition to temp_meter_tables */
		    EXEC archive_queue_partition_switch_out_partition_all
				@number_of_partition = @old_id_partition,
				@partition_filegroup_name = @meter_partition_filegroup_name,
				@temp_table_postfix_oldest = @temp_table_postfix_oldest,
				@temp_table_postfix_preserved = @temp_table_postfix_preserved
		    
		    IF OBJECT_ID('tempdb..##id_sess_to_keep') IS NOT NULL
		        DROP TABLE ##id_sess_to_keep
		    
		    /* Drop temp_meter_tables with switched out data of 'oldest' and 'preserved' partitions */
		    EXEC archive_queue_partition_drop_temp_tables
				@temp_table_postfix = @temp_table_postfix_oldest
		    
		    EXEC archive_queue_partition_drop_temp_tables
				@temp_table_postfix = @temp_table_postfix_preserved
		    		    
		    /* Remove obsolete boundary value that divides 2 empty partitions.
		    * (Ensure no data movement ) */
		    DECLARE @obsoleteRange INT
		    SET @obsoleteRange = @old_id_partition - 2 /* range value before 'preserved' partition range value */
		    IF EXISTS(
		           SELECT *
		           FROM   sys.partition_functions pf
		                  JOIN sys.partition_range_values prv
		                       ON  prv.function_id = pf.function_id
		           WHERE  pf.name = @meter_partition_function_name
		                  AND prv.value = @obsoleteRange
		       )
		    BEGIN
		        SET @sqlCommand = 'ALTER PARTITION FUNCTION ' + @meter_partition_function_name
		            + '() MERGE RANGE (' + CAST(@obsoleteRange AS NVARCHAR(20)) + ')'
		        EXEC (@sqlCommand)
		    END
		END
		
		/* Update next_allow_run value in [t_archive_queue_partition] table.
		* This is an indicator of successful archivation*/
		EXEC prtn_GetNextAllowRunDate @current_datetime = @current_time,
			 @next_allow_run_date = @next_allow_run_time OUT
		
		UPDATE t_archive_queue_partition
		SET next_allow_run = @next_allow_run_time
		WHERE current_id_partition = @new_current_id_partition
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		    ROLLBACK TRANSACTION
		    
		DECLARE @ErrorSeverity  INT,
		        @ErrorState     INT
		
		SELECT @result = ERROR_MESSAGE(),
		       @ErrorSeverity = ERROR_SEVERITY(),
		       @ErrorState = ERROR_STATE()
		
		RAISERROR (@result, @ErrorSeverity, @ErrorState)
		
		RETURN
	END CATCH
		
	DECLARE @tab1                   NVARCHAR(1000),
	        @sql1                   NVARCHAR(4000),
	        @NU_varStatPercentChar  VARCHAR(255)
	
	IF (@update_stats = 'Y')
	BEGIN
	    DECLARE c1 CURSOR FAST_FORWARD
	    FOR
	        SELECT nm_table_name
	        FROM   t_service_def_log
	    
	    OPEN c1
	    FETCH NEXT FROM c1 INTO @tab1
	    WHILE (@@fetch_status = 0)
	    BEGIN
	        IF @sampling_ratio < 5
	            SET @NU_varStatPercentChar = ' WITH SAMPLE 5 PERCENT '
	        ELSE
	        IF @sampling_ratio >= 100
	            SET @NU_varStatPercentChar = ' WITH FULLSCAN '
	        ELSE
	            SET @NU_varStatPercentChar = ' WITH SAMPLE '
	                + CAST(@sampling_ratio AS VARCHAR(20)) + ' PERCENT '
	        
	        SET @sql1 = 'UPDATE STATISTICS ' + @tab1 + @NU_varStatPercentChar
	        EXECUTE (@sql1)
	        IF (@@error <> 0)
	        BEGIN
	            SET @result =
	                '7000022-archive_queue_partition operation failed-->Error in update stats'
	            
	            CLOSE c1
	            DEALLOCATE c1
				RAISERROR (@result, 16, 1)
	        END
	        
	        FETCH NEXT FROM c1 INTO @tab1
	    END
	    CLOSE c1
	    DEALLOCATE c1
	    SET @sql1 = 'UPDATE STATISTICS t_session ' + @NU_varStatPercentChar
	    EXECUTE (@sql1)
	    SET @sql1 = 'UPDATE STATISTICS t_session_set ' + @NU_varStatPercentChar
	    EXECUTE (@sql1)
	    SET @sql1 = 'UPDATE STATISTICS t_session_state ' + @NU_varStatPercentChar
	    EXECUTE (@sql1)
	    SET @sql1 = 'UPDATE STATISTICS t_message' + @NU_varStatPercentChar
	    EXECUTE (@sql1)
	END
	
	SET @result = '0-archive_queue_partition operation successful'
GO
PRINT N'Altering [dbo].[archive_queue]'
GO
ALTER PROCEDURE [dbo].[archive_queue](
    @update_stats    CHAR(1) = 'N',
    @sampling_ratio  VARCHAR(3) = '30',
    @current_time    DATETIME = NULL,
    @result          NVARCHAR(4000) OUTPUT
)
AS
	/*
	How to run this stored procedure:	
	DECLARE @result NVARCHAR(2000)
	EXEC archive_queue @result = @result OUTPUT
	PRINT @result
	
	Or if we want to update statistics and change current date/time also:	
	DECLARE @result            NVARCHAR(2000),
	        @current_time  DATETIME
	SET @current_time = GETDATE()
	EXEC archive_queue 'Y',
	     30,
	     @current_time = @current_time,
	     @result = @result OUTPUT
	PRINT @result	
	*/
	
	SET NOCOUNT ON
	
	IF dbo.IsSystemPartitioned() = 1
	    EXEC archive_queue_partition
	         @update_stats = @update_stats,
	         @sampling_ratio = @sampling_ratio,
	         @current_time = @current_time,
	         @result = @result OUTPUT
	ELSE
	    EXEC archive_queue_nonpartition
	         @update_stats = @update_stats,
	         @sampling_ratio = @sampling_ratio,
	         @result = @result OUTPUT
GO
PRINT N'Altering [dbo].[prtn_DeployAllMeterPartitionedTables]'
GO
ALTER PROCEDURE [dbo].[prtn_DeployAllMeterPartitionedTables]
	AS
	BEGIN
		DECLARE @svc_table_name VARCHAR(50),
				@meter_partition_schema VARCHAR(100)

		BEGIN TRY
			SET @meter_partition_schema = dbo.prtn_GetMeterPartitionSchemaName()

			IF dbo.IsSystemPartitioned()=0
				RAISERROR('System not enabled for partitioning.', 16, 1)

			DECLARE svctablecur CURSOR FOR
								SELECT nm_table_name
								FROM t_service_def_log

			--------------------------------------------------------------------------
			------------------Deploy service definition tables -----------------------
			--------------------------------------------------------------------------
			OPEN svctablecur
			FETCH NEXT FROM svctablecur INTO @svc_table_name
			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				EXEC prtn_CreatePartitionedTable
						@svc_table_name,
						N'id_source_sess ASC, id_partition ASC',
						@meter_partition_schema,
						N'id_partition'
			
			FETCH NEXT FROM svctablecur INTO @svc_table_name
			END

			-------------------------------------------------------------------------
			-----------------Deploy message and session tables-----------------------
			-------------------------------------------------------------------------
			EXEC prtn_CreatePartitionedTable
						N't_message',
						N'id_message ASC, id_partition ASC',
						@meter_partition_schema,
						N'id_partition'

			EXEC prtn_CreatePartitionedTable
						N't_session',
						N'id_ss ASC, id_source_sess ASC, id_partition ASC',
						@meter_partition_schema,
						N'id_partition'

			EXEC prtn_CreatePartitionedTable
						N't_session_set',
						N'id_ss ASC, id_partition ASC',
						@meter_partition_schema,
						N'id_partition'

			EXEC prtn_CreatePartitionedTable
						N't_session_state',
						N'id_sess ASC, dt_end ASC, tx_state ASC, id_partition ASC',
						@meter_partition_schema,
						N'id_partition'
		END TRY
		BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT
		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
		END CATCH
	END
GO
PRINT N'Altering [dbo].[amp_staging_tables]'
GO
ALTER TABLE [dbo].[amp_staging_tables] ALTER COLUMN [node_id] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
PRINT N'Creating index [amp_staging_ndx] on [dbo].[amp_staging_tables]'
GO
CREATE NONCLUSTERED INDEX [amp_staging_ndx] ON [dbo].[amp_staging_tables] ([mvm_run_id], [node_id])
GO
PRINT N'Altering [dbo].[mvm_complete_mvm_run_id]'
GO
ALTER
PROCEDURE [dbo].[mvm_complete_mvm_run_id](
    @p_preserve_tables INT,
    @p_preserve_offset INT,
    @p_mvm_run_id INT)
AS
BEGIN

declare @my_preserve_tables INT
declare @my_preserve_offset INT
declare @missing_tables INT = 0

  set @my_preserve_tables = @p_preserve_tables;
  set @my_preserve_offset = @p_preserve_offset;
  if (@my_preserve_offset IS NULL) BEGIN
	set @my_preserve_offset = 31
  END

  IF (@my_preserve_tables = -1) BEGIN
	declare @old_mvm_run_id int = 0
	declare cursor1 CURSOR for SELECT distinct a.mvm_run_id old_mvm_run_id
    FROM amp_staging_tables a
	inner join mvm_run_history b on a.mvm_run_id = b.mvm_run_id
    WHERE a.mvm_run_id != @p_mvm_run_id
	AND b.end_dt IS NULL
	and dateadd(day, 0 - @my_preserve_offset, getdate()) > b.start_dt
	open cursor1
	fetch next from cursor1 into @old_mvm_run_id
	while @@FETCH_STATUS=0
	begin
      		exec mvm_complete_mvm_run_id 0,0,@old_mvm_run_id
		fetch next from cursor1 into @old_mvm_run_id
	end
	close cursor1
	deallocate cursor1

    set @my_preserve_tables = 0
  END

  IF (@my_preserve_tables) = 0 BEGIN

	declare @staging_table_name VARCHAR(1000)
	declare cursor2 CURSOR for SELECT staging_table_name
    FROM amp_staging_tables
    WHERE mvm_run_id = @p_mvm_run_id
	open cursor2
	fetch next from cursor2 into @staging_table_name
	while @@FETCH_STATUS=0
	begin
		begin try
			execute ('begin drop table ' + @staging_table_name + ' end');
		end try
		begin catch
			set @missing_tables = 1
		end catch
		fetch next from cursor2 into @staging_table_name
	end
	close cursor2
	deallocate cursor2

    delete amp_staging_tables where mvm_run_id = @p_mvm_run_id

  END
  update MVM_RUN_HISTORY set end_dt = getdate() where mvm_run_id = @p_mvm_run_id

END
GO
PRINT N'Altering [dbo].[mvm_create_blk_upd_table2]'
GO
ALTER PROCEDURE [dbo].[mvm_create_blk_upd_table2](
    @p_table  VARCHAR(4000),           -- table to bulk update
    @p_prefix VARCHAR(4000),           -- prefix on blk_upd_table name
    @p_mvm_run_id INTEGER,           --  identifier of mvm run
    @p_node_id VARCHAR(4000),           --  identifier of mvm node_id
    @p_blk_upd_table VARCHAR(4000) OUTPUT, -- table we created
    @p_pk_col_string VARCHAR(4000)='' -- optional user specified pk (comma separated) needed if table is really an updateable view
  )
AS
begin
	declare @sql table(s varchar(1000), id int identity)
	declare @v_pk_cols table(s varchar(1000), id int identity)
	declare @v_pk_cols2 table(s varchar(1000), id int identity)
	declare @guid uniqueidentifier
	declare @is_partitioned integer

	--determine if table is partioned
	exec mvm_is_partitioned @p_table=@p_table, @p_is_partitioned=@is_partitioned OUTPUT
	--print 'is_partitioned='+CONVERT(varchar(5), @is_partitioned)

  -- Populate v_pk_cols with ordered list of primary key columns.
  -- Use comma delimited string p_pk_col_string if passed, else look at the pk fields
  -- in p_table
  IF @p_pk_col_string IS NULL
	begin
		if(@is_partitioned=0)
		begin
			insert into @v_pk_cols(s)
			SELECT ' '+ b.column_name + ','
				FROM information_schema.table_constraints a
				INNER JOIN information_schema.key_column_usage b ON a.constraint_name = b.CONSTRAINT_NAME
				WHERE a.constraint_type = 'PRIMARY KEY'
				AND a.table_name = @p_table
				order by ordinal_position
				
			insert into @v_pk_cols2(s)
			SELECT b.column_name
				FROM information_schema.table_constraints a
				INNER JOIN information_schema.key_column_usage b ON a.constraint_name = b.CONSTRAINT_NAME
				WHERE a.constraint_type = 'PRIMARY KEY'
				AND a.table_name = @p_table
				order by ordinal_position
		end
		else
		begin
			insert into @v_pk_cols(s)
			SELECT ' '+ b.column_name + ','
				FROM n_default.information_schema.table_constraints a
				INNER JOIN n_default.information_schema.key_column_usage b ON a.constraint_name = b.CONSTRAINT_NAME
				WHERE a.constraint_type = 'PRIMARY KEY'
				AND a.table_name = @p_table
				order by ordinal_position
				
			insert into @v_pk_cols2(s)
			SELECT b.column_name
				FROM n_default.information_schema.table_constraints a
				INNER JOIN n_default.information_schema.key_column_usage b ON a.constraint_name = b.CONSTRAINT_NAME
				WHERE a.constraint_type = 'PRIMARY KEY'
				AND a.table_name = @p_table
				order by ordinal_position
		end
   end
  ELSE
	begin
	  print 'spliting '+@p_pk_col_string
	  insert into @v_pk_cols(s)
	  SELECT items FROM mvm_split(@p_pk_col_string,',')

	  insert into @v_pk_cols2(s)
	  SELECT items FROM mvm_split(@p_pk_col_string,',')
	end
 
--	declare @stmt1 varchar(8000)
--	SELECT @stmt1 = coalesce(@stmt1 + CHAR(13)+ CHAR(10), '') + s
--	FROM @v_pk_cols
--	print 'got pk cols:'+ CHAR(13)+ CHAR(10)+@stmt1


	-- name of tmp bulk update table
	select @p_blk_upd_table=substring(@p_prefix + replace( newid(),'-',''),0,30)
	while (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME=@p_blk_upd_table))
	begin
		select @p_blk_upd_table=substring(@p_prefix+replace( newid(),'-',''),0,30)
	end

	-- create statement
	insert into  @sql(s) values ('create table [' + @p_blk_upd_table + '] ( format_id int,')

    -- add the pk_N columns as not null allowable
	declare @pk_col_ctr int=0
	declare @pk_col_name nvarchar(1000)
	declare cursor1 CURSOR for select s from @v_pk_cols2 ORDER BY id
	open cursor1
	fetch next from cursor1 into @pk_col_name
	while @@FETCH_STATUS=0
	begin
		print 'here with pk_col_name:'+@pk_col_name + ' and ' + @p_table
		if(@is_partitioned=0)
		begin
			insert into @sql(s)
			select
			'  ['+'pk_'+convert(varchar,@pk_col_ctr)+'] '+data_type + case data_type when 'numeric' then '('+cast(numeric_precision as varchar)+',' + cast(numeric_scale as varchar) +')' else coalesce('('+cast(character_maximum_length as varchar)+')','') end + ' NOT NULL,'
			FROM  information_schema.columns
			WHERE upper(table_name) = upper(@p_table) and upper(COLUMN_NAME) = upper(@pk_col_name)
		end
		else
		begin
			insert into @sql(s)
			select
			'  ['+'pk_'+convert(varchar,@pk_col_ctr)+'] '+data_type + case data_type when 'numeric' then '('+cast(numeric_precision as varchar)+',' + cast(numeric_scale as varchar) +')' else coalesce('('+cast(character_maximum_length as varchar)+')','') end + ' NOT NULL,'
			FROM  n_default.information_schema.columns
			WHERE upper(table_name) = upper(@p_table) and upper(COLUMN_NAME) = upper(@pk_col_name)
		end

		set @pk_col_ctr=@pk_col_ctr+1
		fetch next from cursor1 into @pk_col_name
	end
	close cursor1
	deallocate cursor1

	-- add all columns all as null allowable
	if(@is_partitioned=0)
	begin
		insert into @sql(s)
		select
		'  ['+column_name+'] '+data_type + case data_type when 'numeric' then '('+cast(numeric_precision as varchar)+',' + cast(numeric_scale as varchar) +')' else coalesce('('+cast(character_maximum_length as varchar)+')','') end + ' NULL,'
		FROM  information_schema.columns
		WHERE table_name = @p_table
		order by ordinal_position
	end
	else
	begin
		insert into @sql(s)
		select
		'  ['+column_name+'] '+data_type + case data_type when 'numeric' then '('+cast(numeric_precision as varchar)+',' + cast(numeric_scale as varchar) +')' else coalesce('('+cast(character_maximum_length as varchar)+')','') end + ' NULL,'
		FROM  n_default.information_schema.columns
		WHERE table_name = @p_table
		order by ordinal_position
	end
	

	-- add primary key
	insert into @sql(s) values( ' CONSTRAINT pk_' + @p_blk_upd_table + ' PRIMARY KEY (' )

	-- specify the primary key columns 
	insert into @sql(s)
	SELECT
    rownum = 'pk_'+convert(varchar,ROW_NUMBER() OVER (ORDER BY t.s ASC)-1)+','
	FROM @v_pk_cols t ORDER BY id

	-- remove trailing comma
	update @sql set s=left(s,len(s)-1) where id=(select max(id) from @sql) --@@identity
	
	-- PK closing bracket
	insert into @sql(s) values( ')' )

	-- create closing bracket
	insert into @sql(s) values( ')' )

   -- result!
	declare @stmt varchar(8000)
	SELECT @stmt = coalesce(@stmt + CHAR(13)+ CHAR(10), '') + s
	FROM @sql order by id

	--print @stmt

	begin try
		EXECUTE( 'begin '+@stmt+' end')
		insert into amp_staging_tables (mvm_run_id, node_id, staging_table_name, create_dt) values(@p_mvm_run_id, @p_node_id, @p_blk_upd_table, getdate())

	end try
	begin catch

			DECLARE @FullMessage NVARCHAR(4000);
 		DECLARE @ErrorMessage NVARCHAR(4000);
    		DECLARE @ErrorSeverity INT;
    		DECLARE @ErrorState INT;
    		SELECT
        		@ErrorMessage = ERROR_MESSAGE(),
        		@ErrorSeverity = ERROR_SEVERITY(),
        		@ErrorState = ERROR_STATE();
        select @FullMessage='Error in mvm_create_blk_upd_table2. Got error ['+@ErrorMessage+'] running dynamic sql ['+ 'begin '+@stmt+' end'+']' ;
		RAISERROR(@fullMessage, 16, 1)
	end catch

end
GO
PRINT N'Altering [dbo].[mvm_get_mvm_run_id]'
GO
ALTER
PROCEDURE [dbo].[mvm_get_mvm_run_id](
    @p_app_name VARCHAR(4000),
    @p_mvm_run_id INT OUTPUT )
AS
BEGIN
  -- add our sequence if not there
  INSERT INTO t_current_id SELECT 1,'mvm_run_id',1
  WHERE NOT EXISTS
    (SELECT * FROM t_current_id WHERE nm_current='mvm_run_id');
    
    -- use the core mt proc to get the next value
    exec [DBO].[GetCurrentID] @nm_current = N'mvm_run_id', @id_current  = @p_mvm_run_id OUTPUT

  insert into MVM_RUN_HISTORY(mvm_run_id, application_name, start_dt, end_dt) values (@p_mvm_run_id, @p_app_name, getdate(), NULL);
END
GO
PRINT N'Creating [dbo].[t_acc_template_subs_pub]'
GO
CREATE TABLE [dbo].[t_acc_template_subs_pub]
(
[id_po] [int] NULL,
[id_group] [int] NULL,
[id_acc_template] [int] NOT NULL,
[vt_start] [datetime] NULL,
[vt_end] [datetime] NULL
)
GO

	create clustered index acc_template_subs_pub_idx1 on t_acc_template_subs_pub(id_acc_template,id_po)
	GO
	create index acc_template_subs_pub_idx2 on t_acc_template_subs_pub(id_acc_template,id_group)
	GO

PRINT N'Altering [dbo].[DeleteAccounts]'
GO
ALTER Procedure [dbo].[DeleteAccounts]
				@account_id_list nvarchar(4000), --accounts to be deleted
				@table_name nvarchar(4000), --table containing id_acc to be deleted
				@linked_server_name nvarchar(255), --linked server name for payment server
				@payment_server_dbname nvarchar(255) --payment server database name
			AS
			set nocount on
			set xact_abort on
			declare @sql nvarchar(4000)
	/*
			How to run this stored procedure
			exec DeleteAccounts @account_id_list='123,124',@table_name=null,@linked_server_name=null,@payment_server_dbname=null
			or
			exec DeleteAccounts @account_id_list=null,@table_name='tmp_t_account',@linked_server_name=null,@payment_server_dbname=null
	*/
				-- Break down into simple account IDs
				-- This block of SQL can be used as an example to get
				-- the account IDs from the list of account IDs that are
				-- passed in
				CREATE TABLE #AccountIDsTable (
				  ID int NOT NULL,
					status int NULL,
					message varchar(255) NULL)

				PRINT '------------------------------------------------'
				PRINT '-- Start of Account Deletion Stored Procedure --'
				PRINT '------------------------------------------------'

				if ((@account_id_list is not null and @table_name is not null) or
				(@account_id_list is null and @table_name is null))
				begin
					print 'ERROR--Delete account operation failed-->Either account_id_list or table_name should be specified'
					return -1
				END

				if (@account_id_list is not null)
				begin
					PRINT '-- Parsing Account IDs passed in and inserting in tmp table --'
					WHILE CHARINDEX(',', @account_id_list) > 0
					BEGIN
						INSERT INTO #AccountIDsTable (ID, status, message)
	 					SELECT SUBSTRING(@account_id_list,1,(CHARINDEX(',', @account_id_list)-1)), 1, 'Okay to delete'
	 					SET @account_id_list =
	 						SUBSTRING (@account_id_list, (CHARINDEX(',', @account_id_list)+1),
	  										(LEN(@account_id_list) - (CHARINDEX(',', @account_id_list))))
					END
	 						INSERT INTO #AccountIDsTable (ID, status, message)
							SELECT @account_id_list, 1, 'Okay to delete'
					-- SELECT ID as one FROM #AccountIDsTable

					-- Transitive Closure (check for folder/corporation)
					PRINT '-- Inserting children (if any) into the tmp table --'
					INSERT INTO #AccountIDsTable (ID, status, message)
					SELECT DISTINCT
					  aa.id_descendent,
						1,
						'Okay to delete'
					FROM
					  t_account_ancestor aa INNER JOIN #AccountIDsTable tmp ON
						tmp.ID = aa.id_ancestor AND
						aa.num_generations > 0 AND
					NOT EXISTS (
					  SELECT
						  ID
						FROM
						  #AccountIDsTable tmp1
						WHERE
						  tmp1.ID = aa.id_descendent)

					--fix bug 11599
					INSERT INTO #AccountIDsTable (ID, status, message)
					SELECT DISTINCT
					  aa.id_descendent,
						1,
						'Okay to delete'
					FROM
					  t_account_ancestor aa where id_ancestor in (select id from  #AccountIDsTable)
						AND
						aa.num_generations > 0 AND
					NOT EXISTS (
					  SELECT
						  ID
						FROM
						  #AccountIDsTable tmp1
						WHERE
						  tmp1.ID = aa.id_descendent)
				end
				else
				begin
					set @sql = 'INSERT INTO #AccountIDsTable (ID, status, message) SELECT id_acc,
							1, ''Okay to delete'' from ' + @table_name
					exec (@sql)
					INSERT INTO #AccountIDsTable (ID, status, message)
					SELECT DISTINCT
					  aa.id_descendent,
						1,
						'Okay to delete'
					FROM
					  t_account_ancestor aa INNER JOIN #AccountIDsTable tmp ON
						tmp.ID = aa.id_ancestor AND
						aa.num_generations > 0 AND
					NOT EXISTS (
					  SELECT
						  ID
						FROM
						  #AccountIDsTable tmp1
						WHERE
						  tmp1.ID = aa.id_descendent)
				end
				-- SELECT * from #AccountIDsTable

				/*
				-- print out the accounts with their login names
				SELECT
					ID as two,
					nm_login as two
				FROM
					#AccountIDsTable a,
					t_account_mapper b
				WHERE
					a.ID = b.id_acc
				*/

				/*
				 * Check for all the business rules.  We want to make sure
				 * that we are checking the more restrictive rules first
				 * 1. Check for usage in hard closed interval
				 * 2. Check for invoices in hard closed interval
				 * 3. Check if the account is a payer ever
				 * 4. Check if the account is a payee for usage that exists in the system
				 * 5. Check if the account is a receiver of per subscription Recurring
				 *    Charge
				 * 6. Check for usage in soft/open closed interval
				 * 7. Check for invoices in soft/open closed interval
				 * 8. Check if the account contributes to group discount
				 */
				PRINT '-- Account does not exists check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account does not exists!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					not EXISTS (
						SELECT
							1
						FROM
							t_account acc
						WHERE
							acc.id_acc = tmp.ID )

				-- 1. Check for 'hard close' usage in any of these accounts
				PRINT '-- Usage in Hard closed interval check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account contains usage in hard interval!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							au.id_acc
						FROM
							t_acc_usage au INNER JOIN t_acc_usage_interval ui
						ON
							ui.id_usage_interval = au.id_usage_interval AND
							ui.tx_status in ('H') AND
							au.id_acc = ui.id_acc
						WHERE
							au.id_acc = tmp.ID )

				-- 2. Check for invoices in hard closed interval usage in any of these
				-- accounts
				PRINT '-- Invoices in Hard closed interval check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account contains invoices for hard closed interval!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							i.id_acc
						FROM
							t_invoice i INNER JOIN t_acc_usage_interval ui
						ON
							ui.id_usage_interval = i.id_interval AND
							ui.tx_status in ('H')
						WHERE
							i.id_acc = tmp.ID )

				-- 3. Check if this account has ever been a payer
				PRINT '-- Payer check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account is a payer!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							p.id_payer
						FROM
							t_payment_redir_history p
						WHERE
							p.id_payer = tmp.ID AND
							p.id_payee not in (select id from #AccountIDsTable))

				-- 4. Check if the account is a payee for usage that exists in the system
				PRINT '-- Payee usage check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account is a payee with usage in the system!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT TOP 1 *
						FROM
							t_acc_usage accU
						WHERE
							accU.id_payee = tmp.ID)
							
				-- 5. Check if this account is receiver of per subscription RC
				PRINT '-- Receiver of per subscription Recurring Charge check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account is receiver of per subscription RC!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							gsrm.id_acc
						FROM
							t_gsub_recur_map gsrm
						WHERE
							gsrm.id_acc = tmp.ID )

				-- 6. Check for invoices in soft closed or open usage in any of these
				-- accounts
				PRINT '-- Invoice in Soft closed/Open interval check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account contains invoices for soft closed interval.  Please backout invoice adapter first!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							i.id_acc
						FROM
							t_invoice i INNER JOIN t_acc_usage_interval ui
						ON
							ui.id_usage_interval = i.id_interval AND
							ui.tx_status in ('C', 'O')
						WHERE
							i.id_acc = tmp.ID )

				-- 7. Check for 'soft close/open' usage in any of these accounts
				PRINT '-- Usage in Soft closed/Open interval check --'
				UPDATE
					tmp
				SET					status = 0, -- failure
					message = 'Account contains usage in soft closed or open interval.  Please backout first!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							au.id_acc
						FROM
							t_acc_usage au INNER JOIN t_acc_usage_interval ui
						ON
							ui.id_usage_interval = au.id_usage_interval AND
							ui.tx_status in ('C', 'O') AND
							au.id_acc = ui.id_acc
						WHERE
							au.id_acc = tmp.ID )

				-- 8. Check if this account contributes to group discount
				PRINT '-- Contribution to Discount Distribution check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account is contributing to a discount!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							gs.id_discountAccount
						FROM
							t_group_sub gs
						WHERE
							gs.id_discountAccount = tmp.ID )

				IF EXISTS (
					SELECT
						*
					FROM
						#AccountIDsTable
					WHERE
						status = 0)
				BEGIN					PRINT 'Deletion of accounts cannot proceed. Fix the errors!'
					PRINT '-- Exiting --!'
					SELECT
						*
					FROM
						#AccountIDsTable

					RETURN
				END

				-- Start the deletes here
				PRINT '-- Beginning the transaction here --'
				BEGIN TRANSACTION

				-- Script to find ICB rates and delete from t_pt, t_rsched,
				-- t_pricelist tables
				PRINT '-- Finding ICB rate and deleting for PC tables --'
				create table #id_sub (id_sub int)
				INSERT into #id_sub select id_sub from t_sub where id_acc
				IN (SELECT ID FROM #AccountIDsTable)
				DECLARE @id_pt table (id_pt int,id_pricelist int)
				INSERT
					@id_pt
				SELECT
					id_paramtable,
					id_pricelist
				FROM
					t_pl_map
				WHERE
					id_sub IN (SELECT * FROM #id_sub)
				DECLARE c1 cursor forward_only for select id_pt,id_pricelist from @id_pt
				DECLARE @name varchar(200)
				DECLARE @pt_name varchar(200)
				DECLARE @pl_name varchar(200)
				DECLARE @str varchar(4000)
				OPEN c1
				FETCH c1 INTO @pt_name,@pl_name
				SELECT
					@name =
				REVERSE(substring(REVERSE(nm_name),1,charindex('/',REVERSE(nm_name))-1))
				FROM
					t_base_props
				WHERE
					id_prop = @pt_name
				SELECT
					@str = 'DELETE t_pt_' + @name + ' from t_pt_' + @name + ' INNER JOIN t_rsched rsc on t_pt_'
						+ @name + '.id_sched = rsc.id_sched
						INNER JOIN t_pl_map map ON
						map.id_paramtable = rsc.id_pt AND
						map.id_pi_template = rsc.id_pi_template AND
						map.id_pricelist = rsc.id_pricelist
						WHERE map.id_sub IN (SELECT id_sub FROM #id_sub)'
				EXECUTE (@str)
				SELECT @str = 'DELETE FROM t_rsched WHERE id_pricelist =' + @pl_name
				EXECUTE (@str)
				SELECT @str = 'DELETE FROM t_pl_map WHERE id_pricelist =' + @pl_name
				EXECUTE (@str)
				SELECT @str = 'DELETE FROM t_pricelist WHERE id_pricelist =' + @pl_name
				EXECUTE (@str)

				CLOSE c1
				DEALLOCATE c1

				-- t_billgroup_member
				PRINT '-- Deleting from t_billgroup_member --'
				DELETE FROM t_billgroup_member
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_billgroup_member table'
					GOTO SetError
				END

				-- t_billgroup_member_history
				PRINT '-- Deleting from t_billgroup_member_history --'
				DELETE FROM t_billgroup_member_history
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_billgroup_member_history table'
					GOTO SetError
				END

				-- t_billgroup_member_history
				PRINT '-- Deleting from t_billgroup_source_acc --'
				DELETE FROM t_billgroup_source_acc
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_billgroup_source_acc table'
					GOTO SetError
				END

				-- t_billgroup_constraint
				PRINT '-- Deleting from t_billgroup_constraint  --'
				DELETE FROM t_billgroup_constraint
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_billgroup_constraint table'
					GOTO SetError
				END

				-- t_billgroup_constraint_tmp
				PRINT '-- Deleting from t_billgroup_constraint_tmp --'
				DELETE FROM t_billgroup_constraint_tmp
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_billgroup_constraint_tmp table'
					GOTO SetError
				END

				-- t_av_* tables
				DECLARE @t_av_table_name nvarchar(1000)
				DECLARE c2 CURSOR FOR SELECT table_name FROM information_schema.tables
				WHERE table_name LIKE 't_av_%' AND table_type = 'BASE TABLE'
				-- Delete from t_av_* tables
				OPEN c2
				FETCH NEXT FROM c2 into @t_av_table_name
				WHILE (@@FETCH_STATUS = 0)
				BEGIN
					PRINT '-- Deleting from ' + @t_av_table_name + ' --'
					EXEC ('DELETE FROM ' + @t_av_table_name + ' WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)')
					IF (@@Error <> 0)
					BEGIN
						PRINT 'Cannot delete from ' + @t_av_table_name + ' table'
  						CLOSE c2
   						DEALLOCATE c2
						GOTO SetError
					END
   					FETCH NEXT FROM c2 INTO @t_av_table_name
				END
  				CLOSE c2
   				DEALLOCATE c2

				-- t_account_state_history
				PRINT '-- Deleting from t_account_state_history --'
				DELETE FROM t_account_state_history
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_account_state_history table'
					GOTO SetError
				END

				-- t_account_state
				PRINT '-- Deleting from t_account_state --'
				DELETE FROM t_account_state
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_account_state table'
					GOTO SetError
				END

				-- t_acc_usage_interval
				PRINT '-- Deleting from t_acc_usage_interval --'
				DELETE FROM t_acc_usage_interval
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_acc_usage_interval table'
					GOTO SetError
				END

				-- t_acc_usage_cycle
				PRINT '-- Deleting from t_acc_usage_cycle --'
				DELETE FROM t_acc_usage_cycle
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_acc_usage_cycle table'
					GOTO SetError
				END

				-- t_acc_template_props
				PRINT '-- Deleting from t_acc_template_props --'
				DELETE FROM t_acc_template_props
				WHERE id_acc_template IN
				(SELECT id_acc_template
				FROM t_acc_template
				WHERE id_folder in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_acc_template_props table'
					GOTO SetError
				END

				-- t_acc_template_subs
				PRINT '-- Deleting from t_acc_template_subs --'
				DELETE FROM t_acc_template_subs
				WHERE id_acc_template IN
				(SELECT id_acc_template
				FROM t_acc_template
				WHERE id_folder in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_acc_template_subs table'
					GOTO SetError
				END

				-- t_acc_template_subs_pub
				PRINT '-- Deleting from t_acc_template_subs_pub --'
				DELETE FROM t_acc_template_subs_pub
				WHERE id_acc_template IN
				(SELECT id_acc_template
				FROM t_acc_template
				WHERE id_folder in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_acc_template_subs_pub table'
					GOTO SetError
				END

				-- t_acc_template
				PRINT '-- Deleting from t_acc_template --'
				DELETE FROM t_acc_template
				WHERE id_folder in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_acc_template table'
					GOTO SetError
				END

				-- t_user_credentials
				PRINT '-- Deleting from t_user_credentials --'
				DELETE FROM t_user_credentials
				WHERE nm_login IN
				(SELECT nm_login
				FROM t_account_mapper
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_user_credentials table'
					GOTO SetError
				END

				-- t_profile
				PRINT '-- Deleting from t_profile --'
				DELETE FROM t_profile
				WHERE id_profile IN
				(SELECT id_profile
				FROM t_site_user
				WHERE nm_login IN
				(SELECT nm_login
				FROM t_account_mapper
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_profile table'
					GOTO SetError
				END

				-- t_site_user
				PRINT '-- Deleting from t_site_user --'
				DELETE FROM t_site_user
				WHERE nm_login IN
				(SELECT nm_login
				FROM t_account_mapper
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_site_user table'
					GOTO SetError
				END

				-- t_payment_redirection
				PRINT '-- Deleting from t_payment_redirection --'
				DELETE FROM t_payment_redirection
				WHERE id_payee IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_payment_redirection table'
					GOTO SetError
				END

				-- t_payment_redir_history
				PRINT '-- Deleting from t_payment_redir_history --'
				DELETE FROM t_payment_redir_history
				WHERE id_payee IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_payment_redir_history table'
					GOTO SetError
				END

				-- t_sub
				PRINT '-- Deleting from t_sub --'
				DELETE FROM t_sub
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_sub table'
					GOTO SetError
				END

				-- t_sub_history
				PRINT '-- Deleting from t_sub_history --'
				DELETE FROM t_sub_history
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_sub_history table'
					GOTO SetError
				END

				-- t_group_sub
				PRINT '-- Deleting from t_group_sub --'
				DELETE FROM t_group_sub
				WHERE id_discountAccount in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_group_sub table'
					GOTO SetError
				END

				-- t_gsubmember
				PRINT '-- Deleting from t_gsubmember --'
				DELETE FROM t_gsubmember
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_gsubmember table'
					GOTO SetError
				END

				-- t_gsubmember_historical
				PRINT '-- Deleting from t_gsubmember_historical --'
				DELETE FROM t_gsubmember_historical
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_gsubmember_historical table'
					GOTO SetError
				END

				-- t_gsub_recur_map
				PRINT '-- Deleting from t_gsub_recur_map --'
				DELETE FROM t_gsub_recur_map
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
				  PRINT 'Cannot delete from t_gsub_recur_map table'
					GOTO SetError
				END

				-- t_pl_map
				PRINT '-- Deleting from t_pl_map --'
				DELETE FROM t_pl_map
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_pl_map table'
					GOTO SetError
				END

				-- t_path_capability
				PRINT '-- Deleting from t_path_capability --'
				DELETE FROM t_path_capability
				WHERE id_cap_instance IN (
				SELECT id_cap_instance FROM t_capability_instance ci
				WHERE ci.id_policy IN (
				SELECT id_policy FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_path_capability table'
					GOTO SetError
				END

				-- t_enum_capability
				PRINT '-- Deleting from t_enum_capability --'
				DELETE FROM t_enum_capability
				WHERE id_cap_instance IN (
				SELECT id_cap_instance FROM t_capability_instance ci
				WHERE ci.id_policy IN (
				SELECT id_policy FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_enum_capability table'
					GOTO SetError
				END

				-- t_decimal_capability
				PRINT '-- Deleting from t_decimal_capability --'
				DELETE FROM t_decimal_capability
				WHERE id_cap_instance IN (
				SELECT id_cap_instance FROM t_capability_instance ci
				WHERE ci.id_policy IN (
				SELECT id_policy FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_decimal_capability table'
					GOTO SetError
				END

				-- t_capability_instance
				PRINT '-- Deleting from t_capability_instance --'
				DELETE FROM t_capability_instance
				WHERE id_policy IN (
				SELECT id_policy FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_capability_instance table'
					GOTO SetError
				END

				-- t_policy_role
				PRINT '-- Deleting from t_policy_role --'
				DELETE FROM t_policy_role
				WHERE id_policy IN (
				SELECT id_policy FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_policy_role table'
					GOTO SetError
				END

				-- t_principal_policy
				PRINT '-- Deleting from t_principal_policy --'
				DELETE FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_principal_policy table'
					GOTO SetError
				END

				-- t_impersonate
				PRINT '-- Deleting from t_impersonate --'
				DELETE FROM t_impersonate
				WHERE (id_acc in (SELECT ID FROM #AccountIDsTable)
				or id_owner in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_impersonate table'
					GOTO SetError
				END

				-- t_account_mapper
				PRINT '-- Deleting from t_account_mapper --'
				DELETE FROM t_account_mapper
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_account_mapper table'
					GOTO SetError
				END

				DECLARE @hierarchyrule nvarchar(10)
				SELECT @hierarchyrule = value
				FROM t_db_values
				WHERE parameter = 'Hierarchy_RestrictedOperations'
				IF (@hierarchyrule = 'True')
				BEGIN
				  DELETE FROM t_group_sub
					WHERE id_corporate_account IN (SELECT ID FROM #AccountIDsTable)
					IF (@@Error <> 0)
					BEGIN
					  PRINT 'Cannot delete from t_group_sub table'
						GOTO SetError
					END
				END

				-- t_account_ancestor
				PRINT '-- Deleting from t_account_ancestor --'
				DELETE FROM t_account_ancestor
				WHERE id_descendent in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_account_ancestor table'
					GOTO SetError
				END

				UPDATE
					t_account_ancestor
				SET
					b_Children = 'N'
				FROM
					t_account_ancestor aa1
				WHERE
					id_descendent IN (SELECT ID FROM #AccountIDsTable) and
					NOT EXISTS (SELECT 1 FROM t_account_ancestor aa2
											WHERE aa2.id_ancestor = aa1.id_descendent
											AND num_generations <> 0)

				-- t_account
				PRINT '-- Deleting from t_account --'
				DELETE FROM t_account
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_account table'
					GOTO SetError
				END

				PRINT '-- Deleting from t_dm_account_ancestor --'
				DELETE FROM t_dm_account_ancestor
				WHERE id_dm_descendent in
				(
				select id_dm_acc from t_dm_account where id_acc in
				(SELECT ID FROM #AccountIDsTable)
				)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_dm_account_ancestor table'
					GOTO SetError
				END

				PRINT '-- Deleting from t_dm_account --'
				DELETE FROM t_dm_account
				WHERE id_acc in
				(SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_dm_account table'
					GOTO SetError
				END

				-- IF (@linked_server_name <> NULL)
				-- BEGIN
				  -- Do payment server stuff here
				-- END

				-- If we are here, then all accounts should have been deleted

				if (@linked_server_name is not NULL and @payment_server_dbname is not null)
				begin
					select @sql = 'delete from ' + @linked_server_name + '.' + @payment_server_dbname + '.dbo.t_ps_creditcard WHERE id_acc in
							(SELECT ID FROM #AccountIDsTable)'
					print (@sql)
					execute (@sql)
					IF (@@Error <> 0)
					BEGIN
						PRINT 'Cannot delete from t_ps_creditcard table'
						GOTO SetError
					end
					select @sql = 'delete from ' + @linked_server_name + '.' + @payment_server_dbname + '.dbo.t_ps_ach WHERE id_acc in
							(SELECT ID FROM #AccountIDsTable)'
					execute (@sql)
					IF (@@Error <> 0)
					BEGIN
						PRINT 'Cannot delete from t_ps_ach table'
						GOTO SetError
					END
				end
				if (@linked_server_name is NULL and @payment_server_dbname is not null)
				begin
					select @sql = 'delete from ' + @payment_server_dbname + '.dbo.t_ps_creditcard WHERE id_acc in
							(SELECT ID FROM #AccountIDsTable)'
					execute (@sql)
					IF (@@Error <> 0)
					BEGIN
						PRINT 'Cannot delete from t_ps_creditcard table'
						GOTO SetError
					end
					select @sql = 'delete from ' + @payment_server_dbname + '.dbo.t_ps_ach WHERE id_acc in
							(SELECT ID FROM #AccountIDsTable)'
					execute (@sql)
					IF (@@Error <> 0)
					BEGIN
						PRINT 'Cannot delete from t_ps_ach table'
						GOTO SetError
					END
				end

				if (@linked_server_name is not NULL and @payment_server_dbname is null)
					BEGIN
						PRINT 'Please specify the database name of payment server'
						GOTO SetError
					END

				UPDATE
				  #AccountIDsTable
				SET
				  message = 'This account no longer exists!'

				SELECT
					*
				FROM
					#AccountIDsTable
				--WHERE
				--	status <> 0

				COMMIT TRANSACTION
				RETURN 0

				SetError:
					ROLLBACK TRANSACTION
					RETURN -1
GO
PRINT N'Rebuilding [dbo].[t_updatestatsinfo]'
GO
CREATE TABLE [dbo].[tmp_rg_xx_t_updatestatsinfo]
(
[tab_type] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tab_name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[total_rows] [bigint] NULL,
[default_sampled_rows] [bigint] NULL,
[sampled_rows] [bigint] NULL,
[num_of_stats] [int] NULL,
[execution_time_sec] [int] NULL
)
GO
INSERT INTO [dbo].[tmp_rg_xx_t_updatestatsinfo]([num_of_stats]) SELECT [Duration] FROM [dbo].[t_updatestatsinfo]
GO
DROP TABLE [dbo].[t_updatestatsinfo]
GO
EXEC sp_rename N'[dbo].[tmp_rg_xx_t_updatestatsinfo]', N't_updatestatsinfo'
GO
PRINT N'Creating primary key [pk_t_updatestatsinfo] on [dbo].[t_updatestatsinfo]'
GO
ALTER TABLE [dbo].[t_updatestatsinfo] ADD CONSTRAINT [pk_t_updatestatsinfo] PRIMARY KEY CLUSTERED  ([tab_type], [tab_name])
GO
PRINT N'Creating [dbo].[MT_sys_analyze_single_table]'
GO
CREATE PROCEDURE [dbo].[MT_sys_analyze_single_table](
    @table_type                    NVARCHAR(1),
    @table_name                    NVARCHAR(200),
    @float_sample_rate             FLOAT = NULL,
    @only_indexes                  NVARCHAR(10) = 'ALL'
)
AS
	SET NOCOUNT ON
	
	DECLARE @SampleArgumentString           VARCHAR(255),
	        @num_of_stats                   INT,
	        @num_of_rows                    BIGINT,
	        @default_sampled_rows			BIGINT,
	        @sampled_rows                   BIGINT,
	        @execution_time_sec             INT,
	        @starttime                      DATETIME,
	        @stat_name                      NVARCHAR(200),
	        @is_using_default_sample_rates  BIT,
	        @sql                            NVARCHAR(MAX)
	
	SET @starttime = GETDATE()
	
	IF @table_type NOT IN ( 'U', 'N', 'V')
		RAISERROR('@table_type argument may take only 3 values - ''U'', ''N'' or ''V''',16,1)
	
	IF @float_sample_rate IS NULL
	    SET @is_using_default_sample_rates = 1
	ELSE
	    SET @is_using_default_sample_rates = 0
	
	/* Inset table name on first execution of update stats */
	IF NOT EXISTS ( SELECT * FROM t_updatestatsinfo WHERE tab_type = @table_type AND tab_name = @table_name )
	    INSERT INTO t_updatestatsinfo ( tab_name, tab_type )
	    VALUES ( @table_name, @table_type )
	
	SET @sql = 'select @num_of_stats = count(*) from sys.stats s where s.object_id = object_id(''' + @table_name + ''')'
	EXECUTE sp_executesql @sql, N'@num_of_stats int output', @num_of_stats = @num_of_stats OUT
	
	SELECT @default_sampled_rows = default_sampled_rows
	FROM   t_updatestatsinfo
	WHERE  tab_type = @table_type AND tab_name = @table_name
	
	IF @is_using_default_sample_rates = 1
	    SET @SampleArgumentString = ' WITH ' + @only_indexes
	ELSE
	BEGIN
	    SELECT @num_of_rows = SUM(st.row_count)
	    FROM   sys.dm_db_partition_stats st
	    WHERE  st.object_id = OBJECT_ID(@table_name)
	           AND (index_id < 2)
	    
	    SET @sampled_rows = (@num_of_rows * @float_sample_rate) / 100
	    
	    SET @SampleArgumentString = ' WITH SAMPLE ' + CAST(@sampled_rows AS VARCHAR(200))
	        + ' ROWS, ' + @only_indexes
	END
	
	SET @sql = 'UPDATE STATISTICS [' + @table_name + ']' + @SampleArgumentString
	PRINT @sql + ':START-' + CONVERT(CHAR(25), CURRENT_TIMESTAMP, 131)
	EXECUTE (@sql)
	PRINT 'END-' + CONVERT(CHAR(25), CURRENT_TIMESTAMP, 131)
		
	TRUNCATE TABLE #StatisticsHeader
	
	SET @stat_name = 'pk_' + @table_name
	IF NOT EXISTS (
	       SELECT *
	       FROM   sys.stats s
	       WHERE  s.name = @stat_name
	   )
	    SELECT TOP 1 @stat_name = NAME
	    FROM   sys.stats s
	    WHERE  s.[object_id] = OBJECT_ID(@table_name)
	
	INSERT #StatisticsHeader
	EXEC ( 'DBCC SHOW_STATISTICS(''' + @table_name + ''', ''' + @stat_name + ''') WITH STAT_HEADER')
	
	SELECT @num_of_rows = ISNULL([Rows], 0),
	       @sampled_rows = ISNULL(RowsSampled,0)
	FROM   #StatisticsHeader
	
	IF @is_using_default_sample_rates = 1
	    SET @default_sampled_rows = @sampled_rows
	
	SET @execution_time_sec = DATEDIFF(s, @starttime, GETDATE())
	
	UPDATE t_updatestatsinfo
	SET    total_rows            = @num_of_rows,
	       default_sampled_rows  = @default_sampled_rows,
	       sampled_rows          = @sampled_rows,
	       num_of_stats          = @num_of_stats,
	       execution_time_sec    = @execution_time_sec
	WHERE  tab_type              = @table_type
	       AND tab_name          = @table_name
GO
PRINT N'Altering [dbo].[agg_usage_audit_trail]'
GO
ALTER TABLE [dbo].[agg_usage_audit_trail] ADD
[pushed_priority] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Creating [dbo].[T_VW_GET_ACCOUNTS_BY_TMPL_ID]'
GO
IF object_id('T_VW_GET_ACCOUNTS_BY_TMPL_ID') IS NOT NULL
	DROP VIEW T_VW_GET_ACCOUNTS_BY_TMPL_ID
GO
CREATE VIEW [dbo].[T_VW_GET_ACCOUNTS_BY_TMPL_ID]
AS
WITH rec (id_template, id_descendent, vt_start, vt_end, id_acc_type, id_type, l) as
(
    SELECT at.id_acc_template id_template, aa.id_descendent, aa.vt_start, aa.vt_end, at.id_acc_type, a.id_type id_type, 1 l
      FROM t_account_ancestor aa
           join t_acc_template at on aa.id_descendent = at.id_folder
           join t_account a on a.id_acc = at.id_folder
     WHERE aa.num_generations = 0
    union all
    SELECT rec.id_template, aa.id_descendent, aa.vt_start, aa.vt_end, rec.id_acc_type, a.id_type, rec.l + 1
      FROM t_account_ancestor aa
           join rec on aa.id_ancestor = rec.id_descendent and aa.num_generations = 1
           join t_account a on a.id_acc = aa.id_descendent
     WHERE not exists (SELECT 1 FROM t_acc_template at WHERE aa.id_descendent = at.id_folder and at.id_acc_type = rec.id_acc_type)
)

SELECT id_template, id_descendent, vt_start, vt_end FROM rec, t_acc_tmpl_types tatt
WHERE tatt.all_types <> 0 OR rec.id_type = rec.id_acc_type
GO
PRINT N'Creating [dbo].[UpdateUsageCycleFromTemplate]'
GO
CREATE PROCEDURE  [dbo].[UpdateUsageCycleFromTemplate] (
	@IdAcc INTEGER
	,@UsageCycleId INTEGER
	,@OldUsageCycle INTEGER
	,@systemDate DATETIME
	,@errorStr NVARCHAR(4000) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @p_status INTEGER
		DECLARE @intervalenddate DATETIME
		DECLARE @intervalID int
		DECLARE @pc_start datetime
		DECLARE @pc_end datetime

		IF @errorStr IS NULL BEGIN
			SET @errorStr = ''
		END

	IF @OldUsageCycle <> @UsageCycleId AND @UsageCycleId <> -1
	BEGIN
		SET @p_status = dbo.IsBillingCycleUpdateProhibitedByGroupEBCR(@systemDate, @IdAcc)
		IF @p_status = 1
		BEGIN
			SET @p_status = 0
			UPDATE t_acc_usage_cycle SET id_usage_cycle = @UsageCycleId
				WHERE id_acc = @IdAcc

				-- post-operation business rule check (relies on rollback of work done up until this point)
				-- CR9906: checks to make sure the account's new billing cycle matches all of it's and/or payee's 
				-- group subscription BCR constraints
			SELECT @p_status = ISNULL(MIN(dbo.CheckGroupMembershipCycleConstraint(@systemDate, groups.id_group)), 1)
				FROM (
					-- gets all of the payer's payee's and/or the payee's group subscriptions
					SELECT DISTINCT gsm.id_group id_group
						FROM t_gsubmember gsm
						INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc
						WHERE pay.id_payer = @IdAcc OR pay.id_payee = @IdAcc
					) groups

			IF @p_status = 1
			BEGIN
				SET @p_status = 0
				-- deletes any mappings to intervals in the future from the old cycle
				DELETE FROM t_acc_usage_interval
					WHERE t_acc_usage_interval.id_acc = @IdAcc
					AND	id_usage_interval IN (
						SELECT id_interval
							FROM t_usage_interval ui
							INNER JOIN t_acc_usage_interval aui ON t_acc_usage_interval.id_acc = @IdAcc AND	aui.id_usage_interval = ui.id_interval
							WHERE dt_start > @systemDate
					)

				-- only one pending update is allowed at a time
				-- deletes any previous update mappings which have not yet
				-- transitioned (dt_effective is still in the future)
				DELETE FROM t_acc_usage_interval
					WHERE dt_effective IS NOT NULL
						AND	id_acc = @IdAcc
						AND	dt_effective >= @systemDate

				-- gets the current interval's end date
				SELECT @intervalenddate = ui.dt_end
					FROM t_acc_usage_interval aui
					INNER JOIN t_usage_interval ui ON ui.id_interval = aui.id_usage_interval AND @systemDate BETWEEN ui.dt_start AND ui.dt_end
					WHERE aui.id_acc = @IdAcc

				-- future dated accounts may not yet be associated with an interval (CR11047)
				IF @intervalenddate IS NOT NULL
				BEGIN
					-- figures out the new interval ID based on the end date of the current interval  
					SELECT @intervalID = id_interval
							,@pc_start = dt_start
							,@pc_end = dt_end
						FROM t_pc_interval
						WHERE id_cycle = @usagecycleID
							AND	dbo.addsecond(@intervalenddate) BETWEEN dt_start AND dt_end

					-- inserts the new usage interval if it doesn't already exist
					-- (needed for foreign key relationship in t_acc_usage_interval)
					INSERT INTO t_usage_interval
						SELECT @intervalID
								,@UsageCycleId
								,@pc_start
								,@pc_end
								,'O'
							WHERE @intervalID NOT IN (SELECT id_interval FROM t_usage_interval)

					-- creates the special t_acc_usage_interval mapping to the interval of
					-- new cycle. dt_effective is set to the end of the old interval.
					INSERT INTO t_acc_usage_interval
						SELECT @IdAcc
								,@intervalID
								,ISNULL(tx_interval_status, 'O')
								,@intervalenddate
							FROM t_usage_interval
							WHERE id_interval = @intervalID
								AND tx_interval_status != 'B'
				END
			END
		END
		ELSE
		BEGIN
			SET @errorStr = 'Billing cycle is not updated for account ' + @IdAcc + '. Billing cycle update is prohibited by group EBCR.'
		END
	END
END
GO
PRINT N'Rebuilding [dbo].[t_account_type_view_map]'
/* Account Templates script (CR-55) */
IF NOT EXISTS (select 1 from t_acc_tmpl_types)
	INSERT INTO t_acc_tmpl_types (id, all_types) VALUES (1, 0)
ELSE
	UPDATE t_acc_tmpl_types SET all_types = 0
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns c join sys.objects o ON c.object_id = o.object_id
WHERE  o.name = 't_account_type_view_map' and c.name = 'account_view_name')
BEGIN
	ALTER TABLE t_account_type_view_map
	ADD account_view_name nvarchar(256)

	update m 
	  set account_view_name = CASE WHEN d.name = 'Contact' THEN 'LDAP' ELSE d.name END
	from   t_account_type_view_map m
		   join (
			   select SUBSTRING(nm_enum_data, LEN(nm_enum_data) - CHARINDEX('/', REVERSE(nm_enum_data)) + 2, LEN(nm_enum_data)) name, id_enum_data FROM t_enum_data
		   ) d on m.id_account_view = d.id_enum_data

	ALTER TABLE t_account_type_view_map
	ALTER COLUMN account_view_name nvarchar(256) NOT NULL
END
GO

PRINT N'Creating [dbo].[SplitStringByChar]'
GO
CREATE FUNCTION [dbo].[SplitStringByChar](@Str nvarchar(256), @Delimiter char(1))

RETURNS @Results TABLE (Items nvarchar(256))
AS BEGIN
	DECLARE @start int
	SET @start = 0
	DECLARE @end int
	SET @end = -1

	DECLARE @Slice nvarchar(256)
	WHILE @end <> len(@Str) + 1
		BEGIN
			IF(@end < 0)
			begin
				SET @end = @start
			end
			
			SET @start = @end + 1
			
			SET @end = charindex(@Delimiter, @Str, @start)
			IF(@end = 0)
				SET @end = len(@Str) + 1
			
			SET @Slice = substring(@Str, @start, @end - @start)
			INSERT INTO @Results(Items) VALUES(@Slice)
		END
	RETURN
END
GO
PRINT N'Creating [dbo].[UpdateAccPropsFromTemplate]'
GO
CREATE  PROCEDURE
[dbo].[UpdateAccPropsFromTemplate] (
	@idAccountTemplate INTEGER
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
		SET @condition = @condition + 'id_acc in (SELECT id_descendent FROM t_vw_get_accounts_by_tmpl_id WHERE id_template = ' + convert(nvarchar, @idAccountTemplate) + ')'
		SET @dSql = 'UPDATE ' + @tableName + ' SET ' + @values + ' WHERE ' + @condition
		execute(@dSql)
		fetch next FROM db_cursor into @viewName, @tableName, @additionalOptionString
	END

	close db_cursor
	deallocate db_cursor
END
GO
PRINT N'Creating [dbo].[t_months]'
GO
CREATE TABLE [dbo].[t_months]
(
[num] [int] NOT NULL,
[name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
GO
PRINT N'Creating primary key [PK__t_months__DF908D6538131D28] on [dbo].[t_months]'
GO
ALTER TABLE [dbo].[t_months] ADD PRIMARY KEY CLUSTERED  ([num])
GO
PRINT N'Populating t_month table with data'
GO
INSERT INTO t_months(name,num) VALUES('January',1);
INSERT INTO t_months(name,num) VALUES('February',2);
INSERT INTO t_months(name,num) VALUES('March',3);
INSERT INTO t_months(name,num) VALUES('April',4);
INSERT INTO t_months(name,num) VALUES('May',5);
INSERT INTO t_months(name,num) VALUES('June',6);
INSERT INTO t_months(name,num) VALUES('July',7);
INSERT INTO t_months(name,num) VALUES('August',8);
INSERT INTO t_months(name,num) VALUES('September',9);
INSERT INTO t_months(name,num) VALUES('October',10);
INSERT INTO t_months(name,num) VALUES('November',11);
INSERT INTO t_months(name,num) VALUES('December',12);
GO

PRINT N'Creating [dbo].[ApplyTemplateToAccounts]'
GO
create proc [dbo].[ApplyTemplateToAccounts] @idAccountTemplate int, @sessionId int, @nRetryCount int, @systemDate datetime
as
	SET nocount on

	DECLARE @errTbl TABLE (
		dt_detail datetime NOT NULL,
		nm_text nvarchar(4000) NOT NULL
	)

	DELETE FROM @errTbl

	BEGIN TRANSACTION T1
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

		EXEC UpdateAccPropsFromTemplate @idAccountTemplate

		DECLARE @UsageCycleId INTEGER
		DECLARE @PayerId INTEGER

		SET @UsageCycleId = -1;

		SELECT @UsageCycleId = tuc.id_usage_cycle, @PayerId = tprop.PayerID
			FROM t_usage_cycle tuc
			JOIN (
				SELECT 	tp.DayOfMonth
						,tp.StartDay
						,ISNULL(m.num,-1) StartMonth
						,tuct.id_cycle_type
						,tp.DayOfWeek
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
					LEFT JOIN t_months m ON UPPER(m.name) = UPPER(SUBSTRING(tedm.nm_enum_data, LEN(tedm.nm_enum_data) - CHARINDEX('/',REVERSE(tedm.nm_enum_data))+2, CHARINDEX('/',REVERSE(tedm.nm_enum_data))))
					LEFT JOIN t_usage_cycle_type tuct ON UPPER(tuct.tx_desc) = UPPER(SUBSTRING(tedc.nm_enum_data, LEN(tedc.nm_enum_data) - CHARINDEX('/',REVERSE(tedc.nm_enum_data))+2, CHARINDEX('/',REVERSE(tedc.nm_enum_data))))
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
			EXEC dbo.UpdateUsageCycleFromTemplate @IdAcc, @UsageCycleId, @OldUsageCycle, @systemDate, @errorStr OUTPUT
			IF @errorStr <> '' BEGIN
				INSERT INTO @errTbl(dt_detail, nm_text) VALUES(GETDATE(), @errorStr)
			END
			SET @errorStr = ''
			FETCH NEXT FROM acc INTO @IdAcc, @OldUsageCycle, @PayeeId, @OldPayerId, @PaymentStart, @PaymentEnd, @p_account_currency
		END
		CLOSE acc
		DEALLOCATE acc
		COMMIT TRANSACTION T1
	END TRY
	BEGIN CATCH
		INSERT INTO @errTbl(dt_detail, nm_text) VALUES(GETDATE(), ERROR_MESSAGE())
		ROLLBACK TRANSACTION T1
	END CATCH
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
			@nRetryCount
		FROM @errTbl e
GO
PRINT N'Creating [dbo].[ApplyAccountTemplate]'
GO
create proc [dbo].[ApplyAccountTemplate] @accountTemplateId int, @sessionId int, @systemDate datetime
as
set nocount on


declare @nRetryCount int
set @nRetryCount = 0

declare @DetailTypeGeneral int
declare @DetailResultInformation int
declare @DetailTypeSubscription int
declare @id_acc_type int
declare @id_acc int

select @id_acc_type = id_acc_type, @id_acc = id_folder from t_acc_template where id_acc_template = @accountTemplateId


SELECT @DetailTypeGeneral = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Success'
SELECT @DetailResultInformation = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Information'
SELECT @DetailTypeSubscription = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription'
--!!!Starting application of template
insert into t_acc_template_session_detail
	(
		id_session,
		n_detail_type,
		n_result,
		dt_detail,
		nm_text,
		n_retry_count
	)
	values
	(
		@sessionId,
		@DetailTypeGeneral,
		@DetailResultInformation,
		getdate(),
		'Starting application of template',
		@nRetryCount
	)

declare @incIdTemplate int
--Select account hierarchy for current template and for each child template.
declare accTemplateCursor cursor for

select tat.id_acc_template

from t_account_ancestor taa
inner join t_acc_template tat on taa.id_descendent = tat.id_folder and tat.id_acc_type = @id_acc_type
where taa.id_ancestor = @id_acc

OPEN accTemplateCursor
fetch next from accTemplateCursor into @incIdTemplate

while @@FETCH_STATUS = 0
begin

	--Apply account template to appropriate account list.
	execute ApplyTemplateToAccounts @incIdTemplate, @sessionId, @nRetryCount, @systemDate
	fetch next from accTemplateCursor into @incIdTemplate
end

close accTemplateCursor
deallocate accTemplateCursor


insert into t_acc_template_session_detail
(
	id_session,
	n_detail_type,
	n_result,
	dt_detail,
	nm_text,
	n_retry_count
)
values
(
	@sessionId,
	@DetailTypeSubscription,
	@DetailResultInformation,
	getdate(),
	'There are no subscriptions to be applied',
	@nRetryCount
)

--!!!Template application complete
insert into t_acc_template_session_detail
(
	id_session,
	n_detail_type,
	n_result,
	dt_detail,
	nm_text,
	n_retry_count
)
values
(
	@sessionId,
	@DetailTypeGeneral,
	@DetailResultInformation,
	getdate(),
	'Template application complete',
	@nRetryCount
)
GO
PRINT N'Altering [dbo].[copytemplate]'
GO
ALTER procedure [dbo].[copytemplate](
					@id_folder int,
					@p_id_accounttype int,
					@id_parent int,
          @p_systemdate datetime,
          @p_enforce_same_corporation varchar,
					@status int output)
					as
				 	begin
					declare @parentID int
					declare @cdate datetime
					declare @nexttemplate int
					declare @parentTemplateID int
					 begin
						--only check same hierarchy for parent if corp business rule is
						--enforced.
						if (@p_enforce_same_corporation = '1' AND @id_parent is NULL)
						 begin
							select @parentID = id_ancestor
							from t_account_ancestor where id_descendent = @id_folder
							AND @p_systemdate between vt_start AND vt_end AND
							num_generations = 1
						  if (@parentID is null)
							 begin
						     select @status = -486604771 -- MT_PARENT_NOT_IN_HIERARCHY
							   return
							 end
						 end
						else
						 begin
							select @parentID = @id_parent
						 end
						end
						begin
							select @parentTemplateID = id_acc_template from t_acc_template
							where id_folder = @parentID and id_acc_type = @p_id_accounttype
							if (@parentTemplateID is null)
							 begin
								SELECT @status = -486604772
							  return
							 end
						end
							
							exec clonesecuritypolicy @id_parent,@id_folder,'D','D'

							insert into t_acc_template
							 (id_folder,dt_crt,tx_name,tx_desc,b_applydefaultpolicy, id_acc_type)
							 select @id_folder,@p_systemdate,
							 tx_name,tx_desc,b_applydefaultpolicy, id_acc_type
							 from t_acc_template where id_folder = @parentID
							 and id_acc_type = @p_id_accounttype
  					  select @nexttemplate =@@identity
         		  
							insert into t_acc_template_props (id_acc_template,nm_prop_class,
							nm_prop,nm_value)
							select @nexttemplate,existing.nm_prop_class,existing.nm_prop,
							existing.nm_value from
							t_acc_template_props existing where
							existing.id_acc_template = @parentTemplateID

							insert into t_acc_template_subs_pub (id_po, id_group, id_acc_template,
							vt_start,vt_end)
						  select existing.id_po, existing.id_group, @nexttemplate,
							existing.vt_start,existing.vt_end
							from t_acc_template_subs_pub existing
							where
							existing.id_acc_template = @parentTemplateID
							
							select @status = 1
					 end
GO
PRINT N'Altering [dbo].[RemoveGroupSubscription]'
GO
ALTER procedure [dbo].[RemoveGroupSubscription](
  @p_id_sub int,
  @p_systemdate datetime,
  @p_status int OUTPUT)

  as
  begin
    
    declare @groupID int
    declare @maxdate datetime
    declare @nmembers int
    declare @icbID int

    set @p_status = 0

    select @groupID = id_group,@maxdate = dbo.mtmaxdate()
    from t_sub where id_sub = @p_id_sub

    select distinct @icbID = id_pricelist from t_pl_map where id_sub=@p_id_sub

    select @nmembers = count(*) from t_gsubmember_historical where id_group = @groupID
    if @nmembers > 0
      begin
        -- We don't support deleting group subs if this group sub ever had a member
        select @p_status = 1
        return
      end
    
    delete from t_gsub_recur_map where id_group = @groupID
    delete from t_recur_value where id_sub = @p_id_sub

    -- In the t_acc_template_subs, either id_po or id_group have to be null.
    -- If a subscription is added to a template, then id_po points to the subscription
    -- If a group subscription is added to a template, then id_group points to the group subscription.
    delete from t_acc_template_subs where id_group = @groupID and id_po is null
    delete from t_acc_template_subs_pub where id_group = @groupID and id_po is null

    -- Eventually we would need to make sure that the rules for each icb rate schedule are removed from the proper parameter tables
    delete from t_pl_map where id_sub = @p_id_sub

    update t_recur_value set tt_end = @p_systemdate
      where id_sub = @p_id_sub and tt_end = @maxdate
    update t_sub_history set tt_end = @p_systemdate
      where tt_end = @maxdate and id_sub = @p_id_sub

    delete from t_sub where id_sub = @p_id_sub
    
    delete from t_char_values where id_entity = @p_id_sub
    
      if (@icbID is not NULL)
      begin
        exec sp_DeletePricelist @icbID, @p_status output
        if @p_status <> 0 return
      end
  
    update t_group_sub set tx_name = CAST('[DELETED ' + CAST(GetDate() as nvarchar) + ']' + tx_name as nvarchar(255)) where id_group = @groupID

  end
GO
PRINT N'Altering [dbo].[DeleteTemplate]'
GO
ALTER procedure [dbo].[DeleteTemplate](
				@p_id_template int,
				@p_status int output)
 			as
	 		begin
				select @p_status = 1 --success

				-- delete the subscriptions in this template
		 		delete from t_acc_template_subs
					where id_acc_template = @p_id_template
				-- delete the subscriptions in this template
		 		delete from t_acc_template_subs_pub
					where id_acc_template = @p_id_template
				-- delete public properties for this template
		 		delete from t_acc_template_props_pub
					where id_acc_template = @p_id_template
				-- delete private properties for this template
		 		delete from t_acc_template_props
					where id_acc_template = @p_id_template
				-- delete the template itself
		 		delete from t_acc_template
					where id_acc_template = @p_id_template
		 		if (@@rowcount <> 1)
		   		begin
					select @p_status = -486604725 -- create an error MT_NO_TEMPLATE_FOUND
		   		end
			 end
GO
PRINT N'Altering [dbo].[t_export_report_instance]'
GO
ALTER TABLE [dbo].[t_export_report_instance] DROP
COLUMN [c_xmlConfig_loc]
GO
PRINT N'Altering [dbo].[t_export_workqueue]'
GO
ALTER TABLE [dbo].[t_export_workqueue] DROP
COLUMN [c_rep_query_source],
COLUMN [c_xmlConfig_loc]
GO
PRINT N'Altering [dbo].[t_export_execute_audit]'
GO
ALTER TABLE [dbo].[t_export_execute_audit] DROP
COLUMN [c_rep_query_source],
COLUMN [c_xmlConfig_loc]
GO
PRINT N'Altering [dbo].[Export_AuditReportExecutResult]'
GO
ALTER PROCEDURE [dbo].[Export_AuditReportExecutResult]
      @WorkQId					CHAR(36),
      @ExecuteStatus				VARCHAR(10),
      @ExecuteStartDateTime		DATETIME,
      @ExecuteCompleteDateTime	DATETIME,
      @Descr						VARCHAR(500),
      @executionParamValues		VARCHAR(1000)
      AS
      BEGIN
	      SET NOCOUNT ON
	      INSERT INTO t_export_execute_audit ( id_work_queue, id_rep, id_rep_instance_id, id_schedule, c_sch_type, dt_queued,
			      dt_sched_run, c_use_database, c_rep_title, c_rep_type, c_rep_def_source,
			      c_rep_query_tag, c_rep_output_type,
			      c_rep_distrib_type, c_rep_destn, c_destn_access_user, c_use_quoted_identifiers,
			      c_generate_control_file, c_control_file_delivery_location, c_output_execute_params_info,
			      c_exec_type, c_compressreport, c_compressthreshold, c_ds_id, c_eop_step_instance_name,
			      c_processed_server, id_run, run_start_dt, run_end_dt,
			      c_run_result_status, c_run_result_descr, c_execute_paraminfo, c_queuerow_source, c_output_file_name)
	      SELECT  id_work_queue, id_rep, id_rep_instance_id, id_schedule, c_sch_type, dt_queued,
			      dt_sched_run, ISNULL(c_use_database, '(local)'), c_rep_title, c_rep_type, c_rep_def_source,
			      c_rep_query_tag, c_rep_output_type,
			      c_rep_distrib_type, c_rep_destn, c_destn_access_user, c_use_quoted_identifiers,
			      c_generate_control_file, c_control_file_delivery_location, c_output_execute_params_info,
			      c_exec_type, c_compressreport, c_compressthreshold, c_ds_id, c_eop_step_instance_name,
			      c_processing_server, id_run, @ExecuteStartDateTime, @ExecuteCompleteDateTime,
			      @ExecuteStatus, @Descr, CASE WHEN @executionParamValues = 'Bad Parms passed - see MTLOG: ' THEN @executionParamValues + ': ' + ISNULL(replace(c_param_name_values, '%', ''), 'N/A') ELSE @executionParamValues END,
			      c_queuerow_source, c_output_file_name
	      FROM	t_export_workqueue
	      WHERE	id_work_queue = @WorkQId
	
	      DELETE FROM t_export_workqueue WHERE id_work_queue = @WorkQId

      /*	IF @ExecuteStatus = 'SUCCESS'
	      BEGIN
		      DELETE FROM t_export_workqueue WHERE id_work_queue = @WorkQId
	      END
	      ELSE
	      BEGIN
		      UPDATE 	t_export_workqueue 
		      SET 	c_current_process_stage = 0,
		 	      c_processing_server = NULL
		      WHERE	id_work_queue = @WorkQId
	      END
	      RETURN
      */
      END
GO
PRINT N'Creating [dbo].[mtsp_generate_stateful_nrcs_for_quoting]'
GO
CREATE PROCEDURE [dbo].[mtsp_generate_stateful_nrcs_for_quoting]

@dt_start datetime,
@dt_end datetime,
@v_id_accounts VARCHAR(4000),
@v_id_interval int,
@v_id_batch varchar(256),
@v_n_batch_size int,
@v_run_date datetime,
@p_count int OUTPUT

AS BEGIN

DECLARE @id_nonrec int,
		@n_batches  int,
		@total_nrcs int,
		@id_message bigint,
		@id_ss int,
		@tx_batch binary(16);
		
IF OBJECT_ID('tempdb..#TMP_NRC_ACCOUNTS_FOR_RUN') IS NOT NULL
DROP TABLE #TMP_NRC_ACCOUNTS_FOR_RUN

SELECT * INTO #TMP_NRC_ACCOUNTS_FOR_RUN FROM(SELECT value as id_acc FROM CSVToInt(@v_id_accounts)) A;

SELECT @tx_batch = cast(N'' as xml).value('xs:base64Binary(sql:variable("@v_id_batch"))', 'binary(16)');

SELECT
*
INTO
#TMP_NRC
FROM(
SELECT
		newid() AS id_source_sess,
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
	from t_sub sub
		inner join #TMP_NRC_ACCOUNTS_FOR_RUN acc on acc.id_acc = sub.id_acc
		inner join t_po on sub.id_po = t_po.id_po
		inner join t_pl_map plm on sub.id_po = plm.id_po and plm.id_paramtable IS NULL
		inner join t_base_props bp on bp.id_prop = plm.id_pi_instance and bp.n_kind = 30
		inner join t_nonrecur nrc on nrc.id_prop = bp.id_prop and nrc.n_event_type = 1
		where sub.vt_start >= @dt_start and sub.vt_start < @dt_end
) A;

set @total_nrcs = (select count(*) from #tmp_nrc)

set @id_nonrec = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
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
SELECT id_message, id_ss, @id_nonrec, b_root, COUNT(1) as session_count
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

drop table #tmp_nrc
SET @p_count = @total_nrcs
END
GO
PRINT N'Altering [dbo].[t_export_reports]'
GO
ALTER TABLE [dbo].[t_export_reports] DROP
COLUMN [c_rep_query_source]
GO
PRINT N'Altering [dbo].[Export_CreateReportDefinition]'
GO
ALTER PROCEDURE [dbo].[Export_CreateReportDefinition]
      @c_report_title     VARCHAR(255),
      @c_rep_type         VARCHAR(10),
      @c_rep_def_source   VARCHAR(255)	= NULL,
      @c_rep_query_tag    VARCHAR(255)	= NULL,
      @ParameterNames     VARCHAR(5000)	= NULL,
      @id_rep             INT               OUTPUT

      AS
      BEGIN
	      SET NOCOUNT ON
	 
	      IF EXISTS (SELECT id_rep FROM t_export_reports WHERE c_report_title = @c_report_title)
	      BEGIN
		      SELECT @id_rep = id_rep FROM t_export_reports WHERE c_report_title = @c_report_title
		      RETURN
	      END
	
	      INSERT INTO t_export_reports (c_report_title, c_rep_type, c_rep_def_source, c_rep_query_tag)
	      VALUES		(@c_report_title, @c_rep_type, @c_rep_def_source, @c_rep_query_tag)

	      SELECT @id_rep = SCOPE_IDENTITY()
	
	      DECLARE @ipos INT, @inextpos INT, @paramname VARCHAR(100), @paramnameid INT
	      SELECT @ipos = 0, @inextpos = 0
	
	      IF LEN(ISNULL(@ParameterNames, '')) > 0
	      BEGIN
		      /* Create parameters for this report definition */
		      /* Parse the comma seperated string to get the information for this. */
		      /* fix the comma separated string if the last char is not a comma(",") */
		      SET @ParameterNames = LTRIM(@ParameterNames)
		      SET @ParameterNames = RTRIM(@ParameterNames)
		      IF SUBSTRING(@ParameterNames, LEN(@ParameterNames), 1) <> ','
			      SET @ParameterNames = @ParameterNames + ','

		      SELECT @inextpos = CHARINDEX(',', @ParameterNames, @ipos)
		      WHILE @inextpos > 0
		      BEGIN
			      SET @paramname = SUBSTRING(@ParameterNames, @ipos, @inextpos - @ipos)
			
			      IF EXISTS (SELECT * FROM t_export_param_names WHERE c_param_name = @paramname)
				      SELECT @paramnameid = id_param_name FROM t_export_param_names WHERE c_param_name = @paramname
			      ELSE
			      BEGIN
				      INSERT INTO t_export_param_names (	c_param_name)
				      VALUES					(		@paramname)
				      SELECT @paramnameid = SCOPE_IDENTITY()
			      END
			
			      INSERT INTO t_export_report_params (	id_param_name, id_rep)
			      VALUES				(				@paramnameid, @id_rep)
			
			      SET @ipos = @inextpos + 1
			      SELECT @inextpos = CHARINDEX(',', @ParameterNames, @ipos)
		      END
	      END
	
	      RETURN
      END
GO
PRINT N'Altering [dbo].[Export_CreateReportInstance]'
GO
ALTER PROCEDURE [dbo].[Export_CreateReportInstance]
      @id_rep					INT,
      @desc					VARCHAR(100),
      @outputType				VARCHAR(10),
      @distributionType		VARCHAR(50),
      @destination			VARCHAR(500),
      @ReportExecutionType	CHAR(10),
      @c_report_online		BIT				= NULL,
      @dtActivate				DATETIME		= NULL,
      @dtDeActivate			DATETIME		= NULL,
      @directMoveToDestn		BIT				= NULL,
      @destnAccessUser		VARCHAR(50)		= NULL,
      @destnAccessPwd			NVARCHAR(2048)		= NULL,
      @compressreport			BIT				= NULL,
      @compressthreshold		INT 			= NULL,
      @ds_id					INT				= NULL,
      @eopinstancename		NVARCHAR(510)	= NULL,
      @createcontrolfile		BIT				= NULL,
      @controlfiledelivery	VARCHAR(255)	= NULL,
      @outputExecuteParams	BIT				= NULL,
      @UseQuotedIdentifiers	BIT				= NULL,
      @dtLastRunDateTime		DATETIME		= NULL,
      @dtNextRunDateTime		DATETIME		= NULL,
      @paramDefaultNameValues	VARCHAR(500)	= NULL,
      @outputFileName			VARCHAR(50)		= NULL,
      @system_datetime			DATETIME,
      @ReportInstanceId		INT				OUTPUT
      AS
      BEGIN
	      SET NOCOUNT ON
	      BEGIN TRAN
	      DECLARE @ErrorMessage VARCHAR(100)
	      
	      INSERT INTO t_export_report_instance (
				      c_rep_instance_desc, id_rep, c_report_online, dt_activate,
				      dt_deactivate, c_rep_output_type, c_rep_distrib_type,
				      c_report_destn, c_destn_direct, c_access_user, c_access_pwd,
				      c_generate_control_file, c_control_file_delivery_location, c_output_execute_params_info,
				      c_use_quoted_identifiers, c_exec_type, c_compressreport, c_compressthreshold,
				      c_ds_id, c_eop_step_instance_name, dt_last_run, dt_next_run, c_output_file_name)
	      VALUES	(	@desc, @id_rep, ISNULL(@c_report_online, 0), ISNULL(@dtActivate, @system_datetime),
				      @dtDeActivate, @outputType, @distributionType,
				      @destination, ISNULL(@directMoveToDestn, 1), @destnAccessUser, @destnAccessPwd,
				      @createcontrolfile, @controlfiledelivery, ISNULL(@outputExecuteParams, 0),
				      @UseQuotedIdentifiers, @ReportExecutionType, ISNULL(@compressreport, 0), ISNULL(@compressthreshold, -1),
				      @ds_id, @eopinstancename, @dtLastRunDateTime, @dtNextRunDateTime, @outputFileName)

	      SELECT @ReportInstanceId	= SCOPE_IDENTITY()
         /* Insert Blank Values for all Parameters associated with the report */
         
	  INSERT INTO t_export_default_param_values
          SELECT @ReportInstanceId id_rep_instance_id, erp.id_param_name id_param_name, 'UNDEFINED' c_param_value
          FROM t_export_report_params erp
          where erp.id_rep = @id_rep
          and NOT EXISTS (select id_param_name from t_export_default_param_values where id_rep_instance_id = @ReportInstanceId)

	 
      GOTO EXIT_SUCCESS_
      
      ERROR_:
	      ROLLBACK
	      RAISERROR (@ErrorMessage, 16, 1)
	      RETURN
      EXIT_SUCCESS_:
	      COMMIT TRAN
	      RETURN 0
      END
GO
PRINT N'Altering [dbo].[UpdatePrivateTempates]'
GO
ALTER PROCEDURE [dbo].[UpdatePrivateTempates]
(
	@id_template INT
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
	          SELECT a1.id_acc_template AS id_parent_acc_template, a2.id_acc_template AS current_id
                FROM t_account_ancestor aa
                     JOIN t_acc_template a1 on aa.id_ancestor = a1.id_folder AND a1.id_acc_type = @id_acc_type
                     JOIN t_acc_template a2 on aa.id_descendent = a2.id_folder AND a2.id_acc_type = @id_acc_type
               WHERE aa.id_ancestor = @id_account
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
PRINT N'Creating [dbo].[mtsp_generate_stateful_rcs_for_quoting]'
GO
CREATE PROCEDURE [dbo].[mtsp_generate_stateful_rcs_for_quoting]
                                            @v_id_interval  int
                                           ,@v_id_billgroup int
                                           ,@v_id_run       int
										   ,@v_id_accounts VARCHAR(4000)
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
--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Retrieving RC candidates');

/* Create the list of accounts to generate for */
IF OBJECT_ID('tempdb..#TMP_RC_ACCOUNTS_FOR_RUN') IS NOT NULL
DROP TABLE #TMP_RC_ACCOUNTS_FOR_RUN

SELECT * INTO #TMP_RC_ACCOUNTS_FOR_RUN FROM(SELECT value as id_acc FROM CSVToInt(@v_id_accounts)) A;



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
,rw.c_payerstart,rw.c_payerend,case when rw.c_unitvaluestart < '1970-01-01 00:00:00' THEN '1970-01-01 00:00:00' ELSE rw.c_unitvaluestart END AS c_unitvaluestart ,rw.c_unitvalueend
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
      where 1=1
      and ui.id_interval = @v_id_interval
      /*and bg.id_billgroup = @v_id_billgroup*/
      and rcr.b_advance <> 'Y'
UNION ALL
SELECT
newid() AS idSourceSess,
      'Advance' AS c_RCActionType
      ,pci.dt_start      AS c_RCIntervalStart
      ,pci.dt_end      AS c_RCIntervalEnd
      ,ui.dt_start      AS c_BillingIntervalStart
      ,ui.dt_end          AS c_BillingIntervalEnd
      ,CASE WHEN rcr.tx_cycle_mode <> 'Fixed' AND nui.dt_start <> c_cycleEffectiveDate
       THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(c_cycleEffectiveDate), pci.dt_start)
       ELSE pci.dt_start END as c_RCIntervalSubscriptionStart
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
,rw.c_payerstart,rw.c_payerend,case when rw.c_unitvaluestart < '1970-01-01 00:00:00' THEN '1970-01-01 00:00:00' ELSE rw.c_unitvaluestart END AS c_unitvaluestart,rw.c_unitvalueend
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
      where 1=1
      and ui.id_interval = @v_id_interval
      /*and bg.id_billgroup = @v_id_billgroup*/
      and rcr.b_advance = 'Y'
)A      ;

SELECT @total_rcs  = COUNT(1) FROM #tmp_rc;

--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'RC Candidate Count: ' + CAST(@total_rcs AS VARCHAR));

if @total_rcs > 0
BEGIN

SELECT @total_flat = COUNT(1) FROM #tmp_rc where c_unitvalue is null;
SELECT @total_udrc = COUNT(1) FROM #tmp_rc where c_unitvalue is not null;

--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Flat RC Candidate Count: ' + CAST(@total_flat AS VARCHAR));
--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'UDRC RC Candidate Count: ' + CAST(@total_udrc AS VARCHAR));

--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Session Set Count: ' + CAST(@v_n_batch_size AS VARCHAR));
--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch: ' + @v_id_batch);

SELECT @tx_batch = cast(N'' as xml).value('xs:base64Binary(sql:variable("@v_id_batch"))', 'binary(16)');
--INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch ID: ' + CAST(@tx_batch AS varchar));

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

/*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting Flat RCs');*/

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

			/*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting UDRC RCs');*/

END;
 
 END;
 
 SET @p_count = @total_rcs;

/*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Info', 'Finished submitting RCs, count: ' + CAST(@total_rcs AS VARCHAR));*/

END;
GO
PRINT N'Creating [dbo].[UpdatePayerFromTemplate]'
GO
CREATE PROCEDURE [dbo].[UpdatePayerFromTemplate] (
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
					SET @errorStr = 'No payment record changed for account ' + @IdAcc + '. Return code is ' + CAST(@p_status AS NVARCHAR(255))
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
					SET @errorStr = 'No payment record created for account ' + @IdAcc + '. Return code is ' + CAST(@p_status AS NVARCHAR(255))
					SET @p_status = 0
				end
			end
		END
	END
END
GO
PRINT N'Altering [dbo].[Export_GetQueuedReportInfo]'
GO
ALTER PROCEDURE [dbo].[Export_GetQueuedReportInfo]
      @id_work_queue	CHAR(36),
      @system_datetime DATETIME
      AS
      BEGIN
	      SET NOCOUNT ON

	      SELECT	c_rep_title, c_rep_type, c_rep_def_source, c_rep_query_tag,
			      lower(c_rep_output_type) AS 'c_rep_output_type', c_rep_distrib_type, c_rep_destn,
			      ISNULL(c_destn_direct, 0) AS 'c_destn_direct', c_destn_access_user, c_destn_access_pwd,
			      c_generate_control_file, c_control_file_delivery_location AS 'c_control_file_delivery_locati', c_exec_type, c_compressreport,
			      ISNULL(c_compressthreshold, -1) as [c_compressthreshold], ISNULL(c_ds_id, 0) as 'c_ds_id', c_eop_step_instance_name,
			      dt_last_run, dt_next_run, c_output_execute_params_info, c_use_quoted_identifiers,
			      id_rep_instance_id, id_schedule, c_sch_type, dt_sched_run, replace(c_param_name_values,'%','^') as 'c_param_name_values',
			      c_output_file_name, id_work_queue, dt_queued,
			      CONVERT(VARCHAR(10), DATEADD(DAY, -1, ISNULL(dt_next_run, @system_datetime)), 101) as control_file_data_date
	      INTO #QueuedReportInfo
	      FROM t_export_workqueue A with (nolock)
	      WHERE id_work_queue = @id_work_queue

	      /* Update the EOP rows to set the proper control_file_data_date */
	      UPDATE #QueuedReportInfo
		      SET control_file_data_date = CONVERT(VARCHAR(10), DATEADD(DAY, 1, ISNULL(dt_end, @system_datetime)), 101)
	      FROM #QueuedReportInfo QRI
	      LEFT OUTER JOIN t_usage_interval UI on convert(int, substring(QRI.c_param_name_values, charindex('^^ID_INTERVAL^^', QRI.c_param_name_values, 1) + 16, 5)) = UI.id_interval
	      WHERE id_work_queue IN (SELECT id_work_queue
				      FROM #QueuedReportInfo
				      WHERE c_exec_type = 'eop'
				      AND c_param_name_values LIKE '%ID_INTERVAL%')

        	UPDATE #QueuedReportInfo
        	SET c_param_name_values = replace(c_param_name_values,'^','%')
        	FROM #QueuedReportInfo

	      /* Now return the data to Export */
	      SELECT *
	      FROM #QueuedReportInfo
	      ORDER BY dt_queued
      END
GO
PRINT N'Altering [dbo].[Export_InsertReportDefinition]'
GO
ALTER PROCEDURE [dbo].[Export_InsertReportDefinition]
      @c_report_title     		VARCHAR(50),
      @c_report_desc			VARCHAR(255)	= NULL,
      @c_rep_type         		VARCHAR(50),
      @c_rep_def_source   		VARCHAR(100)	= NULL,
      @c_rep_query_tag    		VARCHAR(100)	= NULL,
      @c_prevent_adhoc_execution	INT			= NULL
      AS
      BEGIN
	      SET NOCOUNT ON
         
          DECLARE @id_rep INT

	      INSERT INTO t_export_reports (	c_report_title, c_report_desc, c_rep_type, c_rep_def_source,
								      c_rep_query_tag, c_prevent_adhoc_execution)
	      VALUES		(			@c_report_title, ISNULL(@c_report_desc, @c_report_title), @c_rep_type, @c_rep_def_source,
								      @c_rep_query_tag, @c_prevent_adhoc_execution)

	      SELECT @id_rep = SCOPE_IDENTITY()

	      SELECT @id_rep AS 'saveStatus', 'Success' AS 'StatusMessage'
      END
GO
PRINT N'Altering [dbo].[Export_Queue_AdHocReport]'
GO
ALTER PROCEDURE [dbo].[Export_Queue_AdHocReport]
      @id_rep					INT,
      @outputType				VARCHAR(5),
      @deliveryType			VARCHAR(10),
      @destn					VARCHAR(500),
      @compressReport			BIT,
      @compressThreshold		INT,
      @identifier				VARCHAR(100) = NULL,
      @paramNameValues		VARCHAR(1000) = NULL,
      @ftpUser				VARCHAR(50) = NULL,
      @ftpPassword			NVARCHAR(2048) = NULL,
      @createControlFile		BIT,
      @controlFileDestn		VARCHAR(500),
      @outputExecParamsInfo	BIT,
      @dsid					VARCHAR(10),
      @outputFileName			VARCHAR(50),
      @usequotedidentifiers	BIT = NULL,
      @system_datetime DATETIME
      AS
      BEGIN
      SET NOCOUNT ON
	
	      DECLARE	@reptitle VARCHAR(255), @repType VARCHAR(10),
			      @repQueryTag VARCHAR(100), @saveStatus  INT,
			      @msg VARCHAR(255), @cRepDefSource VARCHAR(500)
			
	      SELECT  @reptitle = c_report_title,
				  @repType = c_rep_type,
			      @repQueryTag = c_rep_query_tag,
			      @cRepDefSource = c_rep_def_source
	      FROM	t_export_reports
	      WHERE	id_rep = @id_rep

	      INSERT INTO t_export_workqueue (  id_rep, dt_queued, dt_sched_run, c_use_database,
				      c_rep_title, c_rep_type, c_rep_def_source, dt_last_run, dt_next_run,
				      c_use_quoted_identifiers, c_rep_query_tag, c_rep_output_type,
				      c_rep_distrib_type, c_rep_destn, c_destn_direct, c_destn_access_user, c_destn_access_pwd,
				      c_exec_type, c_generate_control_file, c_control_file_delivery_location,
		                      c_compressreport, c_compressthreshold, c_output_execute_params_info, c_ds_id, c_queuerow_source,
                		      c_param_name_values, c_output_file_name)
	
	      VALUES			(@id_rep, @system_datetime, @system_datetime, '(local)',
				      @reptitle, @repType, @cRepDefSource, @system_datetime -1, @system_datetime,
				      ISNULL(@usequotedidentifiers, 0), @repQueryTag, @outputType,
				      @deliveryType, @destn, 0, @ftpuser, @ftpPassword,
				      'ad-hoc', @createControlFile, @controlFileDestn,
				      @compressReport, @compressThreshold, @outputExecParamsInfo, @dsid, @identifier,
				      REPLACE(@paramNameValues, '^', '%'), @outputFileName)
	
	      IF @@ERROR <> 0
		      GOTO ERR_

		      SELECT	@saveStatus = 1,
				      @msg = 'Success'
		      GOTO EXIT_SP_
		
		      RETURN

      ERR_:
		      SELECT	@saveStatus = -1,
				      @msg = 'Queue Ad-hoc report failed'

      EXIT_SP_:
      SET NOCOUNT OFF
	      SELECT @saveStatus as 'SaveStatus', @msg as 'Message'
	      RETURN
      END
GO
PRINT N'Altering [dbo].[Export_QueueEOPReports]'
GO
ALTER PROCEDURE [dbo].[Export_QueueEOPReports]
      @eopInstanceName	NVARCHAR(510),
      @intervalId			INT,
      @id_billgroup		INT,  /* Added the billgroup, but we have to agree on how this will be used..... */
      @runId				INT,
	  @system_datetime DATETIME
      AS
      BEGIN
      SET NOCOUNT ON
	      DECLARE @param_name_values VARCHAR(1000), @wkId UNIQUEIDENTIFIER,
			      @prmval VARCHAR(500), @id_rep INT, @id_rep_inst INT, @old_id_rep INT,
			      @old_id_rep_inst INT, @prm_stor varchar(1000)
	
	      DECLARE @idQs TABLE (idq UNIQUEIDENTIFIER)

	      DECLARE @tprmVals TABLE (id_rep INT, id_report_instance_id INT, c_param_name_values VARCHAR(1000))
	      INSERT INTO @tprmVals
		  SELECT   trp.id_rep, trpi.id_rep_instance_id, tpn.c_param_name+'='+
				      ISNULL(CASE replace(tpn.c_param_name,'%','')
					      WHEN 'ID_INTERVAL' THEN +ISNULL(CAST(@intervalId AS VARCHAR), '')
					      WHEN 'ID_BILLGROUP' THEN +ISNULL(CAST(@id_billgroup AS VARCHAR), '')
					      ELSE tdfp.c_param_value
				      END, '')
	      FROM	t_export_reports trp
	      LEFT  JOIN t_export_report_instance trpi ON trp.id_rep = trpi.id_rep
	      LEFT JOIN t_export_default_param_values tdfp
	      INNER JOIN t_export_param_names tpn ON tdfp.id_param_name = tpn.id_param_name
	      INNER JOIN t_export_report_params trpm ON tpn.id_param_name = trpm.id_param_name ON  trpi.id_rep_instance_id = tdfp.id_rep_instance_id
	      WHERE trpi.c_eop_step_instance_name = @eopInstanceName

	      SET @prm_stor = ''
	
	      DECLARE cr_prms CURSOR FOR
	      SELECT	c_param_name_values, id_rep, id_report_instance_id
	      FROM	@tprmVals
	      GROUP BY id_rep, id_report_instance_id, c_param_name_values
	      ORDER BY id_report_instance_id
	      /* The GROUP BY and ORDER BY above are important - thats how we can get the parameter list in the correct
	      order and this create the parameter name-value list when this gets dropped on the queue */

	      OPEN cr_prms
	      FETCH NEXT FROM cr_prms INTO @prmval, @id_rep, @id_rep_inst
	      SELECT	@old_id_rep			= @id_rep,
			      @old_id_rep_inst	= @id_rep_inst,
			      @prm_stor			= ''
	      WHILE @@fetch_status = 0
	      BEGIN
		      IF @old_id_rep <> @id_rep OR @old_id_rep_inst <> @id_rep_inst
		      BEGIN
			      /* do an insert into the queue here - one set of param-name values has been generated for this
			      reportid/reportinstanceid combination
			      Remove the last "," from the value of @prm_stor */
			      SET @wkid = NEWID()
			      INSERT INTO t_export_workqueue(id_work_queue, id_rep, id_rep_instance_id, id_schedule, c_sch_type, dt_queued, dt_sched_run,
					      c_rep_title, c_rep_type, c_rep_def_source,
					      c_rep_query_tag, c_rep_output_type, c_rep_distrib_type, c_rep_destn,
					      c_destn_direct, c_destn_access_user, c_destn_access_pwd, c_ds_id, c_eop_step_instance_name,
					      c_generate_control_file, c_control_file_delivery_location, c_output_execute_params_info,
					      c_compressreport, c_compressthreshold, c_exec_type, c_use_quoted_identifiers,
					      dt_last_run, dt_next_run, c_current_process_stage, c_param_name_values, id_run, c_queuerow_source, c_output_file_name)
			      SELECT	@wkid, trpi.id_rep, trpi.id_rep_instance_id, NULL as 'id_schedule', NULL as 'c_sch_type', @system_datetime AS dt_Queued, @system_datetime AS dt_sched_run,
					      trp.c_report_title, trp.c_rep_type,trp.c_rep_def_source,
					      trp.c_rep_query_tag, trpi.c_rep_output_type, trpi.c_rep_distrib_type, trpi.c_report_destn,
					      trpi.c_destn_direct, trpi.c_access_user, trpi.c_access_pwd, trpi.c_ds_id, trpi.c_eop_step_instance_name,
					      trpi.c_generate_control_file, trpi.c_control_file_delivery_location, trpi.c_output_execute_params_info,
					      trpi.c_compressreport, trpi.c_compressthreshold, 'eop', trpi.c_use_quoted_identifiers,
					      trpi.dt_last_run, @system_datetime, 0, SUBSTRING(@prm_stor, 1, LEN(@prm_stor) - 1), @runid, 'EOP ADAPTER', trpi.c_output_file_name
			      FROM		t_export_report_instance trpi
			      INNER JOIN	t_export_reports trp ON trpi.id_rep = trp.id_rep
			      WHERE		trpi.c_exec_type = 'eop'
			      AND			trpi.id_rep_instance_id = @old_id_rep_inst
			      AND			trp.id_rep = @old_id_rep
			      AND			trpi.dt_activate <= @system_datetime
			      AND			(trpi.dt_deactivate is null or trpi.dt_deactivate > @system_datetime)

			      INSERT INTO @idQs (idq) VALUES (@wkId)

			      SELECT @old_id_rep = @id_rep, @old_id_rep_inst = @id_rep_inst, @prm_stor = ''
			      SELECT	@prm_stor = @prm_stor + @prmval+ ','
		      END
		      ELSE
		      BEGIN
			      SELECT	@prm_stor = @prm_stor + @prmval+ ','
		      END
		      FETCH NEXT FROM cr_prms INTO @prmval, @id_rep, @id_rep_inst
	      END

	      SET @wkid = NEWID()
	      INSERT INTO t_export_workqueue(id_work_queue, id_rep, id_rep_instance_id, id_schedule, c_sch_type, dt_queued, dt_sched_run,
			      c_rep_title, c_rep_type, c_rep_def_source,
			      c_rep_query_tag, c_rep_output_type, c_rep_distrib_type, c_rep_destn,
			      c_destn_direct, c_destn_access_user, c_destn_access_pwd, c_ds_id, c_eop_step_instance_name,
			      c_generate_control_file, c_control_file_delivery_location, c_output_execute_params_info,
			      c_compressreport, c_compressthreshold, c_exec_type, c_use_quoted_identifiers,
			      dt_last_run, dt_next_run, c_current_process_stage, c_param_name_values, id_run, c_queuerow_source, c_output_file_name)
	      SELECT	@wkid, trpi.id_rep, trpi.id_rep_instance_id, NULL as 'id_schedule', NULL as 'c_sch_type', @system_datetime AS dt_Queued, @system_datetime AS dt_sched_run,
			      trp.c_report_title, trp.c_rep_type,trp.c_rep_def_source,
			      trp.c_rep_query_tag, trpi.c_rep_output_type, trpi.c_rep_distrib_type, trpi.c_report_destn,
			      trpi.c_destn_direct, trpi.c_access_user, trpi.c_access_pwd, trpi.c_ds_id, trpi.c_eop_step_instance_name,
			      trpi.c_generate_control_file, trpi.c_control_file_delivery_location, trpi.c_output_execute_params_info,
			      trpi.c_compressreport, trpi.c_compressthreshold, 'eop', trpi.c_use_quoted_identifiers,
			      trpi.dt_last_run, @system_datetime, 0, SUBSTRING(@prm_stor, 1, LEN(@prm_stor) - 1), @runid, 'EOP ADAPTER', trpi.c_output_file_name
	      FROM		t_export_report_instance trpi
	      INNER JOIN	t_export_reports trp ON trpi.id_rep = trp.id_rep
	      WHERE		trpi.c_exec_type = 'eop'
	      AND			trpi.id_rep_instance_id = @old_id_rep_inst
	      AND			trp.id_rep = @old_id_rep
	      AND			trpi.dt_activate <= @system_datetime
	      AND			(trpi.dt_deactivate is null or trpi.dt_deactivate > @system_datetime)
	
	      INSERT INTO @idQs (idq) VALUES (@wkId)

	      close cr_prms
	      deallocate cr_prms

	      SELECT	*
	      FROM	t_export_workqueue
	      WHERE	id_work_queue IN (SELECT idq FROM @idQs)
	

      RETURN
      END
GO
PRINT N'Altering [dbo].[Export_QueueScheduledReports]'
GO
ALTER   PROCEDURE [dbo].[Export_QueueScheduledReports]
@RunId 	INT,
@system_datetime DATETIME
AS

	DECLARE @Warning_Results int

	SET NOCOUNT ON
	
	DECLARE @id_rep INT, @id_rep_instance_id INT, @id_schedule INT, @c_sch_type VARCHAR(10), @dt_queued DATETIME, @dt_next_run DATETIME,
			@c_current_process_stage INT, @c_processing_server VARCHAR(50), @dt_last_run DATETIME,
			@c_report_title VARCHAR(50), @c_rep_type VARCHAR(10), @c_rep_def_source VARCHAR(100),
			@c_rep_query_tag VARCHAR(50), @c_rep_output_type VARCHAR(10),
			@c_rep_distrib_type VARCHAR(10), @c_report_destn VARCHAR(255),
			@c_destn_direct BIT, @c_access_user VARCHAR(50), @c_access_pwd VARCHAR(2048),
			@ds_id INT, @eopinstancename NVARCHAR(510), @outputExecuteParamInfo BIT, @outputFileName varchar(50),
			@generatecontrolfile BIT, @controlfiledeliverylocation VARCHAR(255), @compressreport BIT,
			@compressthreshold INT, @param_name_values VARCHAR(1000), @UseQuotedIdentifiers BIT,
			@IntervalId INT

	/* Get the interval id using the report's current start date. */
	
	CREATE TABLE #tparamInfo (id_rep INT, id_rep_instance_id INT, c_param_name_value VARCHAR(500))
	INSERT INTO #tparamInfo
	SELECT		distinct trpi.id_rep, trpi.id_rep_instance_id, tpn.c_param_name+'='+
				ISNULL(CASE replace(tpn.c_param_name,'%','')
					WHEN 'START_DATE' THEN ISNULL(convert(VARCHAR(19), trpi.dt_last_run, 121), tdfp.c_param_value)
					WHEN 'START_DT' THEN ISNULL(convert(VARCHAR(19), trpi.dt_last_run, 121), tdfp.c_param_value)
					WHEN 'END_DATE' THEN ISNULL(convert(VARCHAR(19), trpi.dt_next_run, 121), tdfp.c_param_value)
					WHEN 'END_DT' THEN ISNULL(convert(VARCHAR(19), trpi.dt_next_run, 121), tdfp.c_param_value)
					/* 
					WHEN 'ID_INTERVAL' THEN 
							(SELECT CAST(id_interval as varchar) from t_usage_interval 
								where MONTH(dt_start) = MONTH(ISNULL(trpi.dt_last_run, tdfp.c_param_value))
								and YEAR(dt_start) = YEAR(ISNULL(trpi.dt_last_run, tdfp.c_param_value))
								and DAY(dt_start) = 1)
					*/
					ELSE tdfp.c_param_value
				END, 'NULL') as 'c_param_value'
	FROM			t_export_param_names tpn
	INNER JOIN		t_export_report_params trpm ON tpn.id_param_name = trpm.id_param_name
	INNER JOIN		t_export_report_instance trpi ON trpm.id_rep = trpi.id_rep
	LEFT OUTER JOIN	t_export_default_param_values tdfp ON trpi.id_rep_instance_id = tdfp.id_rep_instance_id
				AND trpm.id_param_name = tdfp.id_param_name
	/* SELECT * FROM #tparamInfo */

	SET NOCOUNT OFF
	DECLARE c_reports CURSOR FOR
	SELECT	trpi.id_rep, trps.id_rep_instance_id, trps.id_schedule, trps.c_sch_type, @system_datetime AS dt_Queued, trpi.dt_next_run,
			trp.c_report_title, trp.c_rep_type, trp.c_rep_def_source,
			trp.c_rep_query_tag, trpi.c_rep_output_type, trpi.c_rep_distrib_type, trpi.c_report_destn,
			trpi.c_destn_direct, trpi.c_access_user, trpi.c_access_pwd, trpi.c_ds_id, trpi.c_eop_step_instance_name,
			trpi.c_generate_control_file, trpi.c_control_file_delivery_location, trpi.c_output_execute_params_info,
			trpi.c_use_quoted_identifiers, trpi.c_compressreport, trpi.c_compressthreshold, trpi.dt_last_run, trpi.c_output_file_name
	FROM	t_export_schedule trps
	INNER JOIN	t_export_report_instance trpi ON trps.id_rep_instance_id = trpi.id_rep_instance_id
	INNER JOIN	t_export_reports trp ON trpi.id_rep = trp.id_rep
	WHERE		trpi.c_exec_type = 'Scheduled'
	AND		(trpi.dt_next_run <= @system_datetime OR trpi.dt_next_run IS NULL)
	AND		trpi.dt_activate <= @system_datetime
	AND   (trpi.dt_deactivate >= @system_datetime OR trpi.dt_deactivate IS NULL)
	
	OPEN c_reports
	FETCH NEXT FROM c_reports INTO
	@id_rep, @id_rep_instance_id, @id_schedule, @c_sch_type, @dt_queued, @dt_next_run,
	@c_report_title, @c_rep_type, @c_rep_def_source,
	@c_rep_query_tag, @c_rep_output_type, @c_rep_distrib_type, @c_report_destn,
	@c_destn_direct, @c_access_user, @c_access_pwd, @ds_id, @eopinstancename,
	@generatecontrolfile, @controlfiledeliverylocation, @outputExecuteParamInfo,
	@UseQuotedIdentifiers, @compressreport, @compressthreshold, @dt_last_run, @outputFileName
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @param_name_values = COALESCE(@param_name_values + ',', '') + c_param_name_value
		FROM #tparamInfo
		WHERE id_rep = @id_rep and id_rep_instance_id = @id_rep_instance_id
		
		IF NOT EXISTS (SELECT * FROM t_export_workqueue
			WHERE	id_rep_instance_id	= @id_rep_instance_id
			AND		id_rep					= @id_rep
			AND		c_sch_type			= @c_sch_type
			AND		c_exec_type			= 'sch'
			AND		dt_next_run			= @dt_next_run
			AND		dt_last_run			= @dt_last_run
			AND		ISNULL(c_ds_id, '')	= ISNULL(@ds_id, '')
			AND		dt_sched_run		= @dt_next_run)
		BEGIN

			/*  check if scheduled jobs can run for the next run date specified
			IF EXISTS (select * from netmeter_custom..t_process_control_detail 
									where id_control = 3 and id_control_date >= CONVERT(VARCHAR, @dt_next_run, 101))
				BEGIN				
					This checks for any extra conditions that must be met before a given scheduled report can run. */

					EXEC @Warning_Results = export_QueueReportChecks 'Scheduled', @id_rep, @id_rep_instance_id, @system_datetime
					PRINT 'WARNINGS - ' + convert(varchar, @id_rep_instance_id) + ' ' + convert(varchar, @Warning_Results)
					IF @Warning_Results = 0
						INSERT INTO t_export_workqueue(id_rep_instance_id, id_rep, id_schedule, c_sch_type, dt_queued, dt_sched_run,
								c_rep_title, c_rep_type, c_rep_def_source,
								c_rep_query_tag, c_rep_output_type, c_rep_distrib_type, c_rep_destn,
								c_destn_direct, c_destn_access_user, c_destn_access_pwd, c_ds_id, c_eop_step_instance_name,
								c_generate_control_file, c_control_file_delivery_location, c_output_execute_params_info,
								c_use_quoted_identifiers, c_compressreport, c_compressthreshold, c_exec_type,
								dt_last_run, dt_next_run, c_current_process_stage, c_param_name_values, id_run, c_queuerow_source, c_output_file_name)
						VALUES (@id_rep_instance_id, @id_rep, @id_schedule, @c_sch_type, @dt_queued, @dt_next_run,
								@c_report_title, @c_rep_type, @c_rep_def_source,
								@c_rep_query_tag, @c_rep_output_type, @c_rep_distrib_type, @c_report_destn,
								@c_destn_direct, @c_access_user, @c_access_pwd, @ds_id, @eopinstancename,
								@generatecontrolfile, @controlfiledeliverylocation, @outputExecuteParamInfo,
								@UseQuotedIdentifiers, @compressreport, @compressthreshold, 'sch',
								@dt_last_run, @dt_next_run, 0, @param_name_values, @RunId, CAST(@RunID AS VARCHAR), @outputFileName)
			/* END */
		END
		SET @param_name_values = NULL
		FETCH NEXT FROM c_reports INTO
		@id_rep, @id_rep_instance_id, @id_schedule, @c_sch_type, @dt_queued, @dt_next_run,
		@c_report_title, @c_rep_type, @c_rep_def_source,
		@c_rep_query_tag, @c_rep_output_type, @c_rep_distrib_type, @c_report_destn,
		@c_destn_direct, @c_access_user, @c_access_pwd, @ds_id, @eopinstancename,
		@generatecontrolfile, @controlfiledeliverylocation, @outputExecuteParamInfo,
		@UseQuotedIdentifiers, @compressreport, @compressthreshold, @dt_last_run, @outputFileName
	END

CLOSE c_reports
DEALLOCATE c_reports

DROP TABLE #tparamInfo
GO
PRINT N'Altering [dbo].[Export_UpdateReportDefinition]'
GO
ALTER PROCEDURE [dbo].[Export_UpdateReportDefinition]
      @id_rep 						INT,
      @c_rep_type         			VARCHAR(50),
      @c_report_desc				VARCHAR(255)	= NULL,
      @c_rep_def_source   			VARCHAR(100)	= NULL,
      @c_rep_query_tag    			VARCHAR(100)	= NULL,
      @c_prevent_adhoc_execution	INT				= NULL
      AS
      BEGIN
	      SET NOCOUNT ON

	      declare @c_report_title VARCHAR(255)
	
	      SELECT @c_report_title = c_report_title
	      FROM t_export_reports WHERE id_rep = @id_rep
	
	      UPDATE 	t_export_reports SET
		      c_rep_type					= @c_rep_type,
		      c_report_desc				= ISNULL(@c_report_desc, @c_report_title),
		      c_rep_def_source			= @c_rep_def_source,
		      c_rep_query_tag				= @c_rep_query_tag,
		      c_prevent_adhoc_execution	= @c_prevent_adhoc_execution
	      WHERE 	id_rep = @id_rep

	      SELECT @id_rep AS 'saveStatus', 'Success' as 'StatusMessage'
      END
GO
PRINT N'Altering [dbo].[Export_UpdateReportInstance]'
GO
ALTER PROCEDURE [dbo].[Export_UpdateReportInstance]
      @id_rep					INT,
      @ReportInstanceId		INT,
      @desc					VARCHAR(100),
      @outputType				VARCHAR(10),
      @distributionType		VARCHAR(50),
      @destination			VARCHAR(500),
      @ReportExecutionType	CHAR(10),
      @dtActivate				DATETIME		= NULL,
      @dtDeActivate			DATETIME		= NULL,
      @destnAccessUser		VARCHAR(50)		= NULL,
      @destnAccessPwd			NVARCHAR(2048)		= NULL,
      @compressreport			BIT				= NULL,
      @compressthreshold		INT 			= NULL,
      @ds_id					INT				= NULL,
      @eopinstancename		NVARCHAR(510)	= NULL,
      @createcontrolfile		BIT				= NULL,
      @controlfiledelivery	VARCHAR(255)	= NULL,
      @outputExecuteParams	BIT				= NULL,
      @UseQuotedIdentifiers	BIT				= NULL,
      @dtLastRunDateTime		DATETIME		= NULL,
      @dtNextRunDateTime		DATETIME		= NULL,
      @outputFileName			VARCHAR(50)		= NULL,
      @paramDefaultNameValues	VARCHAR(500)	= NULL
      AS
      BEGIN
	      SET NOCOUNT ON
	      BEGIN TRAN
	      DECLARE @ErrorMessage VARCHAR(100)
	    

	      UPDATE	t_export_report_instance SET
			      c_rep_instance_desc					= @desc,
			      dt_activate							= @dtActivate,
			      dt_deactivate						= @dtDeactivate,
			      c_rep_output_type					= @outputType,
			      c_rep_distrib_type					= @distributionType,
			      c_report_destn						= @destination,
			      c_access_user						= @destnAccessUser,
			      c_access_pwd						= @destnAccessPwd,
			      c_generate_control_file				= @createcontrolfile,
			      c_control_file_delivery_location	= @controlfiledelivery,
			      c_output_execute_params_info		= @outputExecuteParams,
			      c_use_quoted_identifiers			= @UseQuotedIdentifiers,
			      c_exec_type							= @ReportExecutionType,
			      c_compressreport					= @compressreport,
			      c_compressthreshold					= @compressthreshold,
			      c_ds_id								= @ds_id,
			      c_eop_step_instance_name			= @eopinstancename,
			      /* dt_last_run							= @dtLastRunDateTime, */
			      dt_next_run							= @dtNextRunDateTime,
			      c_output_file_name					= @outputFileName
	      WHERE	id_rep_instance_id = @ReportInstanceId
	

		/* Insert parameter default values if there is not one already... */
		
		/* DONT know why we have tio update the assigned parameters?
		* INSERT INTO t_export_default_param_values       
          	SELECT @ReportInstanceId id_rep_instance_id, erp.id_param_name id_param_name, 'UNDEFINED' c_param_value
          	FROM t_export_report_params erp 
          	where erp.id_rep = @id_rep
            and erp.id_param_name not in 
            (select id_param_name from t_export_default_param_values where id_rep_instance_id = @ReportInstanceId)*/
          
     
     GOTO EXIT_SUCCESS_

      ERROR_:
	      ROLLBACK
	      RAISERROR (@ErrorMessage, 16, 1)
	      RETURN
      EXIT_SUCCESS_:
	      COMMIT TRAN
	      RETURN 0
      END
GO
PRINT N'Altering [dbo].[mvm_scheduled_tasks]'
GO
ALTER TABLE [dbo].[mvm_scheduled_tasks] ADD
[id_acc] [int] NULL
GO
PRINT N'Altering [dbo].[agg_decision_audit_trail]'
GO
ALTER TABLE [dbo].[agg_decision_audit_trail] ALTER COLUMN [id_usage_interval] [int] NOT NULL
GO
PRINT N'Creating primary key [agg_dec_audit_trail_pk] on [dbo].[agg_decision_audit_trail]'
GO
ALTER TABLE [dbo].[agg_decision_audit_trail] ADD CONSTRAINT [agg_dec_audit_trail_pk] PRIMARY KEY CLUSTERED  ([decision_unique_id], [id_usage_interval], [end_date])
GO
PRINT N'Creating index [agg_dec_audit_ndx] on [dbo].[agg_decision_audit_trail]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [agg_dec_audit_ndx] ON [dbo].[agg_decision_audit_trail] ([id_acc], [id_usage_interval], [decision_unique_id], [end_date])
GO
PRINT N'Altering [dbo].[mvm_counters]'
GO
ALTER TABLE [dbo].[mvm_counters] ADD
[counter_date] [datetime] NULL
GO
PRINT N'Altering [dbo].[t_export_workqueue_temp]'
GO
ALTER TABLE [dbo].[t_export_workqueue_temp] DROP
COLUMN [c_rep_query_source],
COLUMN [c_xmlConfig_loc]
GO
PRINT N'Creating [dbo].[t_mt_sys_analyze_all_tables]'
GO
CREATE TABLE [dbo].[t_mt_sys_analyze_all_tables]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[execution_date] [datetime] NULL,
[stats_updated] [int] NULL,
[execution_time] [time] NULL,
[U_total_rows] [bigint] NULL,
[NU_total_rows] [bigint] NULL,
[U_sampled_rows] [bigint] NULL,
[NU_sampled_rows] [bigint] NULL,
[U_sampled_percent] [float] NULL,
[NU_sampled_percent] [float] NULL,
[execution_time_sec] [int] NULL
)
GO
PRINT N'Creating primary key [pk_t_mt_sys_analyze_all_tables] on [dbo].[t_mt_sys_analyze_all_tables]'
GO
ALTER TABLE [dbo].[t_mt_sys_analyze_all_tables] ADD CONSTRAINT [pk_t_mt_sys_analyze_all_tables] PRIMARY KEY CLUSTERED  ([id])
GO
PRINT N'Creating primary key [mvm_resource_nodes_pk] on [dbo].[mvm_resource_nodes]'
GO
ALTER TABLE [dbo].[mvm_resource_nodes] ADD CONSTRAINT [mvm_resource_nodes_pk] PRIMARY KEY CLUSTERED  ([resource_type], [logical_cluster])
GO
PRINT N'Adding constraints to [dbo].[t_acc_template_subs_pub]'
GO
ALTER TABLE [dbo].[t_acc_template_subs_pub] ADD CONSTRAINT [date_acc_template_pub_1] CHECK (([vt_start]<=[vt_end]))
GO
ALTER TABLE [dbo].[t_acc_template_subs_pub] ADD CONSTRAINT [t_acc_template_subs_pub_1] CHECK (([id_po] IS NULL AND [id_group] IS NOT NULL OR [id_po] IS NOT NULL AND [id_group] IS NULL))
GO
PRINT N'Adding foreign keys to [dbo].[t_acc_template_subs_pub]'
GO
ALTER TABLE [dbo].[t_acc_template_subs_pub] ADD CONSTRAINT [FK2_T_ACC_TEMPLATE_SUBS_PUB] FOREIGN KEY ([id_acc_template]) REFERENCES [dbo].[t_acc_template] ([id_acc_template])
GO
PRINT N'Altering trigger [dbo].[trig_update_recur_window_on_t_sub] on [dbo].[t_sub]'
GO
ALTER trigger [dbo].[trig_update_recur_window_on_t_sub]
ON [dbo].[t_sub]
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
            AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
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
PRINT N'Creating extended properties'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This is a mapping table that indicates the account views associated with an account type.  An account view is a collection of msixdef properties.  Each account type can have 0 or more account views and each account view is associated with 1 or more account type.  When an account view is associated with an account type, an account of that type can have valid values for the properties contained in the account view. (Package: Account Type)', 'SCHEMA', N'dbo', 'TABLE', N't_account_type_view_map', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Associated account view identifier', 'SCHEMA', N'dbo', 'TABLE', N't_account_type_view_map', 'COLUMN', N'id_account_view'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Account type identifier. This is foreign key to t_account_type table', 'SCHEMA', N'dbo', 'TABLE', N't_account_type_view_map', 'COLUMN', N'id_type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This is internal table and used to audit the performance of update statistics on each object. (Package:Misc. Feature)', 'SCHEMA', N'dbo', 'TABLE', N't_updatestatsinfo', NULL, NULL
GO


UPDATE t_sys_upgrade
SET db_upgrade_status = 'C',
dt_end_db_upgrade = getdate()
WHERE upgrade_id = (SELECT MAX(upgrade_id) FROM t_sys_upgrade)	
go
