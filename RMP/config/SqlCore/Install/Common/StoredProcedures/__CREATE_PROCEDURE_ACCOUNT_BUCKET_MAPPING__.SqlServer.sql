
create procedure account_bucket_mapping
(
@partition_name nvarchar(4000) = null,
@interval_id int = null,
@hash int,
@result nvarchar(4000) output)
as
/*How to execute the procedure
		declare @result nvarchar(4000)
		exec account_bucket_mapping @partition_name='N_20040701_20040731',@interval_id=null,@hash=3,@RESULT=@result output
		print @result
		OR
		declare @result nvarchar(4000)
		exec account_bucket_mapping @partition_name=null,@interval_id=827719717,@hash=3,@RESULT=@result output
		print @result
*/
declare @sql nvarchar(4000)
declare @partname nvarchar(4000)
declare @maxdate datetime
declare @currentdate datetime

set @currentdate = getdate()

set @maxdate = dbo.mtmaxdate()
--Check that either Interval or Partition is specified
if ((@partition_name is not null and @interval_id is not null) or (@partition_name is null and @interval_id is null))
begin
	set @result = '4000001-account_bucket_mapping operation failed-->Either Partition or Interval should be specified'
	return
END
begin tran
--Run the following code if Interval is specified
if (@interval_id is not null)
begin
--Check that Interval exists
	if not exists (select 1 from t_usage_interval where id_interval=@interval_id)
	BEGIN
		set @result = '4000002-account_bucket_mapping operation failed-->Interval Does not exists'
		rollback tran
		return
	END
--Check that Interval is hard closed
	if exists (select 1 from t_usage_interval where id_interval=@interval_id and tx_interval_status in ('O','B'))
	BEGIN
		set @result = '4000002a-account_bucket_mapping operation failed-->Interval is not Hard Closed'
		rollback tran
		return
	END
--Check that mapping should not already exists
	if exists (select 1 from t_acc_bucket_map where id_usage_interval=@interval_id)
	BEGIN
		set @result = '4000003-account_bucket_mapping operation failed-->Mapping already exists'
		rollback tran
		return
	END

--	Insert into account bucket mapping table
	select @sql = 'insert into t_acc_bucket_map(id_usage_interval,id_acc,bucket,status,tt_start,tt_end)
			select distinct ' + cast(@interval_id as nvarchar(10)) + ',id_acc,id_acc%' + cast(@hash as nvarchar(10)) + ',''U'',''' + convert(nvarchar(23),@currentdate,121) + ''','''
			+ convert(nvarchar(23),@maxdate,121) + ''' from t_acc_usage_interval
			where id_usage_interval = ' + cast(@interval_id as nvarchar(10))
	exec (@sql)
	if (@@error <> 0)
	begin
		set @result = '4000004-account_bucket_mapping operation failed-->error in insert into t_acc_bucket_map'
		rollback tran
		return
	end
end
--Run the following code if Partition is specified
else
begin
--Get all the intervals in the specified Partition
	if object_id('tempdb..#tmp') is not null drop table #tmp
	select id_interval into #tmp from t_partition_interval_map map where id_partition
	= (select id_partition  from t_partition where partition_name = @partition_name)
	create unique clustered index idx_tmp on #tmp(id_interval)
	if not exists (select 1 from t_usage_interval inte inner join #tmp map on inte.id_interval=map.id_interval and tx_interval_status = 'H')
		BEGIN
			set @result = '4000005-account_bucket_mapping operation failed-->Interval does not exist or is not Hard Closed or Partition Name does not exist'
			rollback tran
			return
		END
	--Check that mapping should not already exists
	if exists (select 1 from t_acc_bucket_map inte inner join #tmp map on inte.id_usage_interval=map.id_interval)
		BEGIN
			set @result = '4000006-account_bucket_mapping operation failed-->Mapping already exists'
			rollback tran
			return
		END

	set @sql = 'insert into t_acc_bucket_map(id_usage_interval,id_acc,bucket,status,tt_start,tt_end)
			select id_usage_interval,id_acc,id_acc%' + cast(@hash as nvarchar(10)) + ',''U'',''' +
			convert(nvarchar(23),@currentdate,121) + ''','''
			+ convert(nvarchar(23),@maxdate,121) + ''' from t_acc_usage_interval
			where id_usage_interval in (select id_interval from #tmp)'
		exec (@sql)
		if (@@error <> 0)
		begin
			set @result = '4000007-account_bucket_mapping operation failed-->error in insert into t_acc_bucket_map'
			rollback tran
			return
		end
	if object_id('tempdb..#tmp') is not null drop table #tmp
	if object_id('tempdb..#tmp1') is not null drop table #tmp1
end
set @result = '0-account_bucket_mapping operation successful'
commit tran
    