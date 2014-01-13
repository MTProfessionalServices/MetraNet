
/* ===========================================================
Returns 'Y' if the id_parent_billgroup will become empty if the pull list for the
given materialization is allowed to be created
=========================================================== */
SELECT 
CASE 
    WHEN (SELECT COUNT(id_acc) 
               FROM t_billgroup_member bgm
               WHERE bgm.id_billgroup = %%ID_PARENT_BILLGROUP%%)
               =
              (SELECT COUNT(bgm.id_acc) 
               FROM t_billgroup_member bgm
               INNER JOIN t_billgroup_member_tmp bgmt ON bgmt.id_acc = bgm.id_acc
               WHERE bgm.id_billgroup = %%ID_PARENT_BILLGROUP%% AND
                           bgmt.id_materialization =  %%ID_MATERIALIZATION%%)   
    THEN 'Y'
    ELSE 'N'
    END as EmptyParentBillGroup
%%%FROMDUAL%%%
   