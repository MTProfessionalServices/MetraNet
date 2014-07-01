
                delete from t_char_values where id_scv = %%SPEC_CHAR_VAL_ID%% and id_entity = %%ENTITY_ID%%
                insert into t_char_values VALUES(%%SPEC_CHAR_VAL_ID%%, %%ENTITY_ID%%, '%%VALUE%%', %%START_DATE%%, %%END_DATE%%, '%%SPEC_NAME%%', %%SPEC_TYPE%%)
            