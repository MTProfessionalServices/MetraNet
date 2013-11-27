
/* ===========================================================
Verify that there is an entry in t_invoice for the given interval and account.
============================================================== */
SELECT COUNT(id_invoice) numInvoice
FROM t_invoice 
WHERE id_interval = %%ID_INTERVAL%% AND 
      id_acc = %%ID_ACC%% 
       
 