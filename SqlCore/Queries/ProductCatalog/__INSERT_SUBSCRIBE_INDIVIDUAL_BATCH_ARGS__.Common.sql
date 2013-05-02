
INSERT INTO %%DEBUG%%tmp_subscribe_individual_batch
    (
      id_acc, id_sub, id_po, dt_start, dt_end,
      next_cycle_after_startdate, next_cycle_after_enddate, sub_guid,
      id_audit, id_event, id_userid, id_entitytype
    )
VALUES (%%ID_ACC%%, %%ID_SUB%%, %%ID_PO%%, %%DT_START%%, %%DT_END%%,
        %%NCA_STARTDATE%%, %%NCA_ENDDATE%%, %%SUB_GUID%%,
        %%ID_AUDIT%%, %%ID_EVENT%%, %%ID_USERID%%, %%ID_ENTITYTYPE%%);
        