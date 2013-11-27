
/* ===========================================================
Update the status of the given interval to 'H', if all the accounts for that
interval in t_acc_usage_interval are 'H'

Returns one of the following:
 O : No error
-1 : Unknown error
-2 : Payer accounts in the interval are Open
=========================================================== */
CREATE OR REPLACE
PROCEDURE UpdIntervalStatusToHardClosed
(
   p_id_interval INT,
   ignoreBillingGroups INT,
   status out INT 
)
AS
  hard_cnt int;     /* All paying accounts in the interval that are 'H' */
  all_cnt int; /* All paying accounts in the interval */
BEGIN
   status := -1;
  
  if (ignoreBillingGroups = 1)
  then
     /* Update all accounts in t_acc_usage_interval for the given interval to 'H' */
       UPDATE t_acc_usage_interval SET tx_status = 'H'
       WHERE id_usage_interval = p_id_interval;
       
       /* Update t_usage_interval for the given interval to 'H' */
       UPDATE t_usage_interval SET tx_interval_status = 'H'
       WHERE id_interval = p_id_interval;
       status := 0;
  else
  
  select 
    count(*) as allrows, 
    COALESCE(sum(case state when 'H' then 1 else 0 end), 0)
      as hardclosed
  into 
    all_cnt, 
    hard_cnt
  from vw_paying_accounts
  where IntervalID = p_id_interval;
    
  if (hard_cnt = all_cnt) then
      UPDATE t_usage_interval 
        SET tx_interval_status = 'H'
        WHERE id_interval = p_id_interval;

      status := 0;
   else
     status := -2;
   end if;
 end if;
END UpdIntervalStatusToHardClosed;
   