
        select count(*) from 
        (select distinct "_ACCOUNTID" 
           from (%%INNER_QUERY%%) iq1 ) iq2
			