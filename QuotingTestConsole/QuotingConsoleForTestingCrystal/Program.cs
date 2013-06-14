using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Shared.Test;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Reports;
using MetraTech.Reports.CrystalEnterprise;

namespace MetraTech.Quoting.Test.ConsoleForTesting
{
  class Program
  {
    private const string VMIIPAdress = "10.200.91.73";

    private static void Main(string[] args)
    {

      int idQuote = 108;

      IReportManager reportManager = new MetraTech.Reports.CrystalEnterprise.CEReportManager();
      try
      {
        reportManager.LoggerObject = new Logger("[QuotingImplementation]");
        //reportManager.RecurringEventRunContext = null;

        reportManager.LoginToReportingServer("crystal2008.metratech.com", "mtuser", "mtuser");

        //Need to tell the reporting server the details of the database it should connect to/run the reports against
        reportManager.SetReportingDatabase(VMIIPAdress, "NetMeter", "dbo", "nmdbo", "MetraTech1");

        //string aTemplateName = "Rudi Invoice Report";
        string aTemplateName = "Quote Report";

        int aRunID = 0;
        int aBillGroupID = 0;
        int aAccountID = 505201654;

        //string aRecordSelectionFormula = "{sub_invoice_subreport;1.AccountID} = 1000902489"; 
        string aRecordSelectionFormula = ""; // "{t_be_cor_qu_quoteheader.c_QuoteID} = " + idQuote;
        string aGroupSelectionFormula = "";

        IDictionary aReportParameters = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
        aReportParameters.Add("SAMPLE", "1"); //Eventually don't need this but may want/need others so leaving for the moment
        aReportParameters.Add("QuoteId", idQuote);
        aReportParameters.Add("LanguageId", 840);

        string aInstanceFileName = "c:\\reports_rudi/LanguageQuote.pdf";
        //string aInstanceFileName = Path.Combine("c:\\Test", "Quotes", aAccountID.ToString(), "Quote_" + idQuote + ".pdf");

        bool aOverwriteTemplateDestination = true;

        //Forces generation to explicitly be PDF, regardless of what template says
        bool aOverwriteTemplateFormat = true;

        bool aOverwriteTemplateOriginalDataSource = true;

        string apsdatabasename = "MetraNet_Rudi";


        reportManager.AddReportForProcessing(aTemplateName, aRunID, aBillGroupID, aAccountID,
                                             aRecordSelectionFormula, aGroupSelectionFormula, aReportParameters,
                                             aInstanceFileName, aOverwriteTemplateDestination,
                                             aOverwriteTemplateFormat, aOverwriteTemplateOriginalDataSource,
                                             apsdatabasename);

        reportManager.GenerateReports(true);

        reportManager.Disconnect();
      }
      catch (Exception ex)
      {
        reportManager.LoggerObject.LogError("ConsoleForTesting error: " + ex.Message, ex);
      }

    }

    //    MTServerAccessDataSet serveraccess = new MTServerAccessDataSetClass();
      //serveraccess.Initialize();
      //MTServerAccessData db = serveraccess.FindAndReturnObject("ReportingDBServer");
			
      //string apsname = ReportConfiguration.GetInstance().APSName;
      //string apsuser = ReportConfiguration.GetInstance().APSUser;
      //string apspassword = ReportConfiguration.GetInstance().APSPassword;
      //      // g. cieplik 8/25/2009 CORE-1472 
      //      string apsdatabasename = ReportConfiguration.GetInstance().APSDatabaseName;

      //// Note that for Oracle it is important that the dbname is case sensitive
      //// and is in upper case.
      //string dbname = ReportConfiguration.GetInstance().GenerateDatabaseName(aContext).ToUpper();
      //string dbservername = db.ServerName;

      //      // For Oracle the username and password are set to table space name.
      //      // If we are not generating a database each time we need to use the
      //      // configured username and password for oracle.
      //      // g. cieplik CR15147 when creating a new database use the password (db.Password) configured for "ReportingDBServer"
      //      string dbuser;
      //      string dbpassword;
      //      if (mIsOracle && mbCreateNewDatabaseEachTime == true)
      //      {
      //          dbuser = dbname;
      //          dbpassword = db.Password;
      //      }
      //      else
      //      {
      //          dbuser = db.UserName;
      //          dbpassword = db.Password;
      //      }
 
  }
}
