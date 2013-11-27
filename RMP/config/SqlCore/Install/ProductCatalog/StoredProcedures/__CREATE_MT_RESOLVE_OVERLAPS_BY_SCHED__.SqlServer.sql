
CREATE PROCEDURE mt_resolve_overlaps_by_sched (
    @v_id_acc int,
    @v_start datetime,
    @v_end datetime,
    @v_replace_nulls int,
    @v_merge_rates int,
    --@v_reuse_sched int,
	@v_id_pt int,
    --@v_pt IN TP_PARAM_TABLE_DEF,
    --@v_schedules_in IN TP_SCHEDULE_ARRAY,
    @v_id_sched int
    --,@v_schedules_out OUT TP_SCHEDULE_ARRAY
)
AS
BEGIN
    DECLARE @l_id_sched int
	DECLARE @l_id_sched_key uniqueidentifier
    --l_empty    TP_PARAM_ASSOC;

    EXEC mt_load_schedule @v_id_sched, @v_start, @v_end, 0, @v_id_pt, @l_id_sched_key OUT, @l_id_sched OUT
	
    EXEC mt_resolve_overlaps
		@v_id_acc,
		@v_replace_nulls,
		@v_merge_rates,
		0,
		@v_id_pt,
		--v_pt.param_defs,
		--v_schedules_in,
		@l_id_sched_key,
		@l_id_sched,
		@v_start,
		@v_end
		--,v_schedules_out
END
