
        SELECT
        bp.id_prop,
        bp.n_kind,
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
        nm_unit_name,
        n_rating_type,
        b_integral,
        max_unit_value,
        min_unit_value,
        n_unit_name,
        n_unit_display_name,
        td_disp.tx_desc nm_unit_display_name
        FROM
        t_recur r
        LEFT JOIN t_base_props bp on r.id_prop = bp.id_prop
        LEFT JOIN
        (
        SELECT id_desc, tx_desc
        FROM t_description
        WHERE id_lang_code = %%ID_LANG_CODE%%
        ) td_disp ON td_disp.id_desc = r.n_unit_display_name
        WHERE
        r.id_prop=%%ID_PROP%%
      