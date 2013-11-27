
        select id_payer,id_payee,vt_start,vt_end,tt_start,tt_end,
        namemap.displayname displayname
        from t_payment_redir_history
        INNER JOIN vw_mps_or_system_acc_mapper namemap on namemap.id_acc = t_payment_redir_history.id_payer
        where id_payee = %%ID_ACC%%
        order by vt_start,vt_end
			