
   create table t_mf_tracking_scripts (
   id_tracking nvarchar(64) PRIMARY KEY NOT NULL,
   script_name nvarchar(128) NOT NULL,
   dt_start datetime NOT NULL,
   was_completed int NOT NULL)
		