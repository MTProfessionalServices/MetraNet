
        select id_descendent from t_account_ancestor with (NOLOCK) where id_ancestor =  %%PARENTACCOUNTID%%
      