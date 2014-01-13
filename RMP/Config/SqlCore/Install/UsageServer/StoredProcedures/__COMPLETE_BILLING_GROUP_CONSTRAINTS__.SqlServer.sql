
/* ===========================================================
This is executed after the adapters have created billing group constraints in
t_billgroup_constraint_tmp.

1) Fill in missing payers 
If any of the accounts in t_billgroup_source_acc do not exist
in t_billgroup_constraint_tmp after the adapters have created
their constraint groups, then create one group per account for
the remaining accounts.

2) Validate that the id_group in t_billgroup_constraint_tmp is correctly named 
ie. it must be any one of the account IDs in the constraint group

3) Prunes (must be regular) and coalesces constraint groups. 
If constraint groups intersect, they will be coalesced into 
larger groups containing a union of the intersecting groups. 
Worst case, all groups will coalesce into one supergroup 
representing every payer in the interval. 
By the end of this process, there will be one row for 
every payer and every payer will belong to exactly one constraint group.

Returns:
-1 if an unknown error has occurred
-2 if the accounts in t_billgroup_constraint_tmp are not paying accounts
-3 if the id_group is not named as one of the accounts in the group
-4 if there are duplicate id_acc for the given @id_materialization
============================================================== */
CREATE PROCEDURE CompleteBillGroupConstraints
(
   @id_materialization INT,
   @status INT OUTPUT
)
AS

BEGIN 
   -- initialize @status to failure (-1)
   SET @status = -1 

   BEGIN TRAN
  
   /* Store the id_usage_interval */
   DECLARE @id_usage_interval INT
   SELECT @id_usage_interval = id_usage_interval
   FROM t_billgroup_materialization
   WHERE id_materialization = @id_materialization

   /* Validate that the accounts in t_billgroup_constraint_tmp are paying accounts */
   IF (EXISTS (SELECT 1
                    FROM t_billgroup_constraint_tmp bctmp
                    WHERE id_usage_interval = @id_usage_interval AND
                                NOT exists (select 1  FROM t_acc_usage_interval aui
											INNER JOIN t_account_mapper amap ON amap.id_acc = aui.id_acc
											  INNER JOIN t_namespace nmspace ON nmspace.nm_space = amap.nm_space
											  WHERE  nmspace.tx_typ_space = 'system_mps' 
											  and aui.id_acc = bctmp.id_acc
											  and aui.id_usage_interval = @id_usage_interval)))
    BEGIN
       SET @status = -2
       ROLLBACK
       RETURN 
    END

    /* Validate that the id_group in t_billgroup_constraint_tmp is correctly named 
       ie. it must be any one of the account IDs in the constraint group */
    IF (EXISTS (SELECT 1 
	         FROM t_billgroup_constraint_tmp t1
	         WHERE t1.id_group NOT IN (SELECT id_acc
					     FROM t_billgroup_constraint_tmp
					     WHERE id_group = t1.id_group)))
     BEGIN
       SET @status = -3
       ROLLBACK
       RETURN 
    END

    /* coalesces constraint groups into a set of unique, disjoint supergroups  */
DECLARE group_cursor CURSOR FOR
	select distinct id_group from t_billgroup_constraint_tmp
	where id_acc in
	(
	   select id_acc from
		t_billgroup_constraint_tmp
		group by id_acc,id_usage_interval
		having count(id_group) > 1
	)
OPEN group_cursor
DECLARE @group INT
FETCH NEXT FROM group_cursor INTO @group
WHILE @@FETCH_STATUS = 0
BEGIN

  -- check if group still exists 
  IF NOT EXISTS(SELECT * FROM t_billgroup_constraint_tmp where id_group = @group)
  BEGIN
    FETCH NEXT FROM group_cursor into @group
    CONTINUE
  END

  -- figure out which other groups reference accounts from this group
  DECLARE @otherGroups TABLE (id_group int)
  INSERT INTO @otherGroups
  SELECT distinct c2.id_group
  FROM t_billgroup_constraint_tmp c
  INNER JOIN t_billgroup_constraint_tmp c2 
      ON c2.id_acc = c.id_acc AND
            c2.id_usage_interval = c.id_usage_interval
  WHERE c.id_group = @group AND c2.id_group <> @group

  -- adds the additional groups' members to the group we are currently processing
  INSERT INTO t_billgroup_constraint_tmp (id_usage_interval, id_group, id_acc)
  SELECT DISTINCT
    @id_usage_interval,
    @group,
    id_acc
  FROM t_billgroup_constraint_tmp 
  WHERE 
    id_group IN (SELECT * FROM @otherGroups) AND
    id_acc NOT IN (SELECT id_acc 
                            FROM t_billgroup_constraint_tmp 
                            WHERE id_group = @group AND
                                        id_usage_interval = @id_usage_interval) AND
    id_usage_interval = @id_usage_interval

  -- deletes the additional groups now that we've copied their members
  DELETE FROM t_billgroup_constraint_tmp WHERE id_group IN (SELECT * FROM @otherGroups)

  FETCH NEXT FROM group_cursor into @group
END
CLOSE group_cursor
DEALLOCATE group_cursor

 /* Fill in missing payers.
      Adds in the remaining constraint groups of single payers
      that don't already exist in any other constraint groups */
   INSERT INTO t_billgroup_constraint_tmp(id_usage_interval, id_group, id_acc)
   SELECT @id_usage_interval,
               id_acc,
               id_acc
   FROM t_billgroup_source_acc
   WHERE id_materialization = @id_materialization AND
               id_acc NOT IN (SELECT id_acc 
                                       FROM t_billgroup_constraint_tmp 
                                       WHERE id_usage_interval = @id_usage_interval)

   /* Check for duplicate accounts */
   IF EXISTS (SELECT id_acc 
                   FROM t_billgroup_constraint_tmp
	       WHERE id_usage_interval = @id_usage_interval 
	       GROUP BY id_acc
	       HAVING COUNT(id_acc) > 1)
   BEGIN
     SET @status = -4
     ROLLBACK
     RETURN 
   END

  SET @status = 0
  COMMIT
END

 