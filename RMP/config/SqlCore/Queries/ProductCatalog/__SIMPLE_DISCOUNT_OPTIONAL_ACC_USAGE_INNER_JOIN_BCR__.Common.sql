
/*  CR7065: BCR discounts should count usage that falls into the discount interval */
/*  not based on dt_session, but rather on id_interval */
INNER JOIN t_acc_usage
  ON t_acc_usage.id_payee = tmp_2.id_acc AND
     t_acc_usage.id_usage_interval = %%ID_INTERVAL%% AND
     /* the usage still must be contained within subscription boundaries */
     t_acc_usage.dt_session BETWEEN tmp_2.dt_sub_start AND tmp_2.dt_sub_end
/*  we can only filter out non-billing group countable data here because the discount */
/*  period is fully contained in the usage interval (one in the same) */
/*  this ensures that the billing group is well defined over the discount interval */
/*  the billing group constraint takes care of workflow dependencies with */
/*   payees for the usage interval */
INNER JOIN t_billgroup_member bgmember 
  ON bgmember.id_acc = t_acc_usage.id_acc AND
     bgmember.id_billgroup =  %%ID_BILLGROUP%%

