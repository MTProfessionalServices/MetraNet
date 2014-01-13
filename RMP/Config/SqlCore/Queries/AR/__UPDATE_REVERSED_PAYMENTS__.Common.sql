    
          UPDATE t_pv_Payment
          SET c_ARBatchID = NULL
          FROM  t_pv_Payment pv
          JOIN tmp_ARReverse tmp ON tmp.ID = pv.id_sess
        