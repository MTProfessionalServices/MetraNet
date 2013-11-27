
create table t_gsub_recur_map (id_group number(10) not null,id_prop number(10) not null,id_acc number(10) not null,vt_start date not null,	vt_end date not null,	tt_start date not null,tt_end date not null);

alter table t_gsub_recur_map add constraint t_gsub_recur_map_PK PRIMARY KEY (id_group, id_prop, vt_start, vt_end, tt_start, tt_end);

