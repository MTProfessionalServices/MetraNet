
      BEGIN
			FOR DATA IN (SELECT 'X' FROM USER_TABLES WHERE UPPER(TABLE_NAME) = UPPER('tmp_PBAdjustments'))
			LOOP
				exec_ddl( 'DROP TABLE tmp_PBAdjustments' );
				EXIT;
			END LOOP;

			exec_ddl( q'[CREATE TABLE tmp_PBAdjustments AS
			SELECT * FROM (
				SELECT '%%ID_PREFIX%%' + TO_CHAR(adj.id_adj_trx) as AdjustmentID,
				  CASE WHEN (adj.AdjustmentAmount+adj.aj_tax_federal+adj.aj_tax_state+adj.aj_tax_county+adj.aj_tax_local+adj.aj_tax_other) < 0 THEN 'Credit' ELSE 'Debit' END as Type,
				  '%%DEF_BATCH_ID%%' as BatchID,
				  adj.tx_desc as Description,
				  adj.dt_modified as AdjustmentDate,
				  am.ExtAccount as ExtAccountID,
				  /* CASE WHEN adj.AdjustmentAmount < 0 THEN -adj.AdjustmentAmount ELSE adj.AdjustmentAmount END as Amount, */
			    ABS(adj.AdjustmentAmount+adj.aj_tax_federal+adj.aj_tax_state+adj.aj_tax_county+adj.aj_tax_local+adj.aj_tax_other) as Amount,
      	  au.am_currency as Currency
				FROM t_adjustment_transaction adj
				JOIN t_acc_usage au ON adj.id_sess = au.id_sess
				INNER JOIN vw_ar_acc_mapper am ON am.id_acc = adj.id_acc_payer 
            and UPPER(am.ExtNamespace) = UPPER('%%ACC_NAME_SPACE%%')
				WHERE ARBatchID IS NULL
				  AND adj.c_status = 'A' /* approved */
				  AND n_adjustmenttype = 1 /* postbill */
			)
			WHERE ROWNUM <= %%SET_SIZE%%]');
		END;
        