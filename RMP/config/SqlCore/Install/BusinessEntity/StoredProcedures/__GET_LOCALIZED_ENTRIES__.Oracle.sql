
/* ===========================================================
The input string (p_locale_keys) is a list of nm_enum_data items separated by p_separator
Split the input string into a table using the specified separator. 
Join the table to t_enum_data, t_description, etc to get the localized descriptions for each item.

Input:
p_locale_keys     : List of nm_enum_data separated by p_separator
p_separator       : Separator for p_locale_keys
=========================================================== */
create or replace procedure GetLocalizedEntries(
  rows out sys_refcursor,
  p_locale_keys clob,
  p_separator varchar2)
as
begin
   open rows for
   select ed.id_enum_data as Id,
          ed.nm_enum_data as LocaleKey,
          de.tx_desc as Value,
          case when lower(la.tx_lang_code) = 'us' then 'en'
                when lower(la.tx_lang_code) = 'cn' then 'zh' 
                when lower(la.tx_lang_code) = 'jp' then 'ja'
                when lower(la.tx_lang_code) = 'es' then 'es' 				
                else lower(la.tx_lang_code) 
                end as Locale
   from table(cast(dbo.String2Table(p_locale_keys, p_separator) as  str_tab)) args
   inner join t_enum_data ed on upper(ed.nm_enum_data) = upper(args.COLUMN_VALUE)
   left outer join t_description de on de.id_desc = ed.id_enum_data
   left outer join  t_language la on la.id_lang_code = de.id_lang_code;
end;
			