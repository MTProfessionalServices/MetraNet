
			 select 
			 ajdesc.tx_desc as AdjustmentDisplayName, 
			 aj.aj_tax_federal as FederalTaxAdjustment,
			 aj.aj_tax_state as StateTaxAdjustment,
			 aj.aj_tax_county as CountyTaxAdjustment,
			 aj.aj_tax_local as LocalTaxAdjustment,
			 aj.aj_tax_other as OtherTaxAdjustment,
			 ajtable.c_%%PROPNAME%% As AdjustmentValue
       FROM %%AJTABLE%% ajtable
      /* join back to adjustment type in order to get properties metadata */
      INNER JOIN t_adjustment_transaction aj ON aj.id_adj_trx = ajtable.id_adjustment
      INNER JOIN t_Adjustment_type_prop ajprop ON aj.id_aj_type = ajprop.id_adjustment_type
      INNER JOIN t_base_props bp ON bp.id_prop = ajprop.id_Prop AND bp.nm_name = N'%%PROPNAME%%'
      INNER JOIN t_description ajdesc ON bp.n_display_name = ajdesc.id_desc and ajdesc.id_lang_code = %%ID_LANG%%
      WHERE aj.id_adj_trx = %%ID_AJ_TRX%%
			