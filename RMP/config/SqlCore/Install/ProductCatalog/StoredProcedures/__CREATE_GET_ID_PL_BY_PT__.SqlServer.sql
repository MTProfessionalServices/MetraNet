
/* Get the id_pricelist for a given id_sub */
CREATE PROCEDURE get_id_pl_by_pt(
    @my_id_acc int,
    @my_id_sub int,
    @my_id_pt int,
    @my_id_pi_template int,
    @my_id_pricelist int OUT
)
AS
BEGIN
    DECLARE @my_currency_code nvarchar(100)

    SELECT @my_id_pricelist = ISNULL(MIN(pm.id_pricelist), 0)
    FROM   t_pl_map pm
        INNER JOIN t_pricelist pl ON pm.id_pricelist = pl.id_pricelist AND pl.n_type = 0
    WHERE  id_sub = @my_id_sub AND pm.id_paramtable = @my_id_pt AND pm.id_pi_template = @my_id_pi_template
        
    IF (@my_id_pricelist = 0)
	BEGIN
        SELECT @my_currency_code = c_currency
		FROM   t_av_internal
		WHERE  id_acc = @my_id_acc

        INSERT INTO t_base_props
                    (n_kind, n_name, n_desc, nm_name, nm_desc, b_approved, b_archive, n_display_name, nm_display_name)
             VALUES (150, 0, 0, NULL, NULL, 'N', 'N', 0, NULL);
		SELECT @my_id_pricelist = SCOPE_IDENTITY()

        INSERT INTO t_pricelist
                    (id_pricelist, n_type, nm_currency_code)
            VALUES  (@my_id_pricelist, 0, @my_currency_code)
    END
END
