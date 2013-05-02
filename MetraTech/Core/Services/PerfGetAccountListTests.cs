using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.ServiceModel;
using System.Diagnostics;

using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.MTYAAC;
using Microsoft.VisualStudio.TestTools.UnitTesting;

using MetraTech;

using MetraTech.DomainModel.Common;
using MetraTech.Core.Services;



using System.Collections;
using MetraTech.Interop.MTAuth;
using System.Runtime.InteropServices;
using MetraTech.DomainModel.BaseTypes;
using IMTCompositeCapability = MetraTech.Interop.MTAuth.IMTCompositeCapability;
using IMTYAAC = MetraTech.Interop.MTAuth.IMTYAAC;


//
// To Run this test:
// C:\Users\Administrator>s:\Thirdparty\NUnit260\bin\nunit-console-x86.exe /run:MetraTech.Core.Services.UnitTests.PerfGetAccountListTests O:\Debug\bin\MetraTech.Core.Services.UnitTests.dll
//
namespace MetraTech.Core.Services.UnitTests
{
	[TestClass]
	public class PerfGetAccountListTests
	{
		private static bool m_isPerformanceOutputSampleFileSpecified = false;
		private static string m_performanceOutputSampleFile = "";

		/// <summary>
		///    Runs once before any of the tests are run.
		/// </summary>
		[ClassInitialize]
		public static void InitTests(TestContext testContext)
		{
			string performanceOutputSampleFile = System.Environment.GetEnvironmentVariable("PERFORMANCE_OUTPUT_SAMPLE_FILE");
			if ((performanceOutputSampleFile != null) && (performanceOutputSampleFile.Length > 0))
			{
				m_isPerformanceOutputSampleFileSpecified = true;
				m_performanceOutputSampleFile = performanceOutputSampleFile;
			}
		}

		[TestMethod]
		public void TestGetAccountListByLastName50()
		{
			AccountServiceClient client = new AccountServiceClient();
			client.ClientCredentials.UserName.UserName = "su";
			client.ClientCredentials.UserName.Password = "su123";

			// Note: these are the only "real" accounts in the DB.
			// The other accounts fail.
#if true
			List<string> lastNames = new List<string>()
                                 {
                                   "Product Management",
                                   "Cook",
                                   "Spicoli",
                                   "EMEA HQ",
                                   "Software, Inc.",
                                   "Americas HQ",
                                   "Asia Pacific HQ",
                                   "XXX"
                                 };
#else
      List<string> lastNames = new List<string>()
                                 {
                                   "Mamaril",
                                   "Hlavaty",
                                   "Kirkegaard",
                                   "Mcdaries",
                                   "Mastrogiovann",
                                   "Apthorpe",
                                   "Dibari",
                                   "Damato"
                                 };
#endif
			List<long> timingSamples = new List<long>();

			int numDesiredSamples = 50;

			long sumMilliseconds = 0;
			long maxMilliseconds = -1;
			long minMilliseconds = 999999999;
			long firstMilliseconds = 0;
			bool isFirst = true;

			while (timingSamples.Count <= numDesiredSamples)
			{
				foreach (var lastName in lastNames)
				{
					MTList<Account> accounts = new MTList<Account>();
					accounts.Filters.Add(new MTFilterElement("LastName", MTFilterElement.OperationType.Equal, lastName));
					accounts.PageSize = 10;
					accounts.CurrentPage = 1;

					Stopwatch stopWatch = new Stopwatch();

					stopWatch.Start();
					client.GetAccountList(DateTime.Now, ref accounts, false);
					stopWatch.Stop();

					if (isFirst == true)
					{
						firstMilliseconds = stopWatch.ElapsedMilliseconds;
						isFirst = false;
					}
					else
					{
						sumMilliseconds += stopWatch.ElapsedMilliseconds;
						if (stopWatch.ElapsedMilliseconds < minMilliseconds)
						{
							minMilliseconds = stopWatch.ElapsedMilliseconds;
						}

						if (stopWatch.ElapsedMilliseconds > maxMilliseconds)
						{
							maxMilliseconds = stopWatch.ElapsedMilliseconds;
						}

						timingSamples.Add(stopWatch.ElapsedMilliseconds);
						if (timingSamples.Count >= numDesiredSamples)
						{
							break;
						}

					}

				}
			}

			// If PERFORMANCE_OUTPUT_SAMPLE_FILE is set, then write the samples to the specified file
			WriteSamplesToFile("TestGetAccountListByLastName50", timingSamples);

			int ninetyPercentIndex = (int)Math.Round(timingSamples.Count * 0.90);

			timingSamples.Sort();

			Console.WriteLine("TestGetAccountListByLastName50: averageMilliseconds={0}, maxMilliseconds={1}, minMilliseconds={2}, firstMilliseconds={3}, numSamplesInAverage={4}, 90%SamplesBelowThisValue={5}",
			  sumMilliseconds * 1.0 / numDesiredSamples, maxMilliseconds, minMilliseconds, firstMilliseconds,
			  numDesiredSamples, timingSamples[ninetyPercentIndex]);
		}

