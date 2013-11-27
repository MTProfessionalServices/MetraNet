

begin

open :1 for
select 
	id_pt ParameterTableID, 
	nm_name ParameterTableName
from 
	t_pi_rulesetdef_map rsdm
	join
	t_base_props bp on rsdm.id_pt = bp.id_prop
where id_pi = %%PITYPE_ID%%;

open :2 for
select 
	at.id_prop AdjustmentTypeID,
	bp.nm_name Name, 
	bp.nm_desc Description,
	bp.nm_display_name DisplayName,
	formula.id_engine CalculationEngine,
	formula.tx_formula Formula,
	at.b_supportBulk SupportsBulk,
	at.n_adjustmentType AdjustmentKind,
	at.n_composite_adjustment IsComposite,
	loclDesc.id_lang_code LanguageCode,
	loclDesc.tx_desc LocalizedDescriptions,
	dispName.tx_desc LocalizedDisplayNames
from 
	t_adjustment_type at
	join
	t_base_props bp on at.id_prop = bp.id_prop
	left outer join
	t_description loclDesc on bp.n_desc = loclDesc.id_desc
	left outer join
	t_description dispName on dispName.id_desc = bp.n_display_name and dispName.id_lang_code = loclDesc.id_lang_code
	join
	t_calc_formula formula on at.id_formula = formula.id_formula
where
	id_pi_type = %%PITYPE_ID%%;

open :3 for
select 
	at.id_prop AdjustmentTypeID,
	atp.id_prop ID, 
	bp.nm_name Name, 
	bp.nm_display_name DisplayName, 
	atp.nm_datatype DataType, 
	atp.n_direction Direction, 
	dispNames.id_lang_code LanguageCode,  
	dispNames.tx_desc LocalizedDisplayNames 
from 
	t_adjustment_type at
	join
	t_adjustment_type_prop atp on at.id_prop = atp.id_adjustment_type
	join
	t_base_props bp on atp.id_prop = bp.id_prop
	left outer join
	t_description dispNames on dispNames.id_desc = bp.n_desc
where at.id_pi_type = %%PITYPE_ID%%
order by AdjustmentTypeID, Direction;

open :4 for
select 
	at.id_prop AdjustmentTypeID,
	ar.id_prop ID,
	bp.nm_name Name,
	bp.nm_desc Description,
	bp.nm_display_name DisplayName,
	formula.id_engine CalculationEngine,
	formula.tx_formula Formula,
	loclDesc.id_lang_code LanguageCode,
	loclDesc.tx_desc LocalizedDescriptions,
	dispName.tx_desc LocalizedDisplaynames	
from
	t_adjustment_type at
	join
	t_aj_type_applic_map atam on at.id_prop = atam.id_adjustment_type
	join	 
	t_applicability_rule ar on atam.id_applicability_rule = ar.id_prop
	join
	t_base_props bp on ar.id_prop = bp.id_prop
	join
	t_calc_formula formula on ar.id_formula = formula.id_formula
	left outer join
	t_description loclDesc on bp.n_desc = loclDesc.id_desc
	left outer join
	t_description dispName on dispName.id_desc = bp.n_display_name and dispName.id_lang_code = loclDesc.id_lang_code
where
	at.id_pi_type = %%PITYPE_ID%%;

open :5 for
select 
cpd.id_pi,
	cpd.id_prop ID,
	bp.nm_name Name,
	bp.nm_display_name DisplayName,
	cpd.nm_servicedefprop ServiceProperty,
	cpd.nm_preferredcountertype PreferredCounterTypeName,
	dispName.id_lang_code LanguageCode,
	dispName.tx_desc LocalizedDisplayNames
from 
	t_counterpropdef cpd
	join
	t_base_props bp on cpd.id_prop = bp.id_prop
	left outer join
	t_description dispName on bp.n_display_name = dispName.id_desc
where
	cpd.id_pi = %%PITYPE_ID%%;

open :6 for	
select 
	bp.nm_name Name,
	bp.nm_display_name DisplayName,
	dispName.id_lang_code LanguageCode,
	dispName.tx_desc LocalizedDisplayNames
from 
	t_charge c
	join
	t_base_props bp on c.id_charge = bp.id_prop
	left outer join
	t_description dispName on bp.n_display_name = dispName.id_desc
where
	c.id_pi = %%PITYPE_ID%%;


open :7 for
select bp.nm_name name
   from t_pi pi
		join 
		t_base_props bp on bp.id_prop = pi.id_pi
where 	pi.id_parent = %%PITYPE_ID%%;

end;
					
				