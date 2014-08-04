
			  BEGIN
			  
				open :1 for
                Select 	bp.n_kind PIKind,
				id_po PO_ID,
                map.id_pi_instance ID,
                bp.nm_name Name,
                bp.nm_display_name DisplayName,
                bp.nm_desc Description,
                map.id_pi_instance_parent ParentPIInstanceID,
                parentPIBP.nm_name ParentPIInstanceName,
                map.id_pi_type PITypeID,
                piTypeBP.nm_name PITypeName,
                map.id_pi_template PITemplateID,
                piTemplateBP.nm_name PITemplateName,
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
                recur.tx_cycle_mode  CycleMode,
                COALESCE(recurCycle.day_of_month, COALESCE(discCycle.day_of_month, aggCycle.day_of_month)) DayOfMonth,
                COALESCE(recurCycle.day_of_week, COALESCE(discCycle.day_of_week, aggCycle.day_of_week)) DayOfWeek,
                COALESCE(recurCycle.first_day_of_month, 
                COALESCE(discCycle.first_day_of_month, aggCycle.first_day_of_month)) FirstDayOfMonth,
                COALESCE(recurCycle.second_day_of_month, 
                COALESCE(discCycle.second_day_of_month, aggCycle.second_day_of_month)) SecondDayOfMonth,
                COALESCE(recurCycle.start_day, COALESCE(discCycle.start_day, aggCycle.start_day)) StartDay,
                COALESCE(recurCycle.start_month, COALESCE(discCycle.start_month, aggCycle.start_month)) StartMonth,
                COALESCE(recurCycle.start_year, COALESCE(discCycle.start_year, aggCycle.start_year)) StartYear,
				case (select count(1) from t_pl_map where b_canICB = 'Y' and id_pi_instance = map.id_pi_instance)
				  when 0 then 'N'
				  else 'Y'
				end PICanICB,
				recur.max_unit_value MaxValue, 
				recur.min_unit_value MinValue
                from	t_pl_map map
                inner join t_base_props bp on map.id_pi_instance = bp.id_prop
                inner join t_base_props piTypeBP on map.id_pi_type = piTypeBP.id_prop
                inner join	t_base_props piTemplateBP on map.id_pi_template = piTemplateBP.id_prop
                left outer join t_base_props parentPIBP on map.id_pi_instance_parent = parentPIBP.id_prop
                left outer join t_recur recur on map.id_pi_instance = recur.id_prop
                left outer join t_usage_cycle recurCycle on recur.id_usage_cycle = recurCycle.id_usage_cycle
                left outer join t_nonrecur nonrecur on nonrecur.id_prop = map.id_pi_instance
                left outer join t_discount discount on discount.id_prop = map.id_pi_instance
                left outer join t_usage_cycle discCycle on discCycle.id_usage_cycle = discount.id_usage_cycle
                left outer join t_aggregate agg on agg.id_prop = map.id_pi_instance
                left outer join t_usage_cycle aggCycle on agg.id_usage_cycle = aggCycle.id_usage_cycle
                where 	id_po= %%PO_ID%% and id_pi_instance=%%PI_ID%% and id_paramtable is NULL;

				open :2 for
 				select enum_value AllowedUnitValue 
                from t_recur_enum  re 
                inner join t_pl_map map on re.id_prop = map.id_pi_instance
                where map.id_pi_instance = %%PI_ID%% and map.id_po = %%PO_ID%% and map.id_paramtable is NULL;
				END;
               