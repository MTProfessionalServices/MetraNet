
 begin
	  IF OBJECT_ID('tempdb..#aggregate_large') IS NOT NULL 
		      truncate table #aggregate_large;
	  ELSE
          create table #aggregate_large(
	      id_sess int identity(1,1) not null PRIMARY KEY,
	      id_parent_source_sess binary(16),
	      sessions_in_compound int);
 
	  IF OBJECT_ID('tempdb..#aggregate') IS NOT NULL 
		      truncate table #aggregate;		
	  ELSE
     	 create table #aggregate(
	     id_sess int identity(1,1),
	     id_parent_source_sess binary(16),
	     sessions_in_compound int) ;   
   
	  IF OBJECT_ID('tempdb..#child_session_sets') IS NOT NULL 
		      truncate table #child_session_sets;
	  ELSE	      		            
	      create table #child_session_sets(
			id_sess int identity(1, 1),
			id_parent_sess int not null,
			id_svc int not null,
			cnt int,
			PRIMARY KEY (id_parent_sess, id_svc));
  end;       
	    
	 