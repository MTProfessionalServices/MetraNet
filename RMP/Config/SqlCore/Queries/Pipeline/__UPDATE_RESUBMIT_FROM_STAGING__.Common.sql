
insert into t_session (id_ss, id_source_sess) 
select %%ID_SS%%, id_sess
from %%%NETMETERSTAGE_PREFIX%%%t_resubmit_transaction_stage tmp %%%READCOMMITTED%%%
where tmp.id_svc = %%ID_SVC%%
	