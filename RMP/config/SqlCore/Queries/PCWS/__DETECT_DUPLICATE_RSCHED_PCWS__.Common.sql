
        select id_sched from 
			t_pl_map map
			inner join
			t_rsched rs on map.id_pricelist = rs.id_pricelist
			inner join
			t_effectivedate te on rs.id_eff_date = te.id_eff_date 
		where 
			te.n_begintype = %%BEGINTYPE%% 
			AND 
			te.dt_start %%DATE_OPBEGIN%% %%DTSTART%% 
			AND 
			te.n_beginoffset = %%BEGINOFFSET%% 
			AND
			te.n_endtype = %%ENDTYPE%% 
			AND 
			te.dt_end %%DATE_OPEND%% %%DTEND%% 
			AND 
			te.n_endoffset = %%ENDOFFSET%% 
			AND 
			map.id_po = %%id_po%%
			AND
			map.id_pi_template = %%ID_TMPL%% 
			and
			map.id_pi_instance = %%ID_PI%%
			AND 
			map.id_paramtable = %%ID_PT%%
