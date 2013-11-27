/*
	<initialization table="t_usage_server">
		<insert_only/>
	</initialization>
*/
				CREATE TABLE t_usage_server
				(
					n_adv_interval_creation number(10) NOT NULL,    /* number of days to create intervals in advance */
					dt_last_interval_creation DATE NULL,  /* date of last interval creation */
					b_partitioning_enabled nvarchar2(1) default 'N' not null ,
					partition_cycle number(10)  default 30 not null ,
					partition_type nvarchar2(20)  default 'Monthly' not null,
					partition_data_size number(10) default 100 not null ,
					partition_log_size number(10) default 25 not null 
				)

