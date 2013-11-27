
        select count(*) from 
        (select distinct "_ACCOUNTID", "USERNAME", "NAME_SPACE"
           from (%%INNER_QUERY%%) iq1 ) iq2
			