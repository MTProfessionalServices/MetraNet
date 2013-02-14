SELECT 
    a.nm_service_def, 
    a.nm_table_name, 
    b.* 
FROM 
    t_service_def_log a INNER JOIN t_service_def_prop b ON a.id_service_def = b.id_service_def           
