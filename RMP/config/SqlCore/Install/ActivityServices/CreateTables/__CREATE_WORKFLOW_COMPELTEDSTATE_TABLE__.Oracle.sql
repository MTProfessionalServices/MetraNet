
              CREATE TABLE t_wf_completedscope (
	            id_instance nvarchar2(36) NOT NULL,
	            id_completedScope nvarchar2(36) NOT NULL,
	            state blob NOT NULL,
	            dt_modified date NOT NULL
              );
              CREATE  INDEX idx_cmpltdscope_completedscope ON t_wf_CompletedScope(id_completedScope);
              CREATE  INDEX idx_cmpltdscope_id_instance ON t_wf_CompletedScope(id_instance);

