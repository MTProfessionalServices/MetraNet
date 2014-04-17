declare
	v_sql varchar2(4000);
	epProps varchar2(4000);

begin
	/* Create dynamic SQL to retrieve all properties out of the Product Offering Extended Properties */
	select LISTAGG('ep.' || c.column_name || '  ' || substr(c.column_name, 3, 255), (',' || CHR(10))) WITHIN GROUP (ORDER BY c.column_name) INTO epProps
    from user_tab_cols c
    join ALL_OBJECTS o on c.table_name = o.object_name
    where o.object_name = 'T_EP_PRICELIST'
      and c.column_name != 'ID_PROP'  ;


	v_sql := '
	CREATE OR REPLACE VIEW vw_shared_pricelist_details
	AS
	select
		pl.id_pricelist      ID,  
		pl.nm_currency_code  Currency,
		bp.nm_name           Name,
		bp.nm_desc           Description,

	/* Extended Properties (dynamically generated) */
	' || epProps || '
	from t_pricelist pl
	inner join t_base_props bp on bp.id_prop = pl.id_pricelist
	left  join t_ep_pricelist ep on pl.id_pricelist = ep.id_prop
	where pl.n_type = 1';


	-- print v_sql
    execute immediate v_sql;  
end;

--select * from vw_shared_pricelist_details