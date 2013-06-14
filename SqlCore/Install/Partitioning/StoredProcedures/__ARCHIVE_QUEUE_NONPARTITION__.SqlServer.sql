
create  procedure archive_queue_nonpartition
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
    