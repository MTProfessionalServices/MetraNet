
/* ===========================================================
Inserts a row in t_enum_data (if necessary) 
Inserts or updates a row in t_description

Input:
@p_lang_code       : This is the two character language code (e.g. 'us', 'de')
@p_description_key : This is the key for the localized text. Created as an enum in t_enum_data
@p_description     : The localized text for the specified @p_lang_code

Output:
@p_status   : Returns error codes

Error Codes:
 0: No error
-1: if an unknown error has occurred
-2: @p_lang_code is invalid
-3: @p_description_key is invalid
-4: Error creating enum for @p_description_key
=========================================================== */

create procedure CreateLocalizedEntry 
  @p_lang_code nvarchar(5),
  @p_description_key nvarchar(255),
  @p_description nvarchar(255),
  @p_status int OUTPUT 

as
begin
  declare @id_lang_code int

  /* initialize @p_status to unknown error */
  set @p_status = -1 

  /* check @p_lang_code */
  select @id_lang_code = id_lang_code 
  from t_language 
  where tx_lang_code = @p_lang_code

  if @p_lang_code is null
  begin
    set @p_status = -2
    return
  end
  
  /* validate @p_description_key */ 
  if @p_description_key is null or len(ltrim(rtrim(@p_lang_code))) = 0
  begin
    set @p_status = -3 
    return
  end

  declare @id_enum_data_for_key int
  exec InsertEnumData @p_description_key, @id_enum_data_for_key output

  /* check error */
  if (@id_enum_data_for_key = -99)
  begin
    set @p_status = -4
    return
  end

  exec UpsertDescriptionV2 @id_lang_code, 
                           @p_description, 
                           @id_enum_data_for_key, 
                           @id_enum_data_for_key output

  set @p_status = 0
end
		