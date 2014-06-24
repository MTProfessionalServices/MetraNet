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
 	      new TimeZoneHelper() { DisplayName="_GMT_12_00__Eniwetok__Kwajalein", Id="Dateline Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_11_00__Midway_Island__Samoa", Id="Samoa Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_10_00__Hawaii", Id="Hawaiian Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_09_00__Alaska", Id="Alaskan Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_08_00__Pacific_Time__US___Canada___Tijuana", Id="Pacific Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_07_00__Mountain_Time__US___Canada_", Id="Mountain Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_07_00__Arizona", Id="US Mountain Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_06_00__Central_Time__US___Canada_", Id="Central Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_06_00__Saskatchewan", Id="Canada Central Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_06_00__Mexico_City__Tegucigalpa", Id="Mexico Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT-06:00) Central America", Id="Central America Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_05_00__Eastern_Time__US___Canada_", Id="Eastern Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_05_00__Indiana__East_", Id="US Eastern Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_05_00__Bogota__Lima", Id="SA Pacific Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_04_00__Atlantic_Time__Canada_", Id="Atlantic Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_04_00__Caracas__La_Paz", Id="SA Western Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT-04:00) Santiago", Id="Pacific SA Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_03_30__Newfoundland", Id="Newfoundland Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT-03:00) Brasilia", Id="E. South America Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_03_00__Buenos_Aires__Georgetown", Id="SA Eastern Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT-03:00) Greenland", Id="Greenland Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT-02:00) Mid-Atlantic", Id="Mid-Atlantic Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_01_00__Azores__Cape_Verde_Is_", Id="Azores Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT-01:00) Cape Verde Is.", Id="Cape Verde Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT__Greenwich_Mean_Time__Dublin__Edinburgh__London__Lisbon", Id="GMT Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT__Monrovia__Casablanca", Id="Greenwich Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_01_00__Prague__Warsaw__Budapest", Id="Central Europe Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+01:00) Sarajevo, Skopje, Sofija, Vilnius, Warsaw, Zagreb", Id="Central European Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_01_00__Paris__Madrid__Amsterdam", Id="Romance Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_01_00__Berlin__Stockholm__Rome__Bern__Brussels_Vienna", Id="W. Europe Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+01:00) West Central Africa", Id="W. Central Africa Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+02:00) Bucharest", Id="E. Europe Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_02_00__Cairo", Id="Egypt Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+02:00) Helsinki, Riga, Tallinn", Id="FLE Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_02_00__Athens__Helsinki__Istanbul", Id="GTB Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_02_00__Israel", Id="Israel Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_02_00__Harare__Pretoria", Id="South Africa Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_03_00__Moscow__St__Petersburg__Kazan__Volgograd", Id="Russian Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_03_00__Kuwait__Nairobi__Riyadh", Id="Arab Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+03:00) Nairobi", Id="E. Africa Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_03_00__Baghdad", Id="Arabic Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_03_30__Tehran", Id="Iran Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_04_00__Abu_Dhabi__Muscat__Tbilisi", Id="Arabian Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+04:00) Baku, Tbilisi, Yerevan", Id="Caucasus Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_04_30__Kabul", Id="Afghanistan Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+05:00) Ekaterinburg", Id="Ekaterinburg Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_05_00__Islamabad__Karachi__Ekaterinburg__Tashkent", Id="West Asia Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_05_30__Bombay__Calcutta__Madras__New_Delhi__Colombo", Id="India Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+05:45) Kathmandu", Id="Nepal Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_06_00__Almaty__Dhaka", Id="Central Asia Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+06:00) Sri Jayawardenepura", Id="Sri Lanka Standard Time", } 	,
        new TimeZoneHelper() { DisplayName="(GMT+06:00) Almaty, Novosibirsk", Id="N. Central Asia Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+06:30) Rangoon", Id="Myanmar Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_07_00__Bangkok__Jakarta__Hanoi", Id="SE Asia Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+07:00) Krasnoyarsk", Id="North Asia Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_08_00__Beijing__Chongqing__Urumqi", Id="China Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+08:00) Kuala Lumpur, Singapore", Id="Singapore Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_08_00__Hong_Kong__Perth__Singapore__Taipei", Id="Taipei Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+08:00) Perth", Id="W. Australia Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+08:00) Irkutsk, Ulaan Bataar", Id="North Asia East Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+09:00) Seoul", Id="Korea Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_09_00__Tokyo__Osaka__Sapporo__Seoul__Yakutsk", Id="Tokyo Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+09:00) Yakutsk", Id="Yakutsk Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_09_30__Darwin", Id="AUS Central Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_09_30__Adelaide", Id="Cen. Australia Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_10_00__Sydney__Melbourne", Id="AUS Eastern Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_10_00__Brisbane", Id="E. Australia Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_10_00__Hobart", Id="Tasmania Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+10:00) Vladivostok", Id="Vladivostok Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_10_00__Guam__Port_Moresby__Vladivostok", Id="West Pacific Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_11_00__Magadan__Solomon_Is___New_Caledonia", Id="Central Pacific Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_12_00__Fiji__Kamchatka__Marshall_Is_", Id="Fiji Standard Time", },
        new TimeZoneHelper() { DisplayName="_GMT_12_00__Wellington__Auckland", Id="New Zealand Standard Time", },
        new TimeZoneHelper() { DisplayName="(GMT+13:00) Nuku'alofa", Id="Tonga Standard Time", } 
      };
  }
}
