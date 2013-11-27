
				create table t_rerun_history
				(
				id_rerun int,
				dt_action datetime not null,
				tx_action varchar(50) not null,
				id_acc int,
				tx_comment nvarchar(255),
				constraint fk1_t_rerun_history foreign key(id_rerun) REFERENCES t_rerun(id_rerun)
				)
        