using System;
using System.Collections.Generic;
using MetraTech.Reports;
using System.Collections;
using MetraTech.Interop.MTServerAccess;

namespace MetraTech.Quoting
{
  /// <summary>
  /// Class representing the reporting configuration needed by quoting
  /// Information is read from several places and consolidated as values in this class
  /// </summary>
  public class QuoteReportingConfiguration
  {
    public string ReportingServerName { get; set; }
    public string ReportingServerUsername { get; set; }
    public string ReportingServerPassword { get; set; }

    public string ReportingServerFolder { get; set; }

    public string ReportingServerReportInstanceOutputBasePath { get; set; }
    public string ReportingServerReportInstanceVirtualDirectory { get; set; }

    public string ReportingDatabaseServerName { get; set; }
    public string ReportingDatabaseName { get; set; }
    public string ReportingDatabaseOwner { get; set; }
    public string ReportingDatabaseUsername { get; set; }
    public string ReportingDatabasePassword { get; set; }

    //Because we need to determine if the database is Oracle during configuration load,
    //might as well store it in case it is needed in the future
    public bool ReportingDatabaseIsOracle { get; set; }

    public string QuotingInstanceOutputPartialPath { get; set; }

  }

  /// <summary>
  /// Class responsible for managing/loading the reporting configuration used by quoting
  /// </summary>
  public class QuoteReportingConfigurationManager
  {
    /// <summary>
    /// Method to populate the reporting configuration from various configuration files
    /// </summary>
    /// <param name="baseQuotingConfiguration">optional parameter with the current QuotingConfiguration used for determining the desired report output path</param>
    /// <returns></returns>
    public static QuoteReportingConfiguration LoadConfiguration(QuotingConfiguration baseQuotingConfiguration)
    {
      QuoteReportingConfiguration result = new QuoteReportingConfiguration();

      result.ReportingServerName = ReportConfiguration.GetInstance().APSName;
      result.ReportingServerUsername = ReportConfiguration.GetInstance().APSUser;
      result.ReportingServerPassword = ReportConfiguration.GetInstance().APSPassword;

      //CORE-1472: For shared Crystal server, used the APSDatabaseName as the virtual folder name
      result.ReportingServerFolder = ReportConfiguration.GetInstance().APSDatabaseName;

      result.ReportingServerReportInstanceOutputBasePath = ReportConfiguration.GetInstance().ReportInstanceBasePath;
      result.ReportingServerReportInstanceVirtualDirectory = ReportConfiguration.GetInstance().ReportInstanceVirtualDirectory;


      MTServerAccessDataSet serveraccess = new MTServerAccessDataSetClass();
      serveraccess.Initialize();
      MTServerAccessData db = serveraccess.FindAndReturnObject("ReportingDBServerForQuoting");

      result.ReportingDatabaseServerName = db.ServerName;// "10.200.91.73";
      result.ReportingDatabaseName = db.DatabaseName; // "NetMeter";

      result.ReportingDatabaseIsOracle = (string.Compare(db.DatabaseType, "{Oracle}", false) == 0);
      result.ReportingDatabaseOwner = result.ReportingDatabaseIsOracle ? null : "dbo";
      result.ReportingDatabaseUsername = db.UserName;
      result.ReportingDatabasePassword = db.Password;

      //Report partial path
      if (baseQuotingConfiguration != null)
      {
        result.QuotingInstanceOutputPartialPath = baseQuotingConfiguration.ReportInstancePartialPath;
      }
      else
      {
        //Set a workable default
        result.QuotingInstanceOutputPartialPath = @"\Quotes\{AccountId}\Quote_{QuoteId}";
      }

      return result;
    }
  }

  /// <summary>
  /// Implementation responsible for generating the pdf version of the quote
  /// </summary>
  public class QuotePDFReport
  {
    private QuoteReportingConfiguration configuration;

    protected QuotePDFReport()
    {
    }

    public QuotePDFReport(QuoteReportingConfiguration configuration)
    {
      this.configuration = configuration;
    }

