
CREATE OR REPLACE
procedure updatedataforstringtoenum(
  p_table varchar2,
			p_column varchar2,
			p_enum_string varchar2)
			AS
  inclusion varchar2(4000);
  upd varchar2(4000);
  fqenumval varchar2(4000);
  cnt int;

			begin

  fqenumval := ''''||p_enum_string||'/'' || ' || p_column;

  /* all values in the string column must be found in the t_enum_data */
    inclusion := '
        select sum(case when mydata is null then 0 else 1 end)
        from (
          select distinct ' || fqenumval || ' as mydata
          from '|| p_table ||'
          ) data
        where not exists  (
          select 1
          from t_enum_data
          where nm_enum_data = data.mydata
          )';

    execute immediate inclusion into cnt;

    if cnt > 0 then
      raise_application_error(-20000,
        'Invalid enum values in table ' || p_table || ', column ' || p_column);
				end if;

  upd := '
      update '|| p_table || ' set
        '|| p_column || ' = (select id_enum_data
                from t_enum_data
                where nm_enum_data = '||fqenumval||')
      where exists (
                select 1
                from t_enum_data
                where nm_enum_data = '||fqenumval||')';

  execute immediate upd;

			end;
		