
CREATE TABLE t_session
(
  /* session set ID*/
  id_ss number(10) NOT NULL,
  /* session ID*/
  id_source_sess raw(16) NOT NULL,  /* client generated UID*/  
  /* Uses for archive_queue functionality */
  id_partition number(10) DEFAULT 1 NOT NULL
)
/*create clustered index idx_ss on t_session(id_ss)
create index idx_sess on t_session(id_source_sess)*/
			