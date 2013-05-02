namespace MetraTech.Localization.Test
{
  using MetraTech.Localization;
  using MetraTech.Test;
	using NUnit.Framework;
	using System.Runtime.InteropServices;




  //
  // To run the this test fixture:
  // nunit-console /fixture:MetraTech.Localization.Test.Tests /assembly:O:\debug\bin\MetraTech.Localization.Test.dll
  //
  [TestFixture]
  [ComVisible(false)]
  public class Tests 
  {
		[Test]
		public void GetLocalizedDescription()
		{
			LocalizedDescription ld = LocalizedDescription.GetInstance();
			System.Console.In.ReadLine();
		}
    /// <summary>
    /// Test timezone configuration
    /// </summary>
    [Test]
    public void TestGetTimezones()
    {
			ITimeZoneList tzlist = new TimeZoneList();
			string tz = "";
			tz = tzlist.GetTimeZoneName(0);
			Assert.AreEqual("", tz);

			tz = tzlist.GetTimeZoneName(1);
			Assert.AreEqual("Asia/Kabul", tz);

			tz = tzlist.GetTimeZoneName(25);
			Assert.AreEqual("Asia/Calcutta", tz);

			tz = tzlist.GetTimeZoneName(18);
			Assert.AreEqual("America/New_York", tz);

			tz = tzlist.GetTimeZoneName(39);
			Assert.AreEqual("Pacific/Midway", tz);

			tz = tzlist.GetTimeZoneName(50);
			Assert.AreEqual("Pacific/Guam", tz);
			TestLibrary.Trace(tz);
    }

		[Test]
		public void TestInvalidTimezone()
		{
			ITimeZoneList tzlist = new TimeZoneList();
			string tz = "";
			tz = tzlist.GetTimeZoneName(51);
			Assert.AreEqual("", tz);
		}

  }
}
