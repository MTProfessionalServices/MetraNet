
create  procedure PopFirstMessage
  @pipelineID int,
  @systemTime datetime,
  @messageID int OUTPUT
as
begin

set nocount on
begin transaction

select top 1 @messageID = id_message from
t_message m with(readpast, updlock)
where
m.dt_assigned is null
and 
not exists (
	select * from t_session_set ss
	where
	ss.id_message=m.id_message
	and
	ss.id_svc not in (select ps.id_svc from t_pipeline_service ps 
                    inner join t_pipeline p on ps.id_pipeline=p.id_pipeline
                    where 
                    p.id_pipeline=@pipelineID 
                    and p.b_paused = '0'
                    and tt_end=dbo.MTMaxDate())
)
order by id_message asc

if @messageID is not null
begin
	update t_message with(ROWLOCK) set dt_assigned = @systemTime, id_pipeline = @pipelineID where id_message = @messageID

        set nocount off
	 select ss.id_message, ss.id_svc,
	 ss.session_count, m.id_feedback
   from t_session_set ss
	 inner join t_message m on ss.id_message=m.id_message
	 where ss.id_message = @messageID

end
else
begin
-- next line is a hack for now: don't know how to
-- handle conditional rowsets
select -1 as id_message	
end
commit transaction
set nocount off
end
			