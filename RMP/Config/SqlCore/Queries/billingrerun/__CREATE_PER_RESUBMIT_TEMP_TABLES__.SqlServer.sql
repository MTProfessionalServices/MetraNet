
begin
  create table #t_svc_relations(
			      id_svc int primary key,
			      parent_id_svc int);      
 	    
  create table #session(
	       id_ss INT NOT NULL,
               id_source_sess BINARY(16) NOT NULL  
               PRIMARY KEY CLUSTERED (id_ss, id_source_sess)	
	     );
        
	create table #session_set(
	      id_message INT NOT NULL,
        id_ss INT NOT NULL,
        id_svc INT NOT NULL,
        b_root CHAR(1) NOT NULL,
        session_count INT NOT NULL
        PRIMARY KEY CLUSTERED (id_ss)
	     );
        
  create table #message(
	       id_message int PRIMARY KEY
       ) ;
 end;       
	    
	 