
      select * from t_rsched a, t_effectivedate b
	    where a.id_eff_date = b.id_eff_date
	    and id_pt = %%PARAM_TABLE_ID%%
	    and id_pricelist = %%PRICE_LIST_ID%%
	    and id_pi_template = %%PRICE_ABLE_ITEM_ID%%
	    and (
	          (b.n_begintype = %%BEGIN_TYPE%% and b.n_begintype = 4 and b.n_beginoffset = %%START_OFFSET%%)
			    or
			      (b.n_begintype = %%BEGIN_TYPE%% and b.n_beginoffset != 4 and b.dt_start = '%%START_DATE%%')
          )
	    and (
	          (b.n_endtype = %%END_TYPE%%  and b.n_endtype = 4 and b.n_endoffset = %%END_OFFSET%%)
			    or
			      (b.n_endtype = %%END_TYPE%% and b.n_endoffset != 4 and b.dt_end = '%%END_DATE%%')
          )
			