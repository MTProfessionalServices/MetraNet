
			    create proc RemoveAdjustmentTypeProps
          @p_id_prop int
          AS
          BEGIN
            DECLARE @propid INT
            DECLARE CursorVar CURSOR STATIC
            FOR SELECT id_prop FROM T_ADJUSTMENT_TYPE_PROP WHERE id_adjustment_type =@p_id_prop
            OPEN CursorVar
            DELETE FROM T_ADJUSTMENT_TYPE_PROP WHERE id_adjustment_type =@p_id_prop
            FETCH NEXT FROM CursorVar into  @propid
            WHILE @@FETCH_STATUS = 0
            BEGIN
              exec DeleteBaseProps @propid
              FETCH NEXT FROM CursorVar into  @propid
            END
          CLOSE CursorVar
          DEALLOCATE CursorVar
          END
				