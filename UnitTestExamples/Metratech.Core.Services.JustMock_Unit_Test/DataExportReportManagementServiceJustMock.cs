//#define MockLogger

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services;
using MetraTech.DataAccess;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Telerik.JustMock;
using Telerik.JustMock.Helpers;

namespace JustMock
{
    [TestClass]
    public class DataExportReportManagementServiceJustMock
    {
        /// <summary>
        /// Unit test
        /// </summary>
        /// <remarks>
        /// ConnectionManager.CreateConnection
        /// connection.CreateCallableStatement("Export_InsertReportDefinition")
        /// callStmt.AddParam(...)
        /// Logger.LogInfo
        /// callStmt.ExecuteReader
        /// Dispose callStmt
        /// Dispose connection
        /// </remarks>
        [TestMethod]
        public void JM___AddNewReportDefinition_SuccessfulExecution_ReaderExecutedWithAllParameters()
        {
            #region Given

            var service = new DataExportReportManagementService();
            const string reportTitle = "TestReport";
            const string reportType = "TestReportType";
            const string reportDefinitionSource = "ReportDefinitionSource";
            const string reportDescription = "ReportDescription";
            const string reportQuerySource = "ReportQuerySource";
            const string reportQueryTag = "ReportQueryTag";
            const int preventAdhocExecution = 0;

            #endregion

            #region Mocks

            var isConnectionManagerCreateConnectionInvoked = false;
#if MockLogger
            var isLoggerLogInfoInvoked = false;
#endif
            var stParams = new List<StParam>();

            var mockedMtCallableStatement = Mock.Create<IMTCallableStatement>();
            mockedMtCallableStatement.Arrange(
                x => x.AddParam(Arg.IsAny<string>(), Arg.IsAny<MTParameterType>(), Arg.IsAny<object>()))
                                     .DoInstead(
                                         (string name, MTParameterType type, object value) =>
                                         stParams.Add(new StParam(name, type, value)))
                                     .Occurs(7);
            mockedMtCallableStatement.Arrange(x => x.ExecuteReader())
                                     .Occurs(1);
            mockedMtCallableStatement.Arrange(x => x.Dispose())
                                     .MustBeCalled();

            var mockedMtServicedConnection = Mock.Create<IMTServicedConnection>();
            mockedMtServicedConnection.Arrange(x => x.CreateCallableStatement(Arg.AnyString))
                                      .Returns(mockedMtCallableStatement)
                                      .MustBeCalled();

            Mock.SetupStatic(typeof(ConnectionManager));
            Mock.Arrange(() => ConnectionManager.CreateConnection())
                .DoInstead(() => { isConnectionManagerCreateConnectionInvoked = true; })
                .Returns(mockedMtServicedConnection);

#if MockLogger
            var logger = new Logger("LoggerForMocking");
            logger.Arrange(x => x.LogInfo(Arg.IsAny<string>()))
                  .IgnoreInstance()
                  .DoInstead(() =>
                  {
                      isLoggerLogInfoInvoked = true;
                  });
#endif

            #endregion

            #region When

            service.AddNewReportDefinition(reportTitle, reportType, reportDefinitionSource, reportDescription,
                                           reportQuerySource, reportQueryTag, preventAdhocExecution);

            #endregion

            #region Then

            Assert.IsTrue(isConnectionManagerCreateConnectionInvoked, "ConnectionManager.CreateConnection() wasn't invoked");
#if MockLogger
            Assert.IsTrue(isLoggerLogInfoInvoked, "Logger.LogInfo() wasn't invoked");
#endif

            mockedMtCallableStatement.Assert();
            mockedMtServicedConnection.Assert();

            Assert.AreEqual(7, stParams.Count, "Incorrect number of Parameters, that was added.");
            Assert.AreEqual(new StParam("c_report_title", MTParameterType.String, reportTitle), stParams[0]);
            // ...
            Assert.AreEqual(new StParam("c_prevent_adhoc_execution", MTParameterType.Integer, preventAdhocExecution), stParams[6]);

            #endregion
        }

