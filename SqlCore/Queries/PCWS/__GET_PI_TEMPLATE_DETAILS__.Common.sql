
		        select 
	            bp.id_prop ID,
	            bp.nm_name Name,
	            bp.nm_display_name DisplayName,
	            bp.nm_desc Description,
	            pit.id_pi PIType,
              bp2.id_prop idpi,
				      bp2.nm_name PITypeName,
	            bp.n_kind PIKind,
        discount.n_value_type DiscountValueType,
				discount.id_distribution_cpd DiscountCPD,
				recur.b_fixed_proration_length FixedProrationLength,
				recur.b_prorate_on_deactivate ProrateOnDeactivation,
        recur.b_prorate_instantly ProrateInstantly,
				recur.b_prorate_on_activate ProrateOnActivation,
				recur.b_advance ChargeInAdvance,
				recur.b_charge_per_participant ChargePerParticipant,
				recur.nm_unit_name UnitName,
				recur.nm_unit_display_name UnitDisplayName,
				recur.b_integral IntegerUnitValue,
				recur.min_unit_value MinUnitValue,
				recur.max_unit_value MaxUnitValue,
				recur.n_rating_type RatingType,
				nonrecur.n_event_type EventType,
				COALESCE(recur.id_usage_cycle, COALESCE(discount.id_usage_cycle, agg.id_usage_cycle)) UsageCycleID,
				COALESCE(recur.id_cycle_type, COALESCE(discount.id_cycle_type, agg.id_cycle_type)) RelativeCycleType,
				COALESCE(recurCycle.id_cycle_type, COALESCE(discCycle.id_cycle_type, aggCycle.id_cycle_type)) UsageCycleType,
				COALESCE(recurCycle.day_of_month, COALESCE(discCycle.day_of_month, aggCycle.day_of_month)) DayOfMonth,
				COALESCE(recurCycle.day_of_week, COALESCE(discCycle.day_of_week, aggCycle.day_of_week)) DayOfWeek,
				COALESCE(recurCycle.first_day_of_month,COALESCE(discCycle.first_day_of_month, aggCycle.first_day_of_month)) FirstDayOfMonth,
				COALESCE(recurCycle.second_day_of_month, COALESCE(discCycle.second_day_of_month, aggCycle.second_day_of_month)) SecondDayOfMonth,
				COALESCE(recurCycle.start_day, COALESCE(discCycle.start_day, aggCycle.start_day)) StartDay,
				COALESCE(recurCycle.start_month, COALESCE(discCycle.start_month, aggCycle.start_month)) StartMonth,
				COALESCE(recurCycle.start_year, COALESCE(discCycle.start_year, aggCycle.start_year)) StartYear,
				recur.tx_cycle_mode cycleMode
            from 
			t_pi_template pit
            inner join t_base_props bp on pit.id_template = bp.id_prop
			inner join t_base_props bp2 on pit.id_pi = bp2.id_prop
			left outer join t_recur recur on pit.id_template = recur.id_prop
			left outer join t_usage_cycle recurCycle on recur.id_usage_cycle = recurCycle.id_usage_cycle
			left outer join t_nonrecur nonrecur on nonrecur.id_prop = pit.id_template
			left outer join t_discount discount on discount.id_prop = pit.id_template
			left outer join t_usage_cycle discCycle on discCycle.id_usage_cycle = discount.id_usage_cycle
			left outer join t_aggregate agg on agg.id_prop = pit.id_template
			left outer join t_usage_cycle aggCycle on agg.id_usage_cycle = aggCycle.id_usage_cycle
      where pit.id_template = %%ID_TEMPLATE%%
    		    