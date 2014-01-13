
CREATE PROCEDURE mt_load_schedule (
    @v_id_sched int,
    @v_start datetime,
    @v_end datetime,
    @v_is_wildcard int,
	@v_id_pt int,
	@new_id_sched_key uniqueidentifier OUT,
	@new_id_sched int OUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET @new_id_sched_key = NEWID()
	EXEC mt_load_schedule_params @v_id_sched, @v_is_wildcard, @v_id_pt, @new_id_sched_key, @new_id_sched OUT
END
