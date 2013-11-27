
        select count(1) from
        (select distinct _AccountID, username, name_space
           from (%%INNER_QUERY%%) iq1 ) iq2
			