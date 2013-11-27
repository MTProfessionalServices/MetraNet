
        SELECT id_approval FROM t_approvals WHERE c_CurrentState NOT IN ('Applied','Dismissed') AND c_ChangeType = ? AND c_UniqueItemId = ?
			