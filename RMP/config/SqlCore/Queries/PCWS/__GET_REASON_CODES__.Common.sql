
				select
				rc.id_prop "ID",
				bp.nm_name "Name",
				bp.nm_desc "Description",
				bp.nm_display_name "DisplayName"
				from
				t_reason_code rc
				inner join
				t_base_props bp on rc.id_prop = bp.id_prop
			