
/* ===========================================================
Updates the status for the specified interval to 'B' (if the existing status is not 'H')
meaning that no new accounts will be mapped to this interval.
===========================================================*/
CREATE PROCEDURE UpdIntervalBlockedForNewAccts
(
   @id_interval INT
)
AS

BEGIN
  UPDATE t_usage_interval 
  SET tx_interval_status = 'B'
  WHERE id_interval = @id_interval AND
              tx_interval_status != 'H'
END
 
         