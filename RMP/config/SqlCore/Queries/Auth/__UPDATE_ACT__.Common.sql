
				UPDATE 
				/* Query Tag: __UPDATE_ACT__ */
				t_atomic_capability_type
				SET tx_name=N'%%NAME%%',tx_desc=N'%%DESC%%',tx_progid=N'%%PROGID%%',
				tx_editor=N'%%EDITOR%%'
				WHERE id_cap_type = %%ID%%
    	