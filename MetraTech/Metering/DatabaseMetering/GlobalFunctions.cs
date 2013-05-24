using System;

namespace MetraTech.Metering.DatabaseMetering
{
	/// <summary>
	/// Summary description for GlobalFunctions.
	/// </summary>
	public class GlobalFunctions
	{
		public GlobalFunctions()
		{
		}
		
		/// <summary>
		/// This function returns the TimeZone string based on the value of the id passed
		/// </summary>
		/// <param name="iTimeZoneID"></param>
		/// <returns>timeZone string</returns>
		public static string DetermineTimeZone(short iTimeZoneID)
		{
			string strTimeZone;
			switch ( iTimeZoneID )
			{
				case 1:
					strTimeZone = "Afghanistan Standard Time";break;
				case 2:
					strTimeZone = "Alaskan Standard Time";break;
				case 3:
					strTimeZone = "Arabian Standard Time";break;
				case 4:
					strTimeZone = "Atlantic Standard Time";break;
				case 5:
					strTimeZone = "AUS Central Standard Time";break;
				case 6:
					strTimeZone = "Azores Standard Time";break;
				case 7:
					strTimeZone = "Bangkok Standard Time";break;
				case 8:
					strTimeZone = "Canada Central Standard Time";break;
				case 9:
					strTimeZone = "Cen. Australia Standard Time";break;
				case 10:
					strTimeZone = "Central Asia Standard Time";break;
				case 11:
					strTimeZone = "Central Europe Standard Time";break;
				case 12:
					strTimeZone = "Central Pacific Standard Time";break;
				case 13:
					strTimeZone = "Central Standard Time";break;
				case 14:
					strTimeZone = "China Standard Time";break;
				case 15:
					strTimeZone = "Dateline Standard Time";break;
				case 16:
					strTimeZone = "E. Europe Standard Time";break;
				case 17:
					strTimeZone = "E. South America Standard Time";break;
				case 18:
					strTimeZone = "Eastern Standard Time";break;
				case 19:
					strTimeZone = "Egypt Standard Time";break;
				case 20:
					strTimeZone = "Fiji Standard Time";break;
				case 21:
					strTimeZone = "GFT Standard Time";break;
				case 22:
					strTimeZone = "GMT";break;
				case 23:
					strTimeZone = "GMT Standard Time";break;
				case 24:
					strTimeZone = "Hawaiian Standard Time";break;
				case 25:
					strTimeZone = "India Standard Time";break;
				case 26:
					strTimeZone = "Iran Standard Time";break;
				case 27:
					strTimeZone = "Israel Standard Time";break;
				case 28:
					strTimeZone = "Mexico Standard Time";break;
				case 29:
					strTimeZone = "Mid-Atlantic Standard Time";break;
				case 30:
					strTimeZone = "Mountain Standard Time";break;
				case 31:
					strTimeZone = "New Zealand Standard Time";break;
				case 32:
					strTimeZone = "Newfoundland Standard Time";break;
				case 33:
					strTimeZone = "Pacific Standard Time";break;
				case 34:
					strTimeZone = "Romance Standard Time";break;
				case 35:
					strTimeZone = "Russian Standard Time";break;
				case 36:
					strTimeZone = "SA Eastern Standard Time";break;
				case 37:
					strTimeZone = "SA Pacific Standard Time";break;
				case 38:
					strTimeZone = "SA Western Standard Time";break;
				case 39:
					strTimeZone = "Samoa Standard Time";break;
				case 40:
					strTimeZone = "Saudi Arabia Standard Time";break;
				case 41:
					strTimeZone = "South Africa Standard Time";break;
				case 42:
					strTimeZone = "Sydney Standard Time";break;
				case 43:
					strTimeZone = "Taipei Standard Time";break;
				case 44:
					strTimeZone = "Tasmania Standard Time";break;
				case 45:
					strTimeZone = "Tokyo Standard Time";break;
				case 46:
					strTimeZone = "US Eastern Standard Time";break;
				case 47:
					strTimeZone = "US Mountain Standard Time";break;
				case 48:
					strTimeZone = "W. Europe Standard Time";break;
				case 49:
					strTimeZone = "West Asia Standard Time";break;
				case 50:
					strTimeZone = "West Pacific Standard Time";break;
				default:
					strTimeZone = "Eastern Standard Time";break;
			}
			return strTimeZone;
		}

