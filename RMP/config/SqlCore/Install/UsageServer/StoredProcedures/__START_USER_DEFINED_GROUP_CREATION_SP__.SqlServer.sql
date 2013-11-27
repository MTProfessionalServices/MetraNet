
/* ===========================================================
This procedure operates only on unassigned accounts for the given interval (obtained via id_materialization).

1) Check that no interval-only adapter has executed successfully
2) If @accountArray is NULL then use all the unassigned accounts for the given interval 
3) Parses the comma separated account identifiers (@accountArray, if non-NULL) using the user defined function 'CSVToInt'
2) Validates that there are no duplicate accounts in @accountArray
3) Validates that the accounts in @accountArray are from the set of unassigned accounts
4) Inserts name and description into t_billgroup_tmp
5) Inserts unassigned account ids into  t_billgroup_member_tmp

Returns the following error codes:
   -1 : Unknown error occurred
   -2 : Full materialization has not occurred for this interval
   -3 : Atleast one interval-only adapter has executed successfully
   -4 : There are no unassigned accounts for the interval
   -5 : @accountArray is non-NULL and no accounts in @accountArray
   -6 : @accountArray is non-NULL and duplicate accounts in @accountArray 
   -7 : @accountArray is non-NULL and one or more accounts do not belong to the set of unassigned accounts
   -8 : The given billing group name already exists
=========================================================== */
CREATE PROCEDURE StartUserDefinedGroupCreation
(
   @id_materialization INT,
   @tx_name NVARCHAR(50),
   @tx_description NVARCHAR(200),
   @accountArray VARCHAR(4000),
   @status INT OUTPUT
)
AS
   BEGIN TRAN
   
   SET @status = -1
 
   /* Hold the user specified account ids in @accountArray */
   DECLARE @accounts TABLE
   ( 
      id_acc INT NOT NULL
   )

   /* Hold the unassigned account ids for this interval  */
   DECLARE @unassignedAccounts TABLE
   ( 
      id_acc INT NOT NULL
   )

   /* Store the interval id */
   DECLARE @id_interval INT
   SELECT @id_interval = id_usage_interval
   FROM t_billgroup_materialization
   WHERE id_materialization = @id_materialization

   -- CR 14312
   /* Error if a billing group with the given name already exists */
   IF EXISTS (SELECT tx_name 
              FROM t_billgroup bg
              WHERE tx_name = @tx_name AND 
                    id_usage_interval = @id_interval)
      BEGIN
       SET @status = -8
       ROLLBACK
       RETURN 
     END
     
   /* Error if full materialization has not been done on this interval */
   IF NOT EXISTS (SELECT id_materialization 
                           FROM t_billgroup_materialization 
                           WHERE tx_type = 'Full' AND
                                       tx_status = 'Succeeded' AND
                                       id_usage_interval = @id_interval)
    BEGIN
       SET @status = -2
       ROLLBACK
       RETURN 
     END
                                     
   /* Error if atleast one interval-only adapter has executed successfully */
   IF (EXISTS (SELECT id_instance
                    FROM t_recevent_inst ri
                    INNER JOIN t_recevent re
                         ON re.id_event = ri.id_event
                    WHERE ri.id_arg_interval = @id_interval AND
                                re.tx_billgroup_support = 'Interval' AND
                                re.tx_type = 'EndOfPeriod' AND
                                ri.tx_status = 'Succeeded'))
    BEGIN
       SET @status = -3
       ROLLBACK
       RETURN 
     END
    
   /* Get all the open unassigned accounts for the interval */
   INSERT @unassignedAccounts
   SELECT AccountID
   FROM vw_unassigned_accounts vua
    WHERE vua.State = 'O' AND
               vua.IntervalID = @id_interval

   IF (SELECT COUNT(id_acc) FROM @unassignedAccounts) = 0
     BEGIN
       SET @status = -4
       ROLLBACK
       RETURN 
     END
  

    /* If @accountArray is NULL then transfer the accounts from @unassignedAccounts to
        @accounts and continue */
    IF (@accountArray IS NULL)
        BEGIN
            INSERT @accounts
            SELECT * FROM @unassignedAccounts
        END
    ELSE
        /* @accountArray is not NULL - do validations */
        BEGIN
             /* Insert the accounts in @accountArray into @accounts */
             INSERT INTO @accounts
             SELECT value FROM CSVToInt(@accountArray)

             /* Error if there are no accounts */
	 IF (@@ROWCOUNT =  0)
	    BEGIN
	      SET @status = -5
	      ROLLBACK
	      RETURN 
	    END

              /* Error if there are duplicate accounts in @accounts */
	  IF (EXISTS (SELECT id_acc 
	                   FROM @accounts
		       GROUP BY id_acc
		       HAVING COUNT(id_acc) > 1))
	      BEGIN
	         SET @status = -6
	         ROLLBACK
	         RETURN 
	      END

              /* Error if the accounts in @accounts are not a member of @unassignedAccounts */
                IF (EXISTS (SELECT id_acc 
                               FROM @accounts acc
                               WHERE id_acc NOT IN (SELECT id_acc FROM @unassignedAccounts)))
                  BEGIN
	         SET @status = -7
	         ROLLBACK
	         RETURN 
	      END
        END  -- end ELSE

   /* Insert row into t_billgroup_tmp */
   INSERT t_billgroup_tmp  (id_materialization, tx_name, tx_description) 
     VALUES (@id_materialization, @tx_name, @tx_description)

   /* Insert rows into t_billgroup_member_tmp */
   INSERT INTO t_billgroup_member_tmp (id_materialization, tx_name, id_acc)
   SELECT @id_materialization, @tx_name, acc.id_acc
   FROM @accounts acc 

   SET @status = 0
   COMMIT   
         