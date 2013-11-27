
select id_rerun from t_rerun_history r1 %%%READCOMMITTED%%%
where
tx_action = 'START ABANDON'
and not exists ( 
select 1 
from t_rerun_history r2 %%%READCOMMITTED%%% 
where 
 r2.id_rerun=r1.id_rerun
 and
 r2.tx_action='END ABANDON'
)  
	  