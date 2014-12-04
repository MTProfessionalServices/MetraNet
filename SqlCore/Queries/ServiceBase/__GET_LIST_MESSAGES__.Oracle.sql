
  select id_origin_message as id 
     from t_message_mapping 
     where id_origin_message in (%%ID_MESSAGES%%)
     union all
      select id_message as id
from t_message_mapping  
START WITH id_origin_message in (%%ID_MESSAGES%%)
CONNECT BY PRIOR  id_message =id_origin_message
        