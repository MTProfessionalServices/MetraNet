
      (
      EXISTS
      (
        SELECT 1 FROM
        t_account_ancestor anc
        INNER join t_acc_ownership own on anc.id_descendent = own.id_owner AND  anc.id_ancestor = %%ID_ACTOR%%
        /* we join t_account_ancestor (ownedanc) because there is an implicit rule, that I can find an account
        as long as I own any of this account's ancestors */
        INNER join t_account_ancestor ownedanc on ownedanc.id_descendent = acc.id_acc
        WHERE
        own.vt_start <= %%REFDATE%% and own.vt_end > %%REFDATE%%
        AND anc.vt_start <= %%REFDATE%% and anc.vt_end > %%REFDATE%%
        and own.tt_end = dbo.MTMaxDate()
        AND 
        own.id_owned = ownedanc.id_ancestor
        /* AUTH_LIMITATION limits the number of generations between actor
         and his subordinates that the actor is allowed to manage ownerships for:
         less than 1 - only directly owned accounts; less than 2 - directly owned accounts and direct descendents;
         less than 1000000 - no limit (all descendents) */
        AND anc.num_generations < %%AUTH_LIMITATION%%
      )
      OR EXISTS
      (
      SELECT 1 FROM
      t_account_ancestor anc 
      INNER JOIN t_impersonate incumb ON anc.id_ancestor = incumb.id_acc AND incumb.id_owner = %%ID_ACTOR%%
      INNER join t_acc_ownership own on anc.id_descendent = own.id_owner
      /* we join t_account_ancestor (ownedanc) because there is an implicit rule, that I can find an account
       as long as I own any of this account's ancestors */
      INNER join t_account_ancestor ownedanc on ownedanc.id_descendent = acc.id_acc

      WHERE
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
      