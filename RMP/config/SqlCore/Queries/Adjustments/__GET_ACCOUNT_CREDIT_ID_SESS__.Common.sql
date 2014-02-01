select 
pv.id_sess
from t_pv_accountcredit pv
inner join t_acc_usage au on au.id_sess = pv.id_sess
where au.id_acc = @AccountID
and pv.c_MiscAdjustmentID = @MiscAdjustmentID