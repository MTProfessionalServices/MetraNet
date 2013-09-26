using System;
using MetraTech.DataAccess;
using MetraTech.ActivityServices.Common;
using MetraTech.TestCommon;
using MetraTech.DomainModel.BaseTypes;
using Microsoft.VisualStudio.TestTools.UnitTesting;
// FakeItEasy requires Castle assemblies. All required assemblies are under S:\Thirdparty\FakeItEasy\ and S:\Thirdparty\Castle\
using FakeItEasy;

namespace MetraTech.Core.Services.Test
{
    /// <summary>
    /// Due to storing logic in Stored Procedure whole business logic cannot be covered.
    /// Given Unit Tests are checking that stored procedure is called due to it's specification.
    /// If stored procedure throwing exception it is handled as required.
    /// </summary>
    [TestClass]
    public class QuotingServiceTest
    {
        // [MTUnitTest] gives a method TestCategory = "UnitTest".
        // This is required for test to be executed during automation runs.
        /// <summary>
        /// Test Method name 'AddNewReportDefinition_SuccessfulExecution_ReaderExecutedWithAllParameters' means that:
        /// 1. Method is tested here: 'AddNewReportDefinition'
        /// 2. Scenario of this test is: 'SuccessfulExecution'. Other words: on exception occurs.
        /// 3. We're expect that: 'ReaderExecutedWithAllParameters'. Other words: all 7 parameters were set and reaser was executed.
        /// </summary>
        [TestMethod, MTUnitTest]
        public void CreateQuote_SuccessfulExecution_QuoteGeneratedWithoutExceptions()
        {
            //// AAA(Act,Arrange,Assert) Pattern for Unit Tests introdused with simplier words: GIVEN, WHEN, THEN.
            //// http://www.solidsyntaxprogrammer.com/act-arrange-assert/

            //// Set up data for the test
            //#region Given

            //#region Mock object

            //// Indicators of invoking CreateConnection()
            ////var isQuotingImplementationInvoked = false;

            //// Creating Mock objects with 'empty' methods using interfaces
            //var mockQuotingImplementation = A.Fake<IQuotingImplementation>();
            //var mockQuoteRequest = A.Fake<QuoteRequest>();
            //var mockQuoteResponse = A.Fake<QuoteResponse>();
            
            //// CreateCallableStatement() with input value of sprocName="Export_InsertReportDefinition" will return mockCallableStatement
            ////A.CallTo(() => mockQuotingImplementation.StartQuote(mockQuoteRequest);

            //#endregion Mock object

            //// Pass Fake implementation of CreateConnection() to the tested class. See: line-258 in S:\MetraTech\Core\Services\DataExportReportManagementService.cs
            //// This is called Dependency Injection pattern
            //var service = new QuotingService(mockQuotingImplementation);

            //// This values will be used as input for test
            //var quoteRequest = new QuoteRequest {QuoteIdentifier = "TestQuote"};          
            //var quoteResponse = new QuoteResponse ();          
            //#endregion

            //// Perform the action of the test.
            //#region When

            //service.CreateQuote(quoteRequest, out quoteResponse);

            //#endregion

            //// Verify the result of the test
            //#region Then

            //// CreateConnection() invoked?
            ////Assert.IsTrue(isCreateConnectionInvoked, "CreateConnection() wasn't invoked");

            //// CreateCallableStatement was called with input value = "Export_InsertReportDefinition"?
            //A.CallTo(() => mockQuotingImplementation.StartQuote(quoteRequest)).MustHaveHappened();
            //A.CallTo(() => mockQuotingImplementation.AddNonRecurringChargesToQuote()).MustHaveHappened();
            //A.CallTo(() => mockQuotingImplementation.AddRecurringChargesToQuote()).MustHaveHappened();
            //A.CallTo(() => mockQuotingImplementation.FinalizeQuote()).MustHaveHappened();            

            //#endregion
        }

    }
}