		[TestMethod]
		public void TestGetAccountListByEmailAddress50()
		{
			AccountServiceClient client = new AccountServiceClient();
			client.ClientCredentials.UserName.UserName = "Admin";
			client.ClientCredentials.UserName.Password = "Admin123";

			// Note: these are the only "real" accounts in the DB.
			// The other accounts fail.
			List<string> emailAddresses = new List<string>()
                                 {
                                   "jeff.spicoli@metratech.com",
                                   "doug@metratech.com",
                                   "pm@metratech.com",
                                   "emea@metratech.com",
                                   "sw@metratech.com",
                                   "americas@metratech.com",
                                   "apac@metratech.com"
                                 };
			List<long> timingSamples = new List<long>();

			int numDesiredSamples = 50;

			long sumMilliseconds = 0;
			long maxMilliseconds = -1;
			long minMilliseconds = 999999999;
			long firstMilliseconds = 0;
			bool isFirst = true;

			while (timingSamples.Count <= numDesiredSamples)
			{
				foreach (var emailAddress in emailAddresses)
				{

					MTList<Account> accounts = new MTList<Account>();
					accounts.Filters.Add(new MTFilterElement("Email", MTFilterElement.OperationType.Equal, emailAddress));
					accounts.PageSize = 10;
					accounts.CurrentPage = 1;

					Stopwatch stopWatch = new Stopwatch();
					DateTime startTime = DateTime.Now;

					stopWatch.Start();
					client.GetAccountList(DateTime.Now, ref accounts, false);
					stopWatch.Stop();

					if (isFirst == true)
					{
						firstMilliseconds = stopWatch.ElapsedMilliseconds;
						isFirst = false;
					}
					else
					{
						sumMilliseconds += stopWatch.ElapsedMilliseconds;
						if (stopWatch.ElapsedMilliseconds < minMilliseconds)
						{
							minMilliseconds = stopWatch.ElapsedMilliseconds;
						}

						if (stopWatch.ElapsedMilliseconds > maxMilliseconds)
						{
							maxMilliseconds = stopWatch.ElapsedMilliseconds;
						}

						timingSamples.Add(stopWatch.ElapsedMilliseconds);
						if (timingSamples.Count >= numDesiredSamples)
						{
							break;
						}

					}

				}
			}

			// If PERFORMANCE_OUTPUT_SAMPLE_FILE is set, then write the samples to the specified file
			WriteSamplesToFile("TestGetAccountListByEmailAddress50", timingSamples);

			int ninetyPercentIndex = (int)Math.Round(timingSamples.Count * 0.90);

			timingSamples.Sort();

			Console.WriteLine("TestGetAccountListByEmailAddress50: averageMilliseconds={0}, maxMilliseconds={1}, minMilliseconds={2}, firstMilliseconds={3}, numSamplesInAverage={4}, 90%SamplesBelowThisValue={5}",
			  sumMilliseconds * 1.0 / numDesiredSamples, maxMilliseconds, minMilliseconds, firstMilliseconds,
			  numDesiredSamples, timingSamples[ninetyPercentIndex]);
		}

