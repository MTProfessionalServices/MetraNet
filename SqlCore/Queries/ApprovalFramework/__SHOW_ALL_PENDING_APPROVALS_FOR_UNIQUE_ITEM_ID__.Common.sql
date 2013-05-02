

			SELECT id_approval, c_SubmittedDate, c_SubmitterId, c_ChangeType, c_ChangeDetails, c_ApproverId, c_ChangeLastModifiedDate, c_ItemDisplayName, c_Comment, c_CurrentState
            		FROM  t_approvals
            		WHERE c_UniqueItemId= %%UniqueItemId%%
                        AND c_CurrentState = 'PENDING APPROVAL'


			