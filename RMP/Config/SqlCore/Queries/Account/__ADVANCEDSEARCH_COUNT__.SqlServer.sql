
        select count(1) from 
        (select distinct _AccountID
           from (%%INNER_QUERY%%) iq1 ) iq2
			