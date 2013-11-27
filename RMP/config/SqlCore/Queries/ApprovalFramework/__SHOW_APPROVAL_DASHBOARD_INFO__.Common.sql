

			SELECT c_ChangeType, c_ItemDisplayName, count(*) PendingApprovalCount 
			FROM  t_approvals
			WHERE c_approval_status = 'PENDING APPROVAL'
			GROUP BY c_ChangeType, c_ItemDisplayName


			