        /// <summary>
        /// Unit test
        /// </summary>
        /// <remarks>
        /// ConnectionManager.CreateConnection
        /// An MASBasicException was raised
        /// Logger.LogException
        /// raise again
        /// </remarks>
        [TestMethod]
        public void JM___AddNewReportDefinition_MASBasicExceptionOccures_MASBaseExceptionThrown()
        {
            #region Given

            var service = new DataExportReportManagementService();
            const string reportTitle = "TestReport";
            const string reportType = "TestReportType";
            const string reportDefinitionSource = "ReportDefinitionSource";
            const string reportDescription = "ReportDescription";
            const string reportQuerySource = "ReportQuerySource";
            const string reportQueryTag = "ReportQueryTag";
            const int preventAdhocExecution = 0;

            #endregion

            #region Moles

            var isConnectionManagerCreateConnectionInvoked = false;
#if MockLogger
            var isLoggerLogExceptionInvoked = false;
#endif
            var isMASBaseExceptionThrown = false;

            var mockedMASBasicException = Mock.Create<MASBasicException>("MASBasicException");

            // Mock.SetupStatic(typeof(ConnectionManager));
            Mock.Arrange(() => ConnectionManager.CreateConnection())
                .DoInstead(() =>
                {
                    isConnectionManagerCreateConnectionInvoked = true;
                    throw mockedMASBasicException;
                });
            
#if MockLogger
            var logger = new Logger("LoggerForMocking");
            logger.Arrange(x => x.LogException(Arg.IsAny<string>(), Arg.IsAny<MASBasicException>()))
                  .IgnoreInstance()
                  .DoInstead(
                      () => { isLoggerLogExceptionInvoked = true; });
#endif
            // Logger.AllInstances.LogExceptionStringException =
            //    (t1, t2, t3) =>
            //    {
            //        Assert.AreSame(exception, t3);
            //        isLoggerLogExceptionInvoked = true;
            //    };

            #endregion

            #region When

            try
            {
                service.AddNewReportDefinition(reportTitle, reportType, reportDefinitionSource, reportDescription,
                                               reportQuerySource, reportQueryTag, preventAdhocExecution);
            }
            catch (MASBaseException)
            {
                isMASBaseExceptionThrown = true;
            }

            #endregion

            #region Then

            Assert.IsTrue(isConnectionManagerCreateConnectionInvoked);
            Assert.IsTrue(isMASBaseExceptionThrown);
#if MockLogger
            Assert.IsTrue(isLoggerLogExceptionInvoked);
#endif
            //  Assert.IsTrue(isLoggerLogExceptionInvoked);

            #endregion
        }

