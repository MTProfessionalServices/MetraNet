
          CREATE OR REPLACE PACKAGE BODY mt_ttt
AS
   FUNCTION get_tx_id (p_create_transaction BOOLEAN := FALSE)
      RETURN VARCHAR2
   IS
      l_local_tx_id    dba_2pc_pending.local_tran_id%TYPE    DEFAULT NULL;
      l_global_tx_id   dba_2pc_pending.global_tran_id%TYPE   DEFAULT NULL;
      /* Use the largest possible size for the return value */
      l_tx_id          dba_2pc_pending.global_tran_id%TYPE   DEFAULT NULL;
   BEGIN
      l_local_tx_id :=
                 DBMS_TRANSACTION.local_transaction_id (p_create_transaction);

      IF l_local_tx_id IS NOT NULL
      THEN
         BEGIN
            SELECT global_tran_id
              INTO l_global_tx_id
              FROM dba_2pc_pending
             WHERE local_tran_id = l_local_tx_id;

            l_tx_id := l_global_tx_id;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               l_tx_id := l_local_tx_id;
         END;
      END IF;

      RETURN l_tx_id;
   END get_tx_id;
END mt_ttt;
				