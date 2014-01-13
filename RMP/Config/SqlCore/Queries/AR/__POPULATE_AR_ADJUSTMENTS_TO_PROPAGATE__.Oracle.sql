
        BEGIN
			FOR DATA IN (SELECT 'X' FROM USER_TABLES WHERE UPPER(TABLE_NAME) = UPPER('tmp_ARAdjustments'))
			LOOP
				exec_ddl( 'DROP TABLE TMP_ARADJUSTMENTS' );
				EXIT;
			END LOOP;

			exec_ddl( q'[CREATE TABLE tmp_ARAdjustments AS
			SELECT * FROM (
			  SELECT '%%ID_PREFIX%%' || TO_CHAR(pv.id_sess) as AdjustmentID,
			    CASE WHEN au.amount < 0 THEN 'Credit' ELSE 'Debit' END as Type,
			    NVL(b.tx_name, '%%DEF_BATCH_ID%%') as BatchID,
			    pv.c_Description as Description,
			    pv.c_EventDate as AdjustmentDate,
			    am.ExtAccount as ExtAccountID,
			    CASE WHEN au.amount < 0 THEN -au.amount ELSE au.amount END as Amount,
			    au.am_currency as Currency
		    FROM t_pv_ARAdjustment pv
  			JOIN t_acc_usage au ON pv.id_sess = au.id_sess
	    		and au.id_usage_interval=pv.id_usage_interval
			  INNER JOIN vw_ar_acc_mapper am ON am.id_acc = au.id_acc 
            and UPPER(am.ExtNamespace) = UPPER('%%ACC_NAME_SPACE%%')
			  LEFT OUTER JOIN t_batch b ON b.tx_batch = au.tx_batch 
           AND UPPER(tx_namespace) = UPPER('%%BATCH_NAME_SPACE%%')
		      WHERE c_ARBatchID IS NULL
			AND pv.c_Source <> 'AR'
			)
			WHERE ROWNUM <= %%SET_SIZE%%]');
		END;
      