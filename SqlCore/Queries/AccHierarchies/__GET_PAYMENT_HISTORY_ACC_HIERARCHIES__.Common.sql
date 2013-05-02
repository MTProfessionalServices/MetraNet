
        select id_payer,id_payee,vt_start,vt_end,c_folder,
        namemap.displayname displayname
        from t_payment_redirection
        INNER JOIN vw_mps_or_system_acc_mapper namemap on namemap.id_acc = t_payment_redirection.id_payer
				INNER JOIN t_av_internal tav on tav.id_acc = t_payment_redirection.id_payer
        where id_payee = %%ID_ACC%%
        order by vt_start,vt_end
			