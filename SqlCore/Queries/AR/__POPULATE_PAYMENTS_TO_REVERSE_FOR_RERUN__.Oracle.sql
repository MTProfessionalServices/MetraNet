    
	  BEGIN    
		FOR DATA IN (SELECT 'X' FROM USER_TABLES WHERE UPPER(TABLE_NAME) = UPPER('tmp_ARReverse'))
		LOOP
			exec_ddl( 'DROP TABLE tmp_ARReverse');
			EXIT;
		END LOOP;
		exec_ddl( q'[CREATE TABLE tmp_ARReverse AS 
			SELECT
			  pv.id_sess as ID,
			  (case when b.tx_name is null then pv.c_ARBatchID else b.tx_name end) as BatchID,
			  am.ExtNamespace as Namespace
		  FROM t_pv_payment pv
			JOIN t_acc_usage au ON pv.id_sess = au.id_sess
			LEFT OUTER JOIN t_batch b ON b.tx_batch = au.tx_batch AND tx_namespace = '%%BATCH_NAME_SPACE%%'
			JOIN %%RERUN_TABLE_NAME%% rr ON pv.id_sess = rr.id_sess
			INNER JOIN vw_ar_acc_mapper am ON am.id_acc = au.id_acc
		  WHERE rr.tx_state = 'A'
			  AND pv.c_ARBatchID IS NOT NULL]');
	  END;
