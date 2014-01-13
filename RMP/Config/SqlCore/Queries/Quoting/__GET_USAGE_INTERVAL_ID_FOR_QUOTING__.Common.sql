
select 
	ui.id_interval as UsageIntervalId,
	ui.dt_start as UsageIntervalStart,
	ui.dt_end as UsageIntervalEnd,
	ui.tx_interval_status as UsageIntervalState,
	nui.id_interval as NextUsageIntervalId
from 
	t_usage_interval ui
inner join 
	t_usage_cycle uc on ui.id_usage_cycle = uc.id_usage_cycle
inner join 
	t_acc_usage_cycle auc on uc.id_usage_cycle = auc.id_usage_cycle and auc.id_acc = %%ACCOUNT_ID%%
left join
    t_usage_interval nui ON ui.id_usage_cycle = nui.id_usage_cycle AND dbo.AddSecond(ui.dt_end) = nui.dt_start
where 
	%%EFFECTIVE_DATE%% between ui.dt_start and ui.dt_end
		