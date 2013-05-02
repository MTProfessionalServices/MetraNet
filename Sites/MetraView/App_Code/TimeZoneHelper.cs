using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

/// <summary>
/// TimeZoneHealper That returns list of GMT TimeZones
/// </summary>
class TimeZoneHelper
{
  public string DisplayName { get; set; }
  public string Id { get; set; }

   /// <summary>
  ///  Returns List of TimeZones with Ids
  /// </summary>
  /// <returns>List(TimeZoneHelper)</returns>
  public static List<TimeZoneHelper> GetTimeZoneHelpers()
  {
    return new List<TimeZoneHelper>()       
      {          
        new TimeZoneHelper() { DisplayName="(GMT-12:00) Eniwetok, Kwajalein", Id="Dateline Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-11:00) Midway Island, Samoa", Id="Samoa Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-10:00) Hawaii", Id="Hawaiian Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-09:00) Alaska", Id="Alaskan Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-08:00) Pacific Time (US & Canada), Tijuana", Id="Pacific Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-07:00) Mountain Time (US & Canada)", Id="Mountain Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-07:00) Arizona", Id="US Mountain Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-06:00) Central Time (US & Canada)", Id="Central Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-06:00) Saskatchewan", Id="Canada Central Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-06:00) Mexico City, Tegucigalpa", Id="Mexico Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-06:00) Central America", Id="Central America Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-05:00) Eastern Time (US & Canada)", Id="Eastern Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-05:00) Indiana (East)", Id="US Eastern Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-05:00) Bogota, Lima", Id="SA Pacific Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-04:00) Atlantic Time (Canada)", Id="Atlantic Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-04:00) Caracas, La Paz", Id="SA Western Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-04:00) Santiago", Id="Pacific SA Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-03:30) Newfoundland", Id="Newfoundland Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-03:00) Brasilia", Id="E. South America Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-03:00) Buenos Aires, Georgetown", Id="SA Eastern Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-03:00) Greenland", Id="Greenland Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-02:00) Mid-Atlantic", Id="Mid-Atlantic Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-01:00) Azores, Cape Verde Is.", Id="Azores Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT-01:00) Cape Verde Is.", Id="Cape Verde Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT) Greenwich Mean Time; Dublin, Edinburgh, London, Lisbon", Id="GMT Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT) Monrovia, Casablanca", Id="Greenwich Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+01:00) Prague, Warsaw, Budapest", Id="Central Europe Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+01:00) Sarajevo, Skopje, Sofija, Vilnius, Warsaw, Zagreb", Id="Central European Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+01:00) Paris, Madrid, Amsterdam", Id="Romance Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+01:00) Berlin, Stockholm, Rome, Bern, Brussels Vienna", Id="W. Europe Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+01:00) West Central Africa", Id="W. Central Africa Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+02:00) Bucharest", Id="E. Europe Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+02:00) Cairo", Id="Egypt Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+02:00) Helsinki, Riga, Tallinn", Id="FLE Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+02:00) Athens, Helsinki, Istanbul", Id="GTB Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+02:00) Israel", Id="Israel Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+02:00) Harare, Pretoria", Id="South Africa Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+03:00) Moscow, St. Petersburg, Kazan, Volgograd", Id="Russian Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+03:00) Baghdad, Kuwait, Nairobi, Riyadh", Id="Arab Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+03:00) Nairobi", Id="E. Africa Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+03:00) Baghdad", Id="Arabic Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+03:30) Tehran", Id="Iran Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+04:00) Abu Dhabi, Muscat, Tbilisi", Id="Arabian Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+04:00) Baku, Tbilisi, Yerevan", Id="Caucasus Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+04:30) Kabul", Id="Afghanistan Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+05:00) Ekaterinburg", Id="Ekaterinburg Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+05:00) Islamabad, Karachi, Ekaterinburg, Tashkent", Id="West Asia Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+05:30) Bombay, Calcutta, Madras, New Delhi, Colombo", Id="India Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+05:45) Kathmandu", Id="Nepal Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+06:00) Almaty, Dhaka", Id="Central Asia Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+06:00) Sri Jayawardenepura", Id="Sri Lanka Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+06:00) Almaty, Novosibirsk", Id="N. Central Asia Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+06:30) Rangoon", Id="Myanmar Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+07:00) Bangkok, Jakarta, Hanoi", Id="SE Asia Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+07:00) Krasnoyarsk", Id="North Asia Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+08:00) Beijing, Chongqing, Urumqi", Id="China Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+08:00) Kuala Lumpur, Singapore", Id="Singapore Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+08:00) Hong Kong, Perth, Singapore, Taipei", Id="Taipei Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+08:00) Perth", Id="W. Australia Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+08:00) Irkutsk, Ulaan Bataar", Id="North Asia East Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+09:00) Seoul", Id="Korea Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+09:00) Tokyo, Osaka, Sapporo, Seoul, Yakutsk", Id="Tokyo Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+09:00) Yakutsk", Id="Yakutsk Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+09:30) Darwin", Id="AUS Central Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+09:30) Adelaide", Id="Cen. Australia Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+10:00) Brisbane, Melbourne, Sydney", Id="AUS Eastern Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+10:00) Brisbane", Id="E. Australia Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+10:00) Hobart", Id="Tasmania Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+10:00) Vladivostok", Id="Vladivostok Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+10:00) Guam, Port Moresby, Vladivostok", Id="West Pacific Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+11:00) Magadan, Solomon Is., New Caledonia", Id="Central Pacific Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+12:00) Fiji, Kamchatka, Marshall Is.", Id="Fiji Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+12:00) Wellington, Auckland", Id="New Zealand Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+13:00) Nuku'alofa", Id="Tonga Standard Time", } 	

      };
  }
}
