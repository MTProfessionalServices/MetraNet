
                  update t_spec_characteristics
                  set
                    c_spec_type = %%SPEC_TYPE%%,
                    c_category = '%%CATEGORY%%',
                    c_is_required = '%%C_IS_REQUIRED%%',
                    nm_description = '%%NM_DESCRIPTION%%',
                    nm_name = '%%NM_NAME%%',
                    c_user_visible = '%%C_USER_VISIBLE%%',
                    c_user_editable = '%%C_USER_EDITABLE%%',
                    c_min_value = '%%MIN_VALUE%%',
                    c_max_value = '%%MAX_VALUE%%'
                  where id_spec = %%ID_SPEC%%
            