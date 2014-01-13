
      insert into #session (id_ss, id_source_sess)
	select id_ss  + (%%NUM_REGULAR_MESSAGES%% * %%I%%) , rr.id_source_sess
	from %%RERUN_TABLE_NAME%% rr
	inner join #session ss
	on ss.id_source_sess = rr.id_parent_source_sess
	where ss.id_ss >= %%ID_SESSIONSET_START%%
	and ss.id_ss < %%ID_SESSIONSET_START%% + (%%NUM_REGULAR_MESSAGES%% * %%I%%)
	and rr.id_svc = %%ID_CHILD_SVC%%
	      
       
	insert into #session_set(id_ss, id_message, id_svc, session_count, b_root)
		select ss.id_ss , parentset.id_message, %%ID_CHILD_SVC%%, count(*), '0'
		from #session ss
		inner join %%RERUN_TABLE_NAME%% rr
		on ss.id_source_sess = rr.id_source_sess
		left outer join #session parent
		on parent.id_source_sess = rr.id_parent_source_sess
		left outer join #session_set parentset
		on parentset.id_ss = parent.id_ss
		where ss.id_ss >= (%%ID_SESSIONSET_START%% + (%%NUM_REGULAR_MESSAGES%% * %%I%%)) 
		and ss.id_ss < (%%ID_SESSIONSET_START%% + (%%NUM_REGULAR_MESSAGES%% * (%%I%% + 1))) 
		and parentset.id_message >= %%ID_MESSAGE_START%%
		and parentset.id_message < %%ID_MESSAGE_START%% + %%NUM_REGULAR_MESSAGES%%
		group by ss.id_ss, parentset.id_message
    			         
	  