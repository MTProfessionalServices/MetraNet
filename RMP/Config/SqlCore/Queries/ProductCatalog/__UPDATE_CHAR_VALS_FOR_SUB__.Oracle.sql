
                update t_char_values
                  set nm_value = '%%VALUE%%'
                where id_scv = %%SPEC_CHAR_VAL_ID%% and id_entity = %%ENTITY_ID%%
            