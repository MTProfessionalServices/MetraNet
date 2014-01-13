
/* Get the nearest account in the hierarchy with the given id_acc/id_po combination in their template (inheritance ONLY works for the same id_po) */
/* Return all matches from the template (assuming template subscriptions have active dates, which isn't currently the case, but needs to be fixed) */
/* NOTE: This proc relies on t_acc_template_subs_pub, which won't exist unless the template inheritance stuff is on the DB already */
CREATE PROCEDURE get_inherit_id_sub(
    @my_id_acc int,
    @my_id_po int,
    @my_start_dt datetime,
    @my_end_dt datetime,
    @inherit_id_sub_curs CURSOR VARYING OUT
)
AS
BEGIN
	SET NOCOUNT ON

    DECLARE @inherit_id_acc_templt_pub int

    SELECT TOP 1 @inherit_id_acc_templt_pub = ats.id_acc_template
    FROM   t_account_ancestor aa
        INNER JOIN t_acc_template at ON aa.id_ancestor = at.id_folder
        INNER JOIN t_acc_template_subs ats ON at.id_acc_template = ats.id_acc_template
        INNER JOIN t_sub s ON s.id_group = ats.id_group AND s.id_po = @my_id_po
    WHERE aa.id_descendent = @my_id_acc
        AND aa.id_ancestor != aa.id_descendent
    ORDER BY aa.num_generations ASC, at.id_acc_template DESC
    
    SET @inherit_id_sub_curs = CURSOR FOR
        SELECT s.id_sub, CASE WHEN ats.vt_start < @my_start_dt THEN @my_start_dt ELSE ats.vt_start END,
            CASE WHEN ats.vt_end > @my_end_dt THEN @my_end_dt ELSE ats.vt_end END
        FROM   t_acc_template_subs ats
            INNER JOIN t_sub s ON s.id_group = ats.id_group AND s.id_po = @my_id_po 
        WHERE  ats.id_acc_template = @inherit_id_acc_templt_pub
            AND ats.vt_start < @my_end_dt
            AND ats.vt_end > @my_start_dt
        ORDER BY ats.vt_start, ats.vt_end

	OPEN @inherit_id_sub_curs
END
	