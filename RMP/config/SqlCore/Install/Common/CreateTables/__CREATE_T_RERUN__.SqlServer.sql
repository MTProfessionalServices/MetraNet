
				create table t_rerun
				(
				id_rerun int IDENTITY (1, 1),
				tx_filter nvarchar(255),
				tx_tag nvarchar(255) ,
				constraint pk_t_rerun primary key clustered(id_rerun)
				)
        