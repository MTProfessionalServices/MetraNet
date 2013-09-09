CREATE OR REPLACE FUNCTION 
 prtn_GetMeterPartFileGroupName
 /*Full prtn_GetMeterPartitionFileGroupName function name uses in MSSQL*/
RETURN VARCHAR2
IS
	v_partitionname VARCHAR2(50);
BEGIN  
 
	select user || '_MeterFileGroup'
    into v_partitionname from dual;
	
	return v_partitionname;
END;

				