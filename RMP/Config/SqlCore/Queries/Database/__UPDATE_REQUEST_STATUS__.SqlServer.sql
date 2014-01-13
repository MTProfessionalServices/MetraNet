
      update t_pv_AccountCreditRequest
      set c_Status = '%%CREDIT_REQUEST_STATUS%%', c_CreditAmount = %%CREDITAMOUNT%% 
      where id_sess = %%SESSION_ID%%
      