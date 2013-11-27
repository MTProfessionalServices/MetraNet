
		        Select		id_template
				from 		t_pi_template %%UPDLOCK%%
				where 	id_template_parent = %%TEMPL_ID%%
		    