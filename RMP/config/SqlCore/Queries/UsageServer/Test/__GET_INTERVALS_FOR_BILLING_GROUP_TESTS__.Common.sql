
/* ===========================================================
Return the list of intervals which have account mappings for 
only those account id's specified in %%COMMA_SEPARATED_ACCOUNT_IDS%%.
============================================================== */
SELECT aui1.id_usage_interval  
FROM t_acc_usage_interval aui1  
INNER JOIN (SELECT id_usage_interval, COUNT(id_acc) numAccounts             
            FROM t_acc_usage_interval              
            GROUP BY id_usage_interval) aui2  
ON aui1.id_usage_interval = aui2.id_usage_interval  
WHERE aui1.id_acc IN (%%COMMA_SEPARATED_ACCOUNT_IDS%%) 
GROUP BY aui1.id_usage_interval, aui2.numAccounts  
HAVING COUNT(aui1.id_acc) = aui2.numAccounts AND          
       COUNT(aui1.id_acc) = %%NUMBER_OF_ACCOUNTS%%
 