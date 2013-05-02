    
          UPDATE t_pv_ARAdjustment
          SET c_ARBatchID = NULL
          FROM  t_pv_ARAdjustment pv
          JOIN tmp_ARReverse tmp ON tmp.ID = pv.id_sess
        