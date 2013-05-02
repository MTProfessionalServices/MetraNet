
			select 
				/* DATAMART enabled */
				au.id_usage_interval, ui.dt_end, ui.dt_start, ui.tx_interval_status,
				au.am_currency as Currency,
				SUM({fn IFNULL(au.TotalAmount,0)}) +
				/* Total Tax */
				SUM({fn IFNULL(au.TotalTax,0)}) +
				/* Prebill Total Tax Adjustments */
				SUM({fn IFNULL(au.PrebillTotalTaxAdjAmt,0)}) +
				/* Prebill Adjustment Amount */
				SUM({fn IFNULL(au.PrebillAdjAmt,0)}) as TotalAmount,
				ti.invoice_string
			from
				t_dm_account_ancestor s1
				inner join t_dm_account_ancestor d3 on s1.id_dm_descendent=d3.id_dm_ancestor
				inner join t_dm_account acc on acc.id_dm_acc=s1.id_dm_descendent
				left outer join vw_mps_acc_mapper mapd3 on acc.id_acc=mapd3.id_acc
				inner join t_mv_payer_interval au on d3.id_dm_descendent=au.id_dm_acc
				inner join t_view_hierarchy vh on au.id_view = vh.id_view
				inner join vw_mps_acc_mapper mapd1 on au.id_acc=mapd1.id_acc
				left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
				left outer join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi
				inner join t_enum_data enumd2 on au.id_view=enumd2.id_enum_data
				inner join t_usage_interval ui on ui.id_interval = au.id_usage_interval
				left outer join t_invoice ti on ti.id_interval = au.id_usage_interval and ti.id_acc = au.id_acc
			where 	vh.id_view = vh.id_view_parent
				and au.id_acc = @idAcc
				and (
					pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or 
					%%%UPPER%%%(enumd2.nm_enum_data) NOT LIKE '%_TEMP')
				and s1.id_dm_ancestor in (
					select id_dm_acc from t_dm_account
					where id_acc=@idAcc
						  group by id_dm_acc)
				and s1.num_generations = 0
			group by
				au.id_usage_interval,
				ui.dt_end, 
				ui.dt_start, 
				ui.tx_interval_status,
				au.am_currency
			order by
				id_usage_interval;
			  
		