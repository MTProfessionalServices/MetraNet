
               select
                   id_spec                   
                from t_spec_characteristics
                where                
                  c_category = '%%CATEGORY%%' AND
                  nm_description = '%%DESCRIPTION%%' AND
                  nm_name = '%%NAME%%'    
                order by id_spec
            