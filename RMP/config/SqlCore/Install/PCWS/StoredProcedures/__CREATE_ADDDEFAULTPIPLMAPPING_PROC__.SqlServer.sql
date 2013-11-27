
			  create procedure AddDefaultPIPLMappings
				(
					@piType int,
					@piTemplateID int,
					@piInstanceID int,
					@piInstanceParentID int,
					@poID int,
					@systemDate datetime
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
						@piType,
						@piTemplateID,
						@piInstanceID,
						@piInstanceParentID,
						@poID,
						null,
						'N', 
						@systemDate
					)

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
						@piType,
						@piTemplateID,
						@piInstanceID,
						@piInstanceParentID,
						@poID,
						id_nonshared_pl,
						'N', 
						@systemDate
					from
						t_pi_template piTemplate
						inner join
						t_pi_rulesetdef_map map on piTemplate.id_pi = map.id_pi,
						t_po
					where
						piTemplate.id_template = @piTemplateID and id_po = @poID
				END
			  