		[TestMethod]
		public void TestGetAccountListByUserName50()
		{
			AccountServiceClient client = new AccountServiceClient();
			client.ClientCredentials.UserName.UserName = "su";
			client.ClientCredentials.UserName.Password = "su123";

			// Note: these are the only "real" accounts in the DB.
			// The other accounts fail.
			List<string> userNames = new List<string>()
                                 {
                                   "demo",
                                   "GL123",
                                   "cuglobalprodmgmt",
                                   "cuapac",
                                   "jcook",
                                   "cuamericas",
                                   "cuemea",
                                   "cuttingedge"
                                 };
			List<long> timingSamples = new List<long>();

			int numDesiredSamples = 50;

			long sumMilliseconds = 0;
			long maxMilliseconds = -1;
			long minMilliseconds = 999999999;
			long firstMilliseconds = 0;
			bool isFirst = true;

			while (timingSamples.Count <= numDesiredSamples)
			{
				foreach (var userName in userNames)
				{

					MTList<Account> accounts = new MTList<Account>();
					accounts.Filters.Add(new MTFilterElement("username", MTFilterElement.OperationType.Equal, userName));
					accounts.PageSize = 10;
					accounts.CurrentPage = 1;

					Stopwatch stopWatch = new Stopwatch();
					DateTime startTime = DateTime.Now;

					stopWatch.Start();
					client.GetAccountList(DateTime.Now, ref accounts, false);
					stopWatch.Stop();

					if (isFirst == true)
					{
						firstMilliseconds = stopWatch.ElapsedMilliseconds;
						isFirst = false;
					}
					else
					{
						sumMilliseconds += stopWatch.ElapsedMilliseconds;
						if (stopWatch.ElapsedMilliseconds < minMilliseconds)
						{
							minMilliseconds = stopWatch.ElapsedMilliseconds;
						}

						if (stopWatch.ElapsedMilliseconds > maxMilliseconds)
						{
							maxMilliseconds = stopWatch.ElapsedMilliseconds;
						}

						timingSamples.Add(stopWatch.ElapsedMilliseconds);
						if (timingSamples.Count >= numDesiredSamples)
						{
							break;
						}

					}

				}
			}

			// If PERFORMANCE_OUTPUT_SAMPLE_FILE is set, then write the samples to the specified file
			WriteSamplesToFile("TestGetAccountListByUserName50", timingSamples);

			int ninetyPercentIndex = (int)Math.Round(timingSamples.Count * 0.90);

			timingSamples.Sort();

			Console.WriteLine("TestGetAccountListByUserName50: averageMilliseconds={0}, maxMilliseconds={1}, minMilliseconds={2}, firstMilliseconds={3}, numSamplesInAverage={4}, 90%SamplesBelowThisValue={5}",
			  sumMilliseconds * 1.0 / numDesiredSamples, maxMilliseconds, minMilliseconds, firstMilliseconds,
			  numDesiredSamples, timingSamples[ninetyPercentIndex]);
		}

		/// <summary>
		/// Write the test duration samples to an output file for later statistical analysis.
		/// </summary>
		/// <param name="testName">the name of the test</param>
		/// <param name="timingSamples">list of sample durations within the specified test</param>
		private void WriteSamplesToFile(string testName, List<long> timingSamples)
		{
			if (m_isPerformanceOutputSampleFileSpecified)
			{
				using (StreamWriter w = File.AppendText(m_performanceOutputSampleFile))
				{
					foreach (var timingSample in timingSamples)
					{
						w.WriteLine("{0},{1}", testName, timingSample);
					}
					w.Flush();
					w.Close();
				}
			}
		}


	}
}
