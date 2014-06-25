
CREATE OR REPLACE PACKAGE mt_ttt
 AS
   FUNCTION get_tx_id (p_create_transaction BOOLEAN := FALSE)
      RETURN VARCHAR2;

   g_tx_id   dba_2pc_pending.global_tran_id%TYPE DEFAULT NULL;
END mt_ttt;