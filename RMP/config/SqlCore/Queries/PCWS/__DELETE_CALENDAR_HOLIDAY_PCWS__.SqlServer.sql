
			  Declare @dayID int

				Select @dayID = id_day from t_calendar_holiday with(updlock)
					Where id_holiday = %%HOLIDAY_ID%%

				Delete from t_calendar_periods where id_day = @dayId
				Delete from t_calendar_holiday where id_day = @dayId
				Delete from t_calendar_day where id_day = @dayId
			