
/* ===========================================================
1) Parses the comma separated account identifiers (@accountArray) using the user defined function 'CSVToInt'
2) Validates that there are no duplicate accounts in @accountArray
3) Validates that the accounts are unassigned
4) Validates that the accounts aren't already in the state specified by @state
5) If @checkUsage is 1 then
       - Separates the accounts in @accountArray into accounts which
          have usage and those which don't
       - Updates the status of the unassigned accounts which don't have usage to @state
       - Returns the list of accounts which have usage
6) If @checkUsage is 0 then
        - Updates the status of all accounts in @accountArray to @state
7) If @isTransactional is 1 then the procedure uses a transaction otherwise
   it is non-transactional.
7) Updates the status of the interval to 'H' if necessary

Returns the following error codes:
   -1 : Unknown error occurred
   -2 : No accounts in @accountArray
   -3 : Duplicate accounts in @accountArray 
   -4 : Account(s) in @accountArray not a member of the unassigned group of accounts 
   -5 : Accounts(s) in @accountArray already in state specified by @state
  
=========================================================== */
CREATE PROCEDURE UpdateUnassignedAccounts
(
   @accountArray VARCHAR(4000),
   @id_interval INT,
   @state CHAR(1),
   @checkUsage INT,   -- 0 or 1
   @isTransactional INT, -- 0 or 1
   @status INT OUTPUT
)
AS
   IF (@isTransactional = 1)
      BEGIN
         BEGIN TRAN
      END
   
   SET @status = -1
 
   /* Hold the user specified account id's in @accountArray */
   DECLARE @accounts TABLE
   ( 
      id_acc INT NOT NULL,
      hasUsage CHAR(1) NOT NULL
   )

  /* Insert the accounts in @accountArray into @accounts */
  INSERT INTO @accounts
  SELECT value, 'N' FROM CSVToInt(@accountArray)
   
  /* Error if there are no accounts */
  IF (@@ROWCOUNT =  0)
    BEGIN
      SET @status = -2
       IF (@isTransactional = 1)
         BEGIN
            ROLLBACK
         END
      RETURN 
    END

   /* Error if there are duplicate accounts in @accounts */
    IF (EXISTS (SELECT id_acc 
                     FROM @accounts
	         GROUP BY id_acc
	         HAVING COUNT(id_acc) > 1))
      BEGIN
         SET @status = -3
          IF (@isTransactional = 1)
          BEGIN
             ROLLBACK
          END
         RETURN 
      END

   /* Error if the accounts in @accounts are not a member unassigned accounts */
   IF (NOT EXISTS (SELECT * 
                            FROM @accounts acc 
                            INNER JOIN vw_unassigned_accounts ua 
                                ON ua.AccountID = acc.id_acc
                            WHERE ua.IntervalID = @id_interval))
      BEGIN
         SET @status = -4
          IF (@isTransactional = 1)
          BEGIN
            ROLLBACK
          END
         RETURN 
      END

   /* Error if the accounts in @accounts are already in the state specified by @state */
   IF (EXISTS (SELECT * 
                    FROM @accounts acc 
                    INNER JOIN vw_unassigned_accounts ua 
                        ON ua.AccountID = acc.id_acc AND
                              ua.State = @state
                    WHERE ua.IntervalID = @id_interval))
      BEGIN
         SET @status = -5
          IF (@isTransactional = 1)
          BEGIN
            ROLLBACK
          END
         RETURN 
      END
   
   /* Separate accounts into two groups. Those that have usage and those that don't.  */
   IF (@checkUsage = 1)
      BEGIN
	   UPDATE acc
	   SET hasUsage = 'Y'
	   FROM @accounts acc 
	   INNER JOIN t_acc_usage au
	      ON au.id_acc = acc.id_acc 
	   WHERE
	      au.id_usage_interval = @id_interval
	
	   /* Update the accounts which don't have usage to @state */
	   UPDATE aui
	   SET tx_status = @state
	   FROM t_acc_usage_interval aui
	   INNER JOIN @accounts accounts
	      ON accounts.id_acc = aui.id_acc
	   WHERE
	      accounts.hasUsage = 'N' AND
	      aui.id_usage_interval = @id_interval
       END
   ELSE
       BEGIN
              /* Update all accounts to @state */
	   UPDATE aui
	   SET tx_status = @state
	   FROM t_acc_usage_interval aui
	   INNER JOIN @accounts accounts
	      ON accounts.id_acc = aui.id_acc
	   WHERE
	      aui.id_usage_interval = @id_interval
        END
  
   SET @status = 0

   -- Update the status in t_usage_interval. The output status does not matter
   -- because the interval may not be updated to hard closed.
   DECLARE @status1 INT
   EXEC UpdIntervalStatusToHardClosed @id_interval, 0, @status1 OUTPUT

   /* Return the list of accounts which have usage */
   SELECT id_acc 
   FROM @accounts
   WHERE hasUsage = 'Y'
   
   IF (@isTransactional = 1)
      BEGIN
         COMMIT
      END   
         