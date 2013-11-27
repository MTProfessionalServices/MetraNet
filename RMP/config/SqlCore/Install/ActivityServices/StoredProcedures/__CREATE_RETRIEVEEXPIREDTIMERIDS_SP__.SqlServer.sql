
            CREATE PROCEDURE [dbo].[WFRetrieveExpiredTimerIds]
              @id_owner nvarchar(36) = NULL,
              @dt_ownedUntil datetime = NULL,
              @now datetime
              AS
                  SELECT id_instance FROM [dbo].[t_wf_InstanceState]
                  WHERE dt_nextTimer<@now AND n_status<>1 AND n_status<>3 AND n_status<>2 -- not n_blocked and not completed and not terminated and not suspended
                      AND ((n_unlocked=1 AND id_owner IS NULL) OR dt_ownedUntil<getutcdate() )
        