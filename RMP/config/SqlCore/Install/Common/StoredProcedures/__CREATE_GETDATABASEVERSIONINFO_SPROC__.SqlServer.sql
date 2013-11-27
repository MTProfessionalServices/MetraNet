
CREATE  PROCEDURE GetDatabaseVersionInfo
(
  @DatabaseVersionInfo VARCHAR(4096) OUTPUT
)
AS
BEGIN
  -- This stored procedure returns a text string that represents version and other information about the database server.
  -- It is only displayed to the user and so the text string can be modified or added to as necessary
  DECLARE @temp_info VARCHAR(2048)
  DECLARE @inferred_info VARCHAR(2048)

  -- gets the version of the database
  SELECT @temp_info =@@VERSION

  SELECT @inferred_info=
    CASE
      WHEN CHARINDEX('8.00.194', @temp_info) <> 0 THEN '*8.00.194 indicates no SQL Server 2000 Service Pack has been applied'
      WHEN CHARINDEX('8.00.384', @temp_info) <> 0 THEN '*8.00.384 indicates SQL Server 2000 Service Pack 1 applied'
      WHEN CHARINDEX('8.00.534', @temp_info) <> 0 THEN '*8.00.534 indicates SQL Server 2000 Service Pack 2 applied'
      WHEN CHARINDEX('8.00.760', @temp_info) <> 0 THEN '*8.00.760 indicates SQL Server 2000 Service Pack 3 applied'
      WHEN CHARINDEX('8.00.818', @temp_info) <> 0 THEN '*8.00.818 indicates SQL Server 2000 Service Pack 3a and Hotfix Q815495 applied'
      ELSE '*Unable to determine from version number what SQL Server 2000 Service Packs have been applied'
    END

  SELECT @DatabaseVersionInfo = @temp_info + @inferred_info
END
			