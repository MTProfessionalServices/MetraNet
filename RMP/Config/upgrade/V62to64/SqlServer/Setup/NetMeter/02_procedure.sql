use %%NETMETER%%

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**************************************************************/
/*  RMP\Config\DBINstall\Queries.xml                          */
/**************************************************************/

/* 	InsertAcctUsageWithUID obsolete since 5.0 release */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertAcctUsageWithUID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[InsertAcctUsageWithUID]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[archive_export]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[archive_export]
GO

/****** Object:  StoredProcedure [dbo].[archive_export]    Script Date: 08/11/2010 13:40:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  procedure [dbo].[archive_export]
			(
			@partition nvarchar(4000)=null,
			@intervalId int=null,
			@path nvarchar(1000),
			@avoid_rerun char(1)  = 'N',
			@result nvarchar(4000) output
			)
		as
/*
		How to run this stored procedure
		declare @result nvarchar(2000)
		exec archive_export @partition='N_20040701_20040731',@path='c:\backup\archive',@avoid_rerun = 'N',@result=@result output
		print @result
		or
		declare @result nvarchar(2000)
		exec archive_export @intervalid=827719717,@path='c:\backup\archive',@avoid_rerun = 'N',@result=@result output
		print @result
*/
		set nocount on
		declare @sql1 nvarchar(4000)
		declare @tab1 nvarchar(1000)
		declare @var1 nvarchar(1000)
		declare @vartime datetime
		declare @maxtime datetime
		declare @acc int
		declare	@servername nvarchar(100)
		declare	@dbname nvarchar(100)
		declare @interval int
		declare @partition1 nvarchar(4000), @minid int, @maxid int
                
--Get the servername and database name from the current connection	
		select @servername = @@servername
		select @dbname = db_name()
		select @vartime = getdate()
		select @maxtime = dbo.mtmaxdate()

		--Checking the Business rules
		--Either Partition or Interval should be specified
		if ((@partition is not null and @intervalId is not null) or (@partition is null and @intervalId is null))
		begin
			set @result = '1000001-archive_export operation failed-->Either Partition or Interval should be specified'
			return
		END
--Get the list of Intervals that need to be archived
		if (@partition is not null)
		begin
			declare  interval_id cursor fast_forward for 
			select id_interval from t_partition_interval_map map where id_partition 
			= (select id_partition  from t_partition where partition_name = @partition)
		end
		else
		begin
			declare  interval_id cursor fast_forward for select @intervalId
			select @partition1 = partition_name from t_partition part inner join
			t_partition_interval_map map on part.id_partition = map.id_partition
			and map.id_interval = @intervalid
		end
		open interval_id
		fetch next from interval_id into @interval
		while (@@fetch_status = 0)
		begin
			--interal should exists
			if not exists (select 1 from t_usage_interval where id_interval=@interval)
			BEGIN
				set @result = '1000002-archive operation failed-->Interval does not exist'
				close interval_id
				deallocate interval_id
				return
			END
			--Interval should be hard-closed
			if exists (select 1 from t_usage_interval where id_interval=@interval and tx_interval_status in ('O','B'))
			BEGIN
				set @result = '1000003-archive operation failed-->Interval is not Hard Closed'
				close interval_id
				deallocate interval_id
				return
			END
			--Interval should not be already archived
			if  exists (select 1 from t_archive where id_interval=@interval and status ='A' and tt_end = @maxtime)
			begin
				set @result = '1000004-archive operation failed-->Interval is already archived-Deleted'
				close interval_id
				deallocate interval_id
				return
			end
			--Interval should have bucket mapping
			if not exists (select 1 from t_acc_bucket_map where id_usage_interval=@interval)
			BEGIN
				set @result = '1000005-archive operation failed-->Interval does not have bucket mappings'
				close interval_id
				deallocate interval_id
				return
			END
			--Interval should be Dearchived
			if  exists (select 1 from t_archive where id_interval=@interval and status ='D' and tt_end = @maxtime)
			begin
				set @result = '1000006-archive operation failed-->Interval is Dearchived and not be exported..run trash/delete procedure'
				close interval_id
				deallocate interval_id
				return
			end

