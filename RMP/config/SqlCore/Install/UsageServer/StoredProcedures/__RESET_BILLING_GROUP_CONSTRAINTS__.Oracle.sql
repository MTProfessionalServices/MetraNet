
/* ===========================================================
Delete the existing constraints for the given interval from t_billgroup_constraint
Copy the constraints from t_billgroup_constraint_tmp to t_billgroup_constraint

Returns:
-1 if an unknown error has occurred
============================================================== */
CREATE OR REPLACE
PROCEDURE ResetBillingGroupConstraints
(
   p_id_usage_interval INT,
   status out INT
)
AS

BEGIN 
  
  /* initialize @status to failure (-1) */
  status := -1;
  
  /* delete previous constraint data for this interval */
  DELETE 
  FROM t_billgroup_constraint
  WHERE id_usage_interval = p_id_usage_interval;
  
  /* copy data from t_billgroup_constraint_tmp to t_billgroup_constraint */
  INSERT INTO t_billgroup_constraint (id_usage_interval, id_group, id_acc)
  SELECT p_id_usage_interval, 
        id_group,
        id_acc
  FROM t_billgroup_constraint_tmp 
  WHERE id_usage_interval =  p_id_usage_interval ;
  
  status := 0;
  
END ResetBillingGroupConstraints;
 