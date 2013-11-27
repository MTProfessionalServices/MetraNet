
  UPDATE t_pv_ARAdjustment pv
  SET c_ARBatchID = '%%BATCH_ID%%'
  WHERE EXISTS (
    SELECT 'X' FROM  tmp_ARAdjustments tmp 
    WHERE tmp.AdjustmentID = '%%ID_PREFIX%%' + cast(pv.id_sess as varchar(100)))
        