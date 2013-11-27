
			UPDATE 
			/* Query Tag: __UPDATE_ROLE__ */
			t_role 
			SET 
			tx_name=N'%%NAME%%',
			tx_desc=N'%%DESC%%',
			csr_assignable = N'%%CSR%%', 
			subscriber_assignable = N'%%SUBSCRIBER%%'
			WHERE id_role= %%ID%%
    	