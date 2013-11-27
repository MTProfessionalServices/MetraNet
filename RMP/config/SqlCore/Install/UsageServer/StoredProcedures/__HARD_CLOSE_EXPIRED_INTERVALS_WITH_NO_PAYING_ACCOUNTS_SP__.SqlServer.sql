
/* ===========================================================
Update the status of the given interval to 'H', if all the accounts for that
interval in t_acc_usage_interval are 'H'
=========================================================== */
CREATE PROCEDURE HardCloseExpiredIntervals_npa
(
   @dt_now DATETIME,
   @n_count INT OUTPUT
)
AS

BEGIN

-- Initialize @n_count
SET @n_count = 0

UPDATE ui
SET tx_interval_status = 'H'
FROM t_usage_interval ui 
INNER JOIN dbo.GetExpiredIntervals (@dt_now, 1) ei -- expired, non-materialized intervals
   ON ei.id_interval = ui.id_interval
WHERE NOT EXISTS (SELECT 1                                    -- no paying accounts
                                FROM vw_paying_accounts pa
                                WHERE pa.IntervalID = ui.id_interval) AND
ui.tx_interval_status <> 'H'
 
SET @n_count = @@ROWCOUNT

END
   