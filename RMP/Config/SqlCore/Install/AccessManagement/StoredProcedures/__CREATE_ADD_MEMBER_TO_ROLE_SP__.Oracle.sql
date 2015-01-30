
CREATE OR REPLACE PROCEDURE addmembertorole (
   p_roleid            INT,
   p_accountid         INT,
   p_status      OUT   INT
)
AS
   v_acctype                     VARCHAR2 (40);
   v_polid                       INT;
   v_bcsrassignableflag          VARCHAR2 (1);
   v_bsubscriberassignableflag   VARCHAR2 (1);
   v_scratch                     INT;
BEGIN
   p_status := 0; /* evaluate business rules: role has to     be assignable to the account type     returned errors:      MTAUTH_ROLE_CAN_NOT_BE_ASSIGNED_TO_SUBSCRIBER ((DWORD)0xE29F001CL) (-492896228)     MTAUTH_ROLE_CAN_NOT_BE_ASSIGNED_TO_CSR ((DWORD)0xE29F001DL) (-492896227)     */

   SELECT atype.NAME
     INTO v_acctype
     FROM t_account acc INNER JOIN t_account_type atype ON acc.id_type =
                                                                 atype.id_type
    WHERE id_acc = p_accountid;

   SELECT csr_assignable, subscriber_assignable
     INTO v_bcsrassignableflag, v_bsubscriberassignableflag
     FROM t_role
    WHERE id_role = p_roleid;

   IF v_acctype <> 'SystemAccount'
   THEN
      IF (UPPER (v_bsubscriberassignableflag) = 'N')
      THEN
         p_status := -492896228;
         RETURN;
      END IF;
   ELSIF UPPER (v_bcsrassignableflag) = 'N'
   THEN
      p_status := -492896227;
      RETURN;
   END IF; /* Get policy id for this account. sp_InsertPolicy will either   insert a new one or get existing one   */

   sp_insertpolicy ('id_acc', p_accountid, 'A', v_polid);
/* make the stored proc idempotent, only insert mapping record if     it's not already there
*/

   SELECT COUNT (1)
     INTO v_scratch
     FROM DUAL
    WHERE EXISTS (SELECT id_policy
                    FROM t_policy_role
                   WHERE id_policy = v_polid AND id_role = p_roleid);

   IF v_scratch = 0
   THEN
      INSERT INTO t_policy_role
                  (id_policy, id_role
                  )
           VALUES (v_polid, p_roleid
                  );
   END IF;

   p_status := 1;
END addmembertorole;
   