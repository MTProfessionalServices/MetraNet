
/* ===========================================================
Inserts a row in t_enum_data (if necessary) 
Inserts or updates a row in t_description

Input:
p_lang_code       : This is the two character language code (e.g. 'us', 'de')
p_description_key : This is the key for the localized text. Created as an enum in t_enum_data
p_description     : The localized p_description for the specified @p_lang_code

Output:
p_status          : Returns error codes

Error Codes:
 0: No error
-1: if an unknown error has occurred
-2: p_lang_code is invalid
-3: p_description_key is invalid
-4: Error creating enum for p_description_key
=========================================================== */
create or replace procedure CreateLocalizedEntry (p_lang_code t_language.tx_lang_code%type,
                                                  p_description_key t_enum_data.nm_enum_data%type,
                                                  p_description t_description.tx_desc%type,
                                                  p_status out int)

as
  id_lang_code int;
  id_enum_data_for_key int;
  
begin
  /* initialize @p_status to unknown error */
  p_status := -1;

  /* check p_lang_code */
  select l.id_lang_code into id_lang_code 
  from t_language l
  WHERE UPPER(tx_lang_code) = UPPER(p_lang_code);

  if id_lang_code is null
  then
    p_status := -2;
    return;
  end if;
  
  /* validate @key */ 
  if p_description_key is null or length(trim(p_description_key)) = 0
  then
    p_status := -3;
    return;
  end if;

  InsertEnumData (p_description_key, id_enum_data_for_key);

  /* check error */
  if id_enum_data_for_key = -99
  then
    p_status := -4;
    return;
  end if;

  UpsertDescriptionV2 (id_lang_code, 
                       p_description, 
                       id_enum_data_for_key, 
                       id_enum_data_for_key);

  p_status := 0;
end;
        