		/// <summary>
		/// This function returns the timezone id based on the TimeZone string passed
		/// </summary>
		/// <param name="strTimeZone"></param>
		/// <returns></returns>
		public static short DetermineTimeZoneID(string strTimeZone)
		{
			short iTimeZoneID=0;
			switch (strTimeZone)
			{
				case "(GMT+04:30) Kabul":
					iTimeZoneID = 1;break;
				case "(GMT-09:00) Alaska":
					iTimeZoneID = 2;break;
				case "(GMT+04:00) Abu Dhabi, Muscat, Tbilisi":
					iTimeZoneID = 3;break;
				case "(GMT-04:00) Atlantic Time (Canada)":
					iTimeZoneID = 4;break;
				case "(GMT+09:30) Darwin":
					iTimeZoneID = 5;break;
				case "(GMT-01:00) Azores, Cape Verde Is.":
					iTimeZoneID = 6;break;
				case "(GMT+07:00) Bangkok, Jakarta, Hanoi":
					iTimeZoneID = 7;break;
				case "(GMT-06:00) Saskatchewan":
					iTimeZoneID = 8;break;
				case "(GMT+09:30) Adelaide":
					iTimeZoneID = 9;break;
				case "(GMT+06:00) Almaty, Dhaka":
					iTimeZoneID = 10;break;
				case "(GMT+01:00) Prague, Warsaw, Budapest":
					iTimeZoneID = 11;break;
				case "(GMT+11:00) Magadan, Solomon Is., New Caledonia":
					iTimeZoneID = 12;break;
				case "(GMT-06:00) Central Time (US & Canada)":
					iTimeZoneID = 13;break;
				case "(GMT+08:00) Beijing, Chongqing, Urumqi":
					iTimeZoneID = 14;break;
				case "(GMT-12:00) Eniwetok, Kwajalein":
					iTimeZoneID = 15;break;
				case "(GMT+02:00) Bucharest": //Not Implemented in MetraTech !!!!
					iTimeZoneID = 16;break;
				case "(GMT-03:00) Brasilia": //Not Implemented in MetraTech !!!!
					iTimeZoneID = 17;break;
				case "(GMT-05:00) Eastern Time (US & Canada)":
					iTimeZoneID = 18;break;
				case "(GMT+02:00) Cairo":
					iTimeZoneID = 19;break;
				case "(GMT+12:00) Fiji, Kamchatka, Marshall Is.":
					iTimeZoneID = 20;break;
				case "(GMT+02:00) Athens, Helsinki, Istanbul":
					iTimeZoneID = 21;break;
				case "(GMT) Greenwich Mean Time; Dublin, Edinburgh, London, Lisbon":
					iTimeZoneID = 22;break;
				case "(GMT) Monrovia, Casablanca":
					iTimeZoneID = 23;break;
				case "(GMT-10:00) Hawaii":
					iTimeZoneID = 24;break;
				case "(GMT+05:30) Bombay, Calcutta, Madras, New Delhi, Colombo":
					iTimeZoneID = 25;break;
				case "(GMT+03:30) Tehran":
					iTimeZoneID = 26;break;
				case "(GMT+02:00) Israel":
					iTimeZoneID = 27;break;
				case "(GMT-06:00) Mexico City, Tegucigalpa":
					iTimeZoneID = 28;break;
				case "(GMT-02:00) Mid-Atlantic": //Not Implemented in MetraTech !!!!
					iTimeZoneID = 29;break;
				case "(GMT-07:00) Mountain Time (US & Canada)":
					iTimeZoneID = 30;break;
				case "(GMT+12:00) Wellington, Auckland":
					iTimeZoneID = 31;break;
				case "(GMT-03:30) Newfoundland":
					iTimeZoneID = 32;break;
				case "(GMT-08:00) Pacific Time (US & Canada), Tijuana":
					iTimeZoneID = 33;break;
				case "(GMT+01:00) Paris, Madrid, Amsterdam":
					iTimeZoneID = 34;break;
				case "(GMT+03:00) Moscow, St. Petersburg, Kazan, Volgograd":
					iTimeZoneID = 35;break;
				case "(GMT-03:00) Buenos Aires, Georgetown":
					iTimeZoneID = 36;break;
				case "(GMT-05:00) Bogota, Lima":
					iTimeZoneID = 37;break;
				case "(GMT-04:00) Caracas, La Paz":
					iTimeZoneID = 38;break;
				case "(GMT-11:00) Midway Island, Samoa":
					iTimeZoneID = 39;break;
				case "(GMT+03:00) Baghdad, Kuwait, Nairobi, Riyadh":
					iTimeZoneID = 40;break;
				case "(GMT+02:00) Harare, Pretoria":
					iTimeZoneID = 41;break;
				case "(GMT+10:00) Brisbane, Melbourne, Sydney":
					iTimeZoneID = 42;break;
				case "(GMT+08:00) Hong Kong, Perth, Singapore, Taipei":
					iTimeZoneID = 43;break;
				case "(GMT+10:00) Hobart":
					iTimeZoneID = 44;break;
				case "(GMT+09:00) Tokyo, Osaka, Sapporo, Seoul, Yakutsk":
					iTimeZoneID = 45;break;
				case "(GMT-05:00) Indiana (East)":
					iTimeZoneID = 46;break;
				case "(GMT-07:00) Arizona":
					iTimeZoneID = 47;break;
				case "(GMT+01:00) Berlin, Stockholm, Rome, Bern, Brussels Vienna":
					iTimeZoneID = 48;break;
				case "(GMT+05:00) Islamabad, Karachi, Ekaterinburg, Tashkent":
					iTimeZoneID = 49;break;
				case "(GMT+10:00) Guam, Port Moresby, Vladivostok":
					iTimeZoneID = 50;break;
				default:
					iTimeZoneID = 18;break;
			}
			return iTimeZoneID;
			
		}


	}
}
