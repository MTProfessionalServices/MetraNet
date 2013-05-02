
      SELECT
        cpd.id_prop,
        cpd.id_pi,
        bp1.nm_name CounterPropDefName,
        bp1.nm_display_name As CounterPropDefDisplayName,
        cm.id_counter,
        (SELECT nm_name FROM t_vw_base_props bp2 WHERE bp2.id_prop = cm.id_counter and bp2.id_lang_code = %%ID_LANG%%) AS CounterName,
        (SELECT nm_desc FROM t_vw_base_props bp2 WHERE bp2.id_prop = cm.id_counter and bp2.id_lang_code = %%ID_LANG%%) AS CounterDescription,
        cpd.nm_preferredcountertype AS PreferredCounterType,
        case when disc.id_distribution_cpd is null then 'N' else 'Y' end as ForDistribution
      FROM
        t_vw_base_props bp1,
        t_counterpropdef cpd
        left outer join
          (SELECT * FROM t_counter_map WHERE id_pi = %%ID_PI%%) cm ON
          cpd.id_prop = cm.id_cpd
              left outer join t_discount disc
                on disc.id_prop = cm.id_pi
                and disc.id_distribution_cpd = cpd.id_prop
      WHERE
        cpd.id_pi = %%ID_PI_TYPE%% AND
        cpd.id_prop = bp1.id_prop and bp1.id_lang_code = %%ID_LANG%%
    