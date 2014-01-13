
                update t_spec_char_values
                  set c_is_default = '%%C_IS_DEFAULT%%',
                  n_value = %%N_VALUE%%,
                nm_value = '%%NM_VALUE%%'
                where id_scv = %%ID_SCV%%;
                insert into t_spec_val_map VALUES(%%ID_SPEC%%, %%ID_SCV%%)      
        
            