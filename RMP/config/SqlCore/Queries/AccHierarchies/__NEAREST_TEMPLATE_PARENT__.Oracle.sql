
				select * from 
				(select id_ancestor id_ancestor,name.displayname displayname
				from t_account_ancestor 
				INNER JOIN t_acc_template template on template.id_folder = id_ancestor
				INNER JOIN vw_mps_acc_mapper name on name.id_acc = t_account_ancestor.id_ancestor
				where id_descendent = %%ID_ACC%% AND
				%%REFDATE%% between vt_start AND vt_end 
				order by num_generations asc)
				where rownum = 1
				