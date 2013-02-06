select 
  lower(regexp_substr(nm_enum_data,'[^/]*$')) enum_value, 
  lower(trim(TRAILING '/' from regexp_substr(nm_enum_data,'.*/'))) namespace,  
  id_enum_data 
from 
  t_enum_data a
