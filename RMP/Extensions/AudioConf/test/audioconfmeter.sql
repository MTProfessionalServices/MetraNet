begin transaction t1
if object_id( 'tempdb..#stage' ) is not null
drop table #stage

select identity(int, 0, 1) as id_sess,
c_ConferenceID,c_Payer,c_AccountingCode,c_ConferenceName,c_ConferenceSubject,c_OrganizationName,c_SpecialInfo,c_SchedulerComments,c_ScheduledConnections,c_ScheduledStartTime,c_ScheduledTimeGMTOffset,c_ScheduledDuration,c_CancelledFlag,c_CancellationTime,c_ServiceLevel,c_TerminationReason,c_SystemName,c_SalesPersonID,c_OperatorID
into #stage
from
MT_audioconfcall


declare @meterSize integer
declare @setSize integer
declare @numSets integer
declare @id_svc integer
select @meterSize = count(*) from #stage
select @setSize = 100
select @numSets = (@meterSize + @setSize - 1)/@setSize
select @id_svc = id_enum_data from t_enum_data where nm_enum_data='metratech.com/audioconfcall'


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

-- As parent records, must save the unique id to internal id mapping
if object_id( 'tempdb..#parents' ) is not null
drop table #parents
select id_sess + @id_sess_start as id_sess, c_ConferenceID
into #parents
from #stage

insert into t_svc_audioconfcall(id_source_sess, id_parent_source_sess, _CollectionID, c_ConferenceID,c_Payer,c_AccountingCode,c_ConferenceName,c_ConferenceSubject,c_OrganizationName,c_SpecialInfo,c_SchedulerComments,c_ScheduledConnections,c_ScheduledStartTime,c_ScheduledTimeGMTOffset,c_ScheduledDuration,c_CancelledFlag,c_CancellationTime,c_ServiceLevel,c_TerminationReason,c_SystemName,c_SalesPersonID,c_OperatorID)
select dbo.ConvertIntegerToUID(id_sess + @id_sess_start) as id_source_sess, NULL, @id_batch, c_ConferenceID,c_Payer,c_AccountingCode,c_ConferenceName,c_ConferenceSubject,c_OrganizationName,c_SpecialInfo,c_SchedulerComments,c_ScheduledConnections,c_ScheduledStartTime,c_ScheduledTimeGMTOffset,c_ScheduledDuration,c_CancelledFlag,c_CancellationTime,c_ServiceLevel,c_TerminationReason,c_SystemName,c_SalesPersonID,c_OperatorID
from
#stage

insert into  t_session (id_ss, id_source_sess)
select @id_ss_start + id_sess/@setSize, dbo.ConvertIntegerToUID(id_sess + @id_sess_start)
from
#stage

insert into t_session_set(id_ss, id_message, id_svc, session_count)
select id_ss, @id_schedule_start + id_ss - @id_ss_start, @id_svc, count(*)
from t_session
where id_ss between @id_ss_start and @id_ss_start + @setSize - 1
group by id_ss

if object_id( 'tempdb..#stage1' ) is not null
drop table #stage1

select identity(int, 0, 1) as id_sess,
c_ConferenceID,c_Payer,c_UserBilled,c_UserName,c_UserRole,c_OrganizationName,c_userphonenumber,c_specialinfo,c_CallType,c_transport,c_Mode,c_ConnectTime,c_EnteredConferenceTime,c_ExitedConferenceTime,c_DisconnectTime,c_Transferred,c_TerminationReason,c_ISDNDisconnectCause,c_TrunkNumber,c_LineNumber,c_DNISDigits,c_ANIDigits
into #stage1
from
MT_audioconfconnection 



select @meterSize = count(*) from #stage1
select @numSets = (@meterSize + @setSize - 1)/@setSize
select @id_svc = id_enum_data from t_enum_data where nm_enum_data='metratech.com/audioconfconnection'


print '@meterSize = ' + cast(@meterSize as varchar(10)) + '; @numSets = ' + cast(@numSets as varchar(10))

select @id_sess_start = id_current from t_current_id with(updlock) where nm_current='id_dbqueue'
select @id_ss_start = id_current from t_current_id with(updlock) where nm_current='id_dbqueuess'

update t_current_id 
set id_current = id_current + @meterSize
where nm_current='id_dbqueue'

update t_current_id 
set id_current = id_current + @numSets
where nm_current='id_dbqueuess'
-- Assume one session set per scheduled item
--update t_current_id 
--set id_current = id_current + @numSets
--where nm_current='id_dbqueuesch'

print '@id_sess_start = ' + cast(@id_sess_start as varchar(10)) + ';@id_ss_start = ' + cast(@id_ss_start as varchar(10)) + ';@id_schedule_start = ' + cast(@id_schedule_start as varchar(10)) 

-- We gotta get the enumerators into the db. Don't need batch id for children
insert into t_svc_audioconfconnection(id_source_sess, id_parent_source_sess, _CollectionID, c_ConferenceID,c_Payer,c_UserBilled,c_UserName,c_UserRole,c_OrganizationName,c_userphonenumber,c_specialinfo,c_CallType,c_transport,c_Mode,c_ConnectTime,c_EnteredConferenceTime,c_ExitedConferenceTime,c_DisconnectTime,c_Transferred,c_TerminationReason,c_ISDNDisconnectCause,c_TrunkNumber,c_LineNumber,c_DNISDigits,c_ANIDigits)
select dbo.ConvertIntegerToUID(#stage1.id_sess + @id_sess_start) as id_source_sess, #parents.id_sess as id_parent_source_sess, NULL, #stage1.c_ConferenceID,c_Payer,c_UserBilled,c_UserName,c_UserRole,c_OrganizationName,c_userphonenumber,c_specialinfo,c_CallType,c_transport,c_Mode,c_ConnectTime,c_EnteredConferenceTime,c_ExitedConferenceTime,c_DisconnectTime,c_Transferred,c_TerminationReason,c_ISDNDisconnectCause,c_TrunkNumber,c_LineNumber,c_DNISDigits,c_ANIDigits
from
#stage1 
inner join #parents on #stage1.c_ConferenceID=#parents.c_ConferenceID


insert into t_session (id_ss, id_source_sess)
select @id_ss_start + #stage1.id_sess/@setSize, dbo.ConvertIntegerToUID(#stage1.id_sess + @id_sess_start)
from
#stage1


insert into t_session_set(id_ss, id_message, id_svc, session_count)
select id_ss, @id_schedule_start + id_ss - @id_ss_start, @id_svc, count(*)
from t_session
where id_ss between @id_ss_start and @id_ss_start + @setSize - 1
group by id_ss

insert into t_message(id_message, id_route, dt_crt, dt_assigned, id_listener, id_pipeline, dt_completed, id_feedback, dt_metered) 
select distinct id_message, null, GetUTCDate(), null, null, null, null, null, GetUTCDate()
from t_session_set where id_message between @id_schedule_start and @id_schedule_start + @setSize
commit transaction t1