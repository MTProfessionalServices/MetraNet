CREATE TABLE t_updatestatsinfo
(
	tab_type              NVARCHAR(1) NOT NULL,
	tab_name              NVARCHAR(200) NOT NULL,
	total_rows            BIGINT,
	default_sampled_rows  BIGINT,
	sampled_rows          BIGINT,
	num_of_stats          INT,
	execution_time_sec    INT,
	CONSTRAINT pk_t_updatestatsinfo PRIMARY KEY(tab_type, tab_name)
)
