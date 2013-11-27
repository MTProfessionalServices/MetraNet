
/* ===========================================================
 Validate the following for the given materialization:
   1) The accounts in t_billgroup_source_acc are not repeated
   2) The accounts in t_billgroup_member_tmp are 
        not repeated i.e. each account is matched to exactly 
        one billing group name. 
   3) All accounts in t_billgroup_source_acc are present in t_billgroup_member_tmp
   4) Each billing group has atleast one account.


Returns the following error codes - for the given materialization:
   -1 : Unknown error occurred
   -2 : If there are duplicate accounts in t_billgroup_source_acc 
   -3 : If there are duplicate accounts in t_billgroup_member_tmp 
   -4 : If all accounts in t_billgroup_source_acc are not present in t_billgroup_member_tmp
   -5 : Each billing group in t_billgroup_tmp has atleast one account
   -6 : If there are duplicate billing group names in t_billgroup_tmp
=========================================================== */
CREATE PROCEDURE ValidateBillGroupAssignments
(
   @id_materialization INT,
   @billingGroupsCount INT OUTPUT,
   @status INT OUTPUT
)
AS
   -- initialize @status to unknown error
   SET @status = -1
   SET @billingGroupsCount = 0
   
   -- check for duplicate id_acc in t_billgroup_source_acc
   IF EXISTS (SELECT id_acc 
                   FROM t_billgroup_source_acc
	       WHERE id_materialization = @id_materialization 
	       GROUP BY id_acc
	       HAVING COUNT(id_acc) > 1)
   BEGIN
     SET @status = -2
     RETURN 
   END

   -- check for duplicate id_acc in t_billgroup_member_tmp
   IF EXISTS (SELECT id_acc 
                   FROM t_billgroup_member_tmp
	       WHERE id_materialization = @id_materialization 
	       GROUP BY id_acc
	       HAVING COUNT(id_acc) > 1)
   BEGIN
     SET @status = -3
     RETURN 
   END
   
   -- check that all accounts in t_billgroup_source_acc are present in
   -- t_billgroup_member_tmp
   DECLARE @numJoinAccounts INT
   DECLARE @numOriginalAccounts INT
   
   SET @numJoinAccounts = (SELECT COUNT(bgsa.id_acc) 
			         FROM t_billgroup_source_acc bgsa
			         INNER JOIN t_billgroup_member_tmp bgt 
                                                ON bgt.id_acc = bgsa.id_acc AND
                                                      bgt.id_materialization = bgsa.id_materialization
			         WHERE bgsa.id_materialization = @id_materialization) 

   SET @numOriginalAccounts = (SELECT COUNT(id_acc) 
                                                    FROM t_billgroup_source_acc 
                                                    WHERE id_materialization = @id_materialization) 

    IF (@numJoinAccounts <> @numOriginalAccounts)
    BEGIN
      SET @status = -4
      RETURN 
    END
  
   -- Check that each billing group in t_billgroup_tmp has atleast one account   
    IF EXISTS (SELECT tx_name
	             FROM t_billgroup_tmp 
               WHERE tx_name NOT IN (SELECT tx_name
                                     FROM t_billgroup_member_tmp
                                     WHERE id_materialization = @id_materialization) AND
                     id_materialization = @id_materialization )
   BEGIN
      SET @status = -5
      RETURN 
   END

   -- Check that there are no duplicate billing group names in t_billgroup_member
   IF EXISTS (SELECT tx_name 
                   FROM t_billgroup_tmp
	       WHERE id_materialization = @id_materialization 
	       GROUP BY tx_name
	       HAVING COUNT(tx_name) > 1)
   BEGIN
      SET @status = -6
      RETURN 
   END

   SELECT @billingGroupsCount = COUNT(id_billgroup)
   FROM t_billgroup_tmp
   WHERE id_materialization = @id_materialization

   SET @status = 0
         
         