
				select
          accname.displayname,
					pr.id_payer,
					pr.id_payee,
					pr.vt_start,
					pr.vt_end,
					tav.c_folder
					from t_payment_redirection pr
          LEFT OUTER JOIN VW_MPS_ACC_MAPPER accname on pr.id_payee = accname.id_acc
					INNER JOIN t_av_internal tav on tav.id_acc = pr.id_payee
          where id_payer = %%ID_PAYER%%
          order by pr.vt_start,pr.vt_end
			