
        
	BEGIN

			FOR DATA IN (SELECT 'X' FROM USER_TABLES WHERE UPPER(TABLE_NAME) = UPPER('tmp_ARReverse'))
			LOOP
				exec_ddl( 'DROP TABLE tmp_ARReverse');
				EXIT;
			END LOOP;

		exec_ddl( q'[CREATE TABLE tmp_ARReverse AS 
		      SELECT * FROM (SELECT
            pv.id_sess as ID,
            NVL(b.tx_name, '%%AR_BATCH_ID%%') as BatchID,
            am.ExtNamespace as Namespace
            FROM t_pv_ARAdjustment pv
            JOIN t_acc_usage au ON pv.id_sess = au.id_sess
						and au.id_usage_interval=pv.id_usage_interval 
            LEFT OUTER JOIN t_batch b ON b.tx_batch = au.tx_batch AND tx_namespace = '%%BATCH_NAME_SPACE%%'
            INNER JOIN vw_ar_acc_mapper am ON am.id_acc = au.id_acc
            WHERE c_ARBatchID = '%%AR_BATCH_ID%%'
				)  WHERE ROWNUM <= %%SET_SIZE%%]');
	END;
      