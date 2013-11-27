
CREATE TABLE t_session
(
  -- session set ID
  id_ss INT NOT NULL,
  -- session ID
  id_source_sess BINARY(16) NOT NULL,  -- client generated UID
  id_partition INT NOT NULL DEFAULT 1,                                     -- 
  CONSTRAINT pk_t_session PRIMARY KEY CLUSTERED (id_ss, id_source_sess)	
)
--create clustered index idx_ss on t_session(id_ss)
--create index idx_sess on t_session(id_source_sess)
			