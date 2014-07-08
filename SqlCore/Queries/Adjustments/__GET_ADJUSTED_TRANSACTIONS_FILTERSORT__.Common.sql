SELECT /*+ INDEX(am1 t_account_mapper_idx1) INDEX(am2 t_account_mapper_idx1) INDEX(tbp t_base_props_pk) INDEX(postbillajs idx_adj_trx_id_sess_c_status) INDEX(prebillajs idx_adj_trx_id_sess_c_status) */ 
       ad.dt_crt, /* default sort field */ 
       /* Using column order in GetAdjustedTransactions to make visual matchup easier */ 
       tbp.nm_display_name AS PITemplateDisplayName, 
       ad.dt_crt AS AdjustmentCreationDate, 
       ad.c_status AS Status, 
       au.amount AS Amount, 
       ad.tx_desc AS Description, 
       CASE WHEN (postbillajs.c_status = 'P') THEN postbillajs.AdjustmentAmount ELSE 0 END 
          AS PendingPostbillAdjAmt, 
       CASE WHEN (prebillajs.c_status = 'P') THEN prebillajs.AdjustmentAmount ELSE 0 END 
          AS PendingPrebillAdjAmt, 
       CASE WHEN (postbillajs.c_status = 'A') THEN postbillajs.AdjustmentAmount ELSE 0 END 
          AS PostbillAdjAmt, 
       CASE WHEN (prebillajs.c_status = 'A') THEN prebillajs.AdjustmentAmount ELSE 0 END 
          AS PrebillAdjAmt, 
       ad.id_sess AS SessionId, 
       am2.nm_login AS UserNamePayee, 
       am1.nm_login AS UserNamePayer, 
       au.id_parent_sess AS ParentSessionId 
  FROM t_adjustment_transaction ad 
          /* NOTE: id_usage_interval is the adjustment interval, and NOT the usage interval! */ 
       /* So, we can only use id_sess to join usage, and thus need to scan partitions.    */ 
       INNER JOIN t_acc_usage au ON au.id_sess = ad.id_sess 
       INNER JOIN t_account_mapper am1 ON ad.id_acc_payer = am1.id_acc 
       INNER JOIN t_namespace ns1 ON %%%UPPER%%%(ns1.nm_space) = %%%UPPER%%%(am1.nm_space) AND %%%UPPER%%%(ns1.tx_typ_space) = %%%UPPER%%%('system_mps') 
       INNER JOIN t_acc_usage_interval taui  
          ON au.id_usage_interval = taui.id_usage_interval AND au.id_acc = taui.id_acc 
       INNER JOIN t_account_mapper am2 ON au.id_payee = am2.id_acc 
       INNER JOIN t_namespace ns2 ON %%%UPPER%%%(ns2.nm_space) = %%%UPPER%%%(am2.nm_space) AND %%%UPPER%%%(ns2.tx_typ_space) = %%%UPPER%%%('system_mps') 
       INNER JOIN t_base_props tbp ON au.id_pi_template = tbp.id_prop 
       INNER JOIN t_description ajdesc ON %%%UPPER%%%(ajdesc.id_desc) = %%%UPPER%%%(tbp.n_display_name) AND ajdesc.id_lang_code = %%ID_LANG%% 
       LEFT OUTER JOIN t_adjustment_transaction prebillajs 
          ON     prebillajs.id_sess = ad.id_sess 
             AND %%%UPPER%%%(prebillajs.c_status) IN ('A', 'P') 
             AND prebillajs.n_adjustmenttype = 0 
       LEFT OUTER JOIN t_adjustment_transaction postbillajs 
          ON     postbillajs.id_sess = ad.id_sess 
             AND %%%UPPER%%%(postbillajs.c_status) IN ('A', 'P') 
             AND postbillajs.n_adjustmenttype = 1 
       LEFT OUTER JOIN t_acc_usage_interval postbillaui  
          ON postbillajs.id_usage_interval = postbillaui.id_usage_interval AND postbillajs.id_acc_payer = postbillaui.id_acc 
       LEFT OUTER JOIN t_adjustment_type postbillajtype ON postbillajtype.id_prop = postbillajs.id_aj_type 
 WHERE  %%%UPPER%%%(ad.c_status) IN ('A', 'P') 
        /* Usage interval must be open except for a Postbill adjustment */ 
        AND (taui.tx_status  = 'O' OR 
             taui.tx_status != 'O' AND ad.n_adjustmenttype = 1) 
        /* CanManage must also be Y */ 
        AND ( (CASE 
                 WHEN (postbillajs.id_adj_trx IS NOT NULL) 
                 THEN 
                    /* CR 11775: we want to allow adjustment management 
                       if adjustment is pending but interval is hard closed */ 
                    (CASE 
                        WHEN (   postbillaui.tx_status IN ('C') 
                              OR (postbillaui.tx_status = 'H' AND %%%UPPER%%%(postbillajs.c_status) = 'A') 
                              OR postbillajtype.n_adjustmenttype = 4) 
                        THEN 
                           'N' 
                        ELSE 
                           'Y' 
                     END) 
                 ELSE 
                    (CASE 
                        WHEN (prebillajs.id_adj_trx IS NOT NULL) 
                        THEN 
                           (CASE WHEN taui.tx_status IN ('C', 'H') THEN 'N' ELSE 'Y' END) 
                        ELSE 
                           'N' 
                     END) 
              END) = 'Y')  