
CREATE VIEW t_vw_expanded_sub
(
id_sub,
id_acc,
id_po,
vt_start,
vt_end,
dt_crt,
id_group,
id_group_cycle,
b_supportgroupops
)
AS 
SELECT
   sub.id_sub,
   CASE WHEN sub.id_group IS NULL THEN sub.id_acc ELSE mem.id_acc END id_acc,
   sub.id_po,
   CASE WHEN sub.id_group IS NULL THEN sub.vt_start ELSE mem.vt_start END vt_start,
   CASE WHEN sub.id_group IS NULL THEN sub.vt_end ELSE mem.vt_end END vt_end,
   sub.dt_crt,
   sub.id_group,
   gsub.id_usage_cycle,
   CASE WHEN sub.id_group IS NULL THEN 'N' ELSE gsub.b_supportgroupops END b_supportgroupops
FROM  
   t_sub sub
   LEFT OUTER JOIN t_group_sub gsub ON gsub.id_group = sub.id_group
   LEFT OUTER JOIN t_gsubmember mem ON mem.id_group = gsub.id_group
