if object_id( 'tempdb..#stage' ) is not null
drop table #stage

select top 10 identity(int, 0, 1) as id_source_sess,
c_description,c_time,c_units,c_accountname,c_DecProp1,c_DecProp2,c_DecProp3
into #stage
from
MT_TestService

begin transaction T

	declare @meterSize integer
	declare @setSize integer
	declare @numSets integer
	declare @id_svc integer
	select @meterSize = count(*) from #stage
	select @setSize = 1000
	select @numSets = (@meterSize + @setSize - 1)/@setSize
	select @id_svc = id_enum_data from t_enum_data where nm_enum_data='metratech.com/testservice'


	print '@meterSize = ' + cast(@meterSize as varchar(10)) + '; @numSets = ' + cast(@numSets as varchar(10))

	declare @id_sess_start integer
	declare @id_ss_start integer
	declare @id_schedule_start integer
	declare @id_batch varbinary(16)

	select @id_sess_start = id_current from t_current_id with(updlock) where nm_current='id_dbqueue'
	select @id_ss_start = id_current from t_current_id with(updlock) where nm_current='id_dbqueuess'
	select @id_schedule_start = id_current from t_current_id with(updlock) where nm_current='id_dbqueuesch'
	select @id_batch = dbo.ConvertIntegerToUID(id_current) from t_current_id with(updlock) where nm_current='id_dbqueuebatch'

	update t_current_id 
	set id_current = id_current + @meterSize
	where nm_current='id_dbqueue'

	update t_current_id 
	set id_current = id_current + @numSets
	where nm_current='id_dbqueuess'
	-- Assume one session set per scheduled item
	update t_current_id 
	set id_current = id_current + @numSets
	where nm_current='id_dbqueuesch'
	-- Assume one batch
	update t_current_id 
	set id_current = id_current + 1
	where nm_current='id_dbqueuebatch'

	print '@id_sess_start = ' + cast(@id_sess_start as varchar(10)) + ';@id_ss_start = ' + cast(@id_ss_start as varchar(10)) + ';@id_schedule_start = ' + cast(@id_schedule_start as varchar(10)) 


	insert into t_svc_testservice(id_source_sess, id_parent_source_sess, _CollectionID, c_description,c_time,c_units,c_accountname,c_DecProp1,c_DecProp2,c_DecProp3)
	select dbo.ConvertIntegerToUID(id_source_sess + @id_sess_start) as id_source_sess, NULL, @id_batch, c_description,c_time,c_units,c_accountname,c_DecProp1,c_DecProp2,c_DecProp3
	from
	#stage

	insert into t_session(id_ss, id_source_sess)
	select @id_ss_start + id_source_sess/@setSize, dbo.ConvertIntegerToUID(id_source_sess + @id_sess_start)
	from
	#stage

	insert into t_session_set(id_ss, id_message, id_svc, session_count)
	select  id_ss, @id_schedule_start + id_ss - @id_ss_start, @id_svc, count(*)
	from t_session
	where id_ss between @id_ss_start and @id_ss_start + @setSize - 1
	group by id_ss

	insert into t_message(id_message, id_route, dt_crt, dt_assigned, id_listener, id_pipeline, dt_completed, id_feedback, dt_metered) 
	select id_message, null, GetUTCDate(), null, null, null, null, null, GetUTCDate()
	from t_session_set where id_message between @id_schedule_start and @id_schedule_start + @setSize
	
commit transaction T