using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.Core.Services;
using MetraTech.DataAccess;
using FakeItEasy;
using MetraTech.ActivityServices.Common;
using MetraTech;

namespace TestFakeItEasy
{
    [TestClass]
    public class DataExportReportManagementServiceFakeItEasyTest
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
        // [ClassInitialize()]
        // public static void MyClassInitialize(TestContext testContext) { }
        //
        // Use ClassCleanup to run code after all tests in a class have run
        // [ClassCleanup()]
        // public static void MyClassCleanup() { }
        //
        // Use TestInitialize to run code before running each test 
        // [TestInitialize()]
        // public void MyTestInitialize() { }
        //
        // Use TestCleanup to run code after each test has run
        // [TestCleanup()]
        // public void MyTestCleanup() { }
        //
        #endregion

        [TestMethod]
        public void FIt___AddNewReportDefinition_SuccessfulExecution_ReaderExecutedWithAllParameters()
        {
            #region Given

            #region Mock object

            var mockConnection = A.Fake<IMTConnection>();
            var mockCallableStatement = A.Fake<IMTCallableStatement>();
            A.CallTo(() => mockConnection.CreateCallableStatement("Export_InsertReportDefinition")).Returns(mockCallableStatement);

            DataExportReportManagementService.CreateConnectionDelegate mockedCreateConnection = delegate() { return mockConnection; };
            DataExportReportManagementService.CreateConnectionFromPathDelegate mockedCreateConnectionFromPath = delegate(string pathToFolder) { return null; };

            #endregion Mock object

            var service = new DataExportReportManagementService(mockedCreateConnection, mockedCreateConnectionFromPath);
            const string ReportTitle = "TestReport";
            const string ReportType = "TestReportType";
            const string ReportDefinitionSource = "ReportDefinitionSource";
            const string ReportDescription = "ReportDescription";
            const string ReportQuerySource = "ReportQuerySource";
            const string ReportQueryTag = "ReportQueryTag";
            int PreventAdhocExecution = 0;

            #endregion

            #region When

            service.AddNewReportDefinition(ReportTitle, ReportType, ReportDefinitionSource, ReportDescription,
                                           ReportQuerySource, ReportQueryTag, PreventAdhocExecution);

            #endregion

            #region Then

            A.CallTo(() =>
              mockCallableStatement.AddParam(A<string>.Ignored, A<MTParameterType>.Ignored, A<object>.Ignored)
            ).MustHaveHappened(Repeated.Exactly.Times(7));

            A.CallTo(() => mockCallableStatement.ExecuteReader()).MustHaveHappened();

            A.CallTo(() => mockCallableStatement.Dispose()).MustHaveHappened();

            A.CallTo(() => mockConnection.Dispose()).MustHaveHappened();

            #endregion

        }

        [TestMethod]
        public void FIt___AddNewReportDefinition_MASBasicExceptionOccures_MASBaseExceptionThrown()
        {
            #region Given

            #region Mock object

            var isConnectionManagerCreateConnectionInvoked = false;
            var isMASBaseExceptionThrown = false;

            var mockedMASBasicException = A.Fake<MASBasicException>();

            DataExportReportManagementService.CreateConnectionDelegate mockedCreateConnection =
                delegate()
                {
                    isConnectionManagerCreateConnectionInvoked = true;
                    throw mockedMASBasicException;
                };
            DataExportReportManagementService.CreateConnectionFromPathDelegate mockedCreateConnectionFromPath = delegate(string pathToFolder) { return null; };

            #endregion Mock object

            var service = new DataExportReportManagementService(mockedCreateConnection, mockedCreateConnectionFromPath);

            const string ReportTitle = "TestReport";
            const string ReportType = "TestReportType";
            const string ReportDefinitionSource = "ReportDefinitionSource";
            const string ReportDescription = "ReportDescription";
            const string ReportQuerySource = "ReportQuerySource";
            const string ReportQueryTag = "ReportQueryTag";
            const int PreventAdhocExecution = 0;

            #endregion

            #region When
            try
            {
                service.AddNewReportDefinition(ReportTitle, ReportType, ReportDefinitionSource, ReportDescription,
                                               ReportQuerySource, ReportQueryTag, PreventAdhocExecution);
            }
            catch (MASBaseException e)
            {
                Assert.AreSame(mockedMASBasicException, e);
                isMASBaseExceptionThrown = true;
            }

            #endregion

            #region Then

            Assert.IsTrue(isConnectionManagerCreateConnectionInvoked);
            Assert.IsTrue(isMASBaseExceptionThrown);

            #endregion
        }

        [TestMethod]
        [ExpectedException(typeof(MASBasicException), "Report Creation Failed")]
        public void FIt___AddNewReportDefinition_ExceptionOccures_MASBaseExceptionThrown()
        {
            #region Given

            #region Mock object

            var mockConnection = A.Fake<IMTConnection>();
            var mockCallableStatement = A.Fake<IMTCallableStatement>();
            A.CallTo(() => mockConnection.CreateCallableStatement("Export_InsertReportDefinition"))
                .Returns(mockCallableStatement);
            A.CallTo(() => mockCallableStatement.ExecuteReader())
                .Throws(new Exception("Exception"));

            DataExportReportManagementService.CreateConnectionDelegate mockedCreateConnection = delegate() { return mockConnection; };
            DataExportReportManagementService.CreateConnectionFromPathDelegate mockedCreateConnectionFromPath = delegate(string pathToFolder) { return null; };

            #endregion Mock object

            var service = new DataExportReportManagementService(mockedCreateConnection, mockedCreateConnectionFromPath);
            const string ReportTitle = "TestReport";
            const string ReportType = "TestReportType";
            const string ReportDefinitionSource = "ReportDefinitionSource";
            const string ReportDescription = "ReportDescription";
            const string ReportQuerySource = "ReportQuerySource";
            const string ReportQueryTag = "ReportQueryTag";
            const int PreventAdhocExecution = 0;

            #endregion

            #region When

            try
            {
                service.AddNewReportDefinition(ReportTitle, ReportType, ReportDefinitionSource, ReportDescription,
                                           ReportQuerySource, ReportQueryTag, PreventAdhocExecution);
            }
            catch
            {
                A.CallTo(() => mockCallableStatement.AddParam(A<string>.Ignored, A<MTParameterType>.Ignored, A<object>.Ignored))
                    .MustHaveHappened(Repeated.Exactly.Times(7));
                A.CallTo(() => mockCallableStatement.ExecuteReader()).MustHaveHappened();
                A.CallTo(() => mockCallableStatement.Dispose()).MustHaveHappened();
                A.CallTo(() => mockConnection.Dispose()).MustHaveHappened();
                throw;
            }

            #endregion

            #region Then

            // MASBasicException expected

            #endregion
        }
    }
}
