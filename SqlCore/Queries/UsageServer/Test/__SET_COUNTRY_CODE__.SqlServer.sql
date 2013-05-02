
/* ===========================================================
Update the country code for the given account based on the given country name.
============================================================== */
UPDATE ac
SET ac.c_country = (SELECT id_enum_data 
                                FROM t_enum_data
                                WHERE nm_enum_data = '%%COUNTRY_NAME%%')
FROM t_av_contact ac
INNER JOIN t_enum_data contactType
  ON contactType.id_enum_data = ac.c_contacttype
WHERE
   ac.id_acc = %%ID_ACC%% AND
   contactType.nm_enum_data = 'metratech.com/accountcreation/contacttype/bill-to' 
 