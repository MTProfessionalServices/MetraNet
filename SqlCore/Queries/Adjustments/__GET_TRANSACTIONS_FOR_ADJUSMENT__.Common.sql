
      select 
      /* __GET_TRANSACTIONS_FOR_ADJUSMENT__ */
      ajv.*,
      pi.id_pi PITypeID,
      templateaj.id_prop AdjustmentTemplateID,
      /* ajv.id_aj_instance AS AdjustmentInstanceID, */
      CASE WHEN instanceaj.id_prop IS NOT NULL THEN
        instanceaj.id_prop
      ELSE
        -1 
      END AS AdjustmentInstanceID,
      /* required	properties from	the	product	view */
      pvtable.*,
      (CASE WHEN ajv.id_parent_sess IS NOT NULL THEN 'N' ELSE 'Y' END) AS IsParentSession,
      (CASE WHEN parentajtype.id_prop IS NOT NULL THEN 'Y' ELSE 'N' END) AS IsParentSessPostBillRebilled
      from VW_AJ_INFO ajv
      INNER	JOIN %%PVTABLE%% pvtable on	pvtable.id_sess	=	ajv.id_sess
      INNER	JOIN t_pi_template pi	on ajv.id_pi_template = pi.id_template
      /* pull adjustment template id in order to get */
      /* available reason codes */
      INNER JOIN t_adjustment templateaj 
      ON (templateaj.id_pi_template = ajv.id_pi_template AND templateaj.id_adjustment_type = %%ID_AJ_TYPE%%)
      /* get adjustment instance id if pi instance had it */
      LEFT OUTER JOIN t_adjustment instanceaj 
      ON (instanceaj.id_pi_instance = ajv.id_pi_instance AND instanceaj.id_adjustment_type = %%ID_AJ_TYPE%%)
      /* CR 11284: Need to find out if a parent transaction has been postbill rebilled. If it was,  */
      /* then none of the children should be adjustable */
      /* 'A' means Apporved, 1 means PostBill */
      LEFT OUTER JOIN t_adjustment_transaction parentajt ON parentajt.id_sess = ajv.id_parent_sess AND ajv.id_usage_interval = parentajt.id_usage_interval AND parentajt.c_status = 'A' AND parentajt.n_adjustmenttype = 1 
	  LEFT OUTER JOIN t_adjustment_type parentajtype ON parentajtype.id_prop = parentajt.id_aj_type AND parentajtype.n_adjustmentType = 4
      %%PREDICATE%%
			