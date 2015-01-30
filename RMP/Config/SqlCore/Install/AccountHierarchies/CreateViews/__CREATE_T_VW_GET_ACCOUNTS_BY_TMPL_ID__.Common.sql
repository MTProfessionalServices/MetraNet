
CREATE VIEW T_VW_GET_ACCOUNTS_BY_TMPL_ID
AS
WITH rec (id_template, id_descendent, vt_start, vt_end, id_acc_type, id_type, l) as
(
    SELECT at.id_acc_template id_template, aa.id_descendent, aa.vt_start, aa.vt_end, at.id_acc_type, a.id_type id_type, 1 l
      FROM t_account_ancestor aa
           join t_acc_template at on aa.id_descendent = at.id_folder
           join t_account a on a.id_acc = at.id_folder
     WHERE aa.num_generations = 0
    union all
    SELECT rec.id_template, aa.id_descendent, aa.vt_start, aa.vt_end, rec.id_acc_type, a.id_type, rec.l + 1
      FROM t_account_ancestor aa
           join rec on aa.id_ancestor = rec.id_descendent and aa.num_generations = 1
           join t_account a on a.id_acc = aa.id_descendent
     WHERE not exists (SELECT 1 FROM t_acc_template at WHERE aa.id_descendent = at.id_folder and at.id_acc_type = rec.id_acc_type)
)

SELECT id_template, id_descendent, vt_start, vt_end FROM rec, t_acc_tmpl_types tatt
WHERE tatt.all_types <> 0 OR rec.id_type = rec.id_acc_type
