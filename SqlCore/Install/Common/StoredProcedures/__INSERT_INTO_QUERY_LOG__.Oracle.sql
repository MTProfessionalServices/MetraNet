
CREATE OR REPLACE
procedure insertintoquerylog(
			p_groupid varchar2,
			p_viewid int,
			p_old_schema varchar2,
  p_query nvarchar2)
as
			begin
  insert into t_query_log(c_id,
    c_groupid,   c_id_view,   c_old_schema,   c_query)
  values (seq_t_query_log.nextval,
    p_groupid,   p_viewid,   p_old_schema,   p_query);
			end;
  