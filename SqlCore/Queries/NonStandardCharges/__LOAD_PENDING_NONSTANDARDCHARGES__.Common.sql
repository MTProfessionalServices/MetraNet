
            select pv.* from t_pv_NonStandardChargeRequest pv
            where c_Status = 'P'
            and id_sess in (%%SESSION_IDS%%)
      