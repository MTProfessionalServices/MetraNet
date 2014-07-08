
			  create or replace procedure GetICBMappingForSub
					(p_id_paramtable int,
					 p_id_pi_instance int,
					 p_id_sub int,
					 p_p_systemdate timestamp,
					 p_status out int,
					 p_id_pricelist out int )
				as
					l_id_pi_type int;
					l_id_pi_template int;
					l_id_pi_instance_parent int;
					l_currency varchar2(10);
					l_id_po int;
					l_id_defaultpl int;
					l_id_partition int;
				BEGIN			
					p_status := 0;
					
					select id_pi_type, id_pi_template, id_pi_instance_parent
					into l_id_pi_type, l_id_pi_template, l_id_pi_instance_parent
					from
					t_pl_map where id_pi_instance = p_id_pi_instance AND id_paramtable is NULL;

					/*CR 10884 fix: get the price list currency from product catalog, not
					  corporation. This will take care of the case when gsubs are generated "globally".
					  Also, this seems to be correct for all other cases as well */
					
					select pl.nm_currency_code, po.id_po, po.c_POPartitionId
					into l_currency, l_id_po, l_id_partition
					from 
						t_po po
						inner join 
						t_pricelist pl on po.id_nonshared_pl = pl.id_pricelist
						inner join 
						t_sub s on po.id_po = s.id_po
					where s.id_sub = p_id_sub;

					BEGIN
						/* Select to see if a pricelist mapping exists */
						select id_pricelist into p_id_pricelist from t_pl_map 
								where id_sub = p_id_sub and id_pi_instance = p_id_pi_instance and 
										id_paramtable = p_id_paramtable;
										
					EXCEPTION
						WHEN NO_DATA_FOUND THEN
						
							BEGIN
								select id_pricelist into l_id_defaultpl from t_pl_map where
									id_po = l_id_po and id_pi_instance = p_id_pi_instance and
									id_paramtable = p_id_paramtable and
									id_sub is null and id_acc is null and 
									B_CANICB = 'Y';
							EXCEPTION
								WHEN NO_DATA_FOUND THEN
									p_status := -10;
									return;
							END;
							
							insert into t_base_props (id_prop, n_kind,n_name,n_display_name,n_desc) 
								values (seq_t_base_props.nextval, 150,0,0,0);

							select seq_t_base_props.currval into p_id_pricelist from dual;
							
							insert into t_pricelist(id_pricelist, n_type, nm_currency_code, c_PLPartitionId) 
								values (p_id_pricelist, 0, l_currency, l_id_partition);
							
							insert into t_pl_map(
							  id_paramtable,
							  id_pi_type,
							  id_pi_instance,
							  id_pi_template,
							  id_pi_instance_parent,
							  id_sub,
							  id_po,
							  id_pricelist,
							  b_canICB,
							  dt_modified
							  )
									values(
							  p_id_paramtable,
							  l_id_pi_type,              
							  p_id_pi_instance,
							  l_id_pi_template,
							  l_id_pi_instance_parent,
							  p_id_sub,
							  l_id_po,
							  p_id_pricelist,
							  'N',
							  p_p_systemdate
							  );
					END;
				END;
		