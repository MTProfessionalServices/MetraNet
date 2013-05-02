
		select id_prop from 
			(select id_holiday  as id_prop, nm_name as nm_name 
				from t_calendar_holiday ch %%UPDLOCK%%
				inner join
				t_calendar_day cd %%UPDLOCK%% on ch.id_day = cd.id_day and cd.id_calendar = %%ID_PO%% ) innerQ
		where %%PREDICATE%%
                