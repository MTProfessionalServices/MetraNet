
/* ===========================================================
Update the country code for the given account based on the given country name.
============================================================== */
UPDATE t_av_contact
SET c_country = (SELECT id_enum_data 
                                FROM t_enum_data
                                WHERE upper(nm_enum_data) = upper(N'%%COUNTRY_NAME%%'))
where (id_acc, c_contacttype) in (
select ac.id_acc, ac.c_contacttype
FROM t_av_contact ac
INNER JOIN t_enum_data contactType
  ON contactType.id_enum_data = ac.c_contacttype
WHERE
   ac.id_acc = %%ID_ACC%% AND
   upper(contactType.nm_enum_data) = upper(N'metratech.com/accountcreation/contacttype/bill-to')
  )
 