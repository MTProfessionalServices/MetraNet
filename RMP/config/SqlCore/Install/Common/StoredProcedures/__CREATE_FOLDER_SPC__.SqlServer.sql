CREATE PROCEDURE Create_folder
(
	@folder_path nvarchar(256)
)
AS

DECLARE @shell_cmd NVARCHAR(300)

SET @shell_cmd = 'MD ' + @folder_path

EXEC master.dbo.xp_cmdshell @shell_cmd