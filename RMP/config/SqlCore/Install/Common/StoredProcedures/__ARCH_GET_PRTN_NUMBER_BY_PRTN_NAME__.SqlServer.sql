CREATE PROCEDURE arch_get_prtn_number_by_prtn_name
(
    @partition_name    NVARCHAR(30),
	@table_name        NVARCHAR(30),
	@partition_number  INT OUTPUT
)
AS
BEGIN
    SELECT @partition_number = p.partition_number
    FROM   sys.partitions p
           INNER JOIN sys.allocation_units au
                ON  au.container_id = p.hobt_id
           INNER JOIN sys.filegroups fg
                ON  fg.data_space_id = au.data_space_id
    WHERE  p.object_id = OBJECT_ID(@table_name)
           AND fg.name = @partition_name
END