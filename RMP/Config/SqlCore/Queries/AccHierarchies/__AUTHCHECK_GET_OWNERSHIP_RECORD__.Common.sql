
       select 1
       /* __AUTHCHECK_GET_OWNERSHIP_RECORD__ */
       from t_account_ancestor anc
      inner join t_acc_ownership own on anc.id_descendent = own.id_owner
      where anc.id_ancestor = %%ID_OWNER%% 
      AND own.id_owned = %%ID_OWNED%%
      AND own.vt_start <= %%%SYSTEMDATE%%% and own.vt_end > %%%SYSTEMDATE%%%
      AND anc.vt_start <= %%%SYSTEMDATE%%% and anc.vt_end > %%%SYSTEMDATE%%%
      /* VIEW_CONSTRAINT is based on the results of ManagedOwnedFolders capability check */
      AND anc.num_generations < %%VIEW_CONSTRAINT%%
      and own.tt_end = %%MAX_DATE%%
      UNION ALL
      select 1
      from t_impersonate incum
      inner join t_account_ancestor anc ON incum.id_acc = anc.id_ancestor
      inner join t_acc_ownership own on anc.id_descendent = own.id_owner
      where incum.id_owner = %%ID_OWNER%%
      AND own.id_owned = %%ID_OWNED%%
      AND own.vt_start <= %%%SYSTEMDATE%%% and own.vt_end > %%%SYSTEMDATE%%%
      AND anc.vt_start <= %%%SYSTEMDATE%%% and anc.vt_end > %%%SYSTEMDATE%%%
      /* VIEW_CONSTRAINT is based on the results of ManagedOwnedFolders capability check */
      AND anc.num_generations < %%VIEW_CONSTRAINT%%
      and own.tt_end = %%MAX_DATE%%
        