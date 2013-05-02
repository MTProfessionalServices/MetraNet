
CREATE TABLE t_session_set
(
  id_message number(10) NOT NULL,
  id_ss number(10) NOT NULL,
  id_svc number(10) NOT NULL,
/* indicates whether this session set contains the root sessions (parent or atomic) of the message
   only one session set per message can contain root sessions. non-root sessions are children.*/
  b_root CHAR(1) NOT NULL,
  session_count number(10) NOT NULL,
  id_partition number(10) DEFAULT 1 NOT NULL
)
PARTITION BY LIST(ID_PARTITION)
(
  PARTITION P1 VALUES(1)
)

			