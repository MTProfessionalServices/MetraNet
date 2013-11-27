
                    -- Displays info about existing partitions
                    CREATE VIEW v_partition_info AS
                    SELECT 
                          OBJECT_NAME(i.object_id) as c_object_name, 
                        p.partition_number AS c_partition_number, 
                        fg.name AS c_filegroup_name, 
                        ROWS AS c_rows_in_partition, 
                        au.total_pages AS c_total_pages,
                        CASE boundary_value_on_right
                            WHEN 1 THEN 'less than'
                            ELSE 'less than or equal to' 
                            END as 'c_comparison', 
                        VALUE AS c_boundary_value
                    FROM sys.partitions p 
                    JOIN sys.indexes i
                        ON p.object_id = i.object_id and p.index_id = i.index_id
                    JOIN sys.partition_schemes ps
                        ON ps.data_space_id = i.data_space_id
                    JOIN sys.partition_functions f
                        ON f.function_id = ps.function_id
                    LEFT JOIN  sys.partition_range_values rv
                          ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id
                    JOIN sys.destination_data_spaces dds
                        ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number
                    JOIN sys.filegroups fg
                        ON dds.data_space_id = fg.data_space_id
                    JOIN (SELECT container_id, sum(total_pages) as total_pages
                        FROM sys.allocation_units
                        GROUP BY container_id) AS au
                        ON au.container_id = p.partition_id
                