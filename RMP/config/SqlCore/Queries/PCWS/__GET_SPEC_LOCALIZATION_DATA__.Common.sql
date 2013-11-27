
                select
                  id_category CategoryId,
                  n_description DescriptionId,
                  n_name NameId
                from t_spec_characteristics
                where id_spec = %%ID_SPEC%%
            