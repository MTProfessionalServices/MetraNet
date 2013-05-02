
            select 
				      count(*) NumSpec,
				      spec.id_category CategoryId,
				      spec.n_name NameId,
				      spec.n_description DescId 
            from t_entity_specs es
            inner join t_spec_characteristics spec on es.id_spec = spec.id_spec
            where spec.id_spec = %%ID_SPEC%%
            group by id_category, n_name, n_description
            