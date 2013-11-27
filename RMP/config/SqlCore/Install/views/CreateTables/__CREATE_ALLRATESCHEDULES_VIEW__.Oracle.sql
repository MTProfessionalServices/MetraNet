
			create view t_vw_allrateschedules
			  as
					select id_po,id_paramtable,id_pi_instance,id_pi_template,id_sub,id_sched,dt_mod,rs_begintype, rs_beginoffset,rs_beginbase, rs_endtype,rs_endoffset,rs_endbase,id_pricelist from t_vw_allrateschedules_po
					union all
					select id_po,id_paramtable,id_pi_instance,id_pi_template,id_sub,id_sched,dt_mod,rs_begintype, rs_beginoffset,rs_beginbase,rs_endtype,rs_endoffset,rs_endbase,id_pricelist from t_vw_allrateschedules_pl			  
		