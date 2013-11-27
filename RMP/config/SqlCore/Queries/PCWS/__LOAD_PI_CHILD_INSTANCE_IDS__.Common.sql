
		        Select		id_pi_instance 
				from 		t_pl_map %%UPDLOCK%%
				where 	id_pi_instance_parent = %%PI_ID%% and id_paramtable is null
		    