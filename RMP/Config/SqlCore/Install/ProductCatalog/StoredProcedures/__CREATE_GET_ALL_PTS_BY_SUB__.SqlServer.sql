
CREATE PROCEDURE get_all_pts_by_sub(
    @my_id_sub int,
    @my_id_pt_curs CURSOR VARYING OUT
)
AS
BEGIN
    SET @my_id_pt_curs = CURSOR FORWARD_ONLY FOR
        SELECT pm.id_paramtable, pm.id_pi_template
        FROM   t_sub s, t_pl_map pm, t_rulesetdefinition rd
        WHERE   s.id_sub = @my_id_sub
            AND s.id_po = pm.id_po
            AND pm.id_sub IS NULL
            AND pm.id_acc IS NULL
            AND pm.id_paramtable = rd.id_paramtable

	OPEN @my_id_pt_curs
END
