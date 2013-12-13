using System;
using MetraTech.Interop.MTServerAccess;
using MetraTech.Reports;

namespace MetraTech.Core.Services.Quoting
{
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
}