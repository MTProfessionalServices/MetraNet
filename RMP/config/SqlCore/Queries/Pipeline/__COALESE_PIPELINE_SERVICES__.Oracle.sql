
BEGIN
WHILE 1=1
LOOP
update t_pipeline_service
set t_pipeline_service.tt_end = (
	select max(aa2.tt_end)
	from
	t_pipeline_service aa2
	where
	t_pipeline_service.id_pipeline=aa2.id_pipeline
	and
	t_pipeline_service.id_svc=aa2.id_svc
	and
	t_pipeline_service.tt_start < aa2.tt_start
	and
	dbo.addsecond(t_pipeline_service.tt_end) >= aa2.tt_start
	and
	t_pipeline_service.tt_end < aa2.tt_end
)
where
exists (
	select 1
	from
	t_pipeline_service aa2
	where
	t_pipeline_service.id_pipeline=aa2.id_pipeline
	and
	t_pipeline_service.id_svc=aa2.id_svc
	and
	t_pipeline_service.tt_start < aa2.tt_start
	and
	dbo.addsecond(t_pipeline_service.tt_end) >= aa2.tt_start
	and
	t_pipeline_service.tt_end < aa2.tt_end
)
and
t_pipeline_service.id_pipeline=%%ID_PIPELINE%%;

exit when SQL%rowcount <= 0 ;
END LOOP;

delete 
from t_pipeline_service 
where
exists (
	select 1
	from t_pipeline_service aa2
	where
	t_pipeline_service.id_pipeline=aa2.id_pipeline
	and
	t_pipeline_service.id_svc=aa2.id_svc
	and
 	(
	(aa2.tt_start < t_pipeline_service.tt_start and t_pipeline_service.tt_end <= aa2.tt_end)
	or
	(aa2.tt_start <= t_pipeline_service.tt_start and t_pipeline_service.tt_end < aa2.tt_end)
	)
)
and
t_pipeline_service.id_pipeline=%%ID_PIPELINE%%;
END;
			