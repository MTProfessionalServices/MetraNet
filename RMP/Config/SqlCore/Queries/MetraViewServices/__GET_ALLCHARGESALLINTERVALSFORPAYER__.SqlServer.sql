
			select 
				/* __GET_BYACCOUNTALLPRODUCTSFORPAYER__
						 DATAMART disabled */
				au.id_usage_interval, ui.dt_end, ui.dt_start, ui.tx_interval_status,
				 au.am_currency as Currency,
				SUM({fn IFNULL(au.Amount, 0.0)}) +
					/* Total Tax */
					SUM({fn IFNULL(au.Tax_Federal,0.0)}) + 
					SUM({fn IFNULL(au.Tax_State,0.0)}) + 
					SUM({fn IFNULL(au.Tax_County,0.0)}) + 
					SUM({fn IFNULL(au.Tax_Local,0.0)}) + 
					SUM({fn IFNULL(au.Tax_Other,0.0)}) +
					/* Prebill Total Tax Adjustments */
					SUM({fn IFNULL(au.CompoundPrebillTotalTaxAdjAmt, 0.0)}) +
					/* Prebill Adjusted Amount */
					SUM({fn IFNULL(au.CompoundPrebillAdjAmt, 0.0)}) as TotalAmount,
					ti.invoice_string
			from
				t_account_ancestor s1 
				inner join 
				t_account_ancestor d3 on s1.id_descendent=d3.id_ancestor
				left outer join 
				vw_mps_acc_mapper mapd3 on d3.id_ancestor=mapd3.id_acc
				inner join 
				vw_aj_info au on 
					d3.id_descendent=au.id_payee and d3.vt_start <= au.dt_session and d3.vt_end >= au.dt_session and 
					s1.vt_start <= au.dt_session and s1.vt_end >= au.dt_session
				inner join t_view_hierarchy vh on au.id_view = vh.id_view
				inner join vw_mps_acc_mapper mapd1 on au.id_acc=mapd1.id_acc
				left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
				left outer join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi
				inner join t_enum_data enumd2 on au.id_view=enumd2.id_enum_data
				inner join t_usage_interval ui on ui.id_interval = au.id_usage_interval
        		left outer join t_invoice ti on ti.id_interval = au.id_usage_interval and ti.id_acc = au.id_acc
			where
				 vh.id_view = vh.id_view_parent and
				au.id_acc = @idAcc and
				(pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or 
					%%%UPPER%%%(enumd2.nm_enum_data) NOT LIKE '%_TEMP')
				and 
				s1.id_ancestor = @idAcc and 
				s1.num_generations = 0	and
				au.id_parent_sess IS NULL
			group by 
				au.id_usage_interval, au.id_acc, mapd1.hierarchydisplayname, s1.id_descendent,
				ui.dt_start, ui.dt_end, ui.tx_interval_status, mapd3.hierarchydisplayname, au.am_currency, ti.invoice_string
			order by
				id_usage_interval
			  
		