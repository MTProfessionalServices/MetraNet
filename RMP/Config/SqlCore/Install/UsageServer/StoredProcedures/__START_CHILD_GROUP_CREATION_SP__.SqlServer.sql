
/* ===========================================================
1) Parses the comma separated account identifiers (@accountArray) using the user defined function 'CSVToInt'
2) Validates that there are no duplicate accounts in @accountArray
3) Validates that the accounts are from the parent billing group (id_parent_billgroup)
4) Inserts name and description into t_billgroup_tmp
5) Inserts user specified account ids into  t_billgroup_member_tmp

Returns the following error codes:
   -1 : Unknown error occurred
   -2 : No accounts in @accountArray
   -3 : Duplicate accounts in @accountArray 
   -4 : Account(s) in @accountArray not a member of id_parent_billgroup 
   -5 : Accounts in @accounts are all the member accounts of id_parent_billgroup

=========================================================== */
CREATE PROCEDURE StartChildGroupCreation
(
   @id_materialization INT,
   @tx_name NVARCHAR(50),
   @tx_description NVARCHAR(200),
   @id_parent_billgroup INT,
   @accountArray VARCHAR(4000),
   @status INT OUTPUT
)
AS
   BEGIN TRAN
   
   SET @status = -1
 
   /* Hold the user specified account id's in @accountArray */
   DECLARE @accounts TABLE
   ( 
      id_acc INT NOT NULL
   )

  /* Insert the accounts in @accountArray into @accounts */
  INSERT INTO @accounts
  SELECT value FROM CSVToInt(@accountArray)
   
  /* Error if there are no accounts */
  IF (@@ROWCOUNT =  0)
    BEGIN
      SET @status = -2
      ROLLBACK
      RETURN 
    END

   /* Error if there are duplicate accounts in @accounts */
    IF (EXISTS (SELECT id_acc 
                     FROM @accounts
	         GROUP BY id_acc
	         HAVING COUNT(id_acc) > 1))
      BEGIN
         SET @status = -3
         ROLLBACK
         RETURN 
      END

   /* Error if the accounts in @accounts are not a member of id_parent_billgroup */
    IF (EXISTS (SELECT id_acc 
                    FROM @accounts 
                    WHERE id_acc NOT IN (SELECT id_acc
                                         FROM t_billgroup_member
                                         WHERE id_billgroup = @id_parent_billgroup)))
      BEGIN
         SET @status = -4
         ROLLBACK
         RETURN 
      END
   
   /* Error if the accounts in @accounts are all the member accounts of id_parent_billgroup */
   IF ( (SELECT COUNT(id_acc) 
         FROM t_billgroup_member
         WHERE id_billgroup = @id_parent_billgroup) 
         =
         (SELECT COUNT(bgm.id_acc) 
          FROM t_billgroup_member bgm
          INNER JOIN @accounts acc ON acc.id_acc = bgm.id_acc
          WHERE bgm.id_billgroup = @id_parent_billgroup) )
      BEGIN
         SET @status = -5
         ROLLBACK
         RETURN 
      END
   
   /* Insert row into t_billgroup_tmp */
   INSERT t_billgroup_tmp  (id_materialization, tx_name, tx_description) 
     VALUES (@id_materialization, @tx_name, @tx_description)

   /* Insert rows into t_billgroup_member_tmp */
   INSERT INTO t_billgroup_member_tmp (id_materialization, tx_name, id_acc)
   SELECT @id_materialization, @tx_name, acc.id_acc
   FROM @accounts acc 

   SET @status = 0
   COMMIT
   
         