
/* ===========================================================
Updates the status for all expired, non-materialized intervals to 'B' 
(if the existing status is not 'H') meaning that no new accounts will 
be mapped to this interval. 
===========================================================*/
CREATE PROCEDURE UpdExpiredIntervalsToBlocked
(
   @dt_now DATETIME,
   @n_count INT OUTPUT
)
AS

BEGIN

-- Initialize @n_count
SET @n_count = 0

UPDATE ui
SET tx_interval_status = 'B'
FROM t_usage_interval ui 
INNER JOIN dbo.GetExpiredIntervals (@dt_now, 1) ei
   ON ei.id_interval = ui.id_interval
WHERE
   ui.tx_interval_status = 'O' 

SET @n_count = @@ROWCOUNT

END
 
         