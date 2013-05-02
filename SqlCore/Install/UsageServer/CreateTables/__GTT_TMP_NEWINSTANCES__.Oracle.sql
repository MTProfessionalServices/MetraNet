
create global temporary table tmp_newinstances(
  id_instance_temp int not null,    
  id_instance_parent int,    
  id_instance_child int,    
  id_event int,    
  tx_status varchar2(14),    
  id_run_parent int,    
  id_run_child int)
		