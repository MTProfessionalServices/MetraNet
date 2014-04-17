declare
    v_sql varchar2(4000);
    epProps varchar2(4000);

begin   
    /* Create dynamic SQL to retrieve all properties out of the Product Offering Extended Properties */
    select LISTAGG('ep.' || c.column_name || '  ' || substr(c.column_name, 3, 255), (',' || CHR(10))) WITHIN GROUP (ORDER BY c.column_name) INTO epProps
    from user_tab_cols c
    join ALL_OBJECTS o on c.table_name = o.object_name
    where o.object_name = 'T_EP_PO'
      and c.column_name != 'ID_PROP'  ;
     
    v_sql := '
    CREATE OR REPLACE VIEW vw_po_details
    AS
    select
      bp.id_prop ProductOfferingId,
      bp.n_name n_name,
      bp.n_desc n_desc,
      bp.n_display_name nDisplayName,
      bp.nm_name Name,
      bp.nm_desc Description,
      bp.nm_display_name DisplayName,
      pl.nm_currency_code Currency,
      po.b_user_subscribe CanUserSubscribe,
      po.b_user_unsubscribe CanUserUnSubscribe,
      po.b_hidden IsHidden,
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
      availdt.n_endoffset Available_EndOffset,
    
    /* Extended Properties (dynamically generated) */
    ' || epProps || '
    from t_base_props bp
    inner join t_po po on bp.id_prop = po.id_po
    inner join t_pricelist pl on po.id_nonshared_pl = pl.id_pricelist
    inner join t_effectivedate effdate on po.id_eff_date = effdate.id_eff_date
    inner join t_effectivedate availdt on po.id_avail = availdt.id_eff_date
    left  join t_ep_po ep on po.id_po = ep.id_prop';
    
    -- print v_sql
    execute immediate v_sql;  
end;