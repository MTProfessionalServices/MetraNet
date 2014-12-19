SELECT /* __LOAD_APPLICABILITY_RULES__ */
       art.id_prop RuleID,
       art.tx_guid RuleGUID,
       base1.nm_name RuleName,
       base1.nm_desc RuleDescription,
       desc1.tx_desc RuleDisplayName,
       arf.tx_formula RuleFormula,
       arf.id_engine RuleFormulaEngine,
       art.id_formula RuleFormulaID,
       base1.n_display_name RuleDisplayNameID,
       base1.n_desc RuleDisplayDescriptionID
FROM   t_applicability_rule art
       INNER JOIN t_calc_formula arf
            ON  art.id_formula = arf.id_formula
       LEFT OUTER JOIN t_base_props base1
            ON  art.id_prop = base1.id_prop
       LEFT OUTER JOIN t_description desc1
            ON  base1.n_display_name = desc1.id_desc
WHERE  desc1.id_lang_code = %%ID_LANG_CODE%% 
       %%PREDICATE%%
