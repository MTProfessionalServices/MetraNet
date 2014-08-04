select 
pv.id_sess
from t_pv_accountcredit pv
where pv.c_SubscriberAccountID = @AccountID
and pv.c_MiscAdjustmentID = @MiscAdjustmentID