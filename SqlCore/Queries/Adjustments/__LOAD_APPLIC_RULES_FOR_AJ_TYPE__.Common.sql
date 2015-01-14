SELECT /* __LOAD_APPLIC_RULES_FOR_AJ_TYPE__ */
       art.id_prop RuleID,
       art.tx_guid RuleGUID,
       bp.nm_name RuleName,
       COALESCE(vbp.nm_desc, bp.nm_desc) RuleDescription,
       COALESCE(vbp.nm_display_name, bp.nm_display_name) RuleDisplayName,
       arf.tx_formula RuleFormula,
       arf.id_engine RuleFormulaEngine,
       art.id_formula RuleFormulaID,
       bp.n_display_name RuleDisplayNameID,
       bp.n_desc RuleDisplayDescriptionID
FROM   T_AJ_TYPE_APPLIC_MAP map
       INNER JOIN t_applicability_rule art
            ON  map.id_applicability_rule = art.id_prop
       INNER JOIN t_calc_formula arf
            ON  art.id_formula = arf.id_formula
       LEFT OUTER JOIN t_base_props bp
            ON  art.id_prop = bp.id_prop
       LEFT OUTER JOIN t_vw_base_props vbp
            ON  vbp.n_display_name = bp.id_prop AND vbp.id_lang_code = %%ID_LANG_CODE%%
			WHERE map.id_adjustment_type = %%ID_AJ_TYPE%%
