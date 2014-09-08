
        select 
          t_po.id_po, 
          t_po.id_eff_date, 
          t_po.id_avail, 
          t_po.b_user_subscribe, 
          t_po.b_user_unsubscribe, 
          t_po.id_nonshared_pl, 
          t_po.b_hidden,
          COALESCE(t_vw_base_props.n_name, tbp.n_name) n_name, 
          COALESCE(t_vw_base_props.n_desc, tbp.n_desc) n_desc, 
          COALESCE(t_vw_base_props.n_display_name, tbp.n_display_name) n_display_name,
          COALESCE(t_vw_base_props.nm_name, tbp.nm_name) nm_name,
          COALESCE(t_vw_base_props.nm_desc, tbp.nm_desc) nm_desc,
          COALESCE(t_vw_base_props.nm_display_name, tbp.nm_display_name) nm_display_name,
          te.n_begintype as te_n_begintype, 
          te.dt_start as te_dt_start, 
          te.n_beginoffset as te_n_beginoffset,
          te.n_endtype as te_n_endtype, 
          te.dt_end as te_dt_end, 
          te.n_endoffset as te_n_endoffset,
          ta.n_begintype as ta_n_begintype, 
          ta.dt_start as ta_dt_start, 
          ta.n_beginoffset as ta_n_beginoffset,
          ta.n_endtype as ta_n_endtype, 
          ta.dt_end as ta_dt_end, 
          ta.n_endoffset as ta_n_endoffset,
          t_po.c_POPartitionId
          %%EXTENDED_SELECT%%
        from
        %%EXTENDED_JOIN%%
        inner join t_base_props tbp on tbp.id_prop = t_po.id_po
        left outer join t_vw_base_props on t_vw_base_props.id_prop = t_po.id_po and t_vw_base_props.n_kind = 100 and t_vw_base_props.id_lang_code = %%ID_LANG%%
        join t_effectivedate te on te.id_eff_date = t_po.id_eff_date
        join t_effectivedate ta on ta.id_eff_date = t_po.id_avail
        where t_po.id_po = %%ID_PO%%
      