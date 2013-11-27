
      
	BEGIN

			FOR DATA IN (SELECT 'X' FROM USER_TABLES WHERE UPPER(TABLE_NAME) = UPPER('tmp_ARReverse'))
			LOOP
				exec_ddl( 'DROP TABLE tmp_ARReverse');
				EXIT;
			END LOOP;

		exec_ddl( q'[CREATE TABLE tmp_ARReverse AS 
		      SELECT * FROM (SELECT
            adj.id_adj_trx as ID,
            CASE WHEN adj.AdjustmentAmount < 0 THEN 'Credit' ELSE 'Debit' END as Type,
            '%%AR_BATCH_ID%%' as BatchID,
            am.ExtNamespace as Namespace
            FROM t_adjustment_transaction adj
            INNER JOIN vw_ar_acc_mapper am ON am.id_acc = adj.id_acc_payer
            WHERE ARBatchID = '%%AR_BATCH_ID%%'
				)  WHERE ROWNUM <= %%SET_SIZE%%]');

      END;
      