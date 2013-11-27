
create table t_pipeline_service
(
  /* unique pipeline ID*/
  id_pipeline number(10) not null,
  /* service id of service that the pipeline will service*/
  id_svc number(10) not null,
  /* transaction time effective date of the time that the */
	/* pipeline is processing this service*/
	tt_start date not null,
	tt_end date not null
);
alter table t_pipeline_service add constraint pk_t_pipeline_service primary key(id_pipeline, id_svc, tt_start, tt_end);

