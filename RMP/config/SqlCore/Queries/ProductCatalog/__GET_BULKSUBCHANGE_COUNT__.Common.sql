
select count(*)
  from t_sub
 where id_po = %%ID_OLD_PO%%
   and vt_end >= %%DATE%%
   and id_group is null
      