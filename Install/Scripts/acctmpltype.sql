delete from t_acc_tmpl_types;
insert into t_acc_tmpl_types(id,all_types) values(1,CAST(&1 AS INT));
exit;
