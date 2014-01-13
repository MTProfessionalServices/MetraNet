-- following fields have to be checked on:
-- #Fields: date time s-ip cs-method 
-- cs-uri-stem cs-uri-query s-port cs-username 
-- c-ip cs(User-Agent) sc-status sc-substatus sc-win32-status sc-bytes cs-bytes time-taken 

if object_id( 'weblog_PMNA' ) is not null
drop table weblog_PMNA
go

CREATE TABLE [dbo].[weblog_PMNA] (
	[id][int] IDENTITY (1, 1) NOT NULL ,
	[date] [datetime] NULL,
	[time] [datetime] NULL ,
	[s-ip] [varchar] (50) NULL ,
	[cs-method] [varchar] (50) NULL ,
	[cs-uri-stem] [varchar] (255) NULL ,
	[cs-uri-query] [varchar] (2048) NULL ,
	[s-port] [int] NULL ,
	[cs-username] [varchar] (255) NULL ,
	[c-ip] [varchar] (255) NULL ,
	[cs(User-Agent)] [varchar] (255) NULL,
	[sc-status] [numeric] (10, 0) NULL ,
	[sc-substatus] [numeric] (10, 0) NULL ,
	[sc-win32-status] [numeric] (10, 0) NULL ,
	[sc-bytes][varchar](255) NULL ,
	[cs-bytes] [varchar](255) NULL ,
	[time-taken][varchar](1024) NULL, 
	[logfile_id] int NOT NULL,
	FOREIGN KEY ([logfile_id]) REFERENCES [logfiles_PMNA]([logfile_id])
	)
GO
if object_id( 'weblog_PMNA_temp' ) is not null
drop table weblog_PMNA_temp
go
CREATE TABLE [dbo].[weblog_PMNA_temp] (
	[date] [varchar] (255) NULL,
	[time] [varchar] (255) NULL,
	[s-ip] [varchar] (50) NULL ,
	[cs-method] [varchar] (50) NULL ,
	[cs-uri-stem] [varchar] (255) NULL ,
	[cs-uri-query] [varchar] (2048) NULL ,
	[s-port] [VARCHAR] (255) NULL ,
	[cs-username] [varchar] (255) NULL ,
	[c-ip] [varchar] (255) NULL ,
	[cs(User-Agent)] [varchar] (255) NULL,
	[sc-status] [varchar](255) NULL ,
	[sc-substatus] [varchar](255) NULL ,
	[sc-win32-status][varchar](255) NULL ,
	[sc-bytes][varchar](255) NULL ,
	[cs-bytes] [varchar](255) NULL ,
	[time-taken][varchar](255) NULL 
	)
GO
if object_id( 'logfiles_PMNA' ) is not null
begin
delete from logfiles_PMNA
end
else
begin
CREATE TABLE [dbo].[logfiles_PMNA] (
        [logfile_id] int identity PRIMARY KEY, 
        [file_name] [varchar] (255) NOT NULL,
        [machine_name] [varchar] (255) NOT NULL,
        [dt_crt] [datetime] NOT NULL
)
end
GO

