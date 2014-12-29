SELECT /* __LOAD_APPLICABILITY_RULES__ */
       art.id_prop RuleID,
       art.tx_guid RuleGUID,
       base1.nm_name RuleName,
       COALESCE(vbase1.nm_desc, base1.nm_desc) RuleDescription,
       COALESCE(vbase1.nm_display_name, base1.nm_display_name) RuleDisplayName,
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
       LEFT OUTER JOIN t_vw_base_props vbase1
            ON  vbase1.n_display_name = base1.id_prop 
			AND vbase1.id_lang_code = %%ID_LANG_CODE%%
WHERE 1=1
	  %%PREDICATE%%
