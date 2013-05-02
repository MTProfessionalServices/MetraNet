
	      select c_TaxVendor,
	             c_MetraTaxCountryEligibility,
	             c_MetraTaxCountryZone,
		     c_MetraTaxHasOverrideBand,
		     c_MetraTaxOverrideBand,
		     c_TaxServiceAddressPCode,
		     c_TaxExempt
              from t_av_Internal
	      where id_acc = %%ID_ACC%%
      