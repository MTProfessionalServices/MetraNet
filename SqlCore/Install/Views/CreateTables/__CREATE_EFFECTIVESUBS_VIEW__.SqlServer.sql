
CREATE VIEW T_VW_EFFECTIVE_SUBS ( ID_SUB, 
ID_ACC, ID_PO, DT_START, DT_END, 
DT_CRT, B_GROUP ) AS  
select 
sub.id_sub, 
tgs.id_acc,
sub.id_po,
tgs.vt_start,
tgs.vt_end,
tgs.tt_start as dt_crt,
'Y' b_group
from t_sub sub
INNER JOIN t_gsubmember_historical tgs on sub.id_group = tgs.id_group 
where tgs.tt_end = dbo.MTMaxDate()
UNION ALL
select 
sub.id_sub, 
sub.id_acc,
sub.id_po,
sub.vt_start,
sub.vt_end,
sub.dt_crt,
'N' b_group
from t_sub sub 
WHERE sub.id_group IS NULL
		