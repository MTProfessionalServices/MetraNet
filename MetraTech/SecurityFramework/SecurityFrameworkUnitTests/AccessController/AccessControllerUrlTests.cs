using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.SecurityFramework;

namespace MetraTech.SecurityFrameworkUnitTests
{
	[TestClass()]
	public class AccessControllerUrlTests
	{
		#region Initialization tests

		private TestContext testContextInstance;

		/// <summary>
		///Gets or sets the test context which provides
		///information about and functionality for the current test run.
		///</summary>
		public TestContext TestContext
		{
			get
			{
				return testContextInstance;
			}
			set
			{
				testContextInstance = value;
			}
		}

		#region Additional test attributes
		// 
		//You can use the following additional attributes as you write your tests:
		//
		//Use ClassInitialize to run code before running the first test in the class
		[ClassInitialize()]
		public static void SecurityKernelInitialize(TestContext testContext)
		{
			UnitTestUtility.InitFrameworkConfiguration(testContext);
		}

		// Use ClassCleanup to run code after all tests in a class have run
		[ClassCleanup()]
		public static void SecurityKernelClassCleanup()
		{
			UnitTestUtility.CleanupFrameworkConfiguration();
		}

		// Use TestInitialize to run code before running each test 
		[TestInitialize()]
		public void SecurityKernelAllTetsInitialize()
		{
			Assert.IsTrue(SecurityKernel.IsInitialized(), "SecurityKernel is not Initialized.");
		}
		//
		//Use TestCleanup to run code after each test has run
		//[TestCleanup()]
		//public void MyTestCleanup()
		//{
		//}
		//
		#endregion

		#endregion

		[TestMethod]
		public void AccessControllerAbsoluteUrlTest_Positive()
		{
			string input = "http://metratech.com";
			ApiOutput output = SecurityKernel.AccessController.Api.ExecuteDefaultByCategory(AccessControllerEngineCategory.UrlController.ToString(), new ApiInput(input));
			string expected = "Access is allowed";
			string actual = output.ToString();

			Assert.AreEqual(expected, actual, string.Format("Access to Url {0} is denied!", input));
		}

		[TestMethod]
		public void AccessControllerRelativeUrlTest_Positive2()
		{
			string input = "/mcm/default/dialog/ServiceChargePriceAbleItem.List.asp?Tab=0&Kind=10&NextPage=/mcm/default/dialog/PriceAbleItem.Usage.ViewEdit.asp&Parameters=Tab|0&LinkColumnMode=TRUE";
			ApiOutput output = SecurityKernel.AccessController.Api.ExecuteDefaultByCategory(AccessControllerEngineCategory.UrlController.ToString(), new ApiInput(input));
			string expected = "Access is allowed";
			string actual = output.ToString();

			Assert.AreEqual(expected, actual, string.Format("Access to Url {0} is denied!", input));
		}

		[TestMethod]
		[ExpectedException(typeof(AccessControllerException))]
		public void AccessControllerAbsoluteUrlTest_Negative()
		{
			string input = "http://microsoft.com";
			ApiOutput output = SecurityKernel.AccessController.Api.ExecuteDefaultByCategory(AccessControllerEngineCategory.UrlController.ToString(), new ApiInput(input));
		}
	}
}
