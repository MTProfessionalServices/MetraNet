
		 CREATE OR REPLACE procedure PIResolutionByID(
				  dt_session IN DATE,
				  temp_id_pi_template IN INTEGER,
				  temp_id_acc IN INTEGER,
				  PICUR OUT sys_refcursor)
			AS
			BEGIN
				OPEN PICUR FOR 
				  select 
				  typemap.id_po,
				  typemap.id_pi_instance,
				  sub.id_sub
				  from
				  t_pl_map typemap 
				  , t_sub sub 
				  where
				  typemap.id_po = sub.id_po
				  and (sub.vt_start <= PIResolutionByID.dt_session)
				  and (sub.vt_end >= PIResolutionByID.dt_session)
				  and typemap.id_paramtable is null
				  and typemap.id_pi_template = PIResolutionByID.temp_id_pi_template
				  and sub.id_acc =  PIResolutionByID.temp_id_acc;
			END PIResolutionByID;
			  