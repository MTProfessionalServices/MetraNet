
				create table t_acc_template_props (
				id_prop number(10)  PRIMARY KEY,
				id_acc_template number(10) not null,
				nm_prop_class nvarchar2(100) null,
				nm_prop nvarchar2(256) not null,
				nm_value nvarchar2(256) null
				)
			 