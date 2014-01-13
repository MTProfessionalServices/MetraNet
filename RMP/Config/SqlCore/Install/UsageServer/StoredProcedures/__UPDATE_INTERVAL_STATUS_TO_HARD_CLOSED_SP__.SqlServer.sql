
/* ===========================================================
If the @ignoreBillingGroups is 1, then 
  (a) Update the accounts in t_acc_usage_interval to 'H' for the given interval
  (b) Update the status of the interval to 'H' in t_usage_interval
Else
  Update the status of the given interval to 'H', if all the accounts for that
  interval in t_acc_usage_interval are 'H'

Returns one of the following:
 O : No error
-1 : Unknown error
-2 : Payer accounts in the interval are Open
=========================================================== */
CREATE PROCEDURE UpdIntervalStatusToHardClosed
(
   @id_interval INT,
   @ignoreBillingGroups INT,
   @status INT OUTPUT
)
AS

BEGIN
   SET @status = -1
   
   IF (@ignoreBillingGroups = 1)
     BEGIN
       /* Update all accounts in t_acc_usage_interval for the given interval to 'H' */
       UPDATE t_acc_usage_interval SET tx_status = 'H'
       WHERE id_usage_interval = @id_interval
       
       /* Update t_usage_interval for the given interval to 'H' */
       UPDATE t_usage_interval SET tx_interval_status = 'H'
       WHERE id_interval = @id_interval 
       SET @status = 0
     END
   ELSE
     BEGIN
         -- All paying accounts in the interval that are 'H'
     IF (SELECT COUNT(AccountID) 
          FROM vw_paying_accounts 
          WHERE IntervalID = @id_interval AND State = 'H') 
          =
          -- All paying accounts in the interval
          (SELECT COUNT(AccountID)  
           FROM vw_paying_accounts
           WHERE IntervalID = @id_interval)
     BEGIN
        UPDATE t_usage_interval 
        SET tx_interval_status = 'H'
        WHERE id_interval = @id_interval 
        SET @status = 0
     END
     ELSE
     BEGIN
       SET @status = -2
     END
   END
END

   