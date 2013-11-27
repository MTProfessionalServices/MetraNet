CREATE TABLE t_archive_queue_partition (
	current_id_partition  INTEGER,
	last_run              DATE NOT NULL,
	next_allow_run        DATE NULL,	
	CONSTRAINT pk_current_id_partition PRIMARY KEY 
        (
          current_id_partition
        )  
)