
              CREATE GLOBAL TEMPORARY TABLE tt_DEF_Export_Status_Table
              (
                status_item VARCHAR2(255) ,
                status_msg VARCHAR2(255) 
              )
             ON COMMIT DELETE ROWS
             