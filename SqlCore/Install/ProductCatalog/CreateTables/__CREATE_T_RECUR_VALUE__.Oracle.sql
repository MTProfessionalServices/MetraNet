
			create table t_recur_value (id_prop number(10) not null,	id_sub number(10) not null,	n_value number(22,10) not null,	vt_start date not null,	vt_end date not null,tt_start date not null,tt_end date not null);
			
			alter table t_recur_value add constraint t_recur_value_PK primary key (id_prop, id_sub, vt_start, vt_end, tt_start, tt_end);

