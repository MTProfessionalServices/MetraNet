
				create table t_ReportingDBLog
				(
				NameOfReportingDB nvarchar(2000)not null,
				doBackup varchar(1),
				constraint pk_t_ReportingDBLog primary key(NameOfReportingDB)
				)
 	 