
	      select c_Country,
	             c_TaxZone,
	             c_TaxRate,
		     c_TaxBand,
		     c_TaxName,
		     id_audit
              from t_pt_taxRate
	      where id_sched = %%ID_SCHED%% and
              tt_end = dbo.MTMaxDate()
      