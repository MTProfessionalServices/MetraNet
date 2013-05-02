
				SELECT 
          t_account_state.id_acc id_acc,status,tav.c_folder folder
				FROM
				  t_account_state 
          INNER JOIN t_av_internal tav on tav.id_acc = t_account_state.id_acc
				WHERE 
				  t_account_state.id_acc in (%%ACCOUNTS%%) AND
          %%REFDATE%% between vt_start AND vt_end
			