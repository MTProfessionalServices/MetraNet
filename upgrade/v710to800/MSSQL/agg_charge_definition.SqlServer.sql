create view agg_charge_definition
       
as
        
select
 
a.c_Name as charge_type_id,
        
a.c_AmountChain as charge_qualification_group,
        
a.c_ProductViewName as productview_name,
        
b.c_row_num as row_num,
        
b.c_include_table_name as include_table_name,
        
b.c_source_value as source_value,
        
b.c_target_field as target_field,
        
b.c_include_predicate as include_predicate,
        
b.c_included_field_prefix as included_field_prefix,
        
b.c_field_name as field_name,
        
b.c_population_string as population_string,
        
b.c_mvm_procedure as mvm_procedure,
        
b.c_child_charge_name as child_charge_id,
        
b.c_filter as filter,
        
b.c_default_value as default_value
          
from t_amp_generatedcharge a
          
inner join t_amp_genchargedirective b on a.c_GenCharge_Id = b.c_GenCharge_Id;