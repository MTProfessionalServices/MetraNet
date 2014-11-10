
create view t_vw_allrateschedules
  as
  select * from t_vw_allrateschedules_po with (noexpand)
  UNION ALL
  select * from t_vw_allrateschedules_pl with (noexpand)
		