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
}