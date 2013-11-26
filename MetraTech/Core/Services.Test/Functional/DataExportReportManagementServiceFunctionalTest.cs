using MetraTech.DataAccess;
using MetraTech.DomainModel.Billing;
using MetraTech.Xml;
using MetraTech.TestCommon;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.IO;

namespace MetraTech.Core.Services.Test.Functional
{
    [TestClass]
    public class DataExportReportManagementServiceFunctionalTest
    {
        private const string TestExtension = "SmokeTest";

        // [MTFunctionalTest] gives a method TestCategory = "FunctionalTest".
        // This is required for test to be executed during automation runs.
        [TestMethod, MTFunctionalTest]
        public void ReportDefinitionCreateRetrieveDelete()
        {
            // Using default constructor for Functional Test
            var service = new DataExportReportManagementService();
            const string reportTitle = "TestReport";
            const string reportType = "TestReportType";
            const string reportDefinitionSource = "ReportDefinitionSource";
            const string reportDescription = "ReportDescription";            
            const string reportQueryTag = "ReportQueryTag";
            const int preventAdhocExecution = 0;            

            // Create Test Report
            service.AddNewReportDefinition(reportTitle, reportType, reportDefinitionSource, reportDescription,
                                           reportQueryTag, preventAdhocExecution);

            var repId = -1;
            try
            {
                // Check that new report was created in DB
                repId = GetReportIdByTitle(reportTitle);

                Assert.AreNotEqual(repId, -1,
                                   "Unable to get newly created Report Id of '{0}' report from t_export_reports",
                                   reportTitle);

                // Retrieve Test Report from DB using service method
                ExportReportDefinition createdReportDefinition;
                service.GetAReportDef(repId, out createdReportDefinition);

                Assert.IsNotNull(createdReportDefinition,
                                 "Unable to get newly created test report definition object.");
                Assert.AreEqual(createdReportDefinition.ReportTitle, reportTitle,
                                "Report Title differs from expected");
                Assert.AreEqual(createdReportDefinition.ReportType, reportType,
                                "Report Type differs from expected");
                Assert.AreEqual(createdReportDefinition.ReportDefinitionSource, reportDefinitionSource,
                                "Report Definition Source differs from expected");
                Assert.AreEqual(createdReportDefinition.ReportDescription, reportDescription,
                                "Report Description differs from expected");               
                Assert.AreEqual(createdReportDefinition.ReportQueryTag, reportQueryTag,
                                "Report Query Tag differs from expected");
                Assert.AreEqual((int) createdReportDefinition.PreventAdhocExecution, preventAdhocExecution,
                                "PreventAdhocExecution value differs from expected");
            }
            finally
            {
                // Delete Test Report from DB using service method
                service.DeleteExistingReportDefinition(repId);
                repId = GetReportIdByTitle(reportTitle);
                Assert.AreEqual(repId, -1, "Newly created '{0}' report was not deleted", reportTitle);
            }

            // Also may be tested here:
            //    CreateNewReportInstance();
            //    ScheduleReportInstance();
            //    AddNewReportParameters();
            //    GetReportDefinitionParameters();
            //    GetAReportInstanceDetails();
            //    QueueAdHocReport();
        }

        private int GetReportIdByTitle(string reportTitle)
        {
            var repId = -1;
            using (var conn = ConnectionManager.CreateConnection())
            {
                using (
                    var stmt = conn.CreateAdapterStatement(Path.Combine(MTXmlDocument.ExtensionDir, TestExtension),
                                                           "__GET_REPORT_DEFINITION_ID__"))
                {
                    stmt.AddParam("%%REPORT_TITLE%%", reportTitle);
                    var reader = stmt.ExecuteReader();
                    if (reader.Read())
                        repId = reader.GetInt32(0);

                    if (reader.Read())
                        Assert.Fail(
                            "More than one '{0}' report exists in t_export_reports table, when expected exacly 1",
                            reportTitle);
                }
            }
            return repId;
        }
    }
}
