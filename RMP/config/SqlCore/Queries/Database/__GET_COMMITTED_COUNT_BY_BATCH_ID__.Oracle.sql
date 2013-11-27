
SELECT   stats.successes + stats.errors committed_count,
         stats.successes success_count,
         stats.errors error_count
FROM
   (SELECT  NVL((SELECT batch.n_completed
                 FROM t_batch batch
                 WHERE tx_batch = hextoraw(ltrim('%%VARBIN_BATCH_ID%%', '0Xx'))), 0) successes,
            (SELECT COUNT(error.id_failed_transaction)
             FROM t_failed_transaction error 
             WHERE error.tx_batch_encoded = '%%STRING_BATCH_ID%%') errors
    FROM dual) stats
 