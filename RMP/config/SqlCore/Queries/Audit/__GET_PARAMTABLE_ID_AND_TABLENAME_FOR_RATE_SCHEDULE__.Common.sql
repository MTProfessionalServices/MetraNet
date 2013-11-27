
select nm_instance_tablename, rsd.id_paramtable from t_rulesetdefinition rsd inner join t_rsched rs on rsd.id_paramtable = rs.id_pt 
where rs.id_sched= %%RS_ID%%
        