-- First record the logfile we are importing.  Grab the generated
-- id so that we can mark each imported record with its lineage.
-- Make sure that this logfile hasn't been imported before.
DECLARE @logfile_id INTEGER
DECLARE @file_name VARCHAR(255)
DECLARE @machine_name VARCHAR(255)
SET @file_name = 'C:\scratch\iislogs_pmna\ex050505.log'
SET @machine_name = 'PMNAB1'
IF NOT EXISTS(SELECT * FROM [dbo].[logfiles_PMNA] WHERE [file_name]=@file_name AND [machine_name]=@machine_name)
BEGIN
	INSERT INTO logfiles_PMNA ([file_name], [machine_name], [dt_crt])
	VALUES (@file_name, @machine_name, current_timestamp)
	SET @logfile_id = @@IDENTITY
	
	TRUNCATE TABLE weblog_PMNA_temp
	
	DECLARE @stmt NVARCHAR(2048)
	SET @stmt =  N'BULK INSERT [dbo].[weblog_PMNA_temp] FROM ''' + @file_name + N'''
	WITH (
	    FIELDTERMINATOR = '' '',
	    ROWTERMINATOR = ''\n'',
MAXERRORS = 1000
	)'
	
	exec sp_executesql @stmt
	
	-- Move date from temp area into the main table, recording which
	-- logfile it came from.
	INSERT INTO [dbo].[weblog_PMNA]
	
SELECT 
CASE WHEN date like '#%' THEN NULL ELSE [dbo].[weblog_PMNA_temp].[date] END,
--CASE WHEN date like '#%' THEN NULL ELSE convert(datetime, [dbo].[weblog_PMNA_temp].[time], 'hh:mi:ss:mmm') END,
CASE WHEN date like '#%' THEN NULL ELSE [dbo].[weblog_PMNA_temp].[time] END,
CASE WHEN date like '#%' THEN NULL ELSE [dbo].[weblog_PMNA_temp].[s-ip] END,
CASE WHEN date like '#%' THEN NULL ELSE [dbo].[weblog_PMNA_temp].[cs-method] END,
CASE WHEN date like '#%' THEN NULL ELSE [dbo].[weblog_PMNA_temp].[cs-uri-stem] END,
CASE WHEN date like '#%' THEN NULL ELSE [dbo].[weblog_PMNA_temp].[cs-uri-query] END,
CASE WHEN date like '#%' THEN NULL ELSE [dbo].[weblog_PMNA_temp].[s-port] END,
CASE WHEN date like '#%' THEN NULL ELSE [dbo].[weblog_PMNA_temp].[cs-username] END,
CASE WHEN date like '#%' THEN NULL ELSE [dbo].[weblog_PMNA_temp].[c-ip] END,
CASE WHEN date like '#%' THEN NULL ELSE [dbo].[weblog_PMNA_temp].[cs(User-Agent)] END,
CASE WHEN date like '#%' THEN NULL ELSE [dbo].[weblog_PMNA_temp].[sc-status] END,
CASE WHEN date like '#%' THEN NULL ELSE [dbo].[weblog_PMNA_temp].[sc-substatus] END,
CASE WHEN date like '#%' THEN NULL ELSE [dbo].[weblog_PMNA_temp].[sc-win32-status] END,
CASE WHEN date like '#%' THEN NULL ELSE [dbo].[weblog_PMNA_temp].[sc-bytes] END,
CASE WHEN date like '#%' THEN NULL ELSE [dbo].[weblog_PMNA_temp].[cs-bytes] END,
CASE WHEN date like '#%' THEN NULL ELSE [dbo].[weblog_PMNA_temp].[time-taken] END
, @logfile_id FROM [dbo].[weblog_PMNA_temp]
END
ELSE
BEGIN
	PRINT 'Logfile already has been imported'
END

select * from weblog_PMNA


select * from logfiles_PMNA
delete from weblog_PMNA where logfile_id=14
delete from logfiles_PMNA where logfile_id=14

select top 100 * from weblog_PMNA

select count(*) as num_errors, [sc-status], [cs-uri-stem] from weblog_PMNA 
where 
[sc-status] = 500 
and 
[date] > '2005-04-26'
group by [cs-uri-stem], [sc-status]
order by num_errors desc



select * from
weblog_PMNA
where
[date]='2005-04-25'
and
[time] between '1900-01-01 12:00:00' and '1900-01-01 14:00:00'
and
[cs-uri-stem] like '/mom%'
order 
by [time] desc

select * 
from 
weblog_PMNA
where
[date] >= '2005-04-26'
--[cs-uri-stem] = '/mam/default/dialog/DefaultDialogSubscription.asp'
and
[sc-status] = 500
and
[cs-uri-query] not like '%out_of_memory%'

select *
from
weblog_PMNA
where
[cs-uri-query] like '%Out_of_Memory%'


select 
[cs-uri-stem], count(*) as cnt
from
weblog_PMNA
where
[cs-uri-stem] not like '%.gif%'
and
[cs-uri-stem] not like '%.css%'
and
[cs-uri-stem] not like '%.dll%'
and
[cs-uri-stem] not like '%.asmx%'
and
[cs-uri-stem] not like '%.aspx%'
and
[cs-uri-stem] not like '%.js%'
and
[cs-uri-stem] not like '%.htc%'
and
[cs-uri-stem] not like '%.exe%'
and
[cs-uri-stem] not like '%.jpg%'
group by 
[cs-uri-stem] 
order by cnt desc


select 
max(cast([time-taken]as int)) as max_time, 
min(cast([time-taken]as int)) as min_time, 
avg(cast([time-taken]as int)) as avg_time, 
stdev(cast([time-taken]as int)) as sigma_time, 
count(*) as num_hits, 
sum(case when [time-taken] > 10000 then 1 else 0 end) as num_long_hits,
(100.0*sum(case when [time-taken] > 10000 then 1 else 0 end))/count(*) as percent_long_hits,
[cs-uri-stem] 
from weblog_PMNA 
group by [cs-uri-stem] 
having max([time-taken]) > 10000
order by avg_time desc, percent_long_hits desc


select * from weblog_pmna where date like '#%'

