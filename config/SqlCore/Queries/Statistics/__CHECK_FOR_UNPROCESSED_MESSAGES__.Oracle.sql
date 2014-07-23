select 
	dbo.GenGuid() "ID", /* dummy filed as identifier for GridLayout*/
	enum.nm_enum_data, 
	id_pipeline,
	count(*) as '# Messages'
from t_session_set ss 
join t_message tm 
on tm.id_message=ss.id_message 
				and tm.dt_completed is null
join t_enum_data enum 
on enum.id_enum_data=ss.id_svc
group by nm_enum_data, id_pipeline