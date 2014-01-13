use %%NETMETER%%

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT

IF  EXISTS (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'FilterSortQuery_v2') AND type in (N'P'))
	DROP PROCEDURE FILTERSORTQUERY_v2
GO

create PROCEDURE FILTERSORTQUERY_v2
(
  @stagingDBName nvarchar(100),
  @tableName nvarchar(50),
  @InnerQuery nvarchar(max),
  @OrderByText nvarchar(500),
  @StartRow int,
  @NumRows int
)
AS
  declare @Sql nvarchar(max)
  /* Create a temp table with all the selected records after the filter */
	set @Sql = 	N'select *, IDENTITY(int, 1, 1) as RowNumber into ' + @stagingDBName + '..' +  @tableName + N' from (' + @InnerQuery + N') innerQuery ' + @OrderByText;
	print(@Sql);
  Execute (@Sql);

  /* Get the total number of records after the filter */
  set @Sql = N'select count(*) as TotalRows from ' + @stagingDBName + '..' + @tableName;
  print(@Sql);
  execute (@Sql);

  /* If the results are to be paged, apply the page filter */
  if @NumRows > 0
  begin
	  set @Sql = N'select * from ' + @stagingDBName + '..' + @tableName + N' where RowNumber between ' + cast(@StartRow as nvarchar(10)) + N' and ' + cast((@StartRow + @NumRows - 1) as nvarchar(10));
	  print(@Sql);
      execute(@Sql);
  end
  else
  begin
      execute('select * from ' + @stagingDBName + '..' + @tableName);
  end

  /* Drop the temp table to clean up */
  Execute('drop table ' + @stagingDBName + '..' + @tableName);