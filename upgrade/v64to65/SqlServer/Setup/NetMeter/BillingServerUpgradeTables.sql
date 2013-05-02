USE [NetMeter]
GO

/****** Object:  Table [dbo].[t_recevent_schedule]    Script Date: 06/27/2011 16:25:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
CREATE TABLE [dbo].[t_recevent_schedule](
	[id_event] [int] NOT NULL,
	[id_cycle_type] [int] NULL,
	[id_cycle] [int] NULL,
	[n_minutes] [int] NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[t_recevent_schedule]  WITH CHECK ADD  CONSTRAINT [FK2_t_recevent_schedule] FOREIGN KEY([id_event])
REFERENCES [dbo].[t_recevent] ([id_event])
GO

ALTER TABLE [dbo].[t_recevent_schedule] CHECK CONSTRAINT [FK2_t_recevent_schedule]
GO
*/

-- create t_recevent_scheduled table

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK1_t_recevent_scheduled]') AND parent_object_id = OBJECT_ID(N'[dbo].[t_recevent_scheduled]'))
ALTER TABLE [dbo].[t_recevent_scheduled] DROP CONSTRAINT [FK1_t_recevent_scheduled]
GO

/****** Object:  Table [dbo].[t_recevent_scheduled]    Script Date: 06/29/2011 17:15:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[t_recevent_scheduled]') AND type in (N'U'))
DROP TABLE [dbo].[t_recevent_scheduled]
GO


CREATE TABLE t_recevent_scheduled
(
	id_event integer  NOT NULL ,
	interval_type varchar(20) NOT NULL ,
	start_date datetime  NULL ,
	interval integer  NULL ,
	execution_times varchar(2000)  NULL ,
	days_of_week varchar(2000)  NULL ,
	days_of_month varchar(2000)  NULL ,
	is_paused char(1) NOT NULL DEFAULT 'N',
	override_date datetime  NULL ,
	update_date datetime  NOT NULL ,
	CONSTRAINT PK_t_recevent_scheduled PRIMARY KEY  CLUSTERED (id_event ASC),
	CONSTRAINT FK1_t_recevent_scheduled FOREIGN KEY (id_event) REFERENCES t_recevent(id_event),
	CONSTRAINT [CK1_t_recevent_scheduled] CHECK (interval_type in ('Monthly', 'Weekly', 'Daily', 'Minutely', 'Manual')),
	CONSTRAINT [CK2_t_recevent_scheduled] CHECK (is_paused in ('Y', 'N'))
)
go


-- create t_recevent_eop table

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK1_t_recevent_eop]') AND parent_object_id = OBJECT_ID(N'[dbo].[t_recevent_eop]'))
ALTER TABLE [dbo].[t_recevent_eop] DROP CONSTRAINT [FK1_t_recevent_eop]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[t_recevent_eop]') AND type in (N'U'))
DROP TABLE [dbo].[t_recevent_eop]
GO

CREATE TABLE t_recevent_eop
(
	id_event integer  NOT NULL,
	id_cycle_type integer  NULL ,
	id_cycle integer  NULL ,
	CONSTRAINT PK_t_recevent_eop PRIMARY KEY  CLUSTERED (id_event ASC),
	CONSTRAINT FK1_t_recevent_eop FOREIGN KEY (id_event) REFERENCES t_recevent(id_event),
)
go

--move data

-- insert EOP events
insert into t_recevent_eop 	(id_event, id_cycle_type, id_cycle)
select rs.id_event, rs.id_cycle_type, rs.id_cycle
from t_recevent_schedule rs 
   inner join t_recevent r on rs.id_event = r.id_event
where r.tx_type <> 'Scheduled'

-- Insert Scheduled events Daily   
INSERT INTO t_recevent_scheduled
(id_event, interval_type, interval, [start_date], execution_times, days_of_week, 
 days_of_month, is_paused, override_date, update_date)
select 
  rs.id_event,
  'Daily',		-- interval_type
  1,			-- interval
  CAST('2010-01-01T00:00:00.00' AS datetime), -- start_date
  '05:00 AM',	-- execution times
  NULL,			-- days_of_week
  NULL,			-- days_of_month
  'N',			-- is_paused
  NULL,			-- override_date
  GETDATE()
from t_recevent_schedule rs 
   inner join t_recevent r on rs.id_event = r.id_event
where r.tx_type = 'Scheduled'
   and rs.n_minutes is NULL

-- Insert Scheduled events Minutely   
INSERT INTO t_recevent_scheduled
(id_event, interval_type, interval, [start_date], execution_times, days_of_week, 
 days_of_month, is_paused, override_date, update_date)
select 
  rs.id_event,
  'Minutely',	-- interval_type
  rs.n_minutes,	-- interval
  CAST('2010-01-01T00:00:00.00' AS datetime), -- start_date
  NULL,			-- execution times
  NULL,			-- days_of_week
  NULL,			-- days_of_month
  'N',			-- is_paused
  NULL,			-- override_date
  GETDATE()
from t_recevent_schedule rs 
   inner join t_recevent r on rs.id_event = r.id_event
where r.tx_type = 'Scheduled'
   and rs.n_minutes is not NULL


-- drop old table t_recevent_schedule
/*
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK2_t_recevent_schedule]') AND parent_object_id = OBJECT_ID(N'[dbo].[t_recevent_schedule]'))
ALTER TABLE [dbo].[t_recevent_schedule] DROP CONSTRAINT [FK2_t_recevent_schedule]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[t_recevent_schedule]') AND type in (N'U'))
DROP TABLE [dbo].[t_recevent_schedule]
GO

*/


--select * from t_recevent_scheduled