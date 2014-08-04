                 delete from t_char_values where id_scv = %%SPEC_CHAR_VAL_ID%% and id_entity = %%ENTITY_ID%%;
                insert into t_char_values VALUES(%%SPEC_CHAR_VAL_ID%%, %%ENTITY_ID%%, '%%VALUE%%', %%START_DATE%%, (select vt_end from t_sub where id_sub=%%ENTITY_ID%%), '%%SPEC_NAME%%', %%SPEC_TYPE%%)
            