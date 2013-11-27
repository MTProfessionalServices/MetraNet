
create procedure dearchive_files
			(
			@interval_id int,
			@account_id_list nvarchar(4000),
			@result nvarchar(4000) output
			)
		as
		set nocount on
		declare @sql1 nvarchar(4000)
		declare @tab1 nvarchar(1000)
		declare @tab2 nvarchar(1000)
		declare @var1 nvarchar(100)
		declare @str1 nvarchar(1000)
		declare @str2 nvarchar(2000)
		declare @vartime datetime
		declare @maxtime datetime
		declare @bucket int
		declare	@dbname nvarchar(100)

		begin
		select @vartime = getdate()
		select @maxtime = dbo.mtmaxdate()
		select @dbname = db_name()
		--how to run this procedure
		--declare @result varchar(4000)
		--exec dearchive_files intervalid,'accountid',@result output
		--print @result

		--Checking following Business rules :
		--Interval should be archived
		--Account is in archived state
		--Verify the database name
		select @tab2 = table_name from information_schema.tables where table_name='T_ACC_USAGE' and table_catalog = @dbname
		if (@tab2 is null)
		begin
			set @result = '6000001-dearchive_files operation failed-->check the database name'
			return
		end
		if not exists (select top 1 * from t_archive where id_interval=@interval_id and status ='A' and tt_end = @maxtime)
		begin
			set @result = '6000002-dearchive_files operation failed-->Interval is not archived'
			return
		end
--TO GET LIST OF ACCOUNT
		CREATE TABLE #file (filename nvarchar(4000),id_acc int)
		CREATE TABLE #AccountIDsTable (ID int NOT NULL,bucket int)
		if (@account_id_list is not null)
		begin
			WHILE CHARINDEX(',', @account_id_list) > 0
				BEGIN
					INSERT INTO #AccountIDsTable (ID)
					SELECT SUBSTRING(@account_id_list,1,(CHARINDEX(',', @account_id_list)-1))
					SET @account_id_list = SUBSTRING (@account_id_list, (CHARINDEX(',', @account_id_list)+1),
										(LEN(@account_id_list) - (CHARINDEX(',', @account_id_list))))
					if (@@error <> 0)
					begin
						set @result = '6000003-dearchive_files operation failed-->error in insert into #AccountIDsTable'
						return
					end
				END
			INSERT INTO #AccountIDsTable (ID) SELECT @account_id_list
			if (@@error <> 0)
			begin
				set @result = '6000004-dearchive_files operation failed-->error in insert into #AccountIDsTable'
				return
			end

			update #AccountIDsTable set bucket = act.bucket
			from #AccountIDsTable inner join t_acc_bucket_map act
			on #AccountIDsTable.id = act.id_acc
			where act.id_usage_interval=@interval_id
			if (@@error <> 0)
			begin
				set @result = '6000005-dearchive_files operation failed-->error in update #AccountIDsTable'
				return
			end
		end
		else
		begin
			set @sql1 = 'insert into #AccountIDsTable(id,bucket) select id_acc,bucket from
			t_acc_bucket_map where id_acc not in (select distinct id_acc from t_acc_usage where id_usage_interval = ' + cast(@interval_id as varchar(20)) + ')
			 and status = ''A'' and tt_end = dbo.mtmaxdate()'
			print(@sql1)
			exec (@sql1)
			if (@@error <> 0)
			begin
				set @result = '6000006-dearchive_files operation failed-->error in insert into #AccountIDsTable'
				return
			end
		end

		if exists (select 1 from t_acc_bucket_map where id_usage_interval=@interval_id and status ='D' and tt_end = @maxtime
				and id_acc in (select id from #AccountIDsTable))
		begin
			set @result = '6000007-dearchive_files operation failed-->one of the account is already dearchived'
			return
		end
		if EXISTS(SELECT 1 FROM #AccountIDsTable WHERE bucket is null)
		begin
			set @result = '6000008-dearchive_files operation failed-->one of the account does not have bucket mapping...check the accountid'
			return
		end

		declare  c1 cursor fast_forward for select distinct id_view from t_archive where id_interval = @interval_id
		and tt_end = @maxtime and id_view is not null
		declare c2 cursor fast_forward for select distinct bucket from #AccountIDsTable
		open c2
		fetch next from c2 into @bucket
		while (@@fetch_status = 0)
		begin
		--Checking the existence of import files for each table
			declare	@FileName nvarchar(128)
			select  @FileName = 't_acc_usage' + '_' + cast(@interval_id as varchar(10)) + '_' + cast(@bucket as varchar(10)) + '.txt'
			insert into #file select @FileName,id from #AccountIDsTable where bucket = @bucket
			if (@@error <> 0)
			begin
				set @result = '6000009-dearchive_files operation failed-->insert into file table for t_acc_usage'
				close c2
				deallocate c2
				deallocate c1
				return
			end

			open c1
			fetch next from c1 into @var1
			while @@fetch_status = 0
			begin
				select @tab1 = nm_table_name from t_prod_view where id_view=@var1
				select @filename = @tab1 + '_' + cast(@interval_id as varchar(10)) + '_' + cast(@bucket as varchar(10)) + '.txt'
				insert into #file select @FileName,id from #AccountIDsTable where bucket = @bucket
				if (@@error <> 0)
				begin
					set @result = '6000010-dearchive_files operation failed-->insert into file table for product views'
					close c1
					deallocate c1
					close c2
					deallocate c2
					return
				end
			fetch next from c1 into @var1
			end
			close c1
		fetch next from c2 into @bucket
		end
		close c2
		deallocate c1

		if not exists (select top 1 id_adj_trx from t_adjustment_transaction where id_usage_interval = @interval_id)
		begin
			select  @FileName = 't_adjustment_transaction' + '_' + cast(@interval_id as varchar(10)) + '.txt'
				insert into #file select @FileName,id from #AccountIDsTable where bucket = @bucket
				if (@@error <> 0)
				begin
				set @result = '6000011-dearchive_files operation failed-->insert into file table for t_adjustment_transaction'
				return
				end

			declare  c1 cursor fast_forward for select distinct adj_name from t_archive where id_interval = @interval_id and tt_end = @maxtime
			and adj_name is not null and status='A'
			open c1
			fetch next from c1 into @var1
			while @@fetch_status = 0
			begin
				select @filename = @var1 + '_' + cast(@interval_id as varchar(10)) + '.txt'
				insert into #file select @FileName,id from #AccountIDsTable where bucket = @bucket
				if (@@error <> 0)
				begin
					set @result = '6000012-dearchive_files operation failed-->insert into file table for t_aj_tables'
					close c1
					deallocate c1
					return
				end
				fetch next from c1 into @var1
			end
			close c1
			deallocate c1
		end
		select filename,id_acc from #file order by id_acc
		set @result = '0-dearchive_files operation successful'
		end
    