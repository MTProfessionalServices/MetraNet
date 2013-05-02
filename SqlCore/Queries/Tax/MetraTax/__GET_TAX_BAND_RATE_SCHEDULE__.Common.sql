
	      select c_Country,
	             c_ProductCode,
		     c_TaxBand,
		     id_audit
              from t_pt_taxBand
	      where id_sched = %%ID_SCHED%%  and
              tt_end = dbo.MTMaxDate()
      