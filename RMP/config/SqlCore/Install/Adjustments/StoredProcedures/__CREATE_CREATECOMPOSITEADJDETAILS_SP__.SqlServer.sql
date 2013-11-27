
			CREATE procedure CreateCompositeAdjDetails
			(@p_id_prop INT, 
			@p_id_pi_type INT, 
			@p_pi_name VARCHAR(255),
			@p_adjustment_type_name VARCHAR(255)
			)
			as
			declare @id_pi_type int
			declare @id_adjustment_type int
			begin

				set @id_pi_type = (select top 1 t_base_props.id_prop from t_adjustment_type inner join t_base_props on
				t_base_props.id_prop = t_adjustment_type.id_pi_type where nm_name like @p_pi_name)
				
				SET @id_adjustment_type = (select t_adjustment_type.id_prop from t_adjustment_type inner join t_base_props on
				t_base_props.id_prop = t_adjustment_type.id_prop where nm_name like @p_adjustment_type_name and t_adjustment_type.id_pi_type = @id_pi_type ) 


				insert into t_composite_adjustment(id_prop, id_pi_type, id_adjustment_type) values(@p_id_prop, @id_pi_type, @id_adjustment_type )

			end
				