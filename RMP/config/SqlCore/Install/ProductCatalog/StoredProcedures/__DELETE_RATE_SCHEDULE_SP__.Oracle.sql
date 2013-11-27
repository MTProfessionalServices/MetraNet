
CREATE OR REPLACE PROCEDURE sp_deleterateschedule (p_a_rsid INT)
AS
   v_id_effdate    INT;
   v_id_paramtbl   INT;
   v_nm_paramtbl   NVARCHAR2 (255);
   v_sqlstring     VARCHAR2 (4000);
BEGIN                       /* Find the information we need to delete rates */
   FOR i IN (SELECT id_eff_date
               FROM t_rsched
              WHERE id_sched = p_a_rsid)
   LOOP
      v_id_effdate := i.id_eff_date;
   END LOOP;

   FOR i IN (SELECT id_pt
               FROM t_rsched
              WHERE id_sched = p_a_rsid)
   LOOP
      v_id_paramtbl := i.id_pt;
   END LOOP;

   FOR i IN (SELECT nm_instance_tablename
               INTO v_nm_paramtbl
               FROM t_rulesetdefinition
              WHERE id_paramtable = v_id_paramtbl)
   LOOP
      v_nm_paramtbl := i.nm_instance_tablename;
   END LOOP;
/* Create the delete statement for the particular rule table and execute it */

   v_sqlstring :=
         'delete from '
      || v_nm_paramtbl
      || ' where id_sched = '
      || CAST (p_a_rsid AS NVARCHAR2);
                                 /* Delete the remaining rate schedule info */

   EXECUTE IMMEDIATE (v_sqlstring);

   DELETE FROM t_rsched
         WHERE id_sched = p_a_rsid;

   DELETE FROM t_effectivedate
         WHERE id_eff_date = v_id_effdate;

   deletebaseprops (p_a_rsid);
END;
		