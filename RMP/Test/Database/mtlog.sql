-- following fields have to be checked on:
-- #Fields: date time s-ip cs-method 
-- cs-uri-stem cs-uri-query s-port cs-username 
-- c-ip cs(User-Agent) sc-status sc-substatus sc-win32-status sc-bytes cs-bytes time-taken 

if object_id( 't_mtlog' ) is not null
drop table t_mtlog
go

CREATE TABLE [dbo].[t_mtlog] (
	[id][int] IDENTITY (1, 1) NOT NULL ,
	[date] [datetime] NULL,
	[process][varchar](50) NULL, 
	[module][varchar](50) NULL, 
	[level][varchar](50) NULL, 
	[message][varchar](1024) NULL, 
	[logfile_id] int NOT NULL
	FOREIGN KEY ([logfile_id]) REFERENCES [logfiles_PMNA]([logfile_id])
	)
GO
if object_id( 't_mtlog_temp' ) is not null
drop table t_mtlog_temp
go
CREATE TABLE [dbo].[t_mtlog_temp] (
	[date] [datetime] NULL,
	[process][varchar](50) NULL, 
	[module][varchar](50) NULL, 
	[level][varchar](50) NULL, 
	[message][varchar](1024) NULL
	)
GO
if object_id( 't_mtlogs' ) is not null
begin
delete from t_mtlogs
end
else
begin
CREATE TABLE [dbo].[t_mtlogs] (
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
SET @file_name = 'C:\scratch\mtlog.txt'
SET @machine_name = 'PMNAB1'
IF NOT EXISTS(SELECT * FROM [dbo].[t_mtlogs] WHERE [file_name]=@file_name AND [machine_name]=@machine_name)
BEGIN
	INSERT INTO t_mtlogs ([file_name], [machine_name], [dt_crt])
	VALUES (@file_name, @machine_name, current_timestamp)
	SET @logfile_id = @@IDENTITY
	
	TRUNCATE TABLE t_mtlog_temp
	
	DECLARE @stmt NVARCHAR(2048)
	SET @stmt =  N'BULK INSERT [dbo].[t_mtlog_temp] FROM ''' + @file_name + N'''
	WITH (
	    FIELDTERMINATOR = '' '',
	    ROWTERMINATOR = ''\n'',
MAXERRORS = 10000
	)'
	
	exec sp_executesql @stmt
	
	-- Move date from temp area into the main table, recording which
	-- logfile it came from.
	INSERT INTO [dbo].[t_mtlog]
	
SELECT 
*, @logfile_id FROM [dbo].[t_mtlog_temp]
END
ELSE
BEGIN
	PRINT 'Logfile already has been imported'
END


select * from t_mtlog_temp