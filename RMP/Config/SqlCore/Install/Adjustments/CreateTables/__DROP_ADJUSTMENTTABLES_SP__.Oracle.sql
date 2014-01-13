
CREATE OR REPLACE PROCEDURE Dropadjustmenttables
AS
  TYPE CursorVar IS REF CURSOR;
  v_CursorVar CursorVar;
  v_pvname VARCHAR2(256);
  v_adjname VARCHAR2(256);
  v_idpi INT;
BEGIN
  OPEN v_CursorVar FOR
  SELECT DISTINCT(pv.nm_table_name),
  't_aj_' + SUBSTR(pv.nm_table_name,6,1000), T_PI.id_pi
  FROM T_PI
  /* all of the product views references by priceable items */
  INNER JOIN T_PROD_VIEW pv ON upper(pv.nm_name) = upper(T_PI.nm_productview)
  INNER JOIN T_CHARGE ON T_CHARGE.id_pi = T_PI.id_pi;

  LOOP
      FETCH v_CursorVar INTO v_pvname,v_adjname,v_idpi;
      EXIT WHEN v_CursorVar%NOTFOUND;
      /* drop the table if it exists */
              EXECUTE IMMEDIATE 'drop table ' || v_adjname;
  END LOOP;
  CLOSE v_CursorVar;
END;
