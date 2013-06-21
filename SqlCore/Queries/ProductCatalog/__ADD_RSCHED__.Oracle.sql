
DECLARE
    id_sub   number;
BEGIN
    INSERT INTO t_rsched (id_sched, id_pt, id_eff_date, id_pricelist, id_pi_template, dt_mod)
    VALUES (%%ID_SCHED%%, %%ID_PT%%, %%ID_EFFDATE%%, %%ID_PL%%, %%ID_TMPL%%, %%%SYSTEMDATE%%%);
    
    BEGIN
        /* Find the subscription if ICB rate */
        SELECT pm.id_sub
        INTO   id_sub
        FROM   t_pl_map pm
               INNER JOIN t_rsched r
                   ON   r.id_pricelist = pm.id_pricelist
                    AND pm.id_pi_template = r.id_pi_template
        WHERE  r.id_sched = %%ID_SCHED%% AND pm.id_sub IS NOT NULL;
        
        mt_rate_pkg.recursive_inherit_sub_to_accs(v_id_sub => id_sub);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;
END;