    /// <summary>
    /// Generate the pdf version of the quote
    /// </summary>
    /// <param name="idQuote">database id of the quote to generate</param>
    /// <param name="idAccountForReportInstanceName">account id to be used when storing the quote</param>
    /// <param name="reportTemplateName">name of the report file to use to generate the pdf</param>
    /// <param name="idLanguageCode">database language id for the report</param>
    /// <returns></returns>
    public string CreatePDFReport(int idQuote, int idAccountForReportInstanceName, string reportTemplateName, int idLanguageCode)
    {

      IReportManager reportManager = new MetraTech.Reports.CrystalEnterprise.CEReportManager();
      try
      {
        reportManager.LoggerObject = new Logger("[QuotingImplementation]");
        //reportManager.RecurringEventRunContext = null;

        reportManager.LoggerObject.LogDebug("CreatePDFReport: Connecting to reporting server {0}", configuration.ReportingServerName);
        reportManager.LoginToReportingServer(configuration.ReportingServerName, configuration.ReportingServerUsername, configuration.ReportingServerPassword);

        //Need to tell the reporting server the details of the database it should connect to/run the reports against
        reportManager.LoggerObject.LogDebug("CreatePDFReport: Setting the database server for processing report {0} {1}", configuration.ReportingDatabaseServerName, configuration.ReportingDatabaseName);
        reportManager.SetReportingDatabase(configuration.ReportingDatabaseServerName,
                                           configuration.ReportingDatabaseName,
                                           configuration.ReportingDatabaseOwner,
                                           configuration.ReportingDatabaseUsername,
                                           configuration.ReportingDatabasePassword);

        int aRunID = 0;
        int aBillGroupID = 0;
        //string accountEnum = "metratech.com/accountcreation/contacttype/bill-to";

        //string aRecordSelectionFormula = string.Format("{{t_be_cor_qu_quoteheader.c_QuoteID}} = {0} and " +
        //                                                "{{t_enum_data.nm_enum_data}} = \"{1}\"", idQuote, accountEnum);
        string aRecordSelectionFormula = "";
        string aGroupSelectionFormula = "";

        IDictionary aReportParameters = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
        aReportParameters.Add("SAMPLE", "1"); //TODO: Remove
        aReportParameters.Add("QuoteId", idQuote);
        aReportParameters.Add("LanguageId", idLanguageCode);

        //string aInstanceFileName = "c:\\reports_rudi/1037172739/1000902489/Invoice.pdf";
        string aInstanceFileName = configuration.ReportingServerReportInstanceOutputBasePath + configuration.QuotingInstanceOutputPartialPath;
        aInstanceFileName = aInstanceFileName.Replace("{AccountId}", idAccountForReportInstanceName.ToString());
        aInstanceFileName = aInstanceFileName.Replace("{QuoteId}", idQuote.ToString());

        bool aOverwriteTemplateOriginalDataSource = true;
        bool aOverwriteTemplateDestination = true;

        //Forces generation to explicitly be PDF, regardless of what template says
        bool aOverwriteTemplateFormat = true;
        if (!aInstanceFileName.ToLower().EndsWith(".pdf"))
        {
          aInstanceFileName += ".pdf";
        }

        reportManager.LoggerObject.LogDebug("CreatePDFReport: Adding report for processing {0} ---> {1}", reportTemplateName, aInstanceFileName);
        reportManager.AddReportForProcessing(reportTemplateName, aRunID, aBillGroupID, idAccountForReportInstanceName,
                                             aRecordSelectionFormula, aGroupSelectionFormula, aReportParameters,
                                             aInstanceFileName, aOverwriteTemplateDestination,
                                             aOverwriteTemplateFormat, aOverwriteTemplateOriginalDataSource,
                                             configuration.ReportingServerFolder);

        reportManager.LoggerObject.LogDebug("Waiting for report to process {0}", aInstanceFileName);
        reportManager.GenerateReports(true);

        reportManager.LoggerObject.LogDebug("Disconnecting from reporting server [0]", configuration.ReportingServerName);
        reportManager.Disconnect();

        return aInstanceFileName;
      }
      catch (Exception ex)
      {
        reportManager.LoggerObject.LogError("CreatePDFReport error: " + ex.Message, ex);
        throw;
      }
    }
  }
}
