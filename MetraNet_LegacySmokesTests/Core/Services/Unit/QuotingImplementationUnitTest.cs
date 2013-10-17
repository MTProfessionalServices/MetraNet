using MetraTech.TestCommon;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using MetraTech.Domain.Quoting;

namespace MetraTech.Core.Services.Test.Unit.Quoting
{
    
    
    /// <summary>
    ///This is a test class for QuotingImplementationTest and is intended
    ///to contain all QuotingImplementationTest Unit Tests
    ///</summary>
    [TestClass()]
    public class QuotingImplementationTest
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
        //[ClassInitialize()]
        //public static void MyClassInitialize(TestContext testContext)
        //{
        //}
        //
        //Use ClassCleanup to run code after all tests in a class have run
        //[ClassCleanup()]
        //public static void MyClassCleanup()
        //{
        //}
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


        ///// <summary>
        /////A test for ValidateRequest
        /////</summary>
        //[TestMethod()]
        //[DeploymentItem("MetraTech.Quoting.dll")]
        //public void ValidateRequestTest()
        //{
        //    QuotingImplementation_Accessor target = new QuotingImplementation_Accessor(); // TODO: Initialize to an appropriate value
        //    QuoteRequest request = null; // TODO: Initialize to an appropriate value
        //    target.ValidateRequest(request);
        //    Assert.Inconclusive("A method that does not return a value cannot be verified.");
        //}

        // [MTUnitTest] gives a method TestCategory = "UnitTest".
        // This is required for test to be executed during automation runs.
        /// <summary>
        /// Test Method name 'AddNewReportDefinition_SuccessfulExecution_ReaderExecutedWithAllParameters' means that:
        /// 1. Method is tested here: 'AddNewReportDefinition'
        /// 2. Scenario of this test is: 'SuccessfulExecution'. Other words: on exception occurs.
        /// 3. We're expect that: 'ReaderExecutedWithAllParameters'. Other words: all 7 parameters were set and reaser was executed.
        /// </summary>
        //[TestMethod, MTUnitTest]
        //public void StartQuote_CallValidateRequest_RequestValidatedSuccessful()
        //{
        //    // AAA(Act,Arrange,Assert) Pattern for Unit Tests introdused with simplier words: GIVEN, WHEN, THEN.
        //    // http://www.solidsyntaxprogrammer.com/act-arrange-assert/

        //    // Set up data for the test
        //    #region Given

        //    #region Mock object

        //    // Indicators of invoking CreateConnection()
        //    var isCreateConnectionInvoked = false;

        //    // Creating Mock objects with 'empty' methods using interfaces
        //    var mockConnection = A.Fake<IMTConnection>();
        //    var mockCallableStatement = A.Fake<IMTCallableStatement>();

        //    // CreateCallableStatement() with input value of sprocName="Export_InsertReportDefinition" will return mockCallableStatement
        //    A.CallTo(() => mockConnection.CreateCallableStatement("Export_InsertReportDefinition")).Returns(mockCallableStatement);

        //    #endregion Mock object

        //    // Pass Fake implementation of CreateConnection() to the tested class. See: line-258 in S:\MetraTech\Core\Services\DataExportReportManagementService.cs
        //    // This is called Dependency Injection pattern
        //    var service = new DataExportReportManagementService(
        //        () =>
        //        {
        //            isCreateConnectionInvoked = true;
        //            return mockConnection;
        //        },
        //        pathToFolder => null);

        //    // This values will be used as input for test
        //    const string reportTitle = "TestReport";
        //    const string reportType = "TestReportType";
        //    const string reportDefinitionSource = "ReportDefinitionSource";
        //    const string reportDescription = "ReportDescription";
        //    const string reportQueryTag = "ReportQueryTag";
        //    const int preventAdhocExecution = 0;

        //    #endregion

        //    // Perform the action of the test.
        //    #region When

        //    service.AddNewReportDefinition(reportTitle, reportType, reportDefinitionSource, reportDescription,
        //                                   reportQueryTag, preventAdhocExecution);

        //    #endregion

        //    // Verify the result of the test
        //    #region Then

        //    // CreateConnection() invoked?
        //    Assert.IsTrue(isCreateConnectionInvoked, "CreateConnection() wasn't invoked");

        //    // CreateCallableStatement was called with input value = "Export_InsertReportDefinition"?
        //    A.CallTo(() => mockConnection.CreateCallableStatement("Export_InsertReportDefinition")).MustHaveHappened();

        //    // AddParam() was executed exactly 7 times?
        //    // Parameters name, type and value also may be specified.
        //    A.CallTo(() =>
        //      mockCallableStatement.AddParam(A<string>.Ignored, A<MTParameterType>.Ignored, A<object>.Ignored)
        //    ).MustHaveHappened(Repeated.Exactly.Times(7));

        //    // ExecuteReader() method was executed?
        //    A.CallTo(() => mockCallableStatement.ExecuteReader()).MustHaveHappened();

        //    // CallableStatement was disposed?
        //    A.CallTo(() => mockCallableStatement.Dispose()).MustHaveHappened();

        //    // Connection was disposed?
        //    A.CallTo(() => mockConnection.Dispose()).MustHaveHappened();

        //    #endregion
        //}
    }
}
