
insert into  %%%TEMP_TABLE_PREFIX%%%tmp_nrc_gsubmember
select 
/* __PREPROCESS_INDIVIDUAL_SUBSCRIPTIONS_FOR_NRC__ */
s1.id_po,
s1.id_acc,
s1.id_sub,
s1.vt_start,
s1.vt_end,
s1.tt_start,
s1.tt_end,
dbo.MTMaxOfTwoDates(s1.vt_start, s1.tt_start) as max_vt_tt_start, 
dbo.MTMaxOfTwoDates(s1.vt_end, s1.tt_start) as max_vt_tt_end, 
s1.id_sub position 
from t_sub_history s1
where
s1.id_group is null
  		