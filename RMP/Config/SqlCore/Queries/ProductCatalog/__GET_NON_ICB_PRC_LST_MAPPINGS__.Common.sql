
  select * from ( 
    select
      tpm.id_paramtable, 
      COALESCE(tpt.nm_name, tbp1.nm_name) as tpt_nm_name,
      tpm.id_pricelist, 
      COALESCE(tpl.nm_name, tbp2.nm_name) as tpl_nm_name,
      b_canICB, 
      COALESCE(tpt.nm_display_name, tbp1.nm_display_name) as nm_display_name,
      rec.n_rating_type as n_rating_type
    from t_pl_map tpm
      join t_base_props tbp1 ON tbp1.id_prop = tpm.id_paramtable
      left outer join t_vw_base_props tpt on tpt.id_prop = tbp1.id_prop and tpt.id_lang_code = %%ID_LANG%%
      left outer join t_base_props tbp2 ON tbp2.id_prop = tpm.id_pricelist
      left outer join t_vw_base_props tpl on tpl.id_prop = tbp2.id_prop and tpl.id_lang_code = %%ID_LANG%%
      left outer join t_recur rec on rec.id_prop = tpm.id_pi_instance
    where id_pi_instance = %%ID_PI%% and tpm.id_sub is null
    /*  ESR-5730 did not displayed all PI in left tab when create new PO */
  ) main
  where (main.n_rating_type = 0 and upper(main.tpt_nm_name) = upper('metratech.com/udrctiered'))
     or (main.n_rating_type = 1 and upper(main.tpt_nm_name) = upper('metratech.com/udrctapered'))
     or (upper(main.tpt_nm_name) not in(upper('metratech.com/UDRCTapered'), upper('metratech.com/UDRCTiered')))
  order by %%%UPPER%%%(main.tpt_nm_name)
  