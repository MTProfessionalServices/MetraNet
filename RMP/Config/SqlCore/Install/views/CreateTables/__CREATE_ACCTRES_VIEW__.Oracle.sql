
CREATE OR REPLACE VIEW t_vw_acctres (id_acc,
                                     nm_login,
                                     nm_space,
                                     payer_id_usage_cycle,
                                     c_pricelist,
                                     id_payer,
                                     payer_start,
                                     payer_end,
                                     status,
                                     state_start,
                                     state_end,
                                     currency
                                    )
AS
   SELECT amap.id_acc, amap.nm_login, amap.nm_space, payer_uc.id_usage_cycle,
          avi.c_pricelist, redir.id_payer,
          NVL (redir.vt_start, dbo.mtmindate ()),
          NVL (redir.vt_end, dbo.mtmaxdate ()), ast.status,
          ast.vt_start state_start, ast.vt_end state_end, tav.c_currency
     FROM t_account_mapper amap INNER JOIN t_av_internal avi
          ON avi.id_acc = amap.id_acc
          INNER JOIN t_account_state ast ON ast.id_acc = amap.id_acc
          INNER JOIN t_payment_redirection redir ON redir.id_payee = amap.id_acc
          LEFT OUTER JOIN t_av_internal tav ON tav.id_acc = redir.id_payer
          LEFT OUTER JOIN t_acc_usage_cycle payer_uc
          ON payer_uc.id_acc = redir.id_payer
