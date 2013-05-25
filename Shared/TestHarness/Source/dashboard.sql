

use TestHarnessCoverageDB

select *from t_TestDashBoard order by id desc
sp_help t_TestDashBoard

drop table t_TestDashBoard

CREATE TABLE [dbo].[t_TestDashBoard] (
        [id] [int] IDENTITY (1, 1) NOT NULL ,
        [TimeStamp] [datetime] NOT NULL ,
        [Status] [varchar] (64)  NOT NULL ,
        [SessionID] [varchar] (64)  NOT NULL ,
        [Tester] [varchar] (64)  NOT NULL ,
        [ScriptName] [varchar] (128)  NOT NULL ,
        [TestName] [varchar] (128)   NULL ,
        [Computer] [varchar] (64)  NOT NULL ,
	[NTUser]  [varchar] (64)  NOT NULL ,
	 [ScriptParameters] [varchar] (255)   NULL ,
        [Message] [varchar] (255)   NULL,
	[ExecutionTime] integer NULL,
	[RMPVersion] [varchar] (64)  NOT NULL ,

) ON [PRIMARY]

delete from t_TestDashBoard 