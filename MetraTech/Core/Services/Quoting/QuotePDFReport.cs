using System;
using System.Collections;
using System.Collections.Generic;
using MetraTech.Interop.MTServerAccess;
using MetraTech.Reports;

namespace MetraTech.Core.Services.Quoting
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
    public static QuoteReportingConfiguration LoadConfiguration(QuotingConfiguration baseQuotingConfiguration, bool throwException = true)
    {
      var serveraccess = new MTServerAccessDataSetClass();
      serveraccess.Initialize();
      
      MTServerAccessData db = null;
      try
      {
        db = serveraccess.FindAndReturnObject("ReportingDBServerForQuoting");
      }
      catch (Exception ex)
      {
        db = null;
        if (throwException)
          throw ex;
      }

      if (db == null)
        return new QuoteReportingConfiguration();

      var result = new QuoteReportingConfiguration
        {
          ReportingServerName = ReportConfiguration.GetInstance().APSName,
          ReportingServerUsername = ReportConfiguration.GetInstance().APSUser,
          ReportingServerPassword = ReportConfiguration.GetInstance().APSPassword,
          ReportingServerFolder = ReportConfiguration.GetInstance().APSDatabaseName,
          ReportingServerReportInstanceOutputBasePath = ReportConfiguration.GetInstance().ReportInstanceBasePath,
          ReportingServerReportInstanceVirtualDirectory =
            ReportConfiguration.GetInstance().ReportInstanceVirtualDirectory,
          ReportingDatabaseServerName = db.ServerName,
          ReportingDatabaseName = db.DatabaseName,
          ReportingDatabaseIsOracle = (String.CompareOrdinal(db.DatabaseType, "{Oracle}") == 0),
          ReportingDatabaseUsername = db.UserName,
          ReportingDatabasePassword = db.Password
        };

      result.ReportingDatabaseOwner = result.ReportingDatabaseIsOracle ? null : "dbo";      
      //Report partial path
      result.QuotingInstanceOutputPartialPath = baseQuotingConfiguration != null ? baseQuotingConfiguration.ReportInstancePartialPath : @"\Quotes\{AccountId}\Quote_{QuoteId}";

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
    public string CreatePdfReport(int idQuote, int idAccountForReportInstanceName, string reportTemplateName, int idLanguageCode, string pdfReportLink = null)
    {
      //todo Update StatusReport value
      IReportManager reportManager = new Reports.CrystalEnterprise.CEReportManager();
      try
      {
        reportManager.LoggerObject = new Logger("[QuotingImplementation]");
        reportManager.LoggerObject.LogDebug("CreatePDFReport: Connecting to reporting server {0}", configuration.ReportingServerName);
        reportManager.LoginToReportingServer(configuration.ReportingServerName, configuration.ReportingServerUsername,
          configuration.ReportingServerPassword);

        //Need to tell the reporting server the details of the database it should connect to/run the reports against
        reportManager.LoggerObject.LogDebug("CreatePDFReport: Setting the database server for processing report {0} {1}", configuration.ReportingDatabaseServerName, configuration.ReportingDatabaseName);
        reportManager.SetReportingDatabase(configuration.ReportingDatabaseServerName,
                                           configuration.ReportingDatabaseName,
                                           configuration.ReportingDatabaseOwner,
                                           configuration.ReportingDatabaseUsername,
                                           configuration.ReportingDatabasePassword);
        var aRunID = 0;
        var aBillGroupID = 0;
        var aRecordSelectionFormula = "";
        var aGroupSelectionFormula = "";

        IDictionary aReportParameters = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
        aReportParameters.Add("QuoteId", idQuote);
        aReportParameters.Add("LanguageId", idLanguageCode);

        //string aInstanceFileName = "c:\\reports_rudi/1037172739/1000902489/Invoice.pdf";
        var aInstanceFileName = pdfReportLink ?? GetPdfReportLink(idQuote, idAccountForReportInstanceName);

        var aOverwriteTemplateOriginalDataSource = true;
        var aOverwriteTemplateDestination = true;
        //Forces generation to explicitly be PDF, regardless of what template says
        var aOverwriteTemplateFormat = true;

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

        //todo Update StatusReport value
        return aInstanceFileName;
      }
      catch (Exception ex)
      {
        //todo Update StatusReport value
        reportManager.LoggerObject.LogError("CreatePDFReport error: " + ex.Message, ex);
        throw;
      }
    }

    public string GetPdfReportLink(int idQuote, int idAccountForReportInstanceName)
    {
      var aInstanceFileName = configuration.ReportingServerReportInstanceOutputBasePath +
                                 configuration.QuotingInstanceOutputPartialPath;
      aInstanceFileName = aInstanceFileName.Replace("{AccountId}", idAccountForReportInstanceName.ToString());
      aInstanceFileName = aInstanceFileName.Replace("{QuoteId}", idQuote.ToString());
      if (!aInstanceFileName.ToLower().EndsWith(".pdf"))
      {
        aInstanceFileName += ".pdf";
      }
      return aInstanceFileName;
    }
  }

}
