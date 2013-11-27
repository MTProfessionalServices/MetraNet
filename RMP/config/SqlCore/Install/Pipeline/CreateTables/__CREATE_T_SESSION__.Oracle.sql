
CREATE TABLE t_session
(
  /* session set ID*/
  id_ss number(10) NOT NULL,
  /* session ID*/
  id_source_sess raw(16) NOT NULL,  /* client generated UID*/
  ID_PARTITION number(10) DEFAULT 1 NOT NULL
)
PARTITION BY LIST(ID_PARTITION)
(
  PARTITION P1 VALUES(1)
)
/*create clustered index idx_ss on t_session(id_ss)
create index idx_sess on t_session(id_source_sess)*/
			