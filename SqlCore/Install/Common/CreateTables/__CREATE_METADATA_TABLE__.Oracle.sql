
CREATE TABLE Metadata
(
  timecreate DATE not null,
  content nclob NOT NULL,
  CONSTRAINT PK_Metadata PRIMARY KEY (timecreate)
)

