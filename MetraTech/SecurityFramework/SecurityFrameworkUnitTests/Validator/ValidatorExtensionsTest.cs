using MetraTech.SecurityFramework;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using MetraTech.SecurityFramework.Core.Validator;

namespace MetraTech.SecurityFrameworkUnitTests
{


	/// <summary>
	///This is a test class for ValidatorExtensionsTest and is intended
	///to contain all ValidatorExtensionsTest Unit Tests
	///</summary>
	[TestClass()]
	public class ValidatorExtensionsTest
	{


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

		#region ValidateAsBasicInt tests

		/// <summary>
		///Test for ValidateAsBasicInt with valid input.
		///</summary>
		[TestMethod()]
		public void ValidateAsBasicIntTest_Positive()
		{
			string str = "201";
			int expected = 201;

			int actual = ValidatorExtensions.ValidateAsBasicInt(str);
			Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
		}

		/// <summary>
		///Test for ValidateAsBasicInt with invalid input.
		///</summary>
		[TestMethod()]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void ValidateAsBasicIntTest_Negative()
		{
			string str = "1rr00";

			ValidatorExtensions.ValidateAsBasicInt(str);
		}

		#endregion

		#region ValidateAsBasicLong tests

		/// <summary>
		/// Test for ValidateAsBasicLong with valid input.
		/// </summary>
		[TestMethod]
		public void ValidateAsBasicLong_Positive()
		{
			string input = "201";
			long expected = 201;

			long actual = input.ValidateAsBasicLong();
			Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
		}

		/// <summary>
		/// Test for ValidateAsBasicLong with invalid input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void ValidateAsBasicLong_Negative()
		{
			string input = "1rr00";

			input.ValidateAsBasicLong();
		}

		#endregion

		#region ValidateAsBasicDouble tests

		/// <summary>
		/// Test for ValidateAsBasicDouble valid input.
		/// </summary>
		[TestMethod]
		public void ValidateAsBasicDoubleTest_Positive()
		{
			string input = "2.0001e-1";
			double expected = 2.0001e-1;

			double actual = input.ValidateAsBasicDouble();
			Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
		}

		/// <summary>
		/// Test for ValidateAsBasicDouble invalid input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void ValidateAsBasicDoubleTest_Negative()
		{
			string input = "r2.0001e-1";

			input.ValidateAsBasicDouble();
		}

		#endregion

		#region ValidateAsBasicString tests

		/// <summary>
		///Test for ValidateAsBasicString with valid input.
		///</summary>
		[TestMethod()]
		public void ValidateAsBasicStringTest_Positive()
		{
			string input = "abcdef";
			string expected = input;

			string actual = ValidatorExtensions.ValidateAsBasicString(input);
			Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
		}

		/// <summary>
		///Test for ValidateAsBasicString with invalid input.
		///</summary>
		[TestMethod()]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void ValidateAsBasicStringTest_Negative()
		{
			string input = "<>";

			ValidatorExtensions.ValidateAsBasicString(input);
		}

		#endregion

		#region ValidateAsCreditCardNumber tests

		/// <summary>
		/// Test for ValidateAsCreditCardNumber with valid input.
		/// </summary>
		[TestMethod]
		public void ValidateAsCreditCardNumberTest_Positive()
		{
			string input = "4111111111111111";
			string expected = "4111111111111111";

			string actual = input.ValidateAsCreditCardNumber();
			Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
		}

		/// <summary>
		/// Test for ValidateAsCreditCardNumber with invalid input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void ValidateAsCreditCardNumberTest_Negative()
		{
			string input = "4111111111111121";

			input.ValidateAsCreditCardNumber();
		}

		#endregion

		#region ValidateAsHexString tests

		/// <summary>
		/// Test for ValidateAsHexString with valid input.
		/// </summary>
		[TestMethod]
		public void ValidateAsHexStringTest_Positive()
		{
			string input = "01234567890abcdefFEDCBA";
			string expected = input;

			string actual = input.ValidateAsHexString();
			Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
		}

		/// <summary>
		/// Test for ValidateAsHexString with invalid input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void ValidateAsHexStringTest_Negative()
		{
			string input = "r0987654";

			input.ValidateAsHexString();
		}

		#endregion

		#region ValidateAsPrintableString tests

		/// <summary>
		/// Test for ValidateAsPrintableString with valid input.
		/// </summary>
		[TestMethod]
		public void ValidateAsPrintableStringTest_Positive()
		{
			string input = "abcdefgh";
			string expected = input;

			string actual = input.ValidateAsPrintableString();
			Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
		}

		/// <summary>
		/// Test for ValidateAsPrintableString with invalid input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void ValidateAsPrintableStringTest_Negative()
		{
			string input = "Фabcdefgh";

			input.ValidateAsPrintableString();
		}

		#endregion

		#region ValidateAsDateString tests

		/// <summary>
		/// Test for ValidateAsDateString with valid value.
		/// </summary>
		[TestMethod]
		public void ValidateAsDateStringTest_Positive()
		{
			string input = "January 01, 2010 13:30:25";
			DateTime expected = new DateTime(2010, 1, 1, 13, 30, 25);

			DateTime actual = input.ValidateAsDateString();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for ValidateAsDateString with invalid value.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void ValidateAsDateStringTest_Negative()
		{
			string input = "31/1/2010";
			
			input.ValidateAsDateString();
		}

		#endregion

		#region ValidateAsBase64String tests

		/// <summary>
		/// Test for ValidateAsBase64String with valid value.
		/// </summary>
		[TestMethod]
		public void ValidateAsBase64StringTest_Positive()
		{
			string input = "all+";
			string expected = "jY~";

			string actual = input.ValidateAsBase64String();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for ValidateAsBase64String with invalid value.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void ValidateAsBase64StringTest_Negative()
		{
			string input = "all+==";

			input.ValidateAsBase64String();
		}

		#endregion
	}
}
