
      select 
      /* __GET_REBILL_REMETER_ROWSET__ */
      ajv.*,
      %%PV_COLUMNS%%
      from VW_AJ_INFO ajv
      INNER	JOIN %%PVTABLE%% pvtable on	pvtable.id_sess	=	ajv.id_sess
      INNER	JOIN t_pi_template pi	on ajv.id_pi_template = pi.id_template
      %%PREDICATE%%
			