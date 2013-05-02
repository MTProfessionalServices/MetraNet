
        declare id_desc_unit_name  number(10);
        id_desc_unit_display_name  number(10);
        nm_unit_name_var nvarchar2(255);
        nm_unit_display_name_var nvarchar2(255);
        begin
        id_desc_unit_name := null;
        id_desc_unit_display_name := null;
        nm_unit_name_var := '%%NM_UNIT_NAME%%';
        nm_unit_display_name_var := '%%NM_UNIT_DISPLAY_NAME%%';

        if length(nm_unit_name_var) > 0 then
        UpsertDescription (%%ID_LANG_CODE%%, nm_unit_name_var, NULL, id_desc_unit_name);
        UpsertDescription (%%ID_LANG_CODE%%, nm_unit_display_name_var, NULL, id_desc_unit_display_name);
        end if;

        INSERT INTO
        t_recur
        (
        id_prop,
        b_advance,
        b_prorate_on_activate,
        b_prorate_instantly,
        b_prorate_on_deactivate,
        b_prorate_on_rate_change,
        b_fixed_proration_length,
        id_usage_cycle,
        id_cycle_type,
        tx_cycle_mode,
        b_charge_per_participant,
        n_unit_name,
        nm_unit_name,
        n_unit_display_name,
        nm_unit_display_name,
        n_rating_type,
        b_integral,
        max_unit_value,
        min_unit_value
        )
        VALUES
        (
        %%ID_PROP%%,
        '%%B_ADVANCE%%',
        '%%B_PRORATE_ON_ACTIVATE%%',
        '%%B_PRORATE_INSTANTLY%%',
        '%%B_PRORATE_ON_DEACTIVATE%%',
        'N',
        '%%B_FIXED_PRORATION_LENGTH%%',
        %%ID_USAGE_CYCLE%%,
        %%ID_CYCLE_TYPE%%,
        '%%TX_CYCLE_MODE%%',
        '%%B_CHARGE_PER_PARTICIPANT%%',
        id_desc_unit_name,
        nm_unit_name_var,
        id_desc_unit_display_name,
        nm_unit_display_name_var,
        %%N_RATING_TYPE%%,
        '%%B_INTEGRAL%%',
        %%MAX_UNIT_VALUE%%,
        %%MIN_UNIT_VALUE%%
        );
        end;
      