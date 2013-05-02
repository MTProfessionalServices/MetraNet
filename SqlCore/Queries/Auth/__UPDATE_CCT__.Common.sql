
				UPDATE 
				/* Query Tag: __UPDATE_CCT__ */
				t_composite_capability_type
				SET tx_name=N'%%NAME%%',tx_desc=N'%%DESC%%',tx_progid=N'%%PROGID%%',
				tx_editor=N'%%EDITOR%%',csr_assignable=N'%%CSR%%',subscriber_assignable=N'%%SUBSCRIBER%%',
				multiple_instances=N'%%MULTIPLE_INSTANCES%%'
				,umbrella_sensitive=N'%%UMBRELLA%%'
				WHERE id_cap_type = %%ID%%
    	