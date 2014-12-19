SELECT /* __LOAD_APPLIC_RULES_FOR_AJ_TYPE__ */
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
FROM   T_AJ_TYPE_APPLIC_MAP map
       INNER JOIN t_applicability_rule art
            ON  map.id_applicability_rule = art.id_prop
       INNER JOIN t_calc_formula arf
            ON  art.id_formula = arf.id_formula
       LEFT OUTER JOIN t_base_props base1
            ON  art.id_prop = base1.id_prop
       LEFT OUTER JOIN t_description desc1
            ON  base1.n_display_name = desc1.id_desc
WHERE  desc1.id_lang_code = %%ID_LANG_CODE%%
       AND map.id_adjustment_type = %%ID_AJ_TYPE%%
