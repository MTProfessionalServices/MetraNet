
		CREATE OR REPLACE PROCEDURE CREATECOMPOSITEADJDETAILS
			(p_id_prop INT,
			p_id_pi_type INT,
			p_pi_name VARCHAR2,
			p_adjustment_type_name VARCHAR2
			)
			as
			id_pi_type int;
			id_adjustment_type int;
			begin

				for i in (
                select  t_base_props.id_prop id_prop
                from t_adjustment_type inner join t_base_props on
				t_base_props.id_prop = t_adjustment_type.id_pi_type
                where nm_name like CreateCompositeAdjDetails.p_pi_name) loop
                    id_pi_type := i.id_prop;
                    exit;
                end loop;
				
                for i in(
                select t_adjustment_type.id_prop id_prop
                from t_adjustment_type inner join t_base_props on
				t_base_props.id_prop = t_adjustment_type.id_prop
                where nm_name like CreateCompositeAdjDetails.p_adjustment_type_name and t_adjustment_type.id_pi_type = CreateCompositeAdjDetails.id_pi_type) loop
                    id_adjustment_type := i.id_prop;
                end loop;

				insert into t_composite_adjustment(id_prop, id_pi_type, id_adjustment_type)
                values
                (p_id_prop, id_pi_type, id_adjustment_type );

			end;
		  