if object_id('tempdb..tmp_t_acc_usage') is not null
drop table tempdb..tmp_t_acc_usage
select act.bucket, au.id_sess into tempdb..tmp_t_acc_usage  from t_acc_usage au with (nolock) inner join t_acc_bucket_map act on au.id_usage_interval = act.id_usage_interval
   and au.id_acc = act.id_acc where au.id_usage_interval = @interval and act.status = 'U'
alter table tempdb..tmp_t_acc_usage add constraint PK_tmp_t_acc_usage primary key clustered (bucket, id_sess)
select distinct id_view into #PV from t_acc_usage with (nolock) where 
				id_usage_interval = @interval and id_acc in (select id_acc from t_acc_usage  with (nolock) where id_usage_interval = @interval)
--Create the temp table that will store the output of the bcp operation
			if object_id('tempdb..#bcpoutput') is not null
			drop table #bcpoutput
			create table #bcpoutput(OutputLine nvarchar(4000))
--Get the number of buckets for the interval..we need to have seperate bcp file for each table for each bucket
			declare  c2 cursor fast_forward for select distinct bucket from tempdb..tmp_t_acc_usage with (nolock)
			open c2
			fetch next from c2 into @acc
			while (@@fetch_status = 0)
			begin		
				--We are creating view to avoid queryout parameter bug
				--(http://support.microsoft.com/default.aspx?scid=kb;en-us;Q309555)
select @minid = min(id_sess), @maxid = max(id_sess) from tempdb..tmp_t_acc_usage with (nolock) where bucket = @acc
				SET @sql1 = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(''bcpview''))
				 DROP view bcpview'
				EXEC (@sql1)
			--bcp out the t_acc_usage table
				select @sql1 = N'create view bcpview as SELECT au.* FROM t_acc_usage au  with (nolock) inner join tempdb..tmp_t_acc_usage act  with (nolock) on au.id_sess = act.id_sess where bucket = ' + cast(@acc as varchar(10)) 
                                          + ' and au.id_sess between ' + cast(@minid as varchar(10)) + ' and '  + cast(@maxid as varchar(10)) 
				exec (@sql1)
				--BCP out the data from t_acc_usage
				select @sql1 = 'bcp "' + @dbname + '..bcpview" out "' +  @path + '\t_acc_usage_' + cast (@interval as varchar (10)) + '_' + cast (@acc as varchar (10)) + '.txt" -n -S' + @servername
				insert into #bcpoutput exec master.dbo.xp_cmdshell @sql1
				--If bcp output file is empty..retrun with the error code
				IF (SELECT count(*) FROM #bcpoutput) = 0 
				BEGIN
					set @result = '1000007-archive operation failed-->Error in bcp out usage table, check the user permissions'
					close c2
					deallocate c2
					deallocate c1
					close interval_id
					deallocate interval_id
					return
				END
				--If there is any error in bcp operation..retrun with the error code
				IF EXISTS(SELECT NULL FROM #bcpoutput 
					WHERE OutputLine like '%Error%' 
						OR OutputLine like '%ODBC SQL Server Driver%')
				BEGIN
					set @result = '1000008-archive operation failed-->Error in bcp out usage table, check the archive directory or hard disk space or database name or servername'
					select * from #bcpoutput
					close c2
					deallocate c2
					deallocate c1
					close interval_id
					deallocate interval_id
					return
				END
				--Truncate the temp table after every bcp operation
				truncate table #bcpoutput

				/*Create a temp table to get the list of id_sess that need go in a particular file
				based on account bucket mapping..we are doing this step to avoid to go to the t_acc_usage
				for each product view 

				select @sql1 = 'SELECT au.id_sess,au.id_usage_interval,au.id_acc into tempdb..tmp_t_acc_usage FROM ' + @dbname + 
						'..t_acc_usage au inner join t_acc_bucket_map act on au.id_usage_interval = act.id_usage_interval
						 and au.id_acc = act.id_acc where au.id_usage_interval=' + cast (@interval as varchar(10)) 
						+ ' and act.status = ''U'' and act.bucket = ' + cast(@acc as varchar(10)) + ' and act.id_usage_interval =' + cast (@interval as varchar(10))
				exec (@sql1)
				create unique clustered index idx_tmp_t_acc_usage on tempdb..tmp_t_acc_usage(id_sess,id_usage_interval)
				create index idx1_tmp_t_acc_usage on tempdb..tmp_t_acc_usage(id_acc)
*/
				if (select b_partitioning_enabled from t_usage_server) = 'Y'
				begin
					declare  c3 cursor fast_forward for select nm_table_name from t_unique_cons
					open c3
					fetch next from c3 into @tab1
					while (@@fetch_status = 0)
					begin
						SET @sql1 = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(''bcpview'')) DROP view bcpview'
							EXEC sp_executesql @sql1
						select @sql1 = N'create view bcpview as SELECT top 100 percent uq.* FROM ' + 
								@dbname + '..' + @tab1 + ' uq 
								inner join tempdb..tmp_t_acc_usage au on 
								uq.id_sess = au.id_sess and uq.id_usage_interval = au.id_usage_interval
								inner join t_acc_bucket_map act on 
								au.id_usage_interval = act.id_usage_interval and au.id_acc = act.id_acc
								where act.bucket =' + cast(@acc as varchar(10)) + 
								' and au.id_usage_interval =' + cast(@interval as varchar(10)) +
								' and act.id_usage_interval =' + cast(@interval as varchar(10)) +
								' and uq.id_usage_interval =' + cast(@interval as varchar(10)) +
								' and act.status = ''U'''
						exec (@sql1)
						--BCP out the data from product view tables
						select @sql1 = 'bcp "' + @dbname + '..bcpview" out "' + @path + '\' + @tab1 + '_' + cast (@interval as varchar (10)) + '_' + cast (@acc as varchar (10)) + '.txt" -n -S' + @servername
						truncate table #bcpoutput
						insert into #bcpoutput exec master.dbo.xp_cmdshell @sql1
						IF EXISTS(SELECT NULL FROM #bcpoutput 
			    			WHERE OutputLine like '%Error%' 
			        			OR OutputLine like '%ODBC SQL Server Driver%')
						BEGIN
							set @result = '1000018-archive operation failed-->Error in bcp out the ' + cast(@tab1 as varchar(1000)) + ' product view table, check the hard disk space'
							select * from #bcpoutput
							close c3
							deallocate c3
							close c2
							deallocate c2
							close interval_id
							deallocate interval_id
							return
						END
					fetch next from c3 into @tab1
					end
					close c3
					deallocate c3
				end	

				--Get the list of product views that needs to be archived (may be removed later)
				declare  c1 cursor fast_forward for select id_view from #PV 
				open c1
				fetch next from c1 into @var1
				while (@@fetch_status = 0)
				begin
					select @tab1 = nm_table_name from t_prod_view where id_view=@var1 
					SET @sql1 = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(''bcpview'')) DROP view bcpview'
						EXEC sp_executesql @sql1
					select @sql1 = N'create view bcpview as SELECT pv.* FROM ' + 
							@tab1 + ' pv  with (nolock) inner join tempdb..tmp_t_acc_usage au  with (nolock) on 
							pv.id_sess=au.id_sess where au.bucket =' + cast(@acc as varchar(10)) 
                                          + ' and pv.id_sess between ' + cast(@minid as varchar(10)) + ' and '  + cast(@maxid as varchar(10)) 

					exec (@sql1)
					--BCP out the data from product view tables
					select @sql1 = 'bcp "' + @dbname + '..bcpview" out "' + @path + '\' + @tab1 + '_' + cast (@interval as varchar (10)) + '_' + cast (@acc as varchar (10)) + '.txt" -n -S' + @servername
					truncate table #bcpoutput
					insert into #bcpoutput exec master.dbo.xp_cmdshell @sql1
					IF EXISTS(SELECT NULL FROM #bcpoutput 
		    			WHERE OutputLine like '%Error%' 
		        			OR OutputLine like '%ODBC SQL Server Driver%')
					BEGIN
						set @result = '1000009-archive operation failed-->Error in bcp out the ' + cast(@tab1 as varchar(1000)) + ' product view table, check the hard disk space'
						select * from #bcpoutput
						close c1
						deallocate c1
						close c2
						deallocate c2
						close interval_id
						deallocate interval_id
						return
					END
				fetch next from c1 into @var1
				end
				close c1
				deallocate c1
				update t_acc_bucket_map 
				set tt_end = dateadd(s,-1,@vartime)
				where id_usage_interval=@interval 
				and status in ('E','U') 
				and tt_end=@maxtime
				and bucket = @acc
				if (@@error <> 0)
				begin
					set @result = '1000010-archive operation failed-->Error in update t_acc_bucket_map table'
					deallocate c1
					close c2
					deallocate c2
					close interval_id
					deallocate interval_id
					return
				end
				insert into t_acc_bucket_map(id_usage_interval,id_acc,bucket,status,tt_start,tt_end) 
				select @interval,id_acc,bucket,'E',@vartime,@maxtime from t_acc_bucket_map
				where id_usage_interval=@interval
				and status in ('E','U') 
				and tt_end=dateadd(s,-1,@vartime)
				and bucket = @acc
				if (@@error <> 0)
				begin
					set @result = '1000011-archive operation failed-->Error in insert into t_acc_bucket_map table'
					deallocate c1
					close c2
					deallocate c2
					close interval_id
					deallocate interval_id
					return
				end
			fetch next from c2 into @acc
			end
			--deallocate c1
			close c2
			deallocate c2
		
			SET @sql1 = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(''bcpview'')) DROP view bcpview'
					EXEC sp_executesql @sql1
			select @sql1 = N'create view bcpview as SELECT top 100 percent * FROM t_adjustment_transaction where id_usage_interval=' + 
					cast (@interval as varchar(10)) + N' order by id_sess'
					exec (@sql1)
			--BCP out the data from t_adjustment_transaction
			select @sql1 = 'bcp "' + @dbname + '..bcpview" out "' + @path + '\t_adjustment_transaction' + '_' + cast (@interval as varchar (10)) + '.txt" -n -S' + @servername
			truncate table #bcpoutput
			insert into #bcpoutput exec master.dbo.xp_cmdshell @sql1
			IF EXISTS(SELECT NULL FROM #bcpoutput 
				WHERE OutputLine like '%Error%' 
					OR OutputLine like '%ODBC SQL Server Driver%')
			BEGIN
				set @result = '1000012-archive operation failed-->Error in bcp out adjustment transaction table, check the hard disk space'
				select * from #bcpoutput
				close interval_id
				deallocate interval_id
				return
			END
			truncate table #bcpoutput
	
			if object_id('tempdb..tmp_t_adjustment_transaction') is not null
			drop table tempdb..tmp_t_adjustment_transaction
			select @sql1 = N'SELECT id_adj_trx into tempdb..tmp_t_adjustment_transaction FROM ' + @dbname + '..t_adjustment_transaction where id_usage_interval=' + cast (@interval as varchar(10)) + N' order by id_sess'
			exec (@sql1)
			create unique clustered index idx_tmp_t_adjustment_transaction on tempdb..tmp_t_adjustment_transaction(id_adj_trx)
	
			if object_id('tempdb..#adjustment') is not null
			drop table #adjustment
			create table #adjustment(name nvarchar(2000))
			declare c1 cursor fast_forward for select table_name from information_schema.tables where 
			table_name like 't_aj_%' and table_name not in ('T_AJ_TEMPLATE_REASON_CODE_MAP','t_aj_type_applic_map')
			open c1
			fetch next from c1 into @var1
			while (@@fetch_status = 0)
			begin
			--Get the name of t_aj tables that have usage in this interval
			set @sql1 = N'if exists
					(select 1 from ' + @var1 + ' where id_adjustment in 
					(select id_adj_trx from t_adjustment_transaction where id_usage_interval = ' + cast(@interval as varchar(10)) + N')) 
					insert into #adjustment values(''' + @var1 + ''')'
					EXEC sp_executesql @sql1
			SET @sql1 = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(''bcpview'')) DROP view bcpview'
					EXEC sp_executesql @sql1
			fetch next from c1 into @var1
			end
			close c1
			deallocate c1
	
			declare c1 cursor for select name from #adjustment
			open c1
			fetch next from c1 into @var1
			while (@@fetch_status = 0)
			begin
				SET @sql1 = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(''bcpview'')) DROP view bcpview'
					EXEC sp_executesql @sql1
				--BCP out the data from t_aj tables
				select @sql1 = N'create view bcpview as SELECT top 100 percent aj.* FROM ' + @dbname + '..' + @var1 
				+ ' aj inner join tempdb..tmp_t_adjustment_transaction trans on aj.id_adjustment=trans.id_adj_trx'
					exec (@sql1)
				select @sql1 = 'bcp "' + @dbname +'..bcpview" out "' + @path + '\' + @var1 + '_' + cast (@interval as varchar (10)) + '.txt" -n -S' + @servername
				truncate table #bcpoutput
				insert into #bcpoutput exec master.dbo.xp_cmdshell @sql1
				IF EXISTS(SELECT NULL FROM #bcpoutput 
	    			WHERE OutputLine like '%Error%' 
	        			OR OutputLine like '%ODBC SQL Server Driver%')
				BEGIN
					set @result = '1000013-archive operation failed-->Error in bcp out ' + cast(@var1 as varchar(1000)) + ' table, check the hard disk space'
					select * from #bcpoutput
					close c1
					deallocate c1
					close interval_id
					deallocate interval_id
					return
				END
				fetch next from c1 into @var1
			end
			close c1
			deallocate c1
		fetch next from interval_id into @interval
		end
		close interval_id
	
		begin tran
