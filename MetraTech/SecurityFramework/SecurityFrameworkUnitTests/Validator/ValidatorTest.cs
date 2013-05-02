using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core.Validator;

namespace MetraTech.SecurityFrameworkUnitTests
{
	/// <summary>
	/// Unit tests for validator engines.
	/// </summary>
	[TestClass]
	public class ValidatorTest
	{
		#region Initialization tests

		public ValidatorTest()
		{
			//
			// TODO: Add constructor logic here
			//
		}

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
		// You can use the following additional attributes as you write your tests:
		//
		// Use ClassInitialize to run code before running the first test in the class
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
		// Use TestInitialize to run code before running each test 
		[TestInitialize()]
		public void SecurityKernelAllTetsInitialize()
		{
			Assert.IsTrue(SecurityKernel.IsInitialized(), "SecurityKernel is not Initialized.");
		}
		//
		// Use TestCleanup to run code after each test has run
		// [TestCleanup()]
		// public void MyTestCleanup() { }

		#endregion

		#endregion Initialization tests

		#region Basic int validator tests

		/// <summary>
		/// Test for the BasicIntValidator with proper decimal value.
		/// </summary>
		[TestMethod]
		public void BasicIntValidatorTest_Positive_Decimal()
		{
			string input = "100";
			int expected = 100;

			int actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicInt + ".V1", input).OfType<int>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicIntValidator with proper decimal value with leading and trailing spaces.
		/// </summary>
		[TestMethod]
		public void BasicIntValidatorTest_Positive_Spaces()
		{
			string input = "  100  ";
			int expected = 100;

			int actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicInt + ".V1", input).OfType<int>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicIntValidator with proper hexadecimal value.
		/// </summary>
		[TestMethod]
		public void BasicIntValidatorTest_Positive_AutoHex1()
		{
			string input = "0x100";
			int expected = 0x100;

			int actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicInt + ".V1", input).OfType<int>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicIntValidator with proper hexadecimal value.
		/// </summary>
		[TestMethod]
		public void BasicIntValidatorTest_Positive_AutoHex2()
		{
			string input = "\\x100";
			int expected = 0x100;

			int actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicInt + ".V1", input).OfType<int>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicIntValidator with proper octal value.
		/// </summary>
		[TestMethod]
		public void BasicIntValidatorTest_Positive_AutoOctal()
		{
			string input = "\\0100";
			int expected = 64;

			int actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicInt + ".V1", input).OfType<int>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicIntValidator with proper hexadecimal value.
		/// </summary>
		[TestMethod]
		public void BasicIntValidatorTest_Positive_ExactHex1()
		{
			string input = "100";
			int expected = 0x100;

			int actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicInt + ".Hex", input).OfType<int>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicIntValidator with proper hexadecimal value.
		/// </summary>
		[TestMethod]
		public void BasicIntValidatorTest_Positive_ExactHex2()
		{
			string input = "0x100";
			int expected = 0x100;

			int actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicInt + ".Hex", input).OfType<int>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicIntValidator with proper hexadecimal value.
		/// </summary>
		[TestMethod]
		public void BasicIntValidatorTest_Positive_ExactHex3()
		{
			string input = "\\x100";
			int expected = 0x100;

			int actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicInt + ".Hex", input).OfType<int>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicIntValidator with proper decimal value.
		/// </summary>
		[TestMethod]
		public void BasicIntValidatorTest_Positive_LowerBound()
		{
			string input = "0";
			int expected = 0;

			int actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicInt + ".V1", input).OfType<int>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicIntValidator with proper decimal value.
		/// </summary>
		[TestMethod]
		public void BasicIntValidatorTest_Positive_UpperBound()
		{
			string input = "2000";
			int expected = 2000;

			int actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicInt + ".V1", input).OfType<int>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicIntValidator with null input value.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void BasicIntValidatorTest_NullInput()
		{
			string input = null;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicInt + ".V1", input).OfType<int>();
		}

