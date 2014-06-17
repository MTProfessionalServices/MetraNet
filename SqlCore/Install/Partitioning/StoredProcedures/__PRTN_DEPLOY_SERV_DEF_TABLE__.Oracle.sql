CREATE OR REPLACE
PROCEDURE prtn_deploy_serv_def_table(
    p_tab               VARCHAR2
)
authid CURRENT_USER 
AS
    is_not_partitioned  INT;  /* is table not partitioned yet? */
    current_id_part     INT;
    is_part_enabled     VARCHAR2(1);
BEGIN

    SELECT UPPER(b_partitioning_enabled) INTO is_part_enabled FROM t_usage_server;
    /* Nothing to do if system isn't enabled for partitioning */
    IF is_part_enabled <> 'Y' THEN 
        dbms_output.put_line('System not enabled for partitioning.');
        RETURN;
    END IF;

    /* If the table is not yet parititoned, then this a conversion */
    SELECT COUNT(1) INTO is_not_partitioned
    FROM   dual
    WHERE  NOT EXISTS (
               SELECT 1
               FROM   user_part_tables
               WHERE  UPPER(table_name) = UPPER(p_tab)
           );

    IF is_not_partitioned = 1 THEN 

        /* Do the converstion.  Only once per table.
        When this call completes the table will be partitioned with
        a default paritions only.  The split op still has to be done. */
        prtn_deploy_table(
            p_tab => p_tab,
            p_tab_type => 'METER');

        /* Rebuild UNUSABLE global indexes */
        RebuildGlobalIndexes(p_tab);

        /* Rebuild UNUSABLE local index partitions. */
        RebuildLocalIndexParts(p_tab);

        /* Enable all unique constraints (that are DISABLED) */
        AlterTableUniqueConstraints(p_tab, 'enable');

        dbms_output.put_line('First partition was created for "' || p_tab || '" with current id_partition = ' || current_id_part);

    END IF;

END prtn_deploy_serv_def_table;
