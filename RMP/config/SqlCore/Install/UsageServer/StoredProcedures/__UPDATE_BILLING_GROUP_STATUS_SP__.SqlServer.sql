
/* ===========================================================
Updates the status for the accounts associated with the specified billing group 
to the specified status. The updates are recorded in t_acc_usage_interval.
===========================================================*/
CREATE PROCEDURE UpdateBillingGroupStatus
(
   @id_billing_group INT,
   @status VARCHAR(1) 
)
AS

UPDATE aui SET aui.tx_status = @status
FROM t_acc_usage_interval aui 
INNER JOIN t_billgroup_member bgm 
   ON bgm.id_acc = aui.id_acc 
INNER JOIN t_billgroup bg 
   ON bg.id_billgroup = bgm.id_billgroup AND
         bg.id_usage_interval = aui.id_usage_interval
WHERE
    bg.id_billgroup = @id_billing_group
         
         