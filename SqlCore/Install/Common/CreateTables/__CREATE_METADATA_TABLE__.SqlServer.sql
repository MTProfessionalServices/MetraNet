
CREATE TABLE Metadata
(
  timecreate datetime not null,
  content nvarchar(max) NOT NULL,
  CONSTRAINT PK_Metadata PRIMARY KEY CLUSTERED (timecreate desc),
)
        