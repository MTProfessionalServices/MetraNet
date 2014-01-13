
          select
            aj.id_prop ID,
            bp.nm_name Name,
            bp.nm_display_name DisplayName,
            bp.nm_desc Description,
            abp.nm_name AdjustmentTypeName
          from
            t_adjustment aj inner join t_base_props bp on aj.id_prop = bp.id_prop
            inner join t_base_props abp on aj.id_adjustment_type = abp.id_prop
          where
            aj.id_pi_template = %%PI_TEMPLATE_ID%%
        