CREATE TABLE t_mt_sys_analyze_all_tables
(
	id                  INT IDENTITY(1, 1) NOT NULL,
	execution_date      DATETIME,
	stats_updated       INT,
	execution_time      TIME,
	U_total_rows        BIGINT,
	NU_total_rows       BIGINT,
	U_sampled_rows      BIGINT,
	NU_sampled_rows     BIGINT,
	U_sampled_percent   FLOAT,
	NU_sampled_percent  FLOAT,
	execution_time_sec  INT,
	CONSTRAINT pk_t_mt_sys_analyze_all_tables PRIMARY KEY(id)
)
