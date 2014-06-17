/*
  Proc: prtn_deploy_usage_table

  Partition non-partition Usage table or add new partition to the partition one.
*/
CREATE OR REPLACE
PROCEDURE prtn_deploy_usage_table(
	p_tab		VARCHAR2
)
authid current_user 
AS
	cnt			INT;
	rowcnt		INT;
	defdb		VARCHAR2(30);	/* default part info */
	defstart	INT;
	defend		INT;
	isconv		INT;			/* Is table corrently not under partition? (Should be converted) */
BEGIN

	/* Nothing to do if system isn't enabled for partitioning */
	IF dbo.isSystemPartitioned() = 0 THEN
		dbms_output.put_line('System not enabled for partitioning.');
		RETURN;
	END IF;

	/* Count active partitions. */	SELECT COUNT(1) INTO cnt
	FROM   t_partition
	WHERE  b_active = 'Y';
	IF (cnt < 2) THEN
		raise_application_error(-20000, 'Found '|| cnt ||' active partitions. Expected at least 2 (including default).');
	END IF;
  
	/* Make sure there's only one default partition. */
	SELECT COUNT(1) INTO cnt
	FROM   t_partition
	WHERE  b_default = 'Y' AND b_active = 'Y';
	IF (cnt != 1) THEN
		raise_application_error(-20000,'Found ' || cnt || ' default partitions. Expected one.');
	END IF;

	/* If the table is not yet parititoned, then this a conversion */
	SELECT COUNT(1) INTO isconv
	FROM   dual
	WHERE  NOT EXISTS (
				SELECT 1
				FROM   user_part_tables
				WHERE  UPPER(table_name) = UPPER(p_tab));

	IF isconv = 1 THEN
		/* Do the converstion.  Only once per table.
		When this call completes the table will be partitioned with
		a default paritions only.  The split op still has to be done. */
		prtn_deploy_table(
			p_tab => p_tab,
			p_tab_type => 'USAGE');
	END IF;

	/* Add as many partitions as needed. */
	ExtendPartitionedTable(p_tab);

	/* Rebuild UNUSABLE global indexes */
	RebuildGlobalIndexes(p_tab);

	/* Rebuild UNUSABLE local index partitions. */
	RebuildLocalIndexParts(p_tab);

	/* Enable all unique constraints (that are DISABLED) */
	AlterTableUniqueConstraints(p_tab, 'enable');

END prtn_deploy_usage_table;
