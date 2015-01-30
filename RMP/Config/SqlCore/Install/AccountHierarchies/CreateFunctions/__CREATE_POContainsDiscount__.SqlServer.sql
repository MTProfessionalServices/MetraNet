
				create function POContainsDiscount
				(@id_po int) returns int
				as
				begin
				declare @retval int
					select @retval = case when count(id_pi_template) > 0 then 1 else 0 end 
					from t_pl_map 
					INNER JOIN t_base_props tb on tb.id_prop = t_pl_map.id_pi_template
					where t_pl_map.id_po = @id_po AND tb.n_kind = 40
					return @retval
				end
			 