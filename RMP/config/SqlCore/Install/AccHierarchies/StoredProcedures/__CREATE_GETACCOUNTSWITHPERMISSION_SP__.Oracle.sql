
create or replace
PROCEDURE GetAccountsWithPermission
  (
    AccountID IN NUMBER)
AS
  pathval   VARCHAR2(2000);
  accessval NUMBER(10,0);
  CURSOR cur
  IS
    SELECT '/1'
      || TO_CHAR(tpc.param_value) AS pathval,
      tec.param_value             AS accessval
    FROM
      (SELECT MAX(
        CASE
          WHEN tact.tx_progid = 'Metratech.MTPathCapability'
          THEN tci.id_cap_instance
          ELSE NULL
        END) AS pc_id ,
        MAX(
        CASE
          WHEN tact.tx_progid = 'Metratech.MTEnumTypeCapability'
          THEN tci.id_cap_instance
          ELSE NULL
        END) AS ec_id ,
        tci.id_policy ,
        tci.id_parent_cap_instance
      FROM t_capability_instance tci
      JOIN t_atomic_capability_type tact
      ON tci.id_cap_type                = tact.id_cap_type
      WHERE tci.id_parent_cap_instance IS NOT NULL
      GROUP BY tci.id_policy,
        tci.id_parent_cap_instance
      ) tmp
  JOIN t_path_capability tpc
  ON tpc.id_cap_instance = tmp.pc_id
  JOIN t_enum_capability tec
  ON tec.id_cap_instance = tmp.ec_id
  JOIN t_principal_policy tpp
  ON tpp.id_policy = tmp.id_policy
  WHERE tmp.pc_id IS NOT NULL
  AND tpp.id_acc   = AccountID;
  
  idx         NUMBER        :=1;
  Str         VARCHAR2(2000):= NULL;
  Slice       VARCHAR2(2000):= NULL;
  Lst         VARCHAR2(2000):= NULL;
  accessLevel NUMBER;
  accID       NUMBER;
  isSuperUser NUMBER;
BEGIN
  DELETE FROM TMP_ACC_PERMISSION;
  DELETE FROM TMP_ACC_PERMISSION_GROUPED;
  
  SELECT COUNT(*)
  INTO isSuperUser
  FROM t_principal_policy pp 
	JOIN t_policy_role pr on pp.id_policy = pr.id_policy AND pp.id_acc = AccountID
	JOIN t_role r on pr.id_role = r.id_role AND r.tx_name = 'Super User';
  
  IF isSuperUser <> 0 THEN
	  RETURN;
  END IF;
  
  OPEN cur;
  LOOP
    FETCH cur INTO pathval, accessval;
    
    EXIT
  WHEN cur%NOTFOUND;
    idx := 1;
    Str       := pathval;
    WHILE idx <> 0
    LOOP
      idx     := INSTR(Str, '/', 1);
      IF idx  <> 0 THEN
        Slice := SUBSTR(Str,1, idx - 1);
      ELSE
        Slice := Str;
      END IF;
      dbms_output.put_line('Slice=' || Slice);
      IF Slice       = '-' THEN
        accessLevel := 2;
        accID       := CAST(Lst AS NUMBER);
      END IF;
      IF Slice       = '*' THEN
        accessLevel := 1;
        accID       := CAST(Lst AS NUMBER);
      END IF;
      IF Slice      IS NULL AND (Str IS NULL OR LENGTH(Str) <> LENGTH(pathval)) THEN
        accessLevel := 0;
        accID       := CAST(Lst AS NUMBER);
      END IF;
      IF Slice NOT IN ('-', '*') AND Slice IS NOT NULL THEN
        INSERT
        INTO TMP_ACC_PERMISSION
          (
            AccountID,
            Permission
          )
          VALUES
          (
            CAST(Slice AS NUMBER),
            1
          );
      END IF;
      IF Slice IS NOT NULL THEN
        Lst := Slice;
      END IF;
      Str := SUBSTR(Str,idx+1);
    END LOOP;
    INSERT
    INTO TMP_ACC_PERMISSION
      (
        AccountID,
        Permission
      )
      VALUES
      (
        accID,
        accessval
      );
    INSERT INTO TMP_ACC_PERMISSION
      (AccountID, Permission
      )
    SELECT id_descendent,
      accessval
    FROM t_account_ancestor
    WHERE id_ancestor  = accID
    AND accessLevel    > 0
    AND (accessLevel   = 2
    OR num_generations = 1);
  END LOOP;
  CLOSE cur;
  INSERT INTO TMP_ACC_PERMISSION_GROUPED
    (AccountID, WritePermission
    )
  SELECT t1.AccountID ,
    CASE
      WHEN Perm > 2
      THEN 1
      ELSE 0
    END
  FROM
    (SELECT AccountID,
      MAX(Permission) AS Perm
    FROM TMP_ACC_PERMISSION
    GROUP BY AccountID
    ) t1;
  
END;
