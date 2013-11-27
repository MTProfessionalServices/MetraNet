
CREATE OR REPLACE 
procedure copytemplate(
p_id_folder IN integer,
p_id_accounttype integer,
p_id_parent IN integer,
p_systemdate IN date,
p_enforce_same_corporation varchar2,
p_status OUT integer)
as
parentID integer;
cdate date;
nexttemplate integer;
parentTemplateID integer;
begin
      if p_enforce_same_corporation = '1' AND p_id_parent is NULL then
      FOR i IN ( select id_ancestor
      from t_account_ancestor where id_descendent = p_id_folder
      AND p_systemdate between vt_start AND vt_end AND
                 num_generations = 1 ) 
      LOOP
          parentID := i.id_ancestor;
      END LOOP;
      IF parentID is NULL THEN
        p_status := -486604771; /* MT_PARENT_NOT_IN_HIERARCHY*/
        return;
      END IF;
    else
      parentID := p_id_parent;  
    end if;
   begin
    select id_acc_template into parentTemplateID 
    from t_acc_template
    where id_folder = parentID and id_acc_type = p_id_accounttype;
    exception when NO_DATA_FOUND then
    /*MT_PARENT_TEMPLATE_DOES_NOT_EXIST*/
    p_status := -486604772;
    return;
  end;
  
  clonesecuritypolicy(parentID,p_id_folder,'D', 'D');
  
  insert into t_acc_template 
  (id_acc_template,id_folder,dt_crt,tx_name,tx_desc,b_applydefaultpolicy,id_acc_type)
  select seq_t_acc_template.NEXTVAL,p_id_folder,p_systemdate,
  tx_name,tx_desc,b_applydefaultpolicy,id_acc_type
  from t_acc_template where id_folder = parentID
	and id_acc_type = p_id_accounttype;
  select seq_t_acc_template.CURRVAL into nexttemplate from dual;
  
  insert into t_acc_template_props (id_prop,id_acc_template,nm_prop_class,
  nm_prop,nm_value)
  select seq_t_acc_template_props.NEXTVAL,nexttemplate,
  existing.nm_prop_class,existing.nm_prop,existing.nm_value
  from 
  t_acc_template_props existing where 
  existing.id_acc_template = parentTemplateID;
  
	insert into t_acc_template_subs_pub (id_po, id_group, id_acc_template,vt_start,vt_end)
  select existing.id_po,existing.id_group,nexttemplate,existing.vt_start,existing.vt_end
  from t_acc_template_subs_pub existing
  where
  existing.id_acc_template = parentTemplateID;
  p_status := 1;
end;
				