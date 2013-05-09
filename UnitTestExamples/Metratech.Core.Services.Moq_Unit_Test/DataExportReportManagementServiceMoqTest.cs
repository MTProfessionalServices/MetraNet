using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.Core.Services;
using MetraTech.DataAccess;
using MetraTech.ActivityServices.Common;
using MetraTech;
using Moq;

namespace TestMoq
{
    [TestClass]
    public class DataExportReportManagementServiceMoqTest
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
        public void Moq___AddNewReportDefinition_SuccessfulExecution_ReaderExecutedWithAllParameters()
        {
            #region Given

            #region Mock object

            var mockConnection = new Mock<IMTConnection>();
            var mockCallableStatement = new Mock<IMTCallableStatement>();
            mockConnection.Setup(x => x.CreateCallableStatement("Export_InsertReportDefinition")).Returns(mockCallableStatement.Object);

            DataExportReportManagementService.CreateConnectionDelegate mockedCreateConnection = delegate() { return mockConnection.Object; };
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

            mockCallableStatement.Verify(callSt => callSt.AddParam(It.IsAny<string>(), It.IsAny<MTParameterType>(), It.IsAny<object>()), Times.Exactly(7));
            mockCallableStatement.Verify(callSt => callSt.ExecuteReader(), Times.Once());
            mockCallableStatement.Verify(callSt => callSt.Dispose(), Times.Once());
            mockConnection.Verify(conn => conn.Dispose(), Times.Once());

            #endregion

        }

        [TestMethod]
        public void Moq___AddNewReportDefinition_MASBasicExceptionOccures_MASBaseExceptionThrown()
        {
            #region Given

            #region Mock object

            var isConnectionManagerCreateConnectionInvoked = false;
            var isMASBaseExceptionThrown = false;

            var mockedMASBasicException = new Mock<MASBasicException>("MASBasicException");

            DataExportReportManagementService.CreateConnectionDelegate mockedCreateConnection =
                delegate()
                {
                    isConnectionManagerCreateConnectionInvoked = true;
                    throw mockedMASBasicException.Object;
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
                Assert.AreSame(mockedMASBasicException.Object, e);
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
        public void Moq___AddNewReportDefinition_ExceptionOccures_MASBaseExceptionThrown()
        {
            #region Given

            #region Mock object

            var mockConnection = new Mock<IMTConnection>();
            var mockCallableStatement = new Mock<IMTCallableStatement>();
            mockConnection.Setup(conn => conn.CreateCallableStatement("Export_InsertReportDefinition"))
                .Returns(mockCallableStatement.Object);
            mockCallableStatement.Setup(callSt => callSt.ExecuteReader())
                .Throws(new Exception("Exception"));

            DataExportReportManagementService.CreateConnectionDelegate mockedCreateConnection = delegate() { return mockConnection.Object; };
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
                mockCallableStatement.Verify(
                    callSt => callSt.AddParam(It.IsAny<string>(), It.IsAny<MTParameterType>(), It.IsAny<object>()),
                    Times.Exactly(7));
                mockCallableStatement.Verify(callSt => callSt.ExecuteReader(), Times.Once());
                mockCallableStatement.Verify(callSt => callSt.Dispose(), Times.Once());
                mockConnection.Verify(conn => conn.Dispose(), Times.Once());
                throw;
            }

            #endregion

            #region Then

            // MASBasicException expected

            #endregion
        
        }
    }
}
