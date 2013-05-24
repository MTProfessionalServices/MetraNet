
using System;

using MetraTech.Interop.MetraTime;

namespace MetraTech
{
	public class MetraTime
	{
		/// <summary>
		/// The current date and time, possibly adjusted for MetraTime.
		/// </summary>
		public static DateTime Now
		{
			get
			{
				IMetraTimeClient timeClient = (IMetraTimeClient) new MetraTimeClient();
				DateTime tmp = (DateTime) timeClient.GetMTOLETime();
        System.Runtime.InteropServices.Marshal.ReleaseComObject(timeClient);
        return tmp;
			}
			set
			{
				IMetraTimeControl timeControl = (IMetraTimeControl) new MetraTimeControl();
				timeControl.SetSimulatedOLETime(value);
        System.Runtime.InteropServices.Marshal.ReleaseComObject(timeControl);
			}
		}

    public static string NowWithMilliSec
    {
      get
      {
        IMetraTimeClient timeClient = (IMetraTimeClient) new MetraTimeClient();
        string tmp = (string) timeClient.GetMTTimeWithMilliSecAsString();
        System.Runtime.InteropServices.Marshal.ReleaseComObject(timeClient);
        return tmp;
      }
    }
		/// <summary>
		/// The earliest possible datetime/value used in the MetraTech system.
		/// </summary>
		public static DateTime Min
		{
			get
			{
				IMetraTimeClient timeClient = (IMetraTimeClient) new MetraTimeClient();
				DateTime tmp = (DateTime) timeClient.MinMTOLETime;
        System.Runtime.InteropServices.Marshal.ReleaseComObject(timeClient);
        return tmp;
			}
		}

		/// <summary>
		/// The latest possible datetime/value used in the MetraTech system.
		/// </summary>
		public static DateTime Max
		{
			get
			{
				IMetraTimeClient timeClient = (IMetraTimeClient) new MetraTimeClient();
        DateTime tmp = (DateTime) timeClient.MaxMTOLETime;
        System.Runtime.InteropServices.Marshal.ReleaseComObject(timeClient);
        return tmp;
			}
		}

		/// <summary>
		/// a string version of the date useful for database queries.
		/// for example: {ts '2003-06-30 23:59:59'}
		/// </summary>
		public static string FormatAsODBC(DateTime input)
		{
			return input.ToString("'{ts \\''yyyy'-'MM'-'dd HH':'mm':'ss'\\'}'");
		}

    /// <summary>
    /// Reset MetraTime to system time.
    /// </summary>
    public static void Reset()
    {
      IMetraTimeControl timeControl = (IMetraTimeControl) new MetraTimeControl();
      timeControl.SetSimulatedTimeOffset(0);
      System.Runtime.InteropServices.Marshal.ReleaseComObject(timeControl);
    }
	}
}
