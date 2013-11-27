
/* ===========================================================
   Returns the ancestor (root parent) for a given id_billing_group
=========================================================== */
CREATE FUNCTION GetBillingGroupAncestor
(
   @id_current_billgroup INT
)
RETURNS INT
AS

BEGIN

   DECLARE @id_parent_billgroup INT
   DECLARE @loopCounter INT
   SET @loopCounter = 0

   WHILE (@loopCounter = 0)
      BEGIN
          SET @id_parent_billgroup = (SELECT id_parent_billgroup /*parent*/
	                                           FROM t_billgroup
	                                           WHERE id_billgroup = @id_current_billgroup) 
          IF (@id_parent_billgroup IS NULL)
             BEGIN
                 BREAK 
             END
         ELSE
             BEGIN
                 SET @id_current_billgroup = @id_parent_billgroup
             END
      END -- WHILE

   RETURN @id_current_billgroup

END
   