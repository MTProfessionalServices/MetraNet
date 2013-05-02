
/* ===========================================================
Populate the temporary table using @accountArray.
===========================================================*/
CREATE PROCEDURE CreateAndPopulateTempAccts
(
   @accountArray VARCHAR(4000),
   @status INT OUTPUT
)
AS

BEGIN     
   SET @status = -1

   delete tmp_billing_rerun_accounts;

  /* Insert the accounts in @accountArray into @tx_tableName */
  INSERT INTO tmp_billing_rerun_accounts with (tablockx)
	SELECT value FROM CSVToInt(@accountArray);

  SET @status = 0
END
         