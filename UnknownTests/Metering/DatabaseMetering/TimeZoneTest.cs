using System;
using NUnit.Framework;

namespace MetraTech.Metering.DatabaseMetering
{
	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.Metering.DatabaseMeteringProgram.TimeZoneTest /assembly:O:\debug\bin\MetraConnect-DB.exe
	//
	[TestFixture]
	public class TimeZoneTest
	{
    // Test
    [Test]
    public void TestTimeZoneConversion()
    {
      Log.LogInit("C:\\sdklog.txt", 5, "MetraConnect-DB");

      DateTime dateTime = DateTime.Now;

      ConvertTimeZoneClass convertTimeZoneClass = new ConvertTimeZoneClass();

      string errorMessage = "ERROR in TimeZone : '";
      foreach (TimeZoneInformation timeZoneInformation in TimeZoneInformation.EnumZones()) 
      {
        DateTime d1 = convertTimeZoneClass.ConvertToGMT(dateTime, timeZoneInformation.Name);
        DateTime d2 = TimeZoneInformation.ToUniversalTime(timeZoneInformation.Index, dateTime);

        CheckDateEquality(d1, d2, true, errorMessage + timeZoneInformation.Name + "' : "); 
      }
    }

    public static void CheckDateEquality(DateTime date1, 
                                         DateTime date2, 
                                         bool checkMilliseconds, 
                                         string message) 
    {
      Assert.AreEqual(date1.Month, date2.Month, message + "Month not equal");
      Assert.AreEqual(date1.Day, date2.Day, message + "Day not equal");
      Assert.AreEqual(date1.Year, date2.Year, message + "Year not equal");
      Assert.AreEqual(date1.Hour, date2.Hour, message + "Hour not equal");
      Assert.AreEqual(date1.Minute, date2.Minute, message + "Minute not equal");
      Assert.AreEqual(date1.Second, date2.Second, message + "Second not equal");
      if(checkMilliseconds) 
      {
        Assert.AreEqual(date1.Millisecond, date2.Millisecond, message + "Millisecond not equal");
      }
    }
	}
}
