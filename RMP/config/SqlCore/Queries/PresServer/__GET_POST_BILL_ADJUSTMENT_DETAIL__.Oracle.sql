
SELECT DISTINCT
                /* __GET_POST_BILL_ADJUSTMENT_DETAIL__ */
                au.amount AS unadjustedamount, 
                adj.compoundpostbillfedtaxadjamt, 
                adj.compoundpostbillstatetaxadjamt,
                adj.compoundpostbillcntytaxadjamt, 
                adj.compoundpostbilllocaltaxadjamt,
                adj.compoundpostbillothertaxadjamt, 
                adj.compoundprebillfedtaxadjamt, 
                adj.compoundprebillstatetaxadjamt,
                adj.compoundprebillcntytaxadjamt, 
                adj.compoundprebilllocaltaxadjamt, 
                adj.compoundprebillothertaxadjamt,
                adj.postbilladjamt AS adjustmentamount,
                au.amount + adj.postbilladjamt AS adjustedamount,
                  adj.postbilladjamt
                + adj.atomicpostbillfedtaxadjamt
                + adj.atomicpostbillstatetaxadjamt
                + adj.atomicpostbillcntytaxadjamt
                + adj.atomicpostbilllocaltaxadjamt
                + adj.atomicpostbillothertaxadjamt AS adjustmentamountwithtax,
                ajt.id_reason_code reasoncode, 
                NVL (ajtemplatedesc.tx_desc, N'') AS "AdjustmentTemplateDisplayName",
                NVL (ajinstancedesc.tx_desc, N'') AS "AdjustmentInstanceDisplayName",
                CASE
                    WHEN (rcbp.nm_name IS NULL OR rcbp.nm_name = N' ') THEN N''
                    ELSE rcbp.nm_name
                END AS reasoncodename, CASE
                    WHEN (rcbp.nm_desc IS NULL OR rcbp.nm_desc = N' ') THEN N''
                    ELSE rcbp.nm_desc
                END AS reasoncodedescription,
                CASE
                    WHEN (rcdesc.tx_desc IS NULL OR rcdesc.tx_desc = N' ') THEN N''
                    ELSE rcdesc.tx_desc
                END AS reasoncodedisplayname, 
                NVL (ajt.tx_desc, N'') AS description,
                ajt.id_adj_trx AS adjustmenttransactionid
           FROM t_adjustment_transaction ajt INNER JOIN vw_adjustment_details adj ON ajt.id_sess = adj.id_sess
                INNER JOIN t_acc_usage au ON ajt.id_sess = au.id_sess
                INNER JOIN t_base_props ajtemplatebp ON ajt.id_aj_template = ajtemplatebp.id_prop
                LEFT OUTER JOIN t_description ajtemplatedesc ON ajtemplatebp.n_display_name = ajtemplatedesc.id_desc
                LEFT OUTER JOIN t_base_props ajinstancebp ON ajt.id_aj_instance = ajinstancebp.id_prop
                LEFT OUTER JOIN t_description ajinstancedesc ON ajinstancebp.n_display_name = ajinstancedesc.id_desc
                LEFT OUTER JOIN t_description des2 ON des2.id_lang_code = ajtemplatedesc.id_lang_code
                                                 AND des2.id_desc = ajinstancebp.n_display_name
                LEFT OUTER JOIN t_description des3 ON des3.id_lang_code = ajinstancedesc.id_lang_code
                                                 AND des3.id_desc = ajtemplatebp.n_display_name
                /* resolve adjustment reason code name */
                INNER JOIN t_base_props rcbp ON ajt.id_reason_code = rcbp.id_prop
                INNER JOIN t_description rcdesc ON rcbp.n_display_name = rcdesc.id_desc
                                              AND NVL (ajinstancedesc.id_lang_code, ajtemplatedesc.id_lang_code) = rcdesc.id_lang_code
          WHERE ajt.c_status = 'A'
            AND (   ajtemplatedesc.id_lang_code = ajinstancedesc.id_lang_code
                 OR des2.id_lang_code IS NULL
                 OR des3.id_lang_code IS NULL
                )
            AND ajt.id_acc_payer = %%ID_ACC%%
            AND ajt.id_usage_interval = %%ID_INTERVAL%%
            /* realated to CR 9739: only return postbill adjustments

             IsPostbillADjusted flag doesn't really do it */
            AND ajt.n_adjustmenttype = 1
            /* TODO: pass lang code into query */
            AND NVL (ajinstancedesc.id_lang_code, ajtemplatedesc.id_lang_code) = %%LANG_CODE%%
			 