
/* ===========================================================
   Returns the list of servers that have promised a heartbeat
   which has not been received. Intentionally uses the database
   time to avoid time conflicts between servers.
   See BillingServerRecordHeartbeat stored procedure for more
   details.
   =========================================================== */
  SELECT *
  FROM t_billingserver_service bss
       LEFT JOIN
          t_billingserver bs
       ON bss.id_billingserver = bs.id_billingserver
 WHERE tt_nextheartbeatpromised < SYSDATE AND tt_end IS NULL