
CREATE OR REPLACE PROCEDURE CLONESECURITYPOLICY(
            parent_id_acc 	IN INT  DEFAULT NULL,
            child_id_acc 	IN INT  DEFAULT NULL,
            parent_pol_type 	IN VARCHAR2  DEFAULT NULL,
            child_pol_type 	IN VARCHAR2  DEFAULT NULL)
        AS
            parent_id_acc_ 	NUMBER(10,0) := parent_id_acc;
            child_id_acc_ 	NUMBER(10,0) := child_id_acc;
            parent_pol_type_ 	VARCHAR2(1) := parent_pol_type;
            child_pol_type_ 	VARCHAR2(1) := child_pol_type;
            polid 	NUMBER(10,0);
            parentPolicy 	NUMBER(10,0);
            childPolicy 	NUMBER(10,0);
            tempVar1 	VARCHAR2(255) :='id_acc';
            tempVar2 	VARCHAR2(255) :='id_acc';
        BEGIN
                /* NetMeter*/
				sp_Insertpolicy(tempVar1,CLONESECURITYPOLICY.parent_id_acc_,CLONESECURITYPOLICY.parent_pol_type_,CLONESECURITYPOLICY.parentPolicy);

                /* NetMeter*/
				sp_Insertpolicy(tempVar2,CLONESECURITYPOLICY.child_id_acc_,CLONESECURITYPOLICY.child_pol_type_,CLONESECURITYPOLICY.childPolicy);

                DELETE FROM T_POLICY_ROLE 
                    WHERE id_policy = CLONESECURITYPOLICY.childPolicy;

                INSERT INTO T_POLICY_ROLE 
                    SELECT  CLONESECURITYPOLICY.childPolicy, pr.id_role 
                    FROM T_POLICY_ROLE pr INNER JOIN T_PRINCIPAL_POLICY pp 
                    ON pp.id_policy = pr.id_policy  
                    WHERE pp.id_acc = CLONESECURITYPOLICY.parent_id_acc_  
                    AND pp.policy_type = CLONESECURITYPOLICY.parent_pol_type_;
        END;				
        