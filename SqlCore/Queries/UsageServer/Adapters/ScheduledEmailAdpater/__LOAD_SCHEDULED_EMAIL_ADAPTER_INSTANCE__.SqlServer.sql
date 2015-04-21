SELECT 
(
SELECT 
  TOP 1 I.id_event
FROM t_recevent_run R
INNER JOIN t_recevent_inst I on I.id_instance = R.id_instance
WHERE R.id_run = %%ID_RUN%%
) AS 'ID_EVENT',
(
SELECT 
  mapping.id_sch_email_entity_mapping
FROM 
t_sch_email_entity_mapping mapping
WHERE mapping.column_name = '%%ENTITY_ID_COLUMNNAME%%'
) AS 'ID_MAPPING'
         
      