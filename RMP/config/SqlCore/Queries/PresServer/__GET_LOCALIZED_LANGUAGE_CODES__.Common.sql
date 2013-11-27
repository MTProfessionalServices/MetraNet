
select l.tx_lang_code langcode, d.tx_desc languagestring
from t_language l, t_description d, t_enum_data ed, t_language l2
where %%%UPPER%%%(ed.nm_enum_data) = %%%UPPER%%%('Global/LanguageCode/' %%%CONCAT%%% l.tx_lang_code)
   and ed.id_enum_data = d.id_desc
   and l2.id_lang_code = d.id_lang_code
   and l2.tx_lang_code = '%%LANG_CODE%%'			
   