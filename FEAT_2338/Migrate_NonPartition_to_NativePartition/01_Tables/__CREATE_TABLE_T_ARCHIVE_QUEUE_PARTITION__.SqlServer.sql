IF OBJECT_ID('t_archive_queue_partition') IS NOT NULL 
DROP TABLE t_archive_queue_partition

CREATE TABLE t_archive_queue_partition
(
	current_id_partition  INT,
	last_run              DATETIME NOT NULL,
	next_allow_run        DATETIME,
	CONSTRAINT pk_current_id_partition PRIMARY KEY (current_id_partition)
)