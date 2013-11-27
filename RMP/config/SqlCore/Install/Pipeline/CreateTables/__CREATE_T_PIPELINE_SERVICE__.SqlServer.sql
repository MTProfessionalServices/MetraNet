
create table t_pipeline_service
(
  -- unique pipeline ID
  id_pipeline int not null,
  -- service id of service that the pipeline will service
  id_svc int not null,

  -- transaction time effective date of the time that the 
	-- pipeline is processing this service
	tt_start datetime not null,
	tt_end datetime not null,
	
)
alter table t_pipeline_service add constraint pk_t_pipeline_service primary key(id_pipeline, id_svc, tt_start, tt_end)
			