		/// <summary>
		/// Test for the BasicIntValidator with empty input value.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void BasicIntValidatorTest_EmptyInput()
		{
			string input = string.Empty;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicInt + ".V1", input).OfType<int>();
		}

		/// <summary>
		/// Test for the BasicIntValidator with value less than lower range bound.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void BasicIntValidatorTest_LowerBoundViolation()
		{
			string input = "-1";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicInt + ".V1", input).OfType<int>();
		}

		/// <summary>
		/// Test for the BasicIntValidator with value greate than upper range bound.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void BasicIntValidatorTest_UpperBoundViolation()
		{
			string input = "2001";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicInt + ".V1", input).OfType<int>();
		}

		/// <summary>
		/// Test for the BasicIntValidator with NaN input value.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void BasicIntValidatorTest_NaNInput()
		{
			string input = "r2001";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicInt + ".V1", input).OfType<int>();
		}

		/// <summary>
		/// Test for the BasicIntValidator with NaN input value.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void BasicIntValidatorTest_Negative_HexInput()
		{
			string input = "0x100";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicInt + ".Dec", input).OfType<int>();
		}

		#endregion

		#region Basic long validator tests

		/// <summary>
		/// Test for the BasicLongValidator with proper decimal value.
		/// </summary>
		[TestMethod]
		public void BasicLongValidatorTest_Positive_Decimal()
		{
			string input = "100";
			long expected = 100;

			long actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".V1", input).OfType<long>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicLongValidator with proper decimal value with leading and trailing spaces.
		/// </summary>
		[TestMethod]
		public void BasicLongValidatorTest_Positive_Spaces()
		{
			string input = "  100  ";
			long expected = 100;

			long actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".V1", input).OfType<long>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicLongValidator with proper hexadecimal value.
		/// </summary>
		[TestMethod]
		public void BasicLongValidatorTest_Positive_AutoHex1()
		{
			string input = "0x100";
			long expected = 0x100;

			long actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".V1", input).OfType<long>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicLongValidator with proper hexadecimal value.
		/// </summary>
		[TestMethod]
		public void BasicLongValidatorTest_Positive_AutoHex2()
		{
			string input = "\\x100";
			long expected = 0x100;

			long actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".V1", input).OfType<long>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicLongValidator with proper octal value.
		/// </summary>
		[TestMethod]
		public void BasicLongValidatorTest_Positive_AutoOctal()
		{
			string input = "\\0100";
			long expected = 64;

			long actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".V1", input).OfType<long>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicLongValidator with max available value.
		/// </summary>
		[TestMethod]
		public void BasicLongValidatorTest_Positive_MaxValue()
		{
			string input = long.MaxValue.ToString();
			long expected = long.MaxValue;

			long actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".V1", input).OfType<long>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicLongValidator with min availablel value.
		/// </summary>
		[TestMethod]
		public void BasicLongValidatorTest_Positive_MinValue()
		{
			string input = long.MinValue.ToString();
			long expected = long.MinValue;

			long actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".V1", input).OfType<long>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicLongValidator with proper hexadcecimal value.
		/// </summary>
		[TestMethod]
		public void BasicLongValidatorTest_Positive_ExactHex1()
		{
			string input = "0x100";
			long expected = 0x100;

			long actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".Hex", input).OfType<long>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicLongValidator with proper hexadcecimal value.
		/// </summary>
		[TestMethod]
		public void BasicLongValidatorTest_Positive_ExactHex2()
		{
			string input = "\\x100";
			long expected = 0x100;

			long actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".Hex", input).OfType<long>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicLongValidator with proper hexadcecimal value.
		/// </summary>
		[TestMethod]
		public void BasicLongValidatorTest_Positive_ExactHex3()
		{
			string input = "100";
			long expected = 0x100;

			long actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".Hex", input).OfType<long>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicLongValidator with proper hexadcecimal value.
		/// </summary>
		[TestMethod]
		public void BasicLongValidatorTest_Positive_LowerBound()
		{
			string input = "0";
			long expected = 0;

			long actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".Hex", input).OfType<long>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicLongValidator with proper hexadcecimal value.
		/// </summary>
		[TestMethod]
		public void BasicLongValidatorTest_Positive_UpperBound()
		{
			string input = "7d0";
			long expected = 2000;

			long actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".Hex", input).OfType<long>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicLongValidator with null input value.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void BasicLongValidatorTest_NullInput()
		{
			string input = null;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".Hex", input).OfType<long>();
		}

		/// <summary>
		/// Test for the BasicLongValidator with empty input value.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void BasicLongValidatorTest_EmptyInput()
		{
			string input = string.Empty;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".Hex", input).OfType<long>();
		}

		/// <summary>
		/// Test for the BasicLongValidator with value less than lower range bound.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void BasicLongValidatorTest_LowerBoundViolation()
		{
			string input = "FFFFFFFFFFFFFFFF";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".Hex", input).OfType<long>();
		}

		/// <summary>
		/// Test for the BasicLongValidator with value greate than upper range bound.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void BasicLongValidatorTest_UpperBoundViolation()
		{
			string input = "7d1";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".Hex", input).OfType<long>();
		}

		/// <summary>
		/// Test for the BasicLongValidator with NaN input value.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void BasicLongValidatorTest_Negative_HexInput()
		{
			string input = "0x7d1";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".Hex", input).OfType<long>();
		}

		/// <summary>
		/// Test for the BasicLongValidator with NaN input value.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void BasicLongValidatorTest_Negative_NaNInput()
		{
			string input = "r2001";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicLongint + ".V1", input).OfType<long>();
		}

		#endregion

		#region Basic double validator tests

		/// <summary>
		/// Test for the BasicDoubleValidator with proper value.
		/// </summary>
		[TestMethod]
		public void BasicDoubleValidatorTest_Positive()
		{
			string input = "100.001";
			double expected = 100.001;

			double actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicDouble + ".V1", input).OfType<double>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicDoubleValidator with proper value with leading and trailing spaces.
		/// </summary>
		[TestMethod]
		public void BasicDoubleValidatorTest_Positive_Speces()
		{
			string input = "  100.001  ";
			double expected = 100.001;

			double actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicDouble + ".V1", input).OfType<double>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicDoubleValidator with max available value.
		/// </summary>
		[TestMethod]
		public void BasicDoubleValidatorTest_Positive_MaxValue()
		{
			string input = "1.79769e+308";
			double expected = 1.79769e+308;

			double actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicDouble + ".V1", input).OfType<double>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicDoubleValidator with min available value.
		/// </summary>
		[TestMethod]
		public void BasicDoubleValidatorTest_Positive_MinValue()
		{
			string input = "-1.79769e+308";
			double expected = -1.79769e+308;

			double actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicDouble + ".V1", input).OfType<double>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicDoubleValidator with proper value.
		/// </summary>
		[TestMethod]
		public void BasicDoubleValidatorTest_Positive_LowerBound()
		{
			string input = "-2000";
			double expected = -2000;

			double actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicDouble + ".Limited", input).OfType<double>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicDoubleValidator with proper value.
		/// </summary>
		[TestMethod]
		public void BasicDoubleValidatorTest_Positive_UpperBound()
		{
			string input = "2000";
			double expected = 2000;

			double actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicDouble + ".Limited", input).OfType<double>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the BasicDoubleValidator with null value.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void BasicDoubleValidatorTest_NullValue()
		{
			string input = null;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicDouble + ".V1", input).OfType<double>();
		}

		/// <summary>
		/// Test for the BasicDoubleValidator with empty value.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void BasicDoubleValidatorTest_EmptyValue()
		{
			string input = string.Empty;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicDouble + ".V1", input).OfType<double>();
		}

		/// <summary>
		/// Test for the BasicDoubleValidator with value less than lower range bound.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void BasicDoubleValidatorTest_LowerBoundViolation()
		{
			string input = "-2000.0001";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicDouble + ".Limited", input).OfType<double>();
		}

		/// <summary>
		/// Test for the BasicDoubleValidator with greate than upper range bound.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void BasicDoubleValidatorTest_UpperBoundViolation()
		{
			string input = "+2000.0001";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicDouble + ".Limited", input).OfType<double>();
		}

		/// <summary>
		/// Test for the BasicDoubleValidator with greate than upper range bound.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void BasicDoubleValidatorTest_Negative_NaNInput()
		{
			string input = "r2000.0001";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicDouble + ".V1", input).OfType<double>();
		}

		#endregion

		#region Basic string validator tests

		/// <summary>
		/// Test for BasicStringValidator with valid data - middle length text.
		/// </summary>
		[TestMethod]
		public void BasicStringValidatorTest_Positive()
		{
			string input = "Pretty good data";
			string expected = input;

			string actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicString + ".V1", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for BasicStringValidator with valid data - short length text.
		/// </summary>
		[TestMethod]
		public void BasicStringValidatorTest_Positive_LowerBoundLength()
		{
			string input = "Adata";
			string expected = input;

			string actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicString + ".V1", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for BasicStringValidator with valid data - short length text.
		/// </summary>
		[TestMethod]
		public void BasicStringValidatorTest_Positive_UpperBoundLength()
		{
			string input = new string('a', 20);
			string expected = input;

			string actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicString + ".V1", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for BasicStringValidator with null input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void BasicStringValidatorTest_NullInput()
		{
			string input = null;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicString + ".V1", input);
		}

		/// <summary>
		/// Test for BasicStringValidator with empty input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void BasicStringValidatorTest_EmptyInput()
		{
			string input = string.Empty;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicString + ".V1", input);
		}

		/// <summary>
		/// Test for BasicStringValidator with too short input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void BasicStringValidatorTest_ShortInput()
		{
			string input = "aaaa";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicString + ".V1", input);
		}

		/// <summary>
		/// Test for BasicStringValidator with too long input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void BasicStringValidatorTest_LongInput()
		{
			string input = new string('a', 21);

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicString + ".V1", input);
		}

		/// <summary>
		/// Test for BasicStringValidator with invalid character in input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void BasicStringValidatorTest_InvalidInput()
		{
			string input = "aaaaa&ll";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.BasicString + ".Def", input);
		}

		#endregion

		#region Credit card string validator tests

		/// <summary>
		/// Test for the CcnStringValidator with proper data.
		/// </summary>
		[TestMethod]
		public void CcnStringValidatorTest_Positive()
		{
			string input = "4111111111111111";
			string expected = "4111111111111111";

			string actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.CreditCardString + ".V1", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the CcnStringValidator with proper data containing spaces and hyphens.
		/// </summary>
		[TestMethod]
		public void CcnStringValidatorTest_Positive_Spaces()
		{
			string input = "   4111-1111-1111-11 11  ";
			string expected = "4111111111111111";

			string actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.CreditCardString + ".V1", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the CcnStringValidator with null input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void CcnStringValidatorTest_NullInput()
		{
			string input = null;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.CreditCardString + ".V1", input);
		}

		/// <summary>
		/// Test for the CcnStringValidator with empty input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void CcnStringValidatorTest_EmptyInput()
		{
			string input = string.Empty;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.CreditCardString + ".V1", input);
		}

		/// <summary>
		/// Test for the CcnStringValidator with too short number.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void CcnStringValidatorTest_Negative_TooShortNumber()
		{
			string input = "4";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.CreditCardString + ".V1", input);
		}

		/// <summary>
		/// Test for the CcnStringValidator with too short number.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void CcnStringValidatorTest_Negative_TooLongNumber()
		{
			string input = "41111111111111111";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.CreditCardString + ".V1", input);
		}

		/// <summary>
		/// Test for the CcnStringValidator with invalid character in the middle of a number.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void CcnStringValidatorTest_Negative_InvalidCharacter1()
		{
			string input = "411r111111111111";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.CreditCardString + ".V1", input);
		}

		/// <summary>
		/// Test for the CcnStringValidator with invalid character at the beginning of a number.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void CcnStringValidatorTest_Negative_InvalidCharacter2()
		{
			string input = "r411111111111111";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.CreditCardString + ".V1", input);
		}

		/// <summary>
		/// Test for the CcnStringValidator with invalid character at the end of a number.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void CcnStringValidatorTest_Negative_InvalidCharacter3()
		{
			string input = "411111111111111r";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.CreditCardString + ".V1", input);
		}

		/// <summary>
		/// Test for the CcnStringValidator with invalid number.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void CcnStringValidatorTest_Negative_InvalidNumber()
		{
			string input = "4111111111111121";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.CreditCardString + ".V1", input);
		}

		#endregion

		#region Hex string validator tests

		/// <summary>
		/// Test for the HexStringValidator with proper input data.
		/// </summary>
		[TestMethod]
		public void HexStringValidatorTest_Positive()
		{
			string input = "0123456789abcdefABCDEF";
			string expected = "0123456789abcdefABCDEF";

			string actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.HexString + ".V1", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the HexStringValidator with null input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void HexStringValidatorTest_NullInput()
		{
			string input = null;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.HexString + ".V1", input);
		}

		/// <summary>
		/// Test for the HexStringValidator with empty input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void HexStringValidatorTest_EmptyInput()
		{
			string input = string.Empty;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.HexString + ".V1", input);
		}

		/// <summary>
		/// Test for the HexStringValidator with invalid character at the beginning of the input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void HexStringValidatorTest_Negative_InvalidCharacter1()
		{
			string input = "r0123456789abcdefABCDEF";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.HexString + ".V1", input);
		}

		/// <summary>
		/// Test for the HexStringValidator with invalid character in the middle of the input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void HexStringValidatorTest_Negative_InvalidCharacter2()
		{
			string input = "0123456r789abcdefABCDEF";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.HexString + ".V1", input);
		}

		/// <summary>
		/// Test for the HexStringValidator with invalid character at the end of the input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void HexStringValidatorTest_Negative_InvalidCharacter3()
		{
			string input = "0123456789abcdefABCDEFr";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.HexString + ".V1", input);
		}

		#endregion

		#region Printable string validator tests

		/// <summary>
		/// Test for PrintableStringValidator with only valid ASCII characters.
		/// </summary>
		[TestMethod]
		public void PrintableStringValidatorTest_Positive()
		{
			string input = " ^[s!\"#$%&'()*+,-./0-9:;<=>?@A-Z\\[]^_`a-z{|}~]+$  \t\n";
			string expected = input;

			string actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.PrintableString + ".V1", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for PrintableStringValidator with only valid ASCII characters.
		/// </summary>
		[TestMethod]
		public void PrintableStringValidatorTest_Positive_Trimmed()
		{
			string input = " ^[s!\"#$%&'()*+,-./0-9:;<=>?@A-Z\\[]^_`a-z{|}~]+$  \t\n";
			string expected = input.Trim();

			string actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.PrintableString + ".Trim", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for PrintableStringValidator with null input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void PrintableStringValidatorTest_NullInput()
		{
			string input = null;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.PrintableString + ".V1", input);
		}

		/// <summary>
		/// Test for PrintableStringValidator with empty input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void PrintableStringValidatorTest_EmptyInput()
		{
			string input = string.Empty;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.PrintableString + ".V1", input);
		}

		/// <summary>
		/// Test for PrintableStringValidator with non-ASCII character at the beginning of the input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void PrintableStringValidatorTest_Negative_InvalidCharacter1()
		{
			string input = "Ф#$%&'()*+,-./0-9:;<=>?@A-Z\\";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.PrintableString + ".V1", input);
		}

		/// <summary>
		/// Test for PrintableStringValidator with non-ASCII character in the middle of the input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void PrintableStringValidatorTest_Negative_InvalidCharacter2()
		{
			string input = "#$%&'()*+,-./Ф0-9:;<=>?@A-Z\\";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.PrintableString + ".V1", input);
		}

		/// <summary>
		/// Test for PrintableStringValidator with non-ASCII character at the end of the input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void PrintableStringValidatorTest_Negative_InvalidCharacter3()
		{
			string input = "#$%&'()*+,-./0-9:;<=>?@A-Z\\Ф";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.PrintableString + ".V1", input);
		}

		#endregion

		#region Date string validator tests

		/// <summary>
		/// Test for DateStringValidator with input value in format dd/MM/yyyy.
		/// </summary>
		[TestMethod]
		public void DateStringValidatorTest_Positive1()
		{
			string input = "01/31/2010";
			DateTime expected = new DateTime(2010, 1, 31);

			DateTime actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for DateStringValidator with input value in format d/M/yyyy.
		/// </summary>
		[TestMethod]
		public void DateStringValidatorTest_Positive2()
		{
			string input = "1/5/2010";
			DateTime expected = new DateTime(2010, 1, 5);

			DateTime actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for DateStringValidator with input value in format MMM dd, yyyy.
		/// </summary>
		[TestMethod]
		public void DateStringValidatorTest_Positive3()
		{
			string input = "Jan 31, 2010";
			DateTime expected = new DateTime(2010, 1, 31);

			DateTime actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for DateStringValidator with input value in format MMM dd, yyyy.
		/// </summary>
		[TestMethod]
		public void DateStringValidatorTest_Positive4()
		{
			string input = "Jan 01, 2010";
			DateTime expected = new DateTime(2010, 1, 1);

			DateTime actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for DateStringValidator with input value in format MMMM d, yyyy.
		/// </summary>
		[TestMethod]
		public void DateStringValidatorTest_Positive5()
		{
			string input = "January 1, 2010";
			DateTime expected = new DateTime(2010, 1, 1);

			DateTime actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for DateStringValidator with input value in format dd/MM/yyyy hh:mm:ss.
		/// </summary>
		[TestMethod]
		public void DateStringValidatorTest_Positive6()
		{
			string input = "01/31/2010 1:30:25PM";
			DateTime expected = new DateTime(2010, 1, 31, 13, 30, 25);

			DateTime actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for DateStringValidator with input value in format dd/MM/yyyy HH:mm:ss.
		/// </summary>
		[TestMethod]
		public void DateStringValidatorTest_Positive7()
		{
			string input = "01/31/2010 13:30:25";
			DateTime expected = new DateTime(2010, 1, 31, 13, 30, 25);

			DateTime actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for DateStringValidator with input value in format MMM dd, yyyy hh:mm:ss.
		/// </summary>
		[TestMethod]
		public void DateStringValidatorTest_Positive8()
		{
			string input = "Jan 01, 2010 1:30:25PM";
			DateTime expected = new DateTime(2010, 1, 1, 13, 30, 25);

			DateTime actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for DateStringValidator with input value in format MMMM dd, yyyy HH:mm:ss.
		/// </summary>
		[TestMethod]
		public void DateStringValidatorTest_Positive9()
		{
			string input = "January 01, 2010 13:30:25";
			DateTime expected = new DateTime(2010, 1, 1, 13, 30, 25);

			DateTime actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for DateStringValidator with input value in format yyyy-MM-dd.
		/// </summary>
		[TestMethod]
		public void DateStringValidatorTest_Positive10()
		{
			string input = "2010-01-31";
			DateTime expected = new DateTime(2010, 1, 31);

			DateTime actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for DateStringValidator with input value in format yyyy-MM-dd HH:mm:ss.
		/// </summary>
		[TestMethod]
		public void DateStringValidatorTest_Positive11()
		{
			string input = "2010-01-31 13:30:25";
			DateTime expected = new DateTime(2010, 1, 31, 13, 30, 25);

			DateTime actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for DateStringValidator with input value in format yyyy-MM-ddTHH:mm:ss.
		/// </summary>
		[TestMethod]
		public void DateStringValidatorTest_Positive12()
		{
			string input = "2010-01-31T13:30:25";
			DateTime expected = new DateTime(2010, 1, 31, 13, 30, 25);

			DateTime actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for DateStringValidator with input value in format yyyy-MM-dd HH:mm:ss and leading and trailing spaces.
		/// </summary>
		[TestMethod]
		public void DateStringValidatorTest_Positive_Spaces()
		{
			string input = "   2010-01-31     13:30:25   ";
			DateTime expected = new DateTime(2010, 1, 31, 13, 30, 25);

			DateTime actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for DateStringValidator with null input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void DateStringValidatorTest_NullInput()
		{
			string input = null;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
		}

		/// <summary>
		/// Test for DateStringValidator with empty input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void DateStringValidatorTest_EmptyInput()
		{
			string input = string.Empty;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
		}

		/// <summary>
		/// Test for DateStringValidator with not a date input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void DateStringValidatorTest_Negative1()
		{
			string input = "asdjkggsd kful";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
		}

		/// <summary>
		/// Test for DateStringValidator with invalid date format.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void DateStringValidatorTest_Negative2()
		{
			string input = "31/1/2010";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
		}

		/// <summary>
		/// Test for DateStringValidator with invalid time format.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void DateStringValidatorTest_Negative3()
		{
			string input = "1/31/2010 :30:25";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.DateString + ".V1", input).OfType<DateTime>();
		}

		#endregion

		#region BASE 64 string validator tests

		/// <summary>
		/// Test for Base64StringValidator with valid input data.
		/// </summary>
		[TestMethod]
		public void Base64StringValidatorTest_Positive()
		{
			string input = "all+";
			string expected = "jY~";

			string actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.Base64String + ".V1", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for Base64StringValidator with another valid input data.
		/// </summary>
		[TestMethod]
		public void Base64StringValidatorTest_Positive2()
		{
			string input = "77+g77+lwqjCv8OF";
			string expected = "￠￥¨¿Å";

			string actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.Base64String + ".V1", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for Base64StringValidator with valid null input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void Base64StringValidatorTest_NullInput()
		{
			string input = null;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.Base64String + ".V1", input);
		}

		/// <summary>
		/// Test for Base64StringValidator with valid empty input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void Base64StringValidatorTest_EmptyInput()
		{
			string input = string.Empty;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.Base64String + ".V1", input);
		}

		/// <summary>
		/// Test for Base64StringValidator with invalid input length.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void Base64StringValidatorTest_InvalidLength()
		{
			string input = "aaa";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.Base64String + ".V1", input);
		}

		/// <summary>
		/// Test for Base64StringValidator with invalid character in input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void Base64StringValidatorTest_InvalidCHaracter()
		{
			string input = "all-";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.Base64String + ".V1", input);
		}

		#endregion

		#region Pattern string validator tests

		/// <summary>
		/// Test for PatternStringValidator with valid input.
		/// </summary>
		[TestMethod]
		public void PatternStringValidatorTest_Positive()
		{
			string input = "0123456789";
			string expected = input;

			string actual = SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.PatternString + ".Test", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for PatternStringValidator with null input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void PatternStringValidatorTest_NullInput()
		{
			string input = null;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.PatternString + ".Test", input);
		}

		/// <summary>
		/// Test for PatternStringValidator with empty input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void PatternStringValidatorTest_EmptyInput()
		{
			string input = string.Empty;

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.PatternString + ".Test", input);
		}

		/// <summary>
		/// Test for PatternStringValidator with invalid input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(ValidatorInputDataException))]
		public void PatternStringValidatorTest_Negative()
		{
			string input = "abc";

			SecurityKernel.Validator.Api.Execute(ValidatorEngineCategory.PatternString + ".Test", input);
		}

		#endregion
	}
}
