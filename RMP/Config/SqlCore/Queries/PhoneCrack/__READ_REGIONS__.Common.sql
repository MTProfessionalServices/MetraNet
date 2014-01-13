
		  select code, countryname, description, international, tollfree, localcodetable from phone_region
		  where %%%UPPER%%%(countryname) = %%%UPPER%%%('%%COUNTRY%%')
	  