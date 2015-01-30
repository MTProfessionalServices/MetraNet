
            CREATE OR REPLACE PROCEDURE Sp_Insertpolicy
            (aPrincipalColumn VARCHAR2, aPrincipalID INT, aPolicyType VARCHAR2, ap_id_prop OUT INT)
            AS
            str VARCHAR2(2000);
            selectstr VARCHAR2(2000);
            BEGIN
	            /* make this stored proc idempotent */
	            selectstr := 'SELECT id_policy  FROM t_principal_policy WHERE '||aPrincipalColumn||' = '||aPrincipalID||' AND ';
	            selectstr := selectstr ||'upper(policy_type)=upper('''||aPolicyType ||''')';
	            str := 'INSERT INTO t_principal_policy (id_policy, '||aPrincipalColumn||', policy_type)';
	            str := str || ' VALUES (seq_t_principal_policy.nextval,'|| aPrincipalID ||', '''|| aPolicyType ||''')';
	            BEGIN
		            EXECUTE IMMEDIATE selectstr  INTO ap_id_prop;
		            EXCEPTION WHEN NO_DATA_FOUND THEN
						EXECUTE IMMEDIATE str;
						SELECT seq_t_principal_policy.CURRVAL INTO ap_id_prop FROM dual;
	            END;
            END;				