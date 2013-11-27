
/* ===========================================================
Updates the status for the accounts associated with the specified billing group 
to the specified status. The updates are recorded in t_acc_usage_interval.
===========================================================*/
CREATE OR REPLACE
PROCEDURE UpdateBillingGroupStatus
(
   p_id_billing_group INT,
   p_status VARCHAR2
)
AS

begin

  UPDATE t_acc_usage_interval aui  
    SET aui.tx_status = p_status
  where exists (
    select 1
    FROM t_billgroup_member bgm 
    INNER JOIN t_billgroup bg 
       ON bg.id_billgroup = bgm.id_billgroup 
    WHERE bg.id_billgroup = p_id_billing_group
      and bgm.id_acc = aui.id_acc
       AND bg.id_usage_interval = aui.id_usage_interval);
    
end UpdateBillingGroupStatus;
         