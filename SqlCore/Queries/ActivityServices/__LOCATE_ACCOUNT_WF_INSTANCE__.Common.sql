
		      select tam.%%PK_COLUMN%% as id_acc, wfMap.id_workflow_instance from 
	          %%INSTANCE_TABLE_NAME%% tam
	          left outer join
	          (select id_acc as id_account, id_workflow_instance from t_wf_acc_inst_map 
              where workflow_type = '%%WORKFLOW_TYPE%%' and 
                    id_type_instance = '%%TYPE_INSTANCE_ID%%' ) wfMap 
              on tam.%%PK_COLUMN%% = wfMap.id_account
          where 
	          %%QUERY_PREDICATE%%
        