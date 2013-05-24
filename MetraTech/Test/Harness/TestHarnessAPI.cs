using System;
using System.Reflection;

namespace MetraTech.Test.TestHarness {


	/// <summary>
	/// 
	/// </summary>
	public class TestHarnessAPI
	{

		public void LogResult(bool success)
    {
			LogResult(success, "", "");
		}

		public void LogResult(bool success, string subTest)
    {
			LogResult(success, subTest, "");
		}
		
		public void LogResult(bool success, string subTest, string details)
		{
			string fullDetails = String.Format("{0}: {1}", subTest, details);
			MetraTech.COMObjectInstance objMTTestApi = new MetraTech.COMObjectInstance("MTTestAPI.TestAPI");
			string msg = (string) objMTTestApi.ExecuteMethod("LogResult",
																											 this.CurrentTest,
																											 success,
																											 DateTime.Now.ToString(),
																											 DateTime.Now.ToString(),
																											 fullDetails);
			TRACE(msg);
		}

		/// <summary></summary>
		public  bool SetOperation(string strMessage){
			return TRACE("Operation:"+strMessage);
		}
		/// <summary></summary>
		public  bool TRACE(string strMessage){

			MetraTech.COMObjectInstance objMTTestApi = new MetraTech.COMObjectInstance("MTTestAPI.TestAPI");
			return (bool)objMTTestApi.ExecuteMethod("Trace",strMessage);
		}
		/// <summary></summary>
		public bool TestHarnessMode{
			get {
				MetraTech.COMObjectInstance objMTTestApi = new MetraTech.COMObjectInstance("MTTestAPI.TestAPI");
				return (bool)objMTTestApi.GetProperty("TestHarnessMode");
			}
		}
		/// <summary></summary>
		public string TestDatabaseFolder{
			get{return System.Environment.GetEnvironmentVariable("METRATECHTESTDATABASE");}
		}

		// returns the name of the current test being run by the TestHarness
		// NOTE: the name includes the .TEST suffix
		public string CurrentTest
		{
			get
			{
				MetraTech.COMObjectInstance objMTTestApi = new MetraTech.COMObjectInstance("MTTestAPI.TestAPI");
				return (string) objMTTestApi.GetProperty("CurrentTest");
			}
		}

		// returns whether a test is currently being run by the TestHarness
		public bool IsTestRunning
		{
			get
			{
				string testName = CurrentTest;
				if ((testName == null) || (testName.Length == 0))
					return false;
				else
					return true;
			}
		}

	}

}

