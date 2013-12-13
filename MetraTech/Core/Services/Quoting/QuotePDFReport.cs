using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using MetraTech.Reports;

namespace MetraTech.Core.Services.Quoting
{
  /// <summary>
  /// Implementation responsible for generating the pdf version of the quote
  /// </summary>
  public class QuotePdfReport
  {
    private QuoteReportingConfiguration configuration;
    private static ILogger _log;

    protected QuotePdfReport()
    {
    }

    public QuotePdfReport(QuoteReportingConfiguration configuration)
    {
      this.configuration = configuration;
      _log = new Logger(String.Format("[{0}]", typeof(QuotePdfReport)));
    }

    /// <summary>Generate the pdf version of the quote
    /// </summary>
    /// <param name="idQuote">database id of the quote to generate</param>
    /// <param name="idAccountForReport">account id to be used when storing the quote</param>
    /// <param name="reportTemplateName">name of the report file to use to generate the pdf</param>
    /// <param name="idLanguageCode">database language id for the report</param>
    /// <returns></returns>
    public string CreateReport(int idQuote, int idAccountForReport, string reportTemplateName, int idLanguageCode, string pdfReportLink = null)
    {
      IReportManager reportManager = new Reports.CrystalEnterprise.CEReportManager();
      try
      {
        reportManager.LoggerObject = _log;
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
        var aInstanceFileName = pdfReportLink ?? GetReportLink(idQuote, idAccountForReport);

        var aOverwriteTemplateOriginalDataSource = true;
        var aOverwriteTemplateDestination = true;
        //Forces generation to explicitly be PDF, regardless of what template says
        var aOverwriteTemplateFormat = true;

        reportManager.LoggerObject.LogDebug("CreateReport: Adding report for processing {0} ---> {1}", reportTemplateName, aInstanceFileName);
        reportManager.AddReportForProcessing(reportTemplateName, aRunID, aBillGroupID, idAccountForReport,
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
        reportManager.LoggerObject.LogError("CreateReport error: " + ex.Message, ex);
        throw;
      }
    }

    public string GetReportLink(int idQuote, int idAccountForReportInstanceName)
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

    public void DeleteReport(int idQuote)
    {
      try
      {
        var quoteHeader = new QuotingRepository().GetQuoteHeader(idQuote);
        var accountId = Convert.ToInt32(quoteHeader.AccountForQuotes.First().AccountID);
        
        var aTemplateName = GetReportLink(idQuote, accountId);
        var files = new ArrayList { aTemplateName };
        
        RemoteReportOperations.DeleteUnmanagedDiskFiles(files, null);
      }      
      catch (Exception ex)
      {
        _log.LogError("DeleteReport error: " + ex.Message, ex);
        throw;
      }
    }
  }

}
