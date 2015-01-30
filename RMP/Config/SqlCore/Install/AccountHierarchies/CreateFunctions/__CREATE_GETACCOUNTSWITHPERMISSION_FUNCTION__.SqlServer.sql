
create FUNCTION GetAccountsWithPermission
(
	@AccountID INT
)
returns @rettable TABLE (
	AccountID INT NOT NULL PRIMARY KEY
	,WritePermission BIT
)
as
begin
	DECLARE @temptable TABLE (
		AccountID INT
		,Permission INT
	)
	
	DECLARE @pathval NVARCHAR(2000)
	DECLARE @accessval INT
	
	DELETE FROM @temptable

	DECLARE cur CURSOR FOR 
		SELECT N'/1' + tpc.param_value as pathval
				,tec.param_value as accessval
			FROM (
				SELECT MAX(CASE WHEN tact.tx_progid = N'Metratech.MTPathCapability' THEN tci.id_cap_instance ELSE NULL END) AS pc_id
						,MAX(CASE WHEN tact.tx_progid = N'Metratech.MTEnumTypeCapability' THEN tci.id_cap_instance ELSE NULL END) AS ec_id
						,tci.id_policy
						,tci.id_parent_cap_instance
					FROM t_capability_instance tci
					JOIN t_atomic_capability_type tact ON tci.id_cap_type = tact.id_cap_type
					WHERE tci.id_parent_cap_instance IS NOT NULL 
					GROUP BY tci.id_policy, tci.id_parent_cap_instance
			) tmp
			JOIN t_path_capability tpc ON tpc.id_cap_instance = tmp.pc_id
			JOIN t_enum_capability tec ON tec.id_cap_instance = tmp.ec_id
			JOIN t_principal_policy tpp ON tpp.id_policy = tmp.id_policy
			WHERE tmp.pc_id IS NOT NULL AND tpp.id_acc = @AccountID

	OPEN cur
	FETCH NEXT FROM cur INTO @pathval, @accessval
	WHILE @@FETCH_STATUS = 0 BEGIN
	    DECLARE @idx INT
	    DECLARE @String NVARCHAR(MAX)
	    DECLARE @Slice NVARCHAR(MAX)
	    DECLARE @Last NVARCHAR(MAX)
	    DECLARE @accessLevel INT
	    DECLARE @accID INT
	    SET @Slice = NULL
	    SET @Last = NULL
	    SET @String = @pathval
	    SET @idx = 1
	    
	    WHILE @idx <> 0 BEGIN
			SET @idx = CHARINDEX(N'/', @String, 1)
			IF @idx <> 0
				SET @Slice = LEFT(@String,@idx - 1)
			ELSE 
				SET @Slice = @String
				
			IF @Slice = N'-' BEGIN
				SET @accessLevel = 2
				SET @accID = CAST(@Last AS INT)
			END
			IF @Slice = N'*' BEGIN
				SET @accessLevel = 1
				SET @accID = CAST(@Last AS INT)
			END
			IF @Slice = N'' AND LEN(@String) <> LEN(@pathval) BEGIN
				SET @accessLevel = 0
				SET @accID = CAST(@Last AS INT)
			END
			IF @Slice NOT IN (N'-', N'*', N'') BEGIN 
				INSERT INTO @temptable (AccountID, Permission)
					VALUES(CAST(@Slice AS INT), 1)
			END 
			SET @Last = @Slice

			SET @String = RIGHT(@String,LEN(@String) - @idx)
	    END
	    INSERT INTO @temptable (AccountID, Permission) VALUES(@accID, @accessval)

	    INSERT INTO @temptable (AccountID, Permission) 
		SELECT id_descendent, @accessval
			FROM t_account_ancestor
			WHERE id_ancestor = @accID
				AND @accessLevel > 0 AND (@accessLevel = 2 OR num_generations = 1) 
		FETCH NEXT FROM cur INTO @pathval, @accessval
	END
	CLOSE cur
	DEALLOCATE cur
	
	INSERT INTO @rettable (AccountID, WritePermission)
	SELECT t1.AccountID
			, CASE WHEN Perm > 2 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
		FROM (
			SELECT AccountID, MAX(Permission) AS Perm
				FROM @temptable
				GROUP BY AccountID
		) t1
		
	RETURN
end
