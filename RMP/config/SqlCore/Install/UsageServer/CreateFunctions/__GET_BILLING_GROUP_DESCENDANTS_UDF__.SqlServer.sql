
/* ===========================================================
   Returns the descendants for a given id_billing_group
=========================================================== */
CREATE FUNCTION GetBillingGroupDescendants
(
   @id_billgroup_current INT
)
RETURNS @retDescendants TABLE (id_billgroup INT)
AS

BEGIN

   DECLARE @level INT, @id_billgroup_descendant INT
   DECLARE @results TABLE (id_billgroup INT)
   DECLARE @stack TABLE (id_billgroup INT, level INT)
   INSERT INTO @stack VALUES (@id_billgroup_current, 1)
   SELECT @level = 1

   WHILE @level > 0
      BEGIN
         IF EXISTS (SELECT * FROM @stack WHERE level = @level)
            BEGIN
	    SELECT @id_billgroup_current = id_billgroup
	    FROM @stack
	    WHERE level = @level
                    
                IF @level > 1
                   BEGIN
                      INSERT @results VALUES (@id_billgroup_current)
                   END
   	    
                DELETE FROM @stack
	    WHERE level = @level AND id_billgroup = @id_billgroup_current
	         
                INSERT @stack
	    SELECT id_billgroup /*child*/, @level + 1
	    FROM t_billgroup
	    WHERE id_parent_billgroup = @id_billgroup_current
	        
                IF @@ROWCOUNT > 0
	    SELECT @level = @level + 1
	END
        ELSE
	SELECT @level = @level - 1
    END -- WHILE

    INSERT @retDescendants
    SELECT id_billgroup 
    FROM @results
    RETURN

END
   