
          SELECT 
            am.ExtAccount as ExtAccountID,
            inv.current_balance as Balance
          FROM VW_AR_ACC_MAPPER am
          INNER JOIN t_invoice inv ON am.id_acc = inv.id_acc and id_interval = %%ID_INTERVAL%%
          WHERE am.ExtNamespace = '%%NAME_SPACE%%'
         