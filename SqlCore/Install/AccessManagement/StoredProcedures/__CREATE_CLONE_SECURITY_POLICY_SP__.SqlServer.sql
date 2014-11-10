
					  CREATE procedure CloneSecurityPolicy 
            (@parent_id_acc int,
             @child_id_acc  int ,
             @parent_pol_type varchar(1),
						 @child_pol_type varchar(1))
            as
            
            begin				
            declare @polid INT,			
										@parentPolicy INT,
										@childPolicy INT		
            exec sp_Insertpolicy N'id_acc', @parent_id_acc,@parent_pol_type, @parentPolicy output
  					exec sp_Insertpolicy N'id_acc', @child_id_acc, @child_pol_type,@childPolicy output
						DELETE FROM T_POLICY_ROLE WHERE id_policy = @childPolicy
						INSERT INTO T_POLICY_ROLE
						SELECT @childPolicy, pr.id_role FROM T_POLICY_ROLE pr
						INNER JOIN T_PRINCIPAL_POLICY pp ON pp.id_policy = pr.id_policy
						WHERE pp.id_acc = @parent_id_acc AND
						pp.policy_type = @parent_pol_type
						end
        