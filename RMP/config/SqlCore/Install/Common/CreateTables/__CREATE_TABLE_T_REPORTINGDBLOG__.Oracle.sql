
				create table t_ReportingDBLog
				(
				NameOfReportingDB nvarchar2(2000) not null,
				doBackup varchar2(1),
				constraint pk_t_ReportingDBLog primary key(NameOfReportingDB)
				)
 	 