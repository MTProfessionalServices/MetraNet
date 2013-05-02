
  (
      EXISTS
      (
        SELECT 1 FROM
        t_account_ancestor anc, t_acc_ownership own, t_account_ancestor ownedanc
        where
          anc.id_descendent = own.id_owner and
          anc.id_ancestor = %%ID_ACTOR%%  and
          ownedanc.id_descendent = acc.id_acc and
          own.vt_start <= %%REFDATE%% and own.vt_end > %%REFDATE%%
          AND anc.vt_start <= %%REFDATE%% and anc.vt_end > %%REFDATE%%
          and own.tt_end = dbo.MTMaxDate()
          AND own.id_owned = ownedanc.id_ancestor
          AND anc.num_generations < %%AUTH_LIMITATION%%               
      )
      
      OR EXISTS
      (
        SELECT 1 FROM
        t_account_ancestor anc, t_impersonate incumb, t_acc_ownership own, t_account_ancestor ownedanc
        where
             anc.id_ancestor = incumb.id_acc AND 
             incumb.id_owner = %%ID_ACTOR%% AND
             anc.id_descendent = own.id_owner AND
             ownedanc.id_descendent = acc.id_acc AND
             own.vt_start <= %%REFDATE%% and own.vt_end > %%REFDATE%%
             AND anc.vt_start <= %%REFDATE%% and anc.vt_end > %%REFDATE%%
             AND own.tt_end = dbo.MTMaxDate()
             AND own.id_owned = ownedanc.id_ancestor
             AND anc.num_generations < %%AUTH_LIMITATION%%
      )
      OR EXISTS
      (
        SELECT 1 FROM
        t_account_ancestor anccorpfilter 
          WHERE anccorpfilter.id_descendent = acc.id_acc
          AND %%CORPORATE_ACCOUNTS%%
          AND anccorpfilter.vt_start <= %%REFDATE%% AND anccorpfilter.vt_end > %%REFDATE%%
      )
      )
      