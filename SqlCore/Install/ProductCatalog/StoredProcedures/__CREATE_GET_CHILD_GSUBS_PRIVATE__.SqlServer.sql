
CREATE PROCEDURE get_child_gsubs_private(
    @my_id_acc int,
    @my_id_po int,
    @my_start_dt datetime,
    @my_end_dt datetime,
    @my_id_gsub_curs CURSOR VARYING OUT
)
AS
BEGIN
	SET @my_id_gsub_curs = CURSOR FOR
		SELECT /*+ ORDERED USE_NL(AT ats s) */ aa.id_descendent id_acc, s.id_sub
		FROM   t_account_ancestor aa
			INNER JOIN t_acc_template at ON aa.id_descendent = at.id_folder
			INNER JOIN t_acc_template_subs ats ON at.id_acc_template = ats.id_acc_template
			INNER JOIN t_sub s ON s.id_group = ats.id_group AND s.id_po = @my_id_po
		WHERE   aa.id_ancestor = @my_id_acc
			and num_generations > 0
			and s.vt_start < @my_end_dt
			and s.vt_end > @my_start_dt
		ORDER BY aa.num_generations ASC

	OPEN @my_id_gsub_curs
END
