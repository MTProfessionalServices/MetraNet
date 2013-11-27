
SELECT /*+  Index (t_dm_account IDX_DM_ACCOUNT )   */  id_acc id_ancestor
  FROM t_dm_account
 WHERE id_dm_acc =
(SELECT id_dm_acc
   FROM (SELECT   derived.id_dm_ancestor AS id_dm_acc
        FROM (SELECT aad2.*
             FROM (SELECT aad1.id_dm_ancestor, aad1.cnt,
                    MAX (aad1.cnt) OVER (ORDER BY aad1.cnt DESC)
                                           AS max_cnt
               FROM 
                 (SELECT   /*+  Index( aa IDX1_DM_ACCOUNT_ANCESTOR ) */ aa.id_dm_ancestor,
                           COUNT (*) AS cnt
                      FROM t_dm_account_ancestor aa,
                           t_dm_account a2
                     WHERE a2.id_dm_acc =
                                aa.id_dm_descendent
                       AND EXISTS 
		(
                         SELECT /*+  Index (au IDX2_T_MV_PAYEE_SESSION )  */  1
                           FROM t_mv_payee_session au
                          WHERE au.id_dm_acc = a2.id_dm_acc
                            AND au.id_acc = %%ID_ACC%% AND
 			%%TIME_PREDICATE%%
                            AND au.dt_session BETWEEN a2.vt_start AND a2.vt_end
		/* where acc.vt_start <= %%END_DATE%% and acc.vt_end > %%BEGIN_DATE%% */
		)
                  GROUP BY aa.id_dm_ancestor
                  ORDER BY COUNT (*) DESC) aad1) aad2
            WHERE aad2.cnt = aad2.max_cnt) derived,
          t_dm_account_ancestor aa2
       WHERE aa2.id_dm_descendent = derived.id_dm_ancestor
         AND aa2.id_dm_ancestor = (SELECT  /*+  Index (t_dm_account IDX1_DM_ACCOUNT ) */  id_dm_acc
                                     FROM t_dm_account
                                    WHERE id_acc = 1)
    ORDER BY derived.cnt DESC, aa2.num_generations DESC)
  WHERE ROWNUM < 2
)
UNION
SELECT /*+  Index (t_dm_account IDX_DM_ACCOUNT )   */  id_acc id_ancestor
  FROM t_dm_account
 WHERE id_dm_acc =
(SELECT id_dm_acc
   FROM (SELECT   derived.id_dm_ancestor AS id_dm_acc
        FROM (SELECT aad2.*
             FROM (SELECT aad1.id_dm_ancestor, aad1.cnt,
                    MAX (aad1.cnt) OVER (ORDER BY aad1.cnt DESC)
                                           AS max_cnt
               FROM 
                 (SELECT   /*+  Index( aa IDX1_DM_ACCOUNT_ANCESTOR ) */ aa.id_dm_ancestor,
                           COUNT (*) AS cnt
                      FROM t_dm_account_ancestor aa,
                           t_dm_account a2
                     WHERE a2.id_dm_acc =
                                aa.id_dm_descendent
                       AND EXISTS 
		(
                         SELECT /*+  Index (au IDX2_T_MV_PAYEE_SESSION )  */  1
                           FROM t_mv_payee_session au
                          WHERE au.id_dm_acc = a2.id_dm_acc
                            AND au.id_acc = %%ID_ACC%% AND
 			%%TIME_PREDICATE%%
                            AND au.dt_session BETWEEN a2.vt_start AND a2.vt_end
		/* where acc.vt_start <= %%END_DATE%% and acc.vt_end > %%BEGIN_DATE%% */
		)
                  GROUP BY aa.id_dm_ancestor
                  ORDER BY COUNT (*) DESC) aad1) aad2
            WHERE aad2.cnt = aad2.max_cnt) derived,
          t_dm_account_ancestor aa2
       WHERE aa2.id_dm_descendent = derived.id_dm_ancestor
         AND aa2.id_dm_ancestor = (SELECT  /*+  Index (t_dm_account IDX1_DM_ACCOUNT ) */  id_dm_acc
                                     FROM t_dm_account
                                    WHERE id_acc = =%%ID_ACC%%)
    ORDER BY derived.cnt DESC, aa2.num_generations DESC)
  WHERE ROWNUM < 2
)
