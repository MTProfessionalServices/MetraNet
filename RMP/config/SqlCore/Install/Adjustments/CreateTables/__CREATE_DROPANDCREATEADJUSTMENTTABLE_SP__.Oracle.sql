
CREATE OR REPLACE PROCEDURE DROPANDCREATEADJUSTMENTTABLE(
  p_id_pi_type         integer,
  p_status       out   integer,
  p_err_msg      out   varchar2
)
as
begin
  createadjustmenttable(p_id_pi_type, p_status, p_err_msg, true);
end;

		