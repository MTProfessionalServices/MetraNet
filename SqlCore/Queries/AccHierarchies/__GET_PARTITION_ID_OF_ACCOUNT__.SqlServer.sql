SELECT     t_account_ancestor.id_ancestor
FROM         t_account INNER JOIN
                      t_account_type ON t_account.id_type = t_account_type.id_type INNER JOIN
                      t_account_ancestor ON t_account.id_acc = t_account_ancestor.id_ancestor
WHERE     (t_account_ancestor.id_descendent = @idAcc) AND (t_account_type.name = 'Partition')