using System;
using MetraTech.DataAccess;
using MetraTech.ActivityServices.Common;
using MetraTech.TestCommon;
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
    public class DataExportReportManagementServiceTest
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
        public void AddNewReportDefinition_SuccessfulExecution_ReaderExecutedWithAllParameters()
        {
            // AAA(Act,Arrange,Assert) Pattern for Unit Tests introdused with simplier words: GIVEN, WHEN, THEN.
            // http://www.solidsyntaxprogrammer.com/act-arrange-assert/

            // Set up data for the test
            #region Given

            #region Mock object

            // Indicators of invoking CreateConnection()
            var isCreateConnectionInvoked = false;

            // Creating Mock objects with 'empty' methods using interfaces
            var mockConnection = A.Fake<IMTConnection>();
            var mockCallableStatement = A.Fake<IMTCallableStatement>();

            // CreateCallableStatement() with input value of sprocName="Export_InsertReportDefinition" will return mockCallableStatement
            A.CallTo(() => mockConnection.CreateCallableStatement("Export_InsertReportDefinition")).Returns(mockCallableStatement);

            #endregion Mock object

            // Pass Fake implementation of CreateConnection() to the tested class. See: line-258 in S:\MetraTech\Core\Services\DataExportReportManagementService.cs
            // This is called Dependency Injection pattern
            var service = new DataExportReportManagementService(
                () =>
                    {
                        isCreateConnectionInvoked = true;
                        return mockConnection;
                    },
                pathToFolder => null);

            // This values will be used as input for test
            const string reportTitle = "TestReport";
            const string reportType = "TestReportType";
            const string reportDefinitionSource = "ReportDefinitionSource";
            const string reportDescription = "ReportDescription";
            const string reportQuerySource = "ReportQuerySource";
            const string reportQueryTag = "ReportQueryTag";
            const int preventAdhocExecution = 0;

            #endregion

            // Perform the action of the test.
            #region When

            service.AddNewReportDefinition(reportTitle, reportType, reportDefinitionSource, reportDescription,
                                           reportQuerySource, reportQueryTag, preventAdhocExecution);

            #endregion

            // Verify the result of the test
            #region Then

            // CreateConnection() invoked?
            Assert.IsTrue(isCreateConnectionInvoked, "CreateConnection() wasn't invoked");

            // CreateCallableStatement was called with input value = "Export_InsertReportDefinition"?
            A.CallTo(() => mockConnection.CreateCallableStatement("Export_InsertReportDefinition")).MustHaveHappened();

            // AddParam() was executed exactly 7 times?
            // Parameters name, type and value also may be specified.
            A.CallTo(() =>
              mockCallableStatement.AddParam(A<string>.Ignored, A<MTParameterType>.Ignored, A<object>.Ignored)
            ).MustHaveHappened(Repeated.Exactly.Times(7));

            // ExecuteReader() method was executed?
            A.CallTo(() => mockCallableStatement.ExecuteReader()).MustHaveHappened();

            // CallableStatement was disposed?
            A.CallTo(() => mockCallableStatement.Dispose()).MustHaveHappened();

            // Connection was disposed?
            A.CallTo(() => mockConnection.Dispose()).MustHaveHappened();

            #endregion
        }

        /// <summary>
        /// Test Method name 'AddNewReportDefinition_MASBasicExceptionOccures_MASBaseExceptionThrown' means that:
        /// 1. Method is tested here: 'AddNewReportDefinition'
        /// 2. Scenario of this test is: 'MASBasicExceptionOccures'. Other words: CreateConnection() throwing MASBasicException when called.
        /// 3. We're expect that: 'MASBaseExceptionThrown'.
        /// </summary>
        [TestMethod, MTUnitTest]
        public void AddNewReportDefinition_MASBasicExceptionOccures_MASBaseExceptionThrown()
        {
            // Set up data for the test
            #region Given

            #region Mock object

            // Two indicators of invoking CreateConnection() and occuring MASBaseException
            var isConnectionManagerCreateConnectionInvoked = false;
            var isMASBaseExceptionThrown = false;

            // Mock MASBasicException to illiminate possibility of test failing due to MASBasicException implementation
            var mockedMASBasicException = A.Fake<MASBasicException>();

            // Instead of lambda expression we're using anonymous delegate here
            DataExportReportManagementService.CreateConnectionDelegate mockedCreateConnection =
                delegate
                {
                    isConnectionManagerCreateConnectionInvoked = true;
                    throw mockedMASBasicException;
                };
            DataExportReportManagementService.CreateConnectionFromPathDelegate mockedCreateConnectionFromPath =
                pathToFolder => null;

            #endregion Mock object

            // Pass Fake implementation of CreateConnection() to the tested class. See: line-258 in S:\MetraTech\Core\Services\DataExportReportManagementService.cs
            // This is called Dependency Injection pattern
            var service = new DataExportReportManagementService(mockedCreateConnection, mockedCreateConnectionFromPath);

            // This values will be used as input for test
            const string reportTitle = "TestReport";
            const string reportType = "TestReportType";
            const string reportDefinitionSource = "ReportDefinitionSource";
            const string reportDescription = "ReportDescription";
            const string reportQuerySource = "ReportQuerySource";
            const string reportQueryTag = "ReportQueryTag";
            const int preventAdhocExecution = 0;

            #endregion

            // Perform the action of the test.
            #region When
            try
            {
                service.AddNewReportDefinition(reportTitle, reportType, reportDefinitionSource, reportDescription,
                                               reportQuerySource, reportQueryTag, preventAdhocExecution);
            }
            // Expecting MASBaseException to be thrown
            catch (MASBaseException e)
            {
                Assert.AreSame(mockedMASBasicException, e);
                isMASBaseExceptionThrown = true;
            }

            #endregion

            // Verify the result of the test
            #region Then
            
            // Ensuring that CreateConnection() was invoked and MASBaseException occured
            Assert.IsTrue(isConnectionManagerCreateConnectionInvoked);
            Assert.IsTrue(isMASBaseExceptionThrown);

            #endregion
        }

        /// <summary>
        /// Test Method name 'AddNewReportDefinition_ExceptionOccures_MASBaseExceptionThrown' means that:
        /// 1. Method is tested here: 'AddNewReportDefinition'
        /// 2. Scenario of this test is: 'ExceptionOccures'. Other words: ExecuteReader() throwing Exception("Exception") when called.
        /// 3. We're expect that: 'MASBaseExceptionThrown'.
        /// </summary>
        [TestMethod, MTUnitTest]
        [ExpectedException(typeof(MASBasicException), "MASBasicException didn't occur")]
        public void AddNewReportDefinition_ExceptionOccures_MASBaseExceptionThrown()
        {
            // Set up data for the test
            #region Given

            #region Mock object

            // Creating Mock objects with 'empty' methods using interfaces
            var mockConnection = A.Fake<IMTConnection>();
            var mockCallableStatement = A.Fake<IMTCallableStatement>();
            
            // CreateCallableStatement() with input value of sprocName="Export_InsertReportDefinition" will return mockCallableStatement
            A.CallTo(() => mockConnection.CreateCallableStatement("Export_InsertReportDefinition"))
                .Returns(mockCallableStatement);

            // ExecuteReader() of created CallableStatement will throw an Exception
            A.CallTo(() => mockCallableStatement.ExecuteReader())
                .Throws(new Exception("Exception"));

            #endregion Mock object

            // Pass Fake implementation of CreateConnection() to the tested class. See: line-258 in S:\MetraTech\Core\Services\DataExportReportManagementService.cs
            // This is called Dependency Injection pattern
            var service = new DataExportReportManagementService(() => mockConnection, s => null);

            // This values will be used as input for test
            const string reportTitle = "TestReport";
            const string reportType = "TestReportType";
            const string reportDefinitionSource = "ReportDefinitionSource";
            const string reportDescription = "ReportDescription";
            const string reportQuerySource = "ReportQuerySource";
            const string reportQueryTag = "ReportQueryTag";
            const int preventAdhocExecution = 0;

            #endregion

            // Perform the action of the test.
            #region When

            try
            {
                service.AddNewReportDefinition(reportTitle, reportType, reportDefinitionSource, reportDescription,
                                           reportQuerySource, reportQueryTag, preventAdhocExecution);
            }
            catch
            {
                // Ensure that AddParam(), ExecuteReader(), Dispose() method took place before excuption was thrown
                A.CallTo(() => mockCallableStatement.AddParam(A<string>.Ignored, A<MTParameterType>.Ignored, A<object>.Ignored))
                    .MustHaveHappened(Repeated.Exactly.Times(7));
                A.CallTo(() => mockCallableStatement.ExecuteReader()).MustHaveHappened();
                A.CallTo(() => mockCallableStatement.Dispose()).MustHaveHappened();
                A.CallTo(() => mockConnection.Dispose()).MustHaveHappened();
                throw;
            }

            #endregion

            // Verify the result of the test
            #region Then

            // MASBasicException expected by test method.
            // See attribute: [ExpectedException(typeof(MASBasicException), "MASBasicException didn't occur")]

            #endregion
        }
    }
}
