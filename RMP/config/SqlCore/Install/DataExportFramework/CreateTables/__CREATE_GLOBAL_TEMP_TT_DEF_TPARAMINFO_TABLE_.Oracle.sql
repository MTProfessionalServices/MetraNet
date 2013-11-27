
             CREATE GLOBAL TEMPORARY TABLE tt_DEF_tparamInfo
             (
            id_rep NUMBER(10,0) ,
            id_rep_instance_id NUMBER(10,0) ,
            c_param_name_value VARCHAR2(500) 
             )ON COMMIT DELETE ROWS
             