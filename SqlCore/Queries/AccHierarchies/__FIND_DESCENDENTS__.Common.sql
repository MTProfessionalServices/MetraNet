
        select
        /* __FIND_DESCENDENTS__ */
        ancestor.id_descendent
        from t_account_ancestor ancestor
	        INNER JOIN t_account_state accstate on 
			        accstate.id_acc = ancestor.id_descendent and
              %%REFDATE%% between accstate.vt_start AND accstate.vt_end AND
              accstate.status in ('AC','PA','PF','SU') 
          INNER JOIN t_av_internal tav on ancestor.id_descendent = tav.id_acc
          INNER JOIN t_account acc
            ON acc.id_acc = ancestor.id_descendent
          INNER JOIN t_account_type atype
            ON atype.id_type = acc.id_type
        where ancestor.id_ancestor = %%ANCESTOR%%
        AND id_descendent <> 1 /* just in case someone adds the root as an acount at some date */
        AND %%REFDATE%% between ancestor.vt_start AND ancestor.vt_end
        AND %%ACCTYPE_PREDICATE%%
        %%NUMGENERATIONS%%
        %%NOFOLDERS%%
		