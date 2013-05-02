using MetraTech.SecurityFramework;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Linq;
using MetraTech.SecurityFramework.Common.Configuration;

namespace MetraTech.SecurityFrameworkUnitTests
{
    
    
    /// <summary>
    ///This is a test class for ProcessorEngineTest and is intended
    ///to contain all ProcessorEngineTest Unit Tests
    ///</summary>
	[TestClass()]
	public class ProcessorEngineTest
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
		//
		#endregion


		/// <summary>
		///A test for Execute
		///</summary>
		[TestMethod()]
		[ExpectedException(typeof(NullInputDataException))]
		public void ProcessorExecute_NullInputTest()
		{
			ApiInput input = null;
			ApiOutput output = null;

			IEngine engine = SecurityKernel.Processor.Api.GetEngine("Processor.Detector.Sql");
			output = engine.Execute(input);
		}

		[TestMethod()]
		[ExpectedException(typeof(ProcessorException))]
		public void ProcessorExecute_EmptyInputTest()
		{
			ApiInput input = new ApiInput("");
			ApiOutput output = null;

			IEngine engine = SecurityKernel.Processor.Api.GetEngine("Processor.Validator");
			output = engine.Execute(input);
		}

		[TestMethod()]
		[ExpectedException(typeof(ProcessorException))]
		public void ProcessorExecute_SqlInjectionInputTest()
		{
			ApiInput input = new ApiInput("5' OR 1=1 --");
			ApiOutput output = null;
			IEngine engine = SecurityKernel.Processor.Api.GetEngine("Processor.Detector.Sql");
			output = engine.Execute(input);
		}

		[TestMethod()]
		[ExpectedException(typeof(ProcessorException))]
		public void ProcessorExecute_XssInjectionInputTest() 
		{
			ApiInput input = new ApiInput("alert('Xss')");
			ApiOutput output = null;
            IEngine engine = SecurityKernel.Processor.Api.GetEngine("Processor.XssDetector");
			output = engine.Execute(input);
		}

		[TestMethod()]
		[ExpectedException(typeof(ProcessorException))]
		public void ProcessorExecute_NoValidInputTest()
		{
			ApiInput input = new ApiInput("asdsdasdasdasdfsdfsdfsdfgsdfgdfgdfgdfgdfgdfgdfgdfg");
			ApiOutput output = null;
			IEngine engine = SecurityKernel.Processor.Api.GetEngine("Processor.Validator");
			output = engine.Execute(input);
		}

		[TestMethod()]
		[ExpectedException(typeof(ProcessorException))]
		public void ProcessorExecute_DeafaultEngineTest()
		{
			ApiInput input = new ApiInput("5' OR 1=1-- <script> %34 testtesttestest");
			ApiOutput output = null;
			IEngine engine = SecurityKernel.Processor.Api.GetEngine("Processor.Default");

			try
			{
				output = engine.Execute(input);
			}
			catch (ProcessorException ex)
			{
				Assert.AreEqual(3, ex.Errors.Count(), "3 errors expected but {0} found.", ex.Errors.Count());
				throw;
			}
		}

		[TestMethod()]
		public void ProcessorExecute_TrueInputTest()
		{
			ApiInput input = new ApiInput("No injection text");
			ApiOutput output = null;
			IEngine engine = SecurityKernel.Processor.Api.GetEngine("Processor.Default");
			output = engine.Execute(input);

			string inp = input.ToString();
			string outp = output.ToString();

			Assert.AreEqual(inp, outp, "Throw exception in Processor.Default");
			

		}

		[TestMethod()]
		[ExpectedException(typeof(ProcessorException))]
		public void ProcessorExecute_RuleCycleTest()
		{
			ApiInput input = new ApiInput("some input data");
			ApiOutput output = null;
			IEngine engine = SecurityKernel.Processor.Api.GetEngine("Processor.Cycle.Test");

			output = engine.Execute(input);
		}

		[TestMethod()]
		[ExpectedException(typeof(ProcessorException))]
		public void ProcessorExecute_CompositeRuleTest()
		{
			ApiInput input = new ApiInput("&#60;script&#62;alert&#40;hi&#41;&#60;&#47;script&#62;");
			ApiOutput output = null;
			IEngine engine = SecurityKernel.Processor.Api.GetEngine("Processor.CompositeRule.Test");

			try
			{
				output = engine.Execute(input);
			}
			catch (ProcessorException e)
			{
				Assert.IsNotNull(e.Errors, "Failure in composite rule chain");
				foreach (Exception exc in e.Errors)
				{
					if (exc is ProcessorException)
					{
						throw e;
					}
				}
			}
		}

		[TestMethod()]
		public void ProcessorExecute_OneStopRule()
		{
			ApiInput input = new ApiInput("&#60;script&#62;alert&#40;hi&#41;&#60;&#47;script&#62;");
			ApiOutput output = null;
			IEngine engine = SecurityKernel.Processor.Api.GetEngine("Processor.OneStopRule.Test");

			output = engine.Execute(input);
			
		}
	}
}
