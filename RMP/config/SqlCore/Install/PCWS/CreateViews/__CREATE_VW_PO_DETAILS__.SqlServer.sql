IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_po_details]'))
DROP VIEW [dbo].[vw_po_details]
GO

declare @SQLQuery nvarchar(4000)
declare @epProps nvarchar(4000)

/* Create dynamic SQL to retrieve all properties out of the Product Offering Extended Properties */
set @epProps = ''
select @epProps = @epProps + 'ep.' + c.name + '  ' + substring(c.name, 3, 255) + ',' + Char(10)
from sys.columns c
join sys.objects o on c.object_id = o.object_id
where o.name = 't_ep_po'
  and c.name != 'id_prop'

/* Remove coma after last property */
set @epProps = substring(@epProps, 1, len(@epProps) - 2)

SET @SQLQuery = '
CREATE VIEW vw_po_details
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
' + @epProps + '
from t_base_props bp
inner join t_po po on bp.id_prop = po.id_po
inner join t_pricelist pl on po.id_nonshared_pl = pl.id_pricelist
inner join t_effectivedate effdate on po.id_eff_date = effdate.id_eff_date
inner join t_effectivedate availdt on po.id_avail = availdt.id_eff_date
left  join t_ep_po ep on po.id_po = ep.id_prop'

-- print @SQLQuery
exec sp_executesql @SQLQuery

-- select * from vw_po_details
