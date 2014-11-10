
        CREATE OR REPLACE PROCEDURE Grantallcapabilitytoaccount
        (aLoginName VARCHAR2, aNameSpace VARCHAR2) AS
          polID INT;
		      dummy INT;
		      aAccountID INT;
          BEGIN
		        dummy := 0;
            polID := 0;
		      	aAccountID := 0;
				begin
					 SELECT id_acc INTO aAccountID FROM t_account_mapper WHERE upper(nm_login) = upper(aLoginName) AND upper(nm_space) = upper(aNameSpace);
					 EXCEPTION
					 WHEN NO_DATA_FOUND THEN
			                 /* RAISERROR('No Records found in t_account_mapper for Login Name %s and NameSpace %s', 16, 2, aLoginName,  aNameSpace) */
							 raise_application_error(-20162, 'No Records found in t_account_mapper for Login Name ' || aLoginName || ' and NameSpace ' || aNameSpace);
              	END;
				
		        BEGIN
		          SELECT id_policy INTO polID FROM T_PRINCIPAL_POLICY WHERE id_acc = aAccountID AND policy_type = 'A';
		          EXCEPTION WHEN NO_DATA_FOUND THEN
		          Sp_Insertpolicy('id_acc', aAccountID, 'A', polID);
		        END;
  			    BEGIN
			        SELECT id_policy INTO dummy FROM T_CAPABILITY_INSTANCE WHERE id_policy = polID;
			        EXCEPTION WHEN NO_DATA_FOUND THEN
		            INSERT INTO T_CAPABILITY_INSTANCE VALUES
			          (seq_t_cap_instance.NEXTVAL, NULL, NULL, polID,
			          (SELECT id_cap_type FROM T_COMPOSITE_CAPABILITY_TYPE WHERE tx_name = 'Unlimited Capability')
         	      );
			    END;
         END Grantallcapabilitytoaccount;
				