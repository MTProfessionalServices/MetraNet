
/* ===========================================================
Used in __GET_EOP_EVENT_INSTANCES_FOR_DISPLAY__
===========================================================*/
CREATE PROCEDURE CreatePopTmpBillGroupStatus
(
   @tx_tableName NVARCHAR(50),
   @id_interval INT,
   @status INT OUTPUT
)
AS

BEGIN     
   SET @status = -1

   DECLARE @sql nvarchar (4000)
   
   /* Drop the table @tx_tableName if it exists*/
   SET @sql = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'''
			                    + @tx_tableName 
			                    + N''') AND OBJECTPROPERTY(id, N''IsUserTable'') = 1)'
			                    + N' DROP TABLE ' + @tx_tableName 
   EXEC sp_executesql @sql
   
   /* Create the table @tx_tableName */
   SET @sql = N'CREATE TABLE ' + @tx_tableName +
	            N'(id_billgroup INT NOT NULL, ' +
              N' id_usage_interval INT NOT NULL, ' +
              N' status CHAR(1) NOT NULL )' 

   EXEC sp_executesql @sql

  /* Insert data from vw_all_billing_groups_status into @tx_tableName */
  IF (@id_interval IS NULL)
  BEGIN
   SET @sql = N'INSERT INTO ' + @tx_tableName +
	            N' SELECT * FROM vw_all_billing_groups_status '
  END
  ELSE
  BEGIN
    SET @sql = N'INSERT INTO ' + @tx_tableName +
	             N' SELECT * FROM vw_all_billing_groups_status WHERE id_usage_interval = ' + CAST( @id_interval  AS NVARCHAR(30)) 
  END

  EXEC sp_executesql @sql
 
  SET @status = 0
END
         