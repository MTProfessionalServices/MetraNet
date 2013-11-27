
      select t_gsubmember.id_acc,
      t_gsubmember.vt_start,
      t_gsubmember.vt_end,
      vwname.hierarchyname acc_name,
      tav.c_folder
      from t_gsubmember 
      INNER JOIN vw_hierarchyname vwname on vwname.id_acc = t_gsubmember.id_acc
      INNER JOIN t_av_internal tav on tav.id_acc = t_gsubmember.id_acc
      where t_gsubmember.id_group = %%ID_GROUP%% 
			