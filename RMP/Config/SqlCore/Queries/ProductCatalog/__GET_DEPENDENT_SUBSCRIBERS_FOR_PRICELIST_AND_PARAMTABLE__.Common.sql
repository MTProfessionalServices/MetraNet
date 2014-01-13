
  select
  /* __GET_DEPENDENT_SUBSCRIBERS_FOR_PRICELIST_AND_PARAMTABLE__ */
          sub.id_group as id,
          case
              when sub.id_group is not null 
              then N'Group Subscription: ' %%%CONCAT%%% gsub.tx_name
              else N'Non-Group Subscriptions'
          end as name,
          count(sub.id_acc) as count, min(vt_start) as minstart,
          max(vt_end) as maxend
      from t_vw_allrateschedules_po rspo 
      inner join t_vw_expanded_sub sub 
        on rspo.id_po = sub.id_po
      left outer join t_group_sub gsub 
        on sub.id_group = gsub.id_group
    where id_paramtable = %%ID_PARAMTABLE%%
      and id_pricelist = %%ID_PRICELIST%%
  group by sub.id_group, gsub.tx_name
  union
  select null as id, N'Default Price List Associations' as name,
        count(acc.id_acc) as count, null as minstart, null as maxend
    from t_vw_allrateschedules_pl rspl 
    join t_av_internal acc 
      on rspl.id_pricelist = acc.c_pricelist
  where id_paramtable = %%ID_PARAMTABLE%%
    