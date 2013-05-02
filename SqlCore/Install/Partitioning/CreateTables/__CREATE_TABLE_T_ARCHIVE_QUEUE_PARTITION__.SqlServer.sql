
CREATE TABLE t_archive_queue_partition
(
	current_id_partition  INT,
	last_run              DATETIME NOT NULL,
	next_allow_run        DATETIME NULL,
	CONSTRAINT pk_current_id_partition PRIMARY KEY (current_id_partition)
)