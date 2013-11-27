
		      select cast(instanceTable.%%PK_COLUMN%% as varchar2(36)) as id_instance, wfMap.id_workflow_instance from 
	          %%INSTANCE_TABLE_NAME%% instanceTable
	          left outer join
	          (select id_instance, id_workflow_instance from t_wf_be_inst_map 
              where workflow_type = '%%WORKFLOW_TYPE%%' and 
                    id_type_instance = '%%TYPE_INSTANCE_ID%%' ) wfMap 
              on instanceTable.%%PK_COLUMN%% = wfMap.id_instance
          where 
	          %%QUERY_PREDICATE%%
        