
  UPDATE t_pv_Payment pv
  SET c_ARBatchID = '%%BATCH_ID%%'
  WHERE EXISTS (
    SELECT 'X' FROM  tmp_ARPayments pm 
    WHERE pm.PaymentID = '%%ID_PREFIX%%' + cast(pv.id_sess as varchar(100)))
        