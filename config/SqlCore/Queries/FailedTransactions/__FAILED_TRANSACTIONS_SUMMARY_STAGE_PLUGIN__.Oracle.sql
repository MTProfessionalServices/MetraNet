select
  RAWTOHEX(SYS_GUID()) as UniqueId, 
  tx_StageName StageName, 
  tx_PlugIn Plugin,
  COUNT(*) as Count
from 
  t_failed_transaction 
where 
  State in ('N','I', 'C') 
  and (
        (dt_start_resubmit IS NULL)
         OR 
        (dt_start_resubmit < TO_TIMESTAMP ('%%DiffTime%%','MM/dd/yyyy hh24:mi:ss.ff'))
       ) 
group by tx_StageName, tx_Plugin
order by Count desc