
      update t_pipeline
			set b_online = '0',
			    b_processing = '0'  /* explicitly resets processing flag in case of shared memory leak (CR13044) */
			where tx_machine = '%%TX_MACHINE%%'
			