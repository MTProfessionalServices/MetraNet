
			select %%VIEW_ID%% ViewID,
			'%%VIEW_NAME%%' ViewName,
			%%DESC_ID%% DescriptionID,
			'%%VIEW_TYPE%%' ViewType,
			%%AMOUNT%% Amount,
			N'USD' Currency,
			1 Count,
			(%%AMOUNT%% - %%AMOUNTWITHTAX%%) TaxAmount,
			%%AMOUNTWITHTAX%% AmountWithTax,
			%%ACCOUNTID%% AccountID,
			%%INTERVALID%% IntervalID,
			t_usage_interval.dt_start IntervalStart,
			t_usage_interval.dt_end IntervalEnd,
			'%%AGGRATE%%' AggRate
			from t_usage_interval where id_interval = %%INTERVALID%%
			