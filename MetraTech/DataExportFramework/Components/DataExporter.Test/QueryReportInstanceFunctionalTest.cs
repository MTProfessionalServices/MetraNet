using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.DataAccess;
using MetraTech.Xml;
using System.IO;
using MetraTech.DataExportFramework.Components.DataExporter;
using MetraTech.Core.Services.ClientProxies;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Billing;
using MetraTech.TestCommon;


namespace DataExporter.Test
{
  /// <summary>
  /// Summary description for UnitTest1
  /// </summary>
  [TestClass]
  [Ignore] //TODO: Need to implement the test  
  public class QueryReportInstanceFunctionalTest
  {
    private const string TagToCreateReportByUsingStoredProcedureStoredProcedureCreation = "__Call_AccByType_Stored_Procedure__";
    private const string FuncTestTitleCallSP = "Functional test: MSSQL\\Oracle Call SP";

    public QueryReportInstanceFunctionalTest()
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
    //[ClassInitialize()]
    //public static void MyClassInitialize(TestContext testContext)
    //{      
    //}
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

    //[TestMethod, MTFunctionalTest(TestAreas.Reporting)]
    // TODO: should be finished implementation for the test
    public void CreateReportByUsingStoredProcedure_Positive()
    {
      // create report definition\parameters and assign pramas to the reposrt deinition
      ExportReportDefinition reportToExecute = CreateOrGetReportDefinition();

      //TODO: put resport deinition as a adhoc instance
      
      // execute report creation
      QueryReportInstance reportInstance = new QueryReportInstance("work ID guid", reportToExecute.ReportID, 0, 0, String.Empty, reportToExecute.ReportTitle);
      reportInstance.Execute();

      //TODO: verifay that report is created in working folder
    }

    /// <summary>
    /// Creatws report definition, thir parameters and assign params to the report definition
    /// </summary>
    /// <returns></returns>
    private ExportReportDefinition CreateOrGetReportDefinition()
    {
      DataExportReportManagementServiceClient client =  new DataExportReportManagementServiceClient();

      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      ExportReportDefinition result = GetReportByTitle(client, TagToCreateReportByUsingStoredProcedureStoredProcedureCreation, FuncTestTitleCallSP);
     
      if (result == null)
      {
        
         client.AddNewReportDefinition(FuncTestTitleCallSP, "Query", "Query", 
            "DEscription of : Functional test for creatinf DEF report by using stored SP",
            TagToCreateReportByUsingStoredProcedureStoredProcedureCreation, 0);

        result = GetReportByTitle(client, TagToCreateReportByUsingStoredProcedureStoredProcedureCreation, FuncTestTitleCallSP);

        if (result == null)
          throw new AssertFailedException(String.Format("Unable to create report definition {0} and tag {1}", FuncTestTitleCallSP, TagToCreateReportByUsingStoredProcedureStoredProcedureCreation));

        client.AddNewReportParameters("ACCTYPE", "Account Type");

        //TODO: Don't know how to to get parameter ID for recently created ACCTYPE?
        // Looks like need to implement one more service method
        //client.AssignNewReportParameter(result.ReportID, /*How to get parameter ID for recently created ACCTYPE?*/, "Some of the description");
      }

     return result;       

      
    }

    private ExportReportDefinition GetReportByTitle(DataExportReportManagementServiceClient client, string queryTag, string reportTitle)
    {
      MTList<ExportReportDefinition> reportLst = new MTList<ExportReportDefinition>();
     
      client.GetAdHocReportDefinitions(ref reportLst);

      foreach(ExportReportDefinition report in reportLst.Items)
      {
        if (report.ReportQueryTag.Equals(queryTag)
           && report.ReportTitle.Equals(reportTitle))
        {
          return report;
        }
      }
      return null;
    }

  }
}
