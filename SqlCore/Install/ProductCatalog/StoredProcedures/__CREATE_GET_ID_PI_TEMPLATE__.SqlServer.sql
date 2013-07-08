
/* Get the id_pi_template for a given id_sub/id_pt */
CREATE PROCEDURE get_id_pi_template(
    @my_id_sub int,
    @my_id_pt int,
    @my_id_pi_template int OUT
)
AS
BEGIN
	SELECT @my_id_pi_template = MIN(id_pi_template)
	FROM   t_pl_map a, t_sub b
	WHERE  b.id_sub = @my_id_sub
		AND a.id_sub IS NULL
		AND a.id_po = b.id_po
		AND a.id_paramtable = @my_id_pt
END