--Update the archiving tables...t_archive, t_archive_partition, t_acc_bucket_map
		open interval_id
		fetch next from interval_id into @interval
		while (@@fetch_status = 0)
		begin
			if object_id('tempdb..#id_view') is not null
			drop table #id_view
			select distinct id_view into #id_view from t_acc_usage where id_usage_interval = @interval
			update t_archive 
			set tt_end = dateadd(s,-1,@vartime)
			where id_interval=@interval 
			and status='E' 
			and tt_end=@maxtime
			if (@@error <> 0)
			begin
				set @result = '1000014-archive operation failed-->Error in update t_archive table'
				rollback tran
				close interval_id
				deallocate interval_id
				return
			end
			insert into t_archive 
			select @interval,id_view,null,'E',@vartime,@maxtime from #id_view
			union all
			select @interval,null,name,'E',@vartime,@maxtime from #adjustment
			if (@@error <> 0)
			begin
				set @result = '1000015-archive operation failed-->Error in insert t_archive table'
				rollback tran
				close interval_id
				deallocate interval_id
				return
			end
		fetch next from interval_id into @interval
		end
		close interval_id
		deallocate interval_id

		if
		( 
		(
			(@partition is not null) 
			or exists
			(
				select 1 from t_partition_interval_map map where id_partition = (select id_partition
				from t_partition_interval_map where id_interval = @intervalid)
				and not exists (select 1 from t_usage_interval inte where inte.id_interval = map.id_interval
				and tx_interval_status <> 'H') 
				and not exists (select 1 from t_archive inte where inte.id_interval = map.id_interval
				and tt_end = @maxtime and status <> 'E') 		
			)
		) 
		and 
			(select b_partitioning_enabled from t_usage_server) = 'Y'
		)
		begin
			update t_archive_partition
			set tt_end = dateadd(s,-1,@vartime)
			where partition_name = isnull(@partition,@partition1)
			and tt_end=@maxtime
			and status = 'E'
			if (@@error <> 0)
			begin
				set @result = '1000016-archive operation failed-->Error in update t_archive_partition table'
				rollback tran
				return
			end
			insert into t_archive_partition values(isnull(@partition,@partition1),'E',@vartime,@maxtime)
			if (@@error <> 0)
			begin
				set @result = '1000017-archive operation failed-->Error in insert into t_archive_partition table'
				rollback tran
				return
			end
		end
		--Drop all the temp tables created in the procedure
		if object_id('tempdb..tmp_t_acc_usage') is not null
		drop table tempdb..tmp_t_acc_usage
		if object_id('tempdb..tmp_t_adjustment_transaction') is not null
		drop table tempdb..tmp_t_adjustment_transaction
		set @result = '0-archive_export operation successful'
		commit tran
		

GO
		
    



