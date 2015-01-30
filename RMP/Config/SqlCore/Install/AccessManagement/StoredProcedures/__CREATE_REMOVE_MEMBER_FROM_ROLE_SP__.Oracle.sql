
          CREATE OR REPLACE PROCEDURE RemoveMemberFromRole
          (
            aRoleID IN INTEGER,
            aAccountID IN INTEGER,
            status OUT INTEGER
          )
          AS
            accType VARCHAR(3);
            polID INTEGER;
            bCSRAssignableFlag VARCHAR(1);
            bSubscriberAssignableFlag VARCHAR(1);
            scratch INTEGER;
          BEGIN
            status := 1;
	          begin
				  SELECT id_policy INTO polID FROM T_PRINCIPAL_POLICY WHERE id_acc = aAccountID AND policy_type = 'A';
			  exception
				  when no_data_found then
					null;
			  end;
	          BEGIN
	            SELECT id_policy INTO scratch FROM T_POLICY_ROLE WHERE id_policy = polID AND id_role = aRoleID;
	            EXCEPTION WHEN NO_DATA_FOUND THEN
              	 RETURN;
	          END;
           DELETE FROM T_POLICY_ROLE WHERE id_policy = polID AND id_role = aRoleID;
          END RemoveMemberFromRole;
        