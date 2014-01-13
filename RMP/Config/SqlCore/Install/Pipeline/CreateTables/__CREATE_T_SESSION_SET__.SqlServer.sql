
CREATE TABLE t_session_set
(
  id_message INT NOT NULL,
  id_ss INT NOT NULL,
  id_svc INT NOT NULL,
  -- indicates whether this session set contains the root sessions (parent or atomic) of the message
  -- only one session set per message can contain root sessions. non-root sessions are children.
  b_root CHAR(1) NOT NULL,
  session_count INT NOT NULL,
  id_partition INT NOT NULL DEFAULT 1,
  CONSTRAINT pk_t_session_set PRIMARY KEY CLUSTERED (id_ss)
)
			