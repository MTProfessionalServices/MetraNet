
				select id_day from t_calendar_day %%UPDLOCK%% where id_calendar = %%CALENDAR_ID%% and n_weekday = %%WEEKDAY%%
				