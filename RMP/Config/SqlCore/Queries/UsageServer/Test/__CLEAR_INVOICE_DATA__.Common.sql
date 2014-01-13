
begin
  /* ===========================================================
  Clear data before starting unit tests.
  ============================================================== */
  /* delete from t_invoice */
  DELETE from t_invoice
  where exists (
    select 1
    from t_usage_interval ui  
    INNER JOIN t_usage_cycle uc  
     ON uc.id_usage_cycle = ui.id_usage_cycle  
    INNER JOIN t_usage_cycle_type uct  
      ON uct.id_cycle_type = uc.id_cycle_type  
    where ui.id_interval = t_invoice.id_interval  
      and (%%USAGE_PREDICATE%%)
    );

  /* delete from t_invoice_range */
  DELETE from t_invoice_range
  where exists (
    select 1
    from t_usage_interval ui  
    INNER JOIN t_usage_cycle uc  
     ON uc.id_usage_cycle = ui.id_usage_cycle  
    INNER JOIN t_usage_cycle_type uct  
      ON uct.id_cycle_type = uc.id_cycle_type  
    where ui.id_interval = t_invoice_range.id_interval  
      and (%%USAGE_PREDICATE%%)
    );

end;
