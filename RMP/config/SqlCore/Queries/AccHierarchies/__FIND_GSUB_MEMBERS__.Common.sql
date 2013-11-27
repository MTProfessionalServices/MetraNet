
select id_acc,
vt_start,
vt_end
from t_gsubmember
where
id_group = %%ID_GROUP%% AND
%%TIMESTAMP%% between vt_start AND vt_end
			