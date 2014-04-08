
			create table t_po ( 
				id_po int not null,
				id_eff_date int not null,
				id_avail int not null,
				b_user_subscribe char(1) not null,
				b_user_unsubscribe char(1) not null,
				id_nonshared_pl int not null,
				c_POPartitionId int null,
				b_hidden char(1) not null default 'N',
				constraint t_po_PK primary key (id_po),
				constraint t_po_FK1 foreign key (id_nonshared_pl) references t_pricelist(id_pricelist)
				)
	 