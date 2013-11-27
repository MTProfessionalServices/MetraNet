
		      create proc PIResolutionByID(
		      @dt_session DATETIME, @id_pi_template INTEGER, @id_acc INTEGER)

		      as
					select 
		      typemap.id_po,
		      typemap.id_pi_instance,
		      sub.id_sub
		      from
		      -- select out the instances from the pl map (either need to follow 
		      -- up with a group by or assume one param table or add a unique entry
		      -- with a null param table/price list; I am assuming the null entry exists)
		      t_pl_map typemap 
		      -- Now that we have the correct list of instances we match them up with the
		      -- accounts on the billing interval being processed.  For each account grab the
		      -- information about the billing interval dates so that we can select the 
		      -- correct intervals to process.
		      -- Go get all subscriptions product offerings containing the proper discount
		      -- instances
		      , t_sub sub 
		      -- Go get the effective date of the subscription to the discount
		      where
		      -- Join criteria for t_sub
		      typemap.id_po = sub.id_po
		      -- join criteria for t_sub to t_effective_date
		      -- Find the subscription which contains the dt_session; there should be
		      -- at most one of these.
		      and (sub.vt_start <= @dt_session)
		      and (sub.vt_end >= @dt_session)
		      -- Select the unique instance record that includes an instance in a template
		      and typemap.id_paramtable is null
		      and typemap.id_pi_template = @id_pi_template
		      and sub.id_acc = @id_acc
		