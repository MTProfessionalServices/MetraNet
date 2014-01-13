
declare c int;
begin
select count(*) into c from t_base_props where id_prop = %%ID_TEMPLATE%% and n_display_name <= 0;
IF c > 0
THEN
---*** UPDATE INSTANCE BASE PROPS WITH 0 AND DELETE DESCRIPTIONS IF TEMPLATE HAS NO DEFAULT *** ---
delete from t_description d
where d.id_desc IN (
                        SELECT fq. n_display_name FROM (
                        select n_display_name
						from t_base_props bbp  join (
						select id_pi_instance from t_pl_map m  join (select id_prop from t_base_props bp  join t_pi_template t on t.id_template = bp.id_prop where bp.n_display_name <= 0 
						and	id_prop = %%ID_TEMPLATE%%) 
						templ on templ.id_prop = m.id_pi_template and m.id_paramtable is null) iq
						on iq.id_pi_instance = bbp.id_prop where bbp.n_display_name > 0) fq
					);
                        	


update t_base_props tbp set (n_display_name, nm_display_name)
= (SELECT 0, null from ( SELECT * from t_base_props bbp  join (
    						select id_pi_instance from t_pl_map m  join (select id_prop from t_base_props bp  join t_pi_template t on t.id_template = bp.id_prop where bp.n_display_name <= 0 
	      					and	id_prop = %%ID_TEMPLATE%%) 
	       					templ on templ.id_prop = m.id_pi_template and m.id_paramtable is null) iq
		      				on iq.id_pi_instance = bbp.id_prop and bbp.n_display_name > 0) fq
		      		WHERE fq.id_prop = tbp.id_prop)
WHERE EXISTS (SELECT 0, null from ( SELECT * from t_base_props bbp  join (
    						select id_pi_instance from t_pl_map m  join (select id_prop from t_base_props bp  join t_pi_template t on t.id_template = bp.id_prop where bp.n_display_name <= 0 
	      					and	id_prop = %%ID_TEMPLATE%%) 
	       					templ on templ.id_prop = m.id_pi_template and m.id_paramtable is null) iq
		      				on iq.id_pi_instance = bbp.id_prop and bbp.n_display_name > 0) fq
		      		WHERE fq.id_prop = tbp.id_prop);


ELSE
---*** UPDATE INSTANCE DISPLAYNAME TEXT IF INSTANCE DISPLAYNAME IS AVAILABLE AND TEMPLATE DISPLAYNAME IS AVAILABLE

update t_base_props tbp set (nm_display_name)   --fq.template_displayname 
= (SELECT fq.template_displayname 
        from (
        select bp.id_prop, bp.n_display_name, bp.nm_display_name as inst_displayname , templ.nm_display_name as template_displayname 
		          						from t_base_props bp  join  t_pl_map m on bp.id_prop = m.id_pi_instance
				        							  join (
						          					select bp.id_prop, bp.nm_display_name  from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_display_name > 0 
								        			) templ on templ.id_prop = m.id_pi_template
        								where bp.n_display_name > 0 and m.id_paramtable is null) fq
        where tbp.id_prop = fq.id_prop
    )
WHERE EXISTS (SELECT fq.template_displayname 
                from (
                    select bp.id_prop, bp.n_display_name, bp.nm_display_name as inst_displayname , templ.nm_display_name as template_displayname 
		                    						from t_base_props bp  join  t_pl_map m on bp.id_prop = m.id_pi_instance
				                  							  join (
						                					select bp.id_prop, bp.nm_display_name  from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_display_name > 0 
								                  			) templ on templ.id_prop = m.id_pi_template
                								where bp.n_display_name > 0 and m.id_paramtable is null) fq
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
	       	       							select bp.id_prop, n_display_name from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_display_name > 0
	   	   		      					) templ on templ.id_prop = m.id_pi_template
    where bp.n_display_name <= 0 and m.id_paramtable is null;

    -- INSERT t_description with the new id's
    insert INTO t_description
    select  seq_id + ROWNUM as NextId, %%ID_LANG_CDE%%, templ.nm_display_name, null
    from t_base_props bp  join  t_pl_map m on bp.id_prop = m.id_pi_instance
	      								  join (
	       								select bp.id_prop, bp.nm_display_name  from t_base_props bp where id_prop = %%ID_LANG_CDE%% and n_display_name > 0 
		      							) templ on templ.id_prop = m.id_pi_template
    where bp.n_display_name <= 0 and m.id_paramtable is null;    
    



    -- update t_base_props with the new id's and default display names
    update t_base_props tbp set (n_display_name, nm_display_name) 
    =   (      SELECT fq.nm_display_name, fq.NextId FROM (
					       			select bp.id_prop, templ.nm_display_name as nm_display_name, seq_id + ROWNUM as NextId
				    				from t_base_props bp  join  t_pl_map m on bp.id_prop = m.id_pi_instance
			     								join (select bp.id_prop, bp.nm_display_name  from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_display_name > 0) 
	       										 templ on templ.id_prop = m.id_pi_template
	      							where bp.n_display_name <= 0 and m.id_paramtable is null) fq 
    								where fq.id_prop = tbp.id_prop)							    
    WHERE EXISTS 
              (      SELECT fq.nm_display_name, fq.NextId FROM (
					       			select bp.id_prop, templ.nm_display_name as nm_display_name, seq_id + ROWNUM as NextId
				    				from t_base_props bp  join  t_pl_map m on bp.id_prop = m.id_pi_instance
			     								join (select bp.id_prop, bp.nm_display_name  from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_display_name > 0) 
	       										 templ on templ.id_prop = m.id_pi_template
	      							where bp.n_display_name <= 0 and m.id_paramtable is null) fq 
    								where fq.id_prop = tbp.id_prop)	;					  
    
    END;
								
END IF;
end;			  
              