
				select 
				tg.id_acc,tg.vt_start,tg.vt_end,hierarchyname acc_name
				from 
				t_gsubmember tg
				INNER JOIN vw_hierarchyname vwname on vwname.id_acc = tg.id_acc
				where
				%%REFDATE%% between tg.vt_start AND tg.vt_end AND
				tg.id_acc = %%ACCOUNTID%% AND
				tg.id_group = %%GSUBID%%
			