
        select id_sched from t_rsched,t_effectivedate te where t_rsched.id_eff_date = te.id_eff_date AND
        te.n_begintype = %%BEGINTYPE%% AND te.dt_start %%DATE_OPBEGIN%% %%DTSTART%% AND te.n_beginoffset = %%BEGINOFFSET%% AND
        te.n_endtype = %%ENDTYPE%% AND te.dt_end %%DATE_OPEND%% %%DTEND%% AND te.n_endoffset = %%ENDOFFSET%% AND
        t_rsched.id_pt = %%PARAMTABLE%% AND t_rsched.id_pricelist = %%PRICELIST%% AND
        t_rsched.id_pi_template = %%PITEMPLATE%% AND t_rsched.id_sched <> %%ID_EXISTING_SCHED%%      