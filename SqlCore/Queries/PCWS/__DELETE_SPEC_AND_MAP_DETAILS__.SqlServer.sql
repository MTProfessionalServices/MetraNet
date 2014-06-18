
                  exec DeleteDescription %%ID_CATEGORY%%
                  exec DeleteDescription %%ID_DISPLAY_NAME%%
                  exec DeleteDescription %%ID_DESC%%
                  delete from t_spec_val_map where id_spec = %%ID_SPEC%%
                  delete from t_spec_characteristics where id_spec = %%ID_SPEC%%                              
            