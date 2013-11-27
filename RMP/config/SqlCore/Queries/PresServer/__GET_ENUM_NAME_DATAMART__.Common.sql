
	select 
	ed.nm_enum_data, 
	count(*) - 1 as num_children 
	from 
	t_enum_data ed
	left outer join t_view_hierarchy vh on vh.id_view_parent=ed.id_enum_data
	where ed.id_enum_data = %%ID_ENUM_DATA%%
	group by ed.nm_enum_data
        