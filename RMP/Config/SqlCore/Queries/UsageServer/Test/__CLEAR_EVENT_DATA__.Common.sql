
begin
  /* ===========================================================
    Clear t_recevent data.
  ============================================================== */
  DELETE FROM t_recevent_dep;
  DELETE FROM t_recevent_scheduled;
  DELETE FROM t_recevent_eop;
  DELETE FROM t_recevent; 
end;
 