        /// <summary>
        /// Unit test
        /// </summary>
        /// <remarks>
        /// ConnectionManager.CreateConnection
        /// connection.CreateCallableStatement("Export_InsertReportDefinition")
        /// callStmt.AddParam(...)
        /// Logger.LogInfo
        /// callStmt.ExecuteReader
        /// An Exception was raised
        /// Logger.LogException
        /// raise a new MASBasicException
        /// Dispose callStmt
        /// Dispose connection
        /// </remarks>
        [TestMethod]
        public void JM___AddNewReportDefinition_ExceptionOccures_MASBaseExceptionThrown()
        {
            #region Given

            var service = new DataExportReportManagementService();
            const string reportTitle = "TestReport";
            const string reportType = "TestReportType";
            const string reportDefinitionSource = "ReportDefinitionSource";
            const string reportDescription = "ReportDescription";
            const string reportQuerySource = "ReportQuerySource";
            const string reportQueryTag = "ReportQueryTag";
            const int preventAdhocExecution = 0;

            #endregion

            #region Mocks

            var isConnectionManagerCreateConnectionInvoked = false;
#if MockLogger
            var isLoggerLogInfoInvoked = false;
            var isLoggerLogExceptionInvoked = false;
#endif
            var isExceptionThrown = false;
            var isMASBasicExceptionThrown = false;
            var stParams = new List<StParam>();
            var exception = new Exception();

            var mockedMtCallableStatement = Mock.Create<IMTCallableStatement>();
            mockedMtCallableStatement.Arrange(
                x => x.AddParam(Arg.IsAny<string>(), Arg.IsAny<MTParameterType>(), Arg.IsAny<object>()))
                                     .DoInstead(
                                         (string name, MTParameterType type, object value) =>
                                         stParams.Add(new StParam(name, type, value)))
                                     .Occurs(7);
            mockedMtCallableStatement.Arrange(x => x.ExecuteReader())
                                     .DoInstead(() => { throw exception; })
                                     .Occurs(1);
            mockedMtCallableStatement.Arrange(x => x.Dispose())
                                     .MustBeCalled();

            var mockedMtServicedConnection = Mock.Create<IMTServicedConnection>();
            mockedMtServicedConnection.Arrange(x => x.CreateCallableStatement(Arg.AnyString))
                                      .Returns(mockedMtCallableStatement)
                                      .MustBeCalled();

            Mock.SetupStatic(typeof(ConnectionManager));
            Mock.Arrange(() => ConnectionManager.CreateConnection())
                .DoInstead(() => { isConnectionManagerCreateConnectionInvoked = true; })
                .Returns(mockedMtServicedConnection);
            
#if MockLogger
            var logger = new Logger("LoggerForMocking");
            logger.Arrange(x => x.LogInfo(Arg.IsAny<string>()))
                  .IgnoreInstance()
                  .DoInstead(() =>
                  {
                      isLoggerLogInfoInvoked = true;
                  });
            logger.Arrange(x => x.LogException(Arg.IsAny<string>(), Arg.IsAny<Exception>()))
                  .IgnoreInstance()
                  .DoInstead((string message, Exception e) =>
                  {
                      isMASBasicExceptionThrown = e is MASBasicException;
                      isLoggerLogExceptionInvoked = true;
                  });
#endif
            #endregion

            #region When

            try
            {
                service.AddNewReportDefinition(reportTitle, reportType, reportDefinitionSource, reportDescription,
                                               reportQuerySource, reportQueryTag, preventAdhocExecution);
            }
            catch (MASBasicException)
            {
                isExceptionThrown = true;
            }

            #endregion

            #region Then

            mockedMtCallableStatement.Assert();
            mockedMtServicedConnection.Assert();

            Assert.IsTrue(isConnectionManagerCreateConnectionInvoked, "ConnectionManager.CreateConnection() wasn't invoked");
            Assert.IsTrue(isExceptionThrown, "Exception wasn't thrown");
            Assert.IsFalse(isMASBasicExceptionThrown, "MASBasicException wasn thrown. But it shouldn't!");
#if MockLogger
            Assert.IsTrue(isLoggerLogInfoInvoked, "Logger.LogInfo() wasn't invoked");
            Assert.IsTrue(isLoggerLogExceptionInvoked, "Logger.LogException() wasn't invoked");
#endif

            #endregion
        }

        private class StParam
        {
            public string Name { get; set; }
            public MTParameterType Type { get; set; }
            public object Value { get; set; }

            public StParam(string name, MTParameterType type, object value)
            {
                Name = name;
                Type = type;
                Value = value;
            }

            public bool Equals(StParam other)
            {
                if (ReferenceEquals(null, other)) return false;
                if (ReferenceEquals(this, other)) return true;
                return Equals(other.Name, Name) && Equals(other.Type, Type) && Equals(other.Value, Value);
            }

            public override bool Equals(object obj)
            {
                if (ReferenceEquals(null, obj)) return false;
                if (ReferenceEquals(this, obj)) return true;
                if (obj.GetType() != typeof(StParam)) return false;
                return Equals((StParam)obj);
            }

            public override int GetHashCode()
            {
                unchecked
                {
                    int result = (Name != null ? Name.GetHashCode() : 0);
                    result = (result * 397) ^ Type.GetHashCode();
                    result = (result * 397) ^ (Value != null ? Value.GetHashCode() : 0);
                    return result;
                }
            }
        }

    }
}
