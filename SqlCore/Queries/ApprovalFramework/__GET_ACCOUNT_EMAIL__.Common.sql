select c_Email
from t_av_contact av
	inner join t_enum_data ed
	on av.c_ContactType = ed.id_enum_data
where av.id_acc = %%id_acc%%
  and ed.nm_enum_data = 'metratech.com/accountcreation/ContactType/Bill-To'
