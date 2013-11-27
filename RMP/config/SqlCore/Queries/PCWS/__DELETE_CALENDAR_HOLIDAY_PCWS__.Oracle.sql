
			  Declare 
				l_dayID int;
			begin

				Select id_day into l_dayID from t_calendar_holiday
					Where id_holiday = %%HOLIDAY_ID%%;

				Delete from t_calendar_periods where id_day = l_dayID;
				Delete from t_calendar_holiday where id_day = l_dayID;
				Delete from t_calendar_day where id_day = l_dayID;
				END;
			