
				select
				id_sched "ID",
				ed.id_eff_date Effective_Id,
				ed.n_begintype Effective_BeginType,
				ed.dt_start Effective_StartDate,
				ed.n_beginoffset Effective_BeginOffset,
				ed.n_endtype Effective_EndType,
				ed.dt_end Effective_EndDate,
				ed.n_endoffset Effective_EndOffSet,
				bp.nm_desc "Description"
				from
				t_rsched rs %%UPDLOCK%%
				inner join
				t_effectivedate ed %%UPDLOCK%% on rs.id_eff_date = ed.id_eff_date
				inner join
				t_base_props bp %%UPDLOCK%% on rs.id_sched = bp.id_prop
				where
				rs.id_pricelist = %%PRICELIST_ID%%
				and
				rs.id_pt = %%PT_ID%%
				and
				rs.id_pi_template = %%PI_TEMPL_ID%%
			