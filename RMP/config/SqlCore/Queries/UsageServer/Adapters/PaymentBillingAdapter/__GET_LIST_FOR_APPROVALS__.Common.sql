
			SELECT 
				bg.id_acc as c__accountID,
				id_interval as c__intervalID
			FROM 
				t_invoice i
				inner join t_billgroup_member bg
				on i.id_acc = bg.id_acc and bg.id_billgroup = %%ID_BILLGROUP%%
				inner join t_av_internal av
				on i.id_interval = %%INTERVAL_ID%% and i.id_acc = av.id_acc
      