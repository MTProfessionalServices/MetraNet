
CREATE OR REPLACE
PROCEDURE UpdIntervalBlockedForNewAccts
(
   p_id_interval INT
)
AS
BEGIN

  UPDATE t_usage_interval 
  SET tx_interval_status = 'B'
  WHERE id_interval = p_id_interval 
    AND tx_interval_status != 'H';

END UpdIntervalBlockedForNewAccts;
         