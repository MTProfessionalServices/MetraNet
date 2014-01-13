	   
		    IF OBJECT_ID('t_rerun_session_%%RERUN_ID%%') IS NOT NULL 
		      DROP table t_rerun_session_%%RERUN_ID%%
		    IF OBJECT_ID('t_source_rerun_session_%%RERUN_ID%%') IS NOT NULL 
		      DROP table t_source_rerun_session_%%RERUN_ID%%
		    IF OBJECT_ID('t_UIDList_%%RERUN_ID%%') IS NOT NULL 
		      DROP table t_UIDList_%%RERUN_ID%%
		      

	  