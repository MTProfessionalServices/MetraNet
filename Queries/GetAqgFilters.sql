select 
	account_qualification_group Aqg,
	filter Filter
from 
	account_qualification_groups 
where 
	filter IS NOT NULL