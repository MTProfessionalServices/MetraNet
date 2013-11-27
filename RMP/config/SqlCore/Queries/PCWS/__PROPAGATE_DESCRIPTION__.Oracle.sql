
declare c int;
begin
select count(*) into c from t_base_props where id_prop = %%ID_TEMPLATE%% and n_desc <= 0;
IF c > 0
THEN
---*** UPDATE INSTANCE BASE PROPS WITH 0 AND DELETE DESCRIPTIONS IF TEMPLATE HAS NO DEFAULT *** ---
delete from t_description d
where d.id_desc IN (
                        SELECT fq. n_desc FROM (
                        select n_desc
						from t_base_props bbp  join (
						select id_pi_instance from t_pl_map m  join (select id_prop from t_base_props bp  join t_pi_template t on t.id_template = bp.id_prop where bp.n_desc <= 0 
						and	id_prop = %%ID_TEMPLATE%%) 
						templ on templ.id_prop = m.id_pi_template and m.id_paramtable is null) iq
						on iq.id_pi_instance = bbp.id_prop where bbp.n_desc > 0) fq
					);
                        	


update t_base_props tbp set (n_desc, nm_desc)
= (SELECT 0, null from ( SELECT * from t_base_props bbp  join (
    						select id_pi_instance from t_pl_map m  join (select id_prop from t_base_props bp  join t_pi_template t on t.id_template = bp.id_prop where bp.n_desc <= 0 
	      					and	id_prop = %%ID_TEMPLATE%%) 
	       					templ on templ.id_prop = m.id_pi_template and m.id_paramtable is null) iq
		      				on iq.id_pi_instance = bbp.id_prop and bbp.n_desc > 0) fq
		      		WHERE fq.id_prop = tbp.id_prop)
WHERE EXISTS (SELECT 0, null from ( SELECT * from t_base_props bbp  join (
    						select id_pi_instance from t_pl_map m  join (select id_prop from t_base_props bp  join t_pi_template t on t.id_template = bp.id_prop where bp.n_desc <= 0 
	      					and	id_prop = %%ID_TEMPLATE%%) 
	       					templ on templ.id_prop = m.id_pi_template and m.id_paramtable is null) iq
		      				on iq.id_pi_instance = bbp.id_prop and bbp.n_desc > 0) fq
		      		WHERE fq.id_prop = tbp.id_prop);


ELSE
---*** UPDATE INSTANCE DESCRIPTION TEXT IF INSTANCE DESCRIPTION IS AVAILABLE AND TEMPLATE DESCRIPTION IS AVAILABLE

update t_base_props tbp set (nm_desc)   --fq.template_desc 
= (SELECT fq.template_desc 
        from (
        select bp.id_prop, bp.n_desc, bp.nm_desc as inst_desc , templ.nm_desc as template_desc 
		          						from t_base_props bp  join  t_pl_map m on bp.id_prop = m.id_pi_instance
				        							  join (
						          					select bp.id_prop, bp.nm_desc  from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_desc > 0 
								        			) templ on templ.id_prop = m.id_pi_template
        								where bp.n_desc > 0 and m.id_paramtable is null) fq
        where tbp.id_prop = fq.id_prop
    )
WHERE EXISTS (SELECT fq.template_desc 
                from (
                    select bp.id_prop, bp.n_desc, bp.nm_desc as inst_desc , templ.nm_desc as template_desc 
		                    						from t_base_props bp  join  t_pl_map m on bp.id_prop = m.id_pi_instance
				                  							  join (
						                					select bp.id_prop, bp.nm_desc  from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_desc > 0 
								                  			) templ on templ.id_prop = m.id_pi_template
                								where bp.n_desc > 0 and m.id_paramtable is null) fq
                where tbp.id_prop = fq.id_prop
            );

								
---*** INSERT BASE PROPS IF TEMPLATE HAS DEFAULT AND INSTANCES DONT *** ---

    declare seq_id int;
    BEGIN
    select last_number - 1 INTO seq_id from user_sequences where sequence_name = 'SEQ_T_MT_ID';
    --GENERATE NEW IDS 
    insert into t_MT_ID 
    select seq_t_mt_id.NEXTVAL from t_base_props bp  join  t_pl_map m on bp.id_prop = m.id_pi_instance
    									  join (
	       	       							select bp.id_prop, n_desc from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_desc > 0
	   	   		      					) templ on templ.id_prop = m.id_pi_template
    where bp.n_desc <= 0 and m.id_paramtable is null;

    -- INSERT t_description with the new id's
    insert INTO t_description
    select  seq_id + ROWNUM as NextId, %%ID_LANG_CDE%%, templ.nm_desc, null
    from t_base_props bp  join  t_pl_map m on bp.id_prop = m.id_pi_instance
	      								  join (
	       								select bp.id_prop, bp.nm_desc  from t_base_props bp where id_prop = %%ID_LANG_CDE%% and n_desc > 0 
		      							) templ on templ.id_prop = m.id_pi_template
    where bp.n_desc <= 0 and m.id_paramtable is null;    
    



    -- update t_base_props with the new id's and default description
    update t_base_props tbp set (n_desc, nm_desc) 
    =   (      SELECT fq.nm_desc, fq.NextId FROM (
					       			select bp.id_prop, templ.nm_desc as nm_desc, seq_id + ROWNUM as NextId
				    				from t_base_props bp  join  t_pl_map m on bp.id_prop = m.id_pi_instance
			     								join (select bp.id_prop, bp.nm_desc  from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_desc > 0) 
	       										 templ on templ.id_prop = m.id_pi_template
	      							where bp.n_desc <= 0 and m.id_paramtable is null) fq 
    								where fq.id_prop = tbp.id_prop)							    
    WHERE EXISTS 
              (      SELECT fq.nm_desc, fq.NextId FROM (
					       			select bp.id_prop, templ.nm_desc as nm_desc, seq_id + ROWNUM as NextId
				    				from t_base_props bp  join  t_pl_map m on bp.id_prop = m.id_pi_instance
			     								join (select bp.id_prop, bp.nm_desc  from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_desc > 0) 
	       										 templ on templ.id_prop = m.id_pi_template
	      							where bp.n_desc <= 0 and m.id_paramtable is null) fq 
    								where fq.id_prop = tbp.id_prop)	;					  
    
    END;
								
END IF;
end;
              