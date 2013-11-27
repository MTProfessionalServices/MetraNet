
				create table t_archive(
				id_interval int,
				id_view int,
				adj_name varchar(1000),
				status CHAR(1),
				tt_start datetime,
				tt_end datetime)
				create clustered index idx_archive on t_archive(id_interval)
 	 