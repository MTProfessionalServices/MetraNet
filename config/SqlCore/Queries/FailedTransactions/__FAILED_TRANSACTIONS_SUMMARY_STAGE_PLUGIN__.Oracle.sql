
		select
			RAWTOHEX(SYS_GUID()) as UniqueId, 
			tx_StageName StageName, 
			tx_PlugIn Plugin,
			COUNT(*) as Count
		from 
		  t_failed_transaction 
		where 
		  State in ('N','I', 'C')
		group by tx_StageName, tx_Plugin
		order by Count desc