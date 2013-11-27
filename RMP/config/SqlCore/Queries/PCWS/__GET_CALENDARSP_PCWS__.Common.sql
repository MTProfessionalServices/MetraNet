
				Select
	c.id_calendar "ID",
	bp.nm_name "Name",
	bp.nm_desc "Description" 
from
	t_calendar c
	inner join
	t_base_props bp on c.id_calendar = bp.id_prop
