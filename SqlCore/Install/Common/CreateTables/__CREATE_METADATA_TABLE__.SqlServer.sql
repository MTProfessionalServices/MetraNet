
CREATE TABLE t_metadata
(
  timecreate datetime not null,
  content nvarchar(max) NOT NULL,
  CONSTRAINT PK_t_metadata PRIMARY KEY CLUSTERED (timecreate desc),
)
        