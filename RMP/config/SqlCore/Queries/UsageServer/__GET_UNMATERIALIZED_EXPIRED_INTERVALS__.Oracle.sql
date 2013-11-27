
/* ===========================================================
Returns those intervals which have expired and not been materialized and
are not hard closed.
=========================================================== */
SELECT ui.id_interval IntervalID 
FROM table(dbo.GetExpiredIntervals (%%%SYSTEMDATE%%%, 1)) ei
INNER JOIN t_usage_interval ui
   ON ui.id_interval = ei.id
WHERE
   ui.tx_interval_status != 'H' 
   