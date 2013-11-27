
			  create or replace procedure AddDefaultPIPLMappings
				(
					p_piType int,
					p_piTemplateID int,
					p_piInstanceID int,
					p_piInstanceParentID int,
					p_poID int,
					p_systemDate timestamp
				)
				as
				BEGIN

					insert into t_pl_map (
						id_paramtable,
						id_pi_type,
						id_pi_template,
						id_pi_instance,
						id_pi_instance_parent,
						id_po,
						id_pricelist,
						b_canICB, 
						dt_modified
					)
					values (
						null,
						p_piType,
						p_piTemplateID,
						p_piInstanceID,
						p_piInstanceParentID,
						p_poID,
						null,
						'N', 
						p_systemDate
					);

					insert into t_pl_map (
						id_paramtable,
						id_pi_type,
						id_pi_template,
						id_pi_instance,
						id_pi_instance_parent,
						id_po,
						id_pricelist,
						b_canICB, 
						dt_modified
					)
					select
						id_pt,
						p_piType,
						p_piTemplateID,
						p_piInstanceID,
						p_piInstanceParentID,
						p_poID,
						id_nonshared_pl,
						'N', 
						p_systemDate
					from
						t_pi_template piTemplate
						inner join
						t_pi_rulesetdef_map map on piTemplate.id_pi = map.id_pi,
						t_po
					where
						piTemplate.id_template = p_piTemplateID and id_po = p_poID;
				END;
			  