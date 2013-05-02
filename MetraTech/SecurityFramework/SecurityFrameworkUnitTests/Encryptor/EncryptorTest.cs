using MetraTech.SecurityFramework.Core.Encryptor;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using MetraTech.SecurityFramework;

namespace MetraTech.SecurityFrameworkUnitTests
{
    /// <summary>
    ///This is a test class for UnprotectDataEngineTest and is intended
    ///to contain all UnprotectDataEngineTest Unit Tests
    ///</summary>
	[TestClass()]
	public class EncryptorTest
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
		//
		//Use TestInitialize to run code before running each test
		//[TestInitialize()]
		//public void MyTestInitialize()
		//{
		//}
		//
		//Use TestCleanup to run code after each test has run
		//[TestCleanup()]
		//public void MyTestCleanup()
		//{
		//}
		//
		#endregion

		#endregion

		#region ProtectDataEngine tests

		/// <summary>
		/// A test for ProtectDataEngine with proper input.
		/// </summary>
		[TestMethod]
		public void ProtectDataEngineTest_Positive()
		{
			string input = "Input Dat a";
			string actual = SecurityKernel.Encryptor.Api.Execute("ProtectData.V1", input);

			// Check the output length
			Assert.IsFalse(string.IsNullOrEmpty(actual), "Non-empty output expected but empty found.");
			Assert.AreEqual(0, actual.Length % 4, "Output length is invalid");
		}

		/// <summary>
		/// A test for ProtectDataEngine with null input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void ProtectDataEngineTest_NullInput()
		{
			string input = null;

			SecurityKernel.Encryptor.Api.Execute("ProtectData.V1", input);
		}

		#endregion

		#region UnprotectDataEngine tests

		/// <summary>
		///A test for UnprotectDataEngine Constructor
		///</summary>
		[TestMethod()]
		public void UnprotectDataEngineConstructorTest()
		{
			UnprotectDataEngine target = new UnprotectDataEngine();

			// It can't be null but an object creation can be removed by optimizer if it's not used.
			Assert.IsNotNull(target);
		}

		/// <summary>
		/// A test for UnprotectDataEngine with proper input.
		/// </summary>
		[TestMethod]
		public void UnprotectDataEngineTest_Positive()
		{
			string input = "Input Dat a";
			string expected = input;
			string intermediate = SecurityKernel.Encryptor.Api.Execute("ProtectData.V1", input);

			string actual = SecurityKernel.Encryptor.Api.Execute("UnprotectData.V1", intermediate);

			// Check the output length
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// A test for UnprotectDataEngine with null input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void UnprotectDataEngineTest_NullInput()
		{
			string input = null;
			
			SecurityKernel.Encryptor.Api.Execute("UnprotectData.V1", input);
		}

		/// <summary>
		/// A test for UnprotectDataEngine with bad encoded input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(EncryptorInputDataException))]
		public void UnprotectDataEngineTest_BadEncoding()
		{
			string input = "ttnnmm";

			SecurityKernel.Encryptor.Api.Execute("UnprotectData.V1", input);
		}

		/// <summary>
		/// A test for UnprotectDataEngine with bad encrypted input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(EncryptorInputDataException))]
		public void UnprotectDataEngineTest_BadEncrypted()
		{
			string input = "ttnnmmgg";

			SecurityKernel.Encryptor.Api.Execute("UnprotectData.V1", input);
		}

		#endregion
	}
}
