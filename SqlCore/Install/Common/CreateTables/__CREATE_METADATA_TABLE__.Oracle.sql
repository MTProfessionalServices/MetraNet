
CREATE TABLE t_metadata
(
  timecreate DATE not null,
  content nclob NOT NULL,
  CONSTRAINT PK_t_metadata PRIMARY KEY (timecreate),
)

