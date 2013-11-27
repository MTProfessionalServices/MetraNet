
select 
	ui.id_interval 
from 
	t_usage_interval ui
inner join 
	t_usage_cycle uc on ui.id_usage_cycle = uc.id_usage_cycle
inner join 
	t_acc_usage_cycle auc on uc.id_usage_cycle = auc.id_usage_cycle and auc.id_acc = %%ACCOUNT_ID%%
where 
	%%EFFECTIVE_DATE%% between ui.dt_start and ui.dt_end
		