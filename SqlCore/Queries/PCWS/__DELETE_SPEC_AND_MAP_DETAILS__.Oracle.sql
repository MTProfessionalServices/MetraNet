declare id_category  t_description.id_desc%type;
id_display_name  t_description.id_desc%type;
id_desc  t_description.id_desc%type;
begin
 id_category := %%ID_CATEGORY%%;
 id_display_name := %%ID_DISPLAY_NAME%%; 
 id_desc := %%ID_DESC%%;
 DeleteDescription (id_category);
 DeleteDescription (id_display_name);
 DeleteDescription (id_desc);
 delete from t_spec_val_map where id_spec = %%ID_SPEC%%;
 delete from t_spec_characteristics where id_spec = %%ID_SPEC%%;                              
end;            