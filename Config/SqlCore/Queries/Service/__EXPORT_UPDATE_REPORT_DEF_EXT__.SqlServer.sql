
				exec export_UpdateReportDefinition @id_rep = %%ID_REP%%, @c_report_desc = %%REPORT_DESC%%,
					@c_rep_type=%%REPORT_TYPE%%, @c_rep_def_source= %%DEFN_SOURCE%%, 
					@c_rep_query_source=%%QUERY_SOURCE%%, @c_rep_query_tag=%%QUERY_TAG%%,
					@c_prevent_adhoc_execution=%%PREVENT_ADHOC_EXECUTION%%
			