
/* ===========================================================
This query adds extra accounts to the t_billgroup_member_tmp table
in order to satisfy grouping constraints specified in the t_billgroup_constraint table.

For the given id_materialization, the t_billgroup_member_tmp table
contains the mapping of the pull list name to the accounts specified by the user.

For each of the user specified accounts 
  - get the group which it belongs to 
  - get those accounts in the group which do not belong to the set of user specified accounts
  - if any of the accounts obtained above do not belong to the parent billing group 
       then return error
     else 
        add those accounts into t_billgroup_member_tmp if they don't exist.
        (new accounts are added with the b_extra flag set to 1)
             

Returns:
-1 if an unknown error has occurred
-2 one or more accounts needed to satisfy the constraints do not belong to the parent billing group
-3 the parent billing group becomes empty due to constraints
============================================================== */
CREATE PROCEDURE SatisfyConstraintsForPullList
(
   @id_materialization INT,
   @id_parent_billgroup INT,
   @status INT OUTPUT
)
AS

BEGIN 
   -- initialize @status to failure (-1)
   SET @status = -1 

   BEGIN TRAN
  
   /* Store the id_usage_interval */
   DECLARE @id_usage_interval INT
   DECLARE @pullListName NVARCHAR(50)

   SELECT @id_usage_interval = id_usage_interval
   FROM t_billgroup_materialization
   WHERE id_materialization = @id_materialization

   SET @pullListName = (SELECT TOP 1 tx_name
                                      FROM t_billgroup_member_tmp
                                      WHERE id_materialization = @id_materialization)

   DECLARE @groups TABLE (id_group INT NOT NULL)
   DECLARE @accounts TABLE (id_acc INT NOT NULL)

   /* Select the candidate groups based on the user specified accounts
       in t_billgroup_member_tmp for this materialization */
   INSERT @groups
   SELECT bc.id_group
   FROM t_billgroup_member_tmp bgmt
   INNER JOIN t_billgroup_constraint bc
      ON bc.id_acc = bgmt.id_acc
   WHERE bc.id_usage_interval = @id_usage_interval AND
               bgmt.id_materialization = @id_materialization
   
   /* Select the extra accounts */
   INSERT INTO @accounts
   SELECT id_acc
   FROM t_billgroup_constraint
   WHERE id_group IN (SELECT id_group 
                                   FROM @groups) AND
               id_usage_interval = @id_usage_interval AND
               -- do not add accounts that have been specified by the user
               id_acc NOT IN (SELECT id_acc 
                                       FROM t_billgroup_member_tmp
                                       WHERE id_materialization = @id_materialization)      

   /* Error if the accounts in @accounts are not a member of id_parent_billgroup */
    IF (SELECT COUNT(id_acc) FROM @accounts) > 0 AND
        (EXISTS (SELECT id_acc 
                     FROM @accounts 
                     WHERE id_acc NOT IN (SELECT id_acc
                                                         FROM t_billgroup_member
                                                         WHERE id_billgroup = @id_parent_billgroup)))
     
      BEGIN
         SET @status = -2
         ROLLBACK
         RETURN 
      END

   /* Check that not all the accounts of the parent billing group are being pulled out */
   IF ( 
         (SELECT COUNT(id_acc) 
          FROM t_billgroup_member
          WHERE id_billgroup = @id_parent_billgroup) 
          =
          (
             (SELECT COUNT(id_acc) 
              FROM t_billgroup_member_tmp 
              WHERE id_materialization = @id_materialization) 
              +
             (SELECT COUNT(id_acc) 
              FROM @accounts)
          )
       )
      BEGIN
         SET @status = -3
         ROLLBACK
         RETURN 
      END

   /* Add the extra accounts into t_billgroup_member_tmp */
   INSERT INTO t_billgroup_member_tmp(id_materialization, tx_name, id_acc, b_extra)
   SELECT @id_materialization, @pullListName, id_acc, 1
   FROM @accounts
   
   SET @status = 0
   COMMIT
END
 