
					CREATE procedure copytemplate(
					@id_folder int,
					@p_id_accounttype int,
					@id_parent int,
          @p_systemdate datetime,
          @p_enforce_same_corporation varchar,
					@status int output)
					as
				 	begin
					declare @parentID int
					declare @cdate datetime
					declare @nexttemplate int
					declare @parentTemplateID int
					 begin
						--only check same hierarchy for parent if corp business rule is
						--enforced.
						if (@p_enforce_same_corporation = '1' AND @id_parent is NULL)
						 begin
							select @parentID = id_ancestor 
							from t_account_ancestor where id_descendent = @id_folder
							AND @p_systemdate between vt_start AND vt_end AND
							num_generations = 1
						  if (@parentID is null)
							 begin
						     select @status = -486604771 -- MT_PARENT_NOT_IN_HIERARCHY
							   return
							 end
						 end
						else
						 begin
							select @parentID = @id_parent  
						 end 
						end	
						begin
							select @parentTemplateID = id_acc_template from t_acc_template
							where id_folder = @parentID and id_acc_type = @p_id_accounttype
							if (@parentTemplateID is null)
							 begin
								SELECT @status = -486604772
							  return
							 end
						end	
							
							exec clonesecuritypolicy @id_parent,@id_folder,'D','D'

							insert into t_acc_template 
							 (id_folder,dt_crt,tx_name,tx_desc,b_applydefaultpolicy, id_acc_type)
							 select @id_folder,@p_systemdate,
							 tx_name,tx_desc,b_applydefaultpolicy, id_acc_type
							 from t_acc_template where id_folder = @parentID
							 and id_acc_type = @p_id_accounttype
  					  select @nexttemplate =@@identity
         		  
							insert into t_acc_template_props (id_acc_template,nm_prop_class,
							nm_prop,nm_value)
							select @nexttemplate,existing.nm_prop_class,existing.nm_prop,
							existing.nm_value from 
							t_acc_template_props existing where 
							existing.id_acc_template = @parentTemplateID

							insert into t_acc_template_subs_pub (id_po, id_group, id_acc_template,
							vt_start,vt_end)
						  select existing.id_po, existing.id_group, @nexttemplate,
							existing.vt_start,existing.vt_end
							from t_acc_template_subs_pub existing
							where
							existing.id_acc_template = @parentTemplateID
							
							select @status = 1
					 end
				