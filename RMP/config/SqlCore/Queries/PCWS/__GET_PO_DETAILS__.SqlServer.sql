
        select
          bp.id_prop ProductOfferingId,
          bp.n_name n_name,
          bp.n_desc n_desc,
          bp.n_display_name nDisplayName,
          bp.nm_name Name,
          bp.nm_desc Description,
          bp.nm_display_name DisplayName,
          po.b_user_subscribe CanUserSubscribe,
          po.b_user_unsubscribe CanUserUnSubscribe,
          po.b_hidden IsHidden,
          pl.nm_currency_code Currency,
          effdate.id_eff_date Effective_Id,
          effdate.n_begintype Effective_BeginType,
          effdate.dt_start Effective_StartDate,
          effdate.n_beginoffset Effective_BeginOffset,
          effdate.n_endtype Effective_EndType,
          effdate.dt_end Effective_EndDate,
          effdate.n_endoffset Effective_EndOffSet,
          availdt.id_eff_date Available_Id,
          availdt.n_begintype Available_BeginType,
          availdt.dt_start Available_StartDate,
          availdt.n_beginoffset Available_BeginOffset,
          availdt.n_endtype Available_EndType,
          availdt.dt_end Available_EndDate,
          availdt.n_endoffset Available_EndOffset
        from t_base_props bp
        inner join t_po po on bp.id_prop = po.id_po
        inner join t_pricelist pl on po.id_nonshared_pl = pl.id_pricelist
        inner join t_effectivedate effdate on po.id_eff_date = effdate.id_eff_date
        inner join t_effectivedate availdt on po.id_avail = availdt.id_eff_date
        where id_po = %%PO_ID%%

        select
        id_type, name as AccountTypeName
        from t_po_account_Type_map map
        inner join t_account_type at on at.id_type = map.id_account_type
        where id_po = %%PO_ID%%

      