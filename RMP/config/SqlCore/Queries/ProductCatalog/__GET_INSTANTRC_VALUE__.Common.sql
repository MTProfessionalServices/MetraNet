select case value when N'true' then 'Y' else 'N' END as InstantRCValue
from t_db_values where parameter like 'InstantRc'
		