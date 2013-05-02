
        delete from t_pl_map where id_paramtable = %%ID_PROP%%
        /* CR 14459 */
        delete t_pi_rulesetdef_map where id_pt = %%ID_PROP%%
        delete t_rsched where id_pt = %%ID_PROP%%
        delete t_rulesetdefinition where id_paramtable = %%ID_PROP%%
      