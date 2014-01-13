CREATE OR REPLACE PROCEDURE recursive_inherit_sub_by_rsch
(
    v_id_rsched   int
)
AS
    id_sub NUMBER;
BEGIN
    SELECT MAX(pm.id_sub)
    INTO   id_sub
    FROM   t_pl_map pm
           INNER JOIN t_rsched r
                ON   r.id_pricelist = pm.id_pricelist
                AND pm.id_pi_template = r.id_pi_template
    WHERE  r.id_sched = v_id_rsched AND pm.id_sub IS NOT NULL;

    IF (id_sub IS NOT NULL) THEN
        mt_rate_pkg.recursive_inherit_sub_to_accs(v_id_sub => id_sub);
    END IF;
END;
