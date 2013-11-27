
        CREATE PROCEDURE PurgeAuditTable (p_dt_start IN varchar2,
                                                     p_ret_code OUT int)
        AS
        BEGIN
          DELETE FROM t_audit
          WHERE dt_crt <= TO_DATE(p_dt_start, 'MM/DD/YYYY');
          p_ret_code := 0;
          exception
            when others
            then
                p_ret_code := -99;
          end;
            