using System;
using System.Collections;
using System.Runtime.InteropServices;
using Microsoft.Win32;

namespace MetraTech.Metering.DatabaseMetering
{
	/// <summary>
	/// Summary description for ConvertTimeZoneClass.
	/// </summary>
	public class ConvertTimeZoneClass
	{
		const string SKEY_NT = @"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones";
		const string SKEY_9X = @"SOFTWARE\Microsoft\Windows\CurrentVersion\Time Zones";

		RegistryKey objLocalRegistry;
		/// <summary>
		/// structure used to store the System time
		/// </summary>
		public struct SYSTEMTIME
		{
			public short iYear;
			public short iMonth;
			public short iDayOfWeek;
			public short iDay;
			public short iHour;
			public short iMinute;
			public short iSecond;
			public short iMilliseconds;
		}
		

		/// <summary>
		/// structure used to store the TimeZone information
		/// </summary>
		public struct REGTIMEZONEINFORMATION
		{
			public int iBias;
			public int iStandardBias;
			public int iDaylightBias;
			public SYSTEMTIME StandardDate;
			public SYSTEMTIME DayLightDate;
		}

		/// <summary>
		/// enum containing the possible values for the TimeZone
		/// </summary>
		public enum TimeZones
		{
			Afghanistan_Standard_Time = 1,
			Alaskan_Standard_Time = 2,
			Arabian_Standard_Time = 3,
			Atlantic_Standard_Time = 4,
			AUS_Central_Standard_Time = 5,
			Azores_Standard_Time = 6,
			Bangkok_Standard_Time = 7,
			Canada_Central_Standard_Time = 8,
			Cen_Australia_Standard_Time = 9,
			Central_Asia_Standard_Time = 10,
			Central_Europe_Standard_Time = 11,
			Central_Pacific_Standard_Time = 12,
			Central_Standard_Time = 13,
			China_Standard_Time = 14,
			Dateline_Standard_Time = 15,
			E_Europe_Standard_Time = 16,
			E_South_America_Standard_Time = 17,
			Eastern_Standard_Time = 18,
			Egypt_Standard_Time = 19,
			Fiji_Standard_Time = 20,
			GFT_Standard_Time = 21,
			GMT = 22,
			GMT_Standard_Time = 23,
			Hawaiian_Standard_Time = 24,
			India_Standard_Time = 25,
			Iran_Standard_Time = 26,
			Israel_Standard_Time = 27,
			Mexico_Standard_Time = 28,
			MidAtlantic_Standard_Time = 29,
			Mountain_Standard_Time = 30,
			New_Zealand_Standard_Time = 31,
			Newfoundland_Standard_Time = 32,
			Pacific_Standard_Time = 33,
			Romance_Standard_Time = 34,
			Russian_Standard_Time = 35,
			SA_Eastern_Standard_Time = 36,
			SA_Pacific_Standard_Time = 37,
			SA_Western_Standard_Time = 38,
			Samoa_Standard_Time = 39,
			Saudi_Arabia_Standard_Time = 40,
			South_Africa_Standard_Time = 41,
			Sydney_Standard_Time = 42,
			Taipei_Standard_Time = 43,
			Tasmania_Standard_Time = 44,
			Tokyo_Standard_Time = 45,
			US_Eastern_Standard_Time = 46,
			US_Mountain_Standard_Time = 47,
			W_Europe_Standard_Time = 48,
			West_Asia_Standard_Time = 49,
			West_Pacific_Standard_Time = 50
		};

    // map timeZone name to REGTIMEZONEINFORMATION
    private Hashtable timeZoneByName;

		/// <summary>
		/// deault constructor
		/// </summary>
		public ConvertTimeZoneClass()
		{
			objLocalRegistry = Registry.LocalMachine;
      InitializeTimeZones();
		}
		
		/// <summary>
		/// This function is used to Convert the passed date (for the fromtimezone) to new date 
		/// (for the totimezone).
		/// </summary>
		/// <param name="dtTime">The date that has to be convered</param>
		/// <param name="iFromTimeZone">Time zone(enum value) for the passed date</param>
		/// <param name="iToTimeZone">Time zone(enum value) for the final(converted) date</param>
		/// <returns>The date for the totimezone</returns>
		public DateTime ConvertToNewTimezoneUsingID(DateTime dtTime, short iFromTimeZone, short iToTimeZone)
		{
			return ConvertToNewTimezone(dtTime, GlobalFunctions.DetermineTimeZone(iFromTimeZone), GlobalFunctions.DetermineTimeZone(iToTimeZone));
		}

		/// <summary>
		/// This function is used to Convert the passed date (for the fromtimezone) to new date 
		/// (for the totimezone).
		/// </summary>
		/// <param name="dtTime">The date that has to be convered</param>
		/// <param name="strFromTimeZone">Time zone(string) for the passed date</param>
		/// <param name="strToTimeZone">Time zone(string) for the final(converted) date</param>
		/// <returns>The date for the totimezone</returns>
		public DateTime ConvertToNewTimezone(DateTime dtTime, string strFromTimeZone, string strToTimeZone)
		{
			DateTime dtNewTime;
			dtNewTime = ConvertToGMT(dtTime, strFromTimeZone);
			dtNewTime = ConvertFromGMT(dtNewTime, strToTimeZone);
			return dtNewTime;
		}

		/// <summary>
		/// This function is used to retrieve the date for the passed TimeZone from the passed datetime(GMT)
		/// </summary>
		/// <param name="dtTime">GMT date</param>
		/// <param name="iTimeZoneID">Time zone (enum value) for which conversion to be done</param>
		/// <returns>The date time for the passed timezone</returns>
		public DateTime ConvertFromGMTUsingID(DateTime dtTime, short iTimeZoneID)
		{
			return ConvertFromGMT(dtTime, GlobalFunctions.DetermineTimeZone(iTimeZoneID));
		}

		/// <summary>
		/// This function is used to retrieve the date for the passed TimeZone from the passed datetime(GMT)
		/// </summary>
		/// <param name="strTime">GMT date in string format</param>
		/// <param name="strTimeZone">Time zone for which conversion to be done</param>
		/// <returns>The date time (string format) for the passed timezone</returns>
		public string ConvertFromGMTAsStr(string strTime, string strTimeZone)
		{
			short iIDofTimeZone;
			DateTime dtTime;
			DateTime dtNewTime;

			dtTime = DateTime.Parse(strTime);
			iIDofTimeZone = GlobalFunctions.DetermineTimeZoneID(strTimeZone);
			dtNewTime = ConvertFromGMTUsingID(dtTime, iIDofTimeZone);
			return dtNewTime.ToString("yyyy-mm-dd hh:mm:ss");
		}

		private void Trace (string s)
		{
			Log objLog = Log.GetInstance();
			objLog.LogString( Log.LogLevel.DEBUG, s);
		}

		/// <summary>
		/// This function is used to retrieve the date for the passed TimeZone from the passed datetime(GMT)
		/// </summary>
		/// <param name="dtTime">GMT date</param>
		/// <param name="strTimeZone">Time zone for which conversion to be done</param>
		/// <returns>The date time for the passed timezone</returns>
		public DateTime ConvertFromGMT(DateTime dtTime, string strTimeZone)
		{
			REGTIMEZONEINFORMATION rTZI = new REGTIMEZONEINFORMATION();
			DateTime dtTime1,dtTime2;
			bool bDaylight1, bDaylight2;

			// Opening the key for the passed TimeZone
			using(RegistryKey objTimeZoneReg = objLocalRegistry.OpenSubKey( SKEY_NT + @"\" + strTimeZone ))
			{
				if ( objTimeZoneReg != null )
				{
					object objKeyVal = objTimeZoneReg.GetValue("TZI");
					if( objKeyVal != null )
					{
						ByteConverter( ref rTZI, objKeyVal );
						objTimeZoneReg.Close();
						dtTime1 = dtTime.AddMinutes(-rTZI.iBias - rTZI.iDaylightBias);
						dtTime2 = dtTime.AddMinutes( -rTZI.iBias);
						bDaylight1 = IsDaylightSavings(dtTime1, rTZI);
						bDaylight2 = IsDaylightSavings(dtTime2, rTZI);
						if (bDaylight1 && bDaylight2)
							return dtTime1;
						else
							return dtTime2;
					}
				}
			}
			return DateTime.MinValue;
		}
		
		/// <summary>
		/// This function is used to convert the passed datetime(for the passed timezone) to its GMT equivalent
		/// </summary>
		/// <param name="dtTime">Datetime for the passed timezone</param>
		/// <param name="iTimeZoneID">Time zone (enum value) for which conversion to be done</param>
		/// <returns>The equivalent date time for the GMT</returns>
		public DateTime ConvertToGMTUsingID(DateTime dtTime, short iTimeZoneID)
		{
			return ConvertToGMT(dtTime, GlobalFunctions.DetermineTimeZone(iTimeZoneID));
		}

		/// <summary>
		/// This function is used to convert the passed datetime(for the passed timezone) to its GMT equivalent
		/// </summary>
		/// <param name="dtTime">GMT date</param>
		/// <param name="strTimeZone">Time zone (string) for which conversion to be done</param>
		/// <returns>The date time for the passed timezone</returns>
		public DateTime ConvertToGMT(DateTime dtTime, string strTimeZone)
		{
						
			Trace ("Entering ConvertToGMT "+dtTime.ToString()+" "+strTimeZone);

			object timeZone = timeZoneByName[strTimeZone];

      if (timeZone == null) 
      {
        throw new ApplicationException( "Value for timezone '" +strTimeZone +"' not found in registry");
      }

      REGTIMEZONEINFORMATION rTZI = (REGTIMEZONEINFORMATION)timeZone;

			if( rTZI.DayLightDate.iDay <=0 )
			{
				Trace ("No DST, Adding "+rTZI.iBias.ToString());
				return dtTime.AddMinutes(rTZI.iBias);
			}
			if (IsDaylightSavings(dtTime, rTZI))
			{
				Trace ("DST=False, Adding "+rTZI.iBias.ToString()+" and "+rTZI.iDaylightBias.ToString());
				return dtTime.AddMinutes(rTZI.iBias + rTZI.iDaylightBias);
			}
			else
			{
				Trace ("DST=True, Adding "+rTZI.iBias.ToString());
				return dtTime.AddMinutes(rTZI.iBias);
			}
				
			// return dtTime;      
		}

		/// <summary>
		/// Returns a value indicating whether a specified date and time is within a daylight saving time period
		/// </summary>
		/// <param name="dtTime">A date and time</param>
		/// <param name="rTZI"></param>
		/// <returns></returns>
		private bool IsDaylightSavings(DateTime dtTime, REGTIMEZONEINFORMATION rTZI)
		{
			DateTime dtDaylightDate, dtStandardDate;
			double iDaylightDif, iStandardDif;

			dtDaylightDate = tzDate(rTZI.DayLightDate, dtTime.Year);
			dtStandardDate = tzDate(rTZI.StandardDate, dtTime.Year);
			TimeSpan t1 = dtDaylightDate.Subtract(dtTime);
			iDaylightDif = ((TimeSpan)(dtDaylightDate.Subtract(dtTime))).TotalHours;
			iStandardDif = ((TimeSpan)(dtStandardDate.Subtract(dtTime))).TotalHours;

			if ((iDaylightDif <= 0) && (iStandardDif > 0))
			{
				return true;
			}
			else if((iDaylightDif > 0) && (iStandardDif < 0)) 
			{
				return false;
			}
			else
			{
				return ( (((TimeSpan)(dtDaylightDate.Subtract(dtStandardDate))).TotalHours) > 0);
			}
		}

		/// <summary>
		/// 
		/// </summary>
		/// <param name="st"></param>
		/// <returns></returns>
		private DateTime tzDate(SYSTEMTIME st, int year)
		{
			int i, n=0;
			int iFirstDay, iLastDay;

			// This member supports two date formats. Absolute format specifies an exact date and time 
			// when standard time begins. In this form, the wYear, wMonth, wDay, wHour, wMinute, wSecond,
			// and wMilliseconds members of the SYSTEMTIME structure are used to specify an exact date.

			// Day-in-month format is specified by setting the wYear member to zero, setting the wDayOfWeek
			// member to an appropriate weekday, and using a wDay value in the range 1 through 5 to select
			// the correct day in the month. Using this notation, the first Sunday in April can be specified,
			// as can the last Thursday in October (5 is equal to "the last").
			// Else Get first day of month
			DateTime dtFirstDayOfMonth = DateSerial(year, st.iMonth, 1);
			iFirstDay = (int) (dtFirstDayOfMonth.ToOADate());
			DateTime dtLastDayOfMonth = DateSerial(dtFirstDayOfMonth.Year, st.iMonth+1, 0 );
			iLastDay = (int) (dtLastDayOfMonth.ToOADate());

			// Match weekday with appropriate week...
			if (st.iDay == 5)
			{
				// Work backwards
				for (i = iLastDay;i>=iFirstDay;i--)
				{
					if( ( (int)(DateTime.FromOADate(i).DayOfWeek) ) == (st.iDayOfWeek ) )
					{
						break;
					}
				}
			}
			else
			{
				// Start at 1st and work forward
				for (i = iFirstDay;i<=iLastDay;i++)
				{
					if( ( (int)(DateTime.FromOADate(i).DayOfWeek) ) == (st.iDayOfWeek ) )
					{
						n++;
						if (n == st.iDay)
						{
							break;
						}
					}
				}
			}	
			DateTime dtTime = DateTime.FromOADate(i);
			return new DateTime(dtTime.Year, dtTime.Month, dtTime.Day, st.iHour, st.iMinute, st.iSecond);
		}
		
		/// <summary>
		/// Similar to DateSerial function defined in the VB
		/// </summary>
		/// <param name="iYear"></param>
		/// <param name="iMonth"></param>
		/// <param name="iDay"></param>
		/// <returns></returns>
		private DateTime DateSerial(int iYear, int iMonth, int iDay)
		{
			DateTime dtTime=DateTime.Now;
			dtTime = dtTime.AddYears(iYear-dtTime.Year);
			dtTime = dtTime.AddMonths(iMonth-dtTime.Month);
			dtTime = dtTime.AddDays(iDay-dtTime.Day);
			return dtTime;
		}
		
		/// <summary>
		/// Converts the passed object to struct
		/// </summary>
		/// <param name="rtz1"></param>
		/// <param name="o"></param>
		private void ByteConverter(ref REGTIMEZONEINFORMATION rtz, object o)
		{	
			byte[] b = (byte[])o;
			int iStartPoint=0;
			rtz.iBias = BitConverter.ToInt32( b, iStartPoint); iStartPoint += 4;
			rtz.iStandardBias = BitConverter.ToInt32(b, iStartPoint); iStartPoint += 4;
			rtz.iDaylightBias = BitConverter.ToInt32(b, iStartPoint); iStartPoint += 4;
			rtz.StandardDate.iYear = BitConverter.ToInt16(b, iStartPoint); iStartPoint += 2;
			rtz.StandardDate.iMonth = BitConverter.ToInt16( b,iStartPoint); iStartPoint += 2;
			rtz.StandardDate.iDayOfWeek = BitConverter.ToInt16(b, iStartPoint); iStartPoint += 2;
			rtz.StandardDate.iDay = BitConverter.ToInt16( b,iStartPoint); iStartPoint += 2;
			rtz.StandardDate.iHour = BitConverter.ToInt16( b,iStartPoint); iStartPoint += 2;
			rtz.StandardDate.iMinute = BitConverter.ToInt16( b,iStartPoint); iStartPoint += 2;
			rtz.StandardDate.iSecond = BitConverter.ToInt16( b,iStartPoint); iStartPoint += 2;
			rtz.StandardDate.iMilliseconds = BitConverter.ToInt16(b, iStartPoint); iStartPoint += 2;

			rtz.DayLightDate.iYear = BitConverter.ToInt16(b, iStartPoint); iStartPoint += 2;
			rtz.DayLightDate.iMonth = BitConverter.ToInt16( b,iStartPoint); iStartPoint += 2;
			rtz.DayLightDate.iDayOfWeek = BitConverter.ToInt16(b, iStartPoint); iStartPoint += 2;
			rtz.DayLightDate.iDay = BitConverter.ToInt16( b,iStartPoint); iStartPoint += 2;
			rtz.DayLightDate.iHour = BitConverter.ToInt16( b,iStartPoint); iStartPoint += 2;
			rtz.DayLightDate.iMinute = BitConverter.ToInt16( b,iStartPoint); iStartPoint += 2;
			rtz.DayLightDate.iSecond = BitConverter.ToInt16( b,iStartPoint); iStartPoint += 2;
			rtz.DayLightDate.iMilliseconds = BitConverter.ToInt16(b, iStartPoint); iStartPoint += 2;
		}
		

    private void InitializeTimeZones() 
    {
      timeZoneByName = new Hashtable();

      using ( RegistryKey key = 
                Registry.LocalMachine.OpenSubKey( 
                  @"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones" ) )
      {
        string[] zoneNames = key.GetSubKeyNames();

        foreach ( string zoneName in zoneNames )
        {
          using ( RegistryKey subKey = key.OpenSubKey( zoneName ) )
          {
            REGTIMEZONEINFORMATION tzi = new REGTIMEZONEINFORMATION();
            
            object objKeyVal = subKey.GetValue( "Tzi" );
            ByteConverter( ref tzi, objKeyVal );
            
            timeZoneByName.Add(zoneName, tzi);
          }
        }
      }
    }

		/// <summary>
		/// Closes the Registry Key
		/// </summary>
		public void Close()
		{
			if( objLocalRegistry != null )
			{
				objLocalRegistry.Close();
				((IDisposable)objLocalRegistry).Dispose();
			}
		}

	}
}
