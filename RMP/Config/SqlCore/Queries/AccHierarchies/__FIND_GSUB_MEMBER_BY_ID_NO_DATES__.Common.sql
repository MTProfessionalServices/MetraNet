
				select 
				tg.id_acc,tg.vt_start,tg.vt_end,hierarchyname acc_name
				from 
				t_gsubmember tg
				INNER JOIN vw_hierarchyname vwname on vwname.id_acc = tg.id_acc
				where
				tg.id_acc = @id_acc AND
				tg.id_group = @id_group
			