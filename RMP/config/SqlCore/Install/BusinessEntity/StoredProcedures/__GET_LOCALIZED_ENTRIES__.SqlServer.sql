
/* ===========================================================
The input string (@p_locale_keys) is a list of nm_enum_data items. 
Split the input string into a table using the specified separator. 
Join the table to t_enum_data, t_description, etc to get the localized descriptions for each item.

Input:
@p_locale_keys     : List of nm_enum_data separated by @p_separator
@p_separator       : Separator for @p_locale_keys
=========================================================== */

create procedure GetLocalizedEntries 
  @p_locale_keys nvarchar(max),
  @p_separator nvarchar(10)

as
begin
    select ed.id_enum_data as Id,
           ed.nm_enum_data as LocaleKey,
           de.tx_desc as Value,
           case when lower(la.tx_lang_code) = 'us' then 'en'
                when lower(la.tx_lang_code) = 'cn' then 'zh' 
                when lower(la.tx_lang_code) = 'jp' then 'ja' 
                when lower(la.tx_lang_code) = 'es' then 'es' 
                else lower(la.tx_lang_code) 
                end as Locale
    from (select item from String2Table(@p_locale_keys, @p_separator)) keys 
    inner join t_enum_data ed on ed.nm_enum_data = keys.item
    left outer join t_description de on de.id_desc = ed.id_enum_data
    left outer join  t_language la on la.id_lang_code = de.id_lang_code
end
		