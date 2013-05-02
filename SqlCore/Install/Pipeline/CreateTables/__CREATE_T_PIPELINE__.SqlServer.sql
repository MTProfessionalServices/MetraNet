
create table t_pipeline
(
  -- unique pipeline ID
  id_pipeline int identity(1,1) not null constraint pk_t_pipeline PRIMARY KEY,
  -- machine name
  tx_machine nvarchar(128) not null,

  -- flag indicating if this pipeline is online or not
  b_online char(1) not null,
	-- flag indicating if this pipeline is currently enabled for routing
	b_paused char(1) not null,
	-- flag indicating if this pipeline is currently processing (detected by sessions in shared memory)
	b_processing char(1) not null
)
alter table t_pipeline add constraint uk_t_pipeline_tx_machine UNIQUE (tx_machine)
			