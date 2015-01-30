
				create table t_acc_template_props (
				id_prop int identity(1,1),
				id_acc_template int not null,
				nm_prop_class nvarchar(100) null,
				nm_prop nvarchar(256) not null,
				nm_value nvarchar(256) null,
				constraint pk_t_acc_template_props PRIMARY KEY(id_prop)
				)
			 