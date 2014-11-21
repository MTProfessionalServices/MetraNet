select 
    dbo.GenGuid() "ID", /* dummy filed as identifier for GridLayout*/ 
    COALESCE(partition_name, N'Non-Partitioned') "PARTITION", 
    concat(mapClient.nm_login, mapClient.nm_space, avi.c_TaxExemptEndDate) 'Unique identifier',
	mapClient.nm_login 'User Identifier',
	isnull(avcClient.c_FirstName + ' ','') + isnull(avcClient.c_LastName,'') 'Name',
	isnull(avi.c_TaxExemptID,0) 'Tax Exempt ID',
	avi.c_TaxExemptEndDate 'Tax Exempt Expiry Date',
	avcClient.c_city City,
	avcClient.c_state 'State',
	avcClient.c_zip 'Zip',
	descCountry.tx_desc Country
from t_account_mapper mapClient
inner join t_av_internal avi on mapClient.id_acc = avi.id_acc
inner join t_av_contact avcClient on mapClient.id_acc = avcClient.id_acc
left outer join vw_bus_partition_accounts bpt on bpt.id_acc = avi.id_acc
and avcClient.c_contacttype = (SELECT id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accountcreation/contacttype/bill-to')
inner join t_description descCountry on avcClient.c_Country = descCountry.id_desc and descCountry.id_lang_code = (SELECT id_lang_code FROM t_language WHERE tx_lang_code = 'us')
WHERE  
   ( ( ( avi.c_MetraTaxHasOverrideBand is not null and avi.c_MetraTaxOverrideBand = (select id_enum_data  from t_enum_data where nm_enum_data = 'metratech.com/tax/TaxBand/exempt'))  OR 
      -- assuming that if it is not MetraTax then a Tax Exempt ID and or a reason specified
      (avi.c_TaxExemptID is not null AND avi.c_TaxExemptID is not null) OR (avi.c_TaxExemptReason is not null) ) 
      AND  /* if any of the above are true, then it is some how an exempted account therefore validate
           -- the exemption end date is either undefined or greater than the current date.
           */ 
        ( (c_TaxExemptEndDate is null) OR (c_TaxExemptEndDate > GETDATE() )  )
    )