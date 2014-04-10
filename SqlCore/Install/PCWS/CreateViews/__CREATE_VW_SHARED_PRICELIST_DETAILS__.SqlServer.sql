IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_shared_pricelist_details]'))
DROP VIEW [dbo].[vw_shared_pricelist_details]
GO

declare @SQLQuery nvarchar(4000)
declare @epProps nvarchar(4000)

/* Create dynamic SQL to retrieve all properties out of the Product Offering Extended Properties */
set @epProps = ''
select @epProps = @epProps + 'ep.' + c.name + '  ' + substring(c.name, 3, 255) + ',' + Char(10)
from sys.columns c
join sys.objects o on c.object_id = o.object_id
where o.name = 't_ep_pricelist'
  and c.name != 'id_prop'

/* Remove coma after last property */
set @epProps = substring(@epProps, 1, len(@epProps) - 2)

SET @SQLQuery = '
CREATE VIEW vw_shared_pricelist_details
AS
select
	pl.id_pricelist      ID,  
	pl.nm_currency_code  Currency,
	bp.nm_name           Name,
	bp.nm_desc           Description,

/* Extended Properties (dynamically generated) */
' + @epProps + '
from t_pricelist pl
inner join t_base_props bp on bp.id_prop = pl.id_pricelist
left  join t_ep_pricelist ep on pl.id_pricelist = ep.id_prop
where pl.n_type = 1'


--print @SQLQuery
exec sp_executesql @SQLQuery

-- select * from vw_shared_